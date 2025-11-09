#!/bin/bash
# GitHub CLI PR Automation Utilities
# Collection of ready-to-use functions for PR management
# Usage: source pr-automation-utils.sh && create-pr-from-issue 42

set -euo pipefail

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*"; }

# Check if gh is installed and authenticated
check_gh_auth() {
  if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) is not installed"
    return 1
  fi

  if ! gh auth status >/dev/null 2>&1; then
    log_error "Not authenticated with GitHub. Run: gh auth login"
    return 1
  fi

  log_success "GitHub CLI is ready"
  return 0
}

# Create PR from issue
# Usage: create-pr-from-issue <issue-number> [repo]
create-pr-from-issue() {
  local issue_num=${1:?Issue number required}
  local repo=${2:-.}

  log_info "Creating PR from issue #$issue_num in $repo"

  # Get issue details
  local issue_data=$(gh issue view -R "$repo" "$issue_num" \
    --json title,body,number)

  local title=$(echo "$issue_data" | jq -r '.title')
  local body=$(echo "$issue_data" | jq -r '.body')

  # Create PR with issue reference
  local pr_body="Closes #$issue_num

## Description
$body"

  gh pr create -R "$repo" \
    --title "$title" \
    --body "$pr_body" \
    --draft

  log_success "PR created from issue #$issue_num"
}

# Wait for PR checks to pass
# Usage: wait-for-checks 123 [repo] [timeout_seconds]
wait-for-checks() {
  local pr_num=${1:?PR number required}
  local repo=${2:-.}
  local timeout=${3:-3600}  # 1 hour default

  log_info "Waiting for checks to pass on PR #$pr_num"

  local start_time=$(date +%s)
  local poll_interval=30

  while true; do
    local status=$(gh pr checks -R "$repo" "$pr_num" --json conclusion \
      --jq 'if all(.conclusion == "SUCCESS") then "PASS"
            elif any(.conclusion == "FAILURE") then "FAIL"
            elif any(.conclusion == "SKIPPED") then "PENDING"
            else "PENDING" end' 2>/dev/null || echo "PENDING")

    case "$status" in
      "PASS")
        log_success "All checks passed!"
        return 0
        ;;
      "FAIL")
        log_error "Checks failed. See details:"
        gh pr checks -R "$repo" "$pr_num"
        return 1
        ;;
      *)
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))

        if [ $elapsed -gt $timeout ]; then
          log_error "Timeout waiting for checks (${timeout}s exceeded)"
          return 1
        fi

        log_info "Checks pending... ($elapsed/$timeout seconds)"
        sleep $poll_interval
        ;;
    esac
  done
}

# Auto-merge PR when checks pass
# Usage: auto-merge-pr 123 [repo] [method]
auto-merge-pr() {
  local pr_num=${1:?PR number required}
  local repo=${2:-.}
  local method=${3:-squash}  # squash, rebase, or merge

  log_info "Setting up auto-merge for PR #$pr_num"

  if ! wait-for-checks "$pr_num" "$repo"; then
    log_error "Cannot auto-merge: checks did not pass"
    return 1
  fi

  log_info "Merging PR #$pr_num with method: $method"
  gh pr merge -R "$repo" "$pr_num" --"$method" --auto

  log_success "PR #$pr_num set to auto-merge"
}

# List PRs needing review
# Usage: list-review-requests [repo] [limit]
list-review-requests() {
  local repo=${1:-.}
  local limit=${2:-10}

  log_info "PRs requesting your review:"

  gh pr list -R "$repo" -L "$limit" \
    --json number,title,author,updatedAt \
    --jq '.[] | "  #\(.number): \(.title) by @\(.author.login) (updated: \(.updatedAt | split("T")[0]))"'

  local count=$(gh pr list -R "$repo" --search "review-requested:@me" -q | wc -l)
  echo ""
  log_info "Total review requests: $count"
}

# Create PR with standard template
# Usage: create-pr-from-template [repo] [title]
create-pr-from-template() {
  local repo=${1:-.}
  local title=${2:?Title required}

  log_info "Creating PR from template: $title"

  local body=$(cat <<'EOF'
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe testing performed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] No new warnings generated
- [ ] Tests added/updated
- [ ] Documentation updated
EOF
)

  gh pr create -R "$repo" \
    --title "$title" \
    --body "$body" \
    --draft

  log_success "Draft PR created with template"
}

# Batch add labels to PRs
# Usage: batch-label-prs <label> <search-query> [repo]
batch-label-prs() {
  local label=${1:?Label required}
  local search=${2:?Search query required}
  local repo=${3:-.}

  log_info "Adding label '$label' to PRs matching: $search"

  local count=0
  gh pr list -R "$repo" --search "$search" -q --json number | while read pr_num; do
    gh pr edit -R "$repo" "$pr_num" --add-label "$label"
    count=$((count + 1))
    log_success "PR #$pr_num labeled"
  done

  log_success "Labeled $count PRs"
}

# Get PR statistics
# Usage: pr-stats [repo]
pr-stats() {
  local repo=${1:-.}

  log_info "PR Statistics for $repo"
  echo ""

  local open_prs=$(gh pr list -R "$repo" --state open -q | wc -l)
  local draft_prs=$(gh pr list -R "$repo" --state open --draft -q | wc -l)
  local stale_prs=$(gh pr list -R "$repo" --search "updated:<$(date -d '14 days ago' +%Y-%m-%d)" -q | wc -l)

  echo "  Open PRs: $open_prs"
  echo "  Draft PRs: $draft_prs"
  echo "  Stale PRs (>14 days): $stale_prs"

  echo ""
  log_info "Average review time:"

  gh pr list -R "$repo" --state closed -L 20 \
    --json createdAt,mergedAt \
    --jq '[.[] |
      (.mergedAt | fromdateiso8601) - (.createdAt | fromdateiso8601) | . / 86400 |
      floor
    ] | add / length | "\(.) days"' || log_warning "Not enough data"
}

# Close stale PRs with notification
# Usage: close-stale-prs <days> [repo]
close-stale-prs() {
  local days=${1:?Days required}
  local repo=${2:-.}
  local cutoff_date=$(date -d "$days days ago" +%Y-%m-%d)

  log_info "Closing PRs not updated in $days days (before $cutoff_date)"

  local count=0
  gh pr list -R "$repo" --search "updated:<$cutoff_date" -q --json number | while read pr_num; do
    log_warning "Closing stale PR #$pr_num"

    gh pr comment -R "$repo" "$pr_num" \
      --body "🤖 Closing stale PR (no activity for $days days). Feel free to reopen if still needed."

    gh pr close -R "$repo" "$pr_num"
    count=$((count + 1))
  done

  log_success "Closed $count stale PRs"
}

# Export PR data to CSV
# Usage: export-pr-data [repo] [output_file]
export-pr-data() {
  local repo=${1:-.}
  local output=${2:-prs.csv}

  log_info "Exporting PR data to $output"

  {
    echo "Number,Title,Author,Status,Reviews,Created,Updated"

    gh pr list -R "$repo" --state all -L 100 \
      --json number,title,author,state,reviews,createdAt,updatedAt \
      --jq '.[] | [
        .number,
        .title,
        .author.login,
        .state,
        (.reviews | length),
        (.createdAt | split("T")[0]),
        (.updatedAt | split("T")[0])
      ] | @csv'
  } > "$output"

  log_success "Data exported to $output"
}

# Show quick PR summary
# Usage: pr-summary 123 [repo]
pr-summary() {
  local pr_num=${1:?PR number required}
  local repo=${2:-.}

  log_info "PR #$pr_num Summary"
  echo ""

  gh pr view -R "$repo" "$pr_num" --json number,title,author,state,reviews,checks \
    --jq '"
Title: \(.title)
Author: @\(.author.login)
Status: \(.state)
Reviews: \(.reviews | length)
Checks: \(.checks | map(.conclusion) | group_by(.) | map("\(.[0]): \(length)") | join(", "))"'

  echo ""
  log_info "Files changed:"
  gh pr view -R "$repo" "$pr_num" --json files --jq '.files[].path' | head -10
}

echo "✓ PR automation utilities loaded"
echo "Available functions:"
echo "  - check-gh-auth           Check GitHub CLI authentication"
echo "  - create-pr-from-issue    Create PR from issue"
echo "  - wait-for-checks         Wait for PR checks to pass"
echo "  - auto-merge-pr           Auto-merge when checks pass"
echo "  - list-review-requests    List PRs needing your review"
echo "  - create-pr-from-template Create PR with standard template"
echo "  - batch-label-prs         Add labels to multiple PRs"
echo "  - pr-stats                Get PR statistics"
echo "  - close-stale-prs         Close inactive PRs"
echo "  - export-pr-data          Export PR data to CSV"
echo "  - pr-summary              Show PR summary"
