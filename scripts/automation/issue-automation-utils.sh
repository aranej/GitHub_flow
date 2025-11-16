#!/bin/bash
# GitHub CLI Issue & Workflow Automation Utilities
# Collection of ready-to-use functions for issue and project management
# Usage: source issue-automation-utils.sh && auto-triage-issues repo-owner/repo

set -euo pipefail

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*"; }
log_section() { echo -e "\n${MAGENTA}═══ $* ═══${NC}\n"; }

# Auto-triage issues based on keywords
# Usage: auto-triage-issues <repo>
auto-triage-issues() {
  local repo=${1:?Repository required (e.g., owner/repo)}

  log_section "Auto-Triaging Issues in $repo"

  # Counters
  local critical=0 high=0 medium=0 low=0

  # Get all unlabeled issues
  gh issue list -R "$repo" --json number,title,body \
    --jq '.[] | select((.title + .body) != "")' | while IFS= read -r issue; do

    local number=$(echo "$issue" | jq -r '.number')
    local title=$(echo "$issue" | jq -r '.title')
    local body=$(echo "$issue" | jq -r '.body')

    local label=""

    # Determine priority by keywords
    if [[ "$title $body" =~ (critical|urgent|blocking|data loss|security breach) ]]; then
      label="priority:critical"
      ((critical++))
    elif [[ "$title $body" =~ (crash|exception|fail|error|broken) ]]; then
      label="priority:high"
      ((high++))
    elif [[ "$title $body" =~ (minor|cosmetic|typo|wording) ]]; then
      label="priority:low"
      ((low++))
    else
      label="priority:medium"
      ((medium++))
    fi

    # Add label
    gh issue edit -R "$repo" "$number" --add-label "$label" 2>/dev/null || true

    # Optionally add type label
    if [[ "$title $body" =~ (how|why|question|help|what|explain) ]]; then
      gh issue edit -R "$repo" "$number" --add-label "type:question" 2>/dev/null || true
    fi

    log_success "Issue #$number → $label"
  done

  log_section "Triage Summary"
  echo "Critical: $critical | High: $high | Medium: $medium | Low: $low"
}

# Create daily issue digest
# Usage: issue-digest <repo> [output_file]
issue-digest() {
  local repo=${1:?Repository required}
  local output=${2:-issue-digest-$(date +%Y-%m-%d).md}

  log_info "Generating issue digest for $repo"

  {
    cat <<EOF
# Issue Digest - $(date '+%Y-%m-%d %H:%M:%S')

## Critical Issues
$(gh issue list -R "$repo" --label "priority:critical" -L 20 -q \
  --json number,title,updatedAt \
  --jq '.[] | "- #\(.number): \(.title) (Updated: \(.updatedAt | split("T")[0]))"' || echo "None")

## High Priority Issues
$(gh issue list -R "$repo" --label "priority:high" -L 20 -q \
  --json number,title,updatedAt \
  --jq '.[] | "- #\(.number): \(.title)"' || echo "None")

## Recently Opened
$(gh issue list -R "$repo" --state open -L 5 \
  --json number,title,createdAt \
  --jq '.[] | "- #\(.number): \(.title) (Created: \(.createdAt | split("T")[0]))"')

## Stale Issues (No activity for 30 days)
$(gh issue list -R "$repo" --search "updated:<$(date -d '30 days ago' +%Y-%m-%d)" -L 20 \
  --json number,title,updatedAt \
  --jq '.[] | "- #\(.number): \(.title) (Last update: \(.updatedAt | split("T")[0]))"' || echo "None")

## Statistics
- Total Open Issues: $(gh issue list -R "$repo" --state open -q | wc -l)
- Total Closed This Month: $(gh issue list -R "$repo" --state closed --search "closed:>$(date -d 'start of month' +%Y-%m-%d)" -q | wc -l)

**Generated**: $(date)
EOF
  } > "$output"

  log_success "Digest saved to $output"
  cat "$output"
}

# Bulk assign issues based on label
# Usage: bulk-assign <repo> <label> <assignee>
bulk-assign() {
  local repo=${1:?Repository required}
  local label=${2:?Label required}
  local assignee=${3:?Assignee required}

  log_section "Assigning issues with label '$label' to @$assignee"

  local count=0
  gh issue list -R "$repo" --label "$label" --state open -q --json number | while read issue_num; do
    gh issue edit -R "$repo" "$issue_num" --add-assignee "$assignee"
    log_success "Issue #$issue_num assigned to @$assignee"
    ((count++))
  done

  log_success "Assigned $count issues"
}

# Close issues by criteria
# Usage: close-issues-by-criteria <repo> <criteria> [reason]
close-issues-by-criteria() {
  local repo=${1:?Repository required}
  local criteria=${2:?Criteria required}
  local reason=${3:-"Closed by automation"}

  log_section "Closing issues matching: $criteria"

  local count=0
  gh issue list -R "$repo" --search "$criteria" -q --json number | while read issue_num; do
    gh issue close -R "$repo" "$issue_num" -c "$reason"
    log_warning "Closed issue #$issue_num"
    ((count++))
  done

  log_success "Closed $count issues"
}

# Monitor issue creation rate
# Usage: issue-creation-rate <repo> [days]
issue-creation-rate() {
  local repo=${1:?Repository required}
  local days=${2:-7}
  local cutoff=$(date -d "$days days ago" +%Y-%m-%d)

  log_section "Issue Creation Rate for $repo (Last $days days)"

  {
    echo "Date,Count"
    for i in $(seq 0 $((days-1))); do
      local date=$(date -d "$i days ago" +%Y-%m-%d)
      local next_date=$(date -d "$((i-1)) days ago" +%Y-%m-%d)
      local count=$(gh issue list -R "$repo" --state all \
        --search "created:$date..$next_date" -q | wc -l)
      echo "$date,$count"
    done
  } | tee issue-creation-$(date +%Y-%m-%d).csv

  log_success "Data exported to issue-creation-*.csv"
}

# Generate issue report by assignee
# Usage: issues-by-assignee <repo>
issues-by-assignee() {
  local repo=${1:?Repository required}

  log_section "Open Issues by Assignee - $repo"

  gh issue list -R "$repo" --state open -L 100 \
    --json assignees,number,title \
    --jq '[.[] | {assignee: (.assignees[0].login // "Unassigned"), issue: .number}] |
    group_by(.assignee) | map({
      assignee: .[0].assignee,
      count: length,
      issues: [.[].issue]
    }) | sort_by(-.count)[] |
    "\(.assignee): \(.count) issues - #\(.issues | join(", #"))"'
}

# Create issue from template with metadata
# Usage: create-issue-from-template <repo> <title> [template_type]
create-issue-from-template() {
  local repo=${1:?Repository required}
  local title=${2:?Title required}
  local template=${3:-general}

  local body=""

  case "$template" in
    "bug")
      body=$(cat <<'EOF'
## Description
Brief description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS:
- Version:
- Browser:

## Additional Context
EOF
      )
      ;;

    "feature")
      body=$(cat <<'EOF'
## Description
Brief description of the feature request

## Motivation
Why is this needed?

## Proposed Solution
How should this be implemented?

## Alternatives Considered
Any alternative approaches?

## Additional Context
EOF
      )
      ;;

    *)
      body=$(cat <<'EOF'
## Description
Detailed description

## Context
Additional context
EOF
      )
      ;;
  esac

  gh issue create -R "$repo" --title "$title" --body "$body"
  log_success "Issue created from '$template' template"
}

# Check issue health metrics
# Usage: issue-health-check <repo>
issue-health-check() {
  local repo=${1:?Repository required}

  log_section "Issue Health Check - $repo"

  # Total issues
  local total=$(gh issue list -R "$repo" --state all -q | wc -l)
  echo "Total Issues: $total"

  # Open issues
  local open=$(gh issue list -R "$repo" --state open -q | wc -l)
  echo "Open Issues: $open"

  # Unassigned
  local unassigned=$(gh issue list -R "$repo" --state open \
    --json assignees --jq '.[] | select(.assignees | length == 0)' | wc -l)
  echo "Unassigned: $unassigned"

  # No labels
  local no_labels=$(gh issue list -R "$repo" --state open \
    --json labels --jq '.[] | select(.labels | length == 0)' | wc -l)
  echo "No Labels: $no_labels"

  # Average age of open issues (days)
  local avg_age=$(gh issue list -R "$repo" --state open -L 50 \
    --json createdAt \
    --jq '[.[] | (now - (.createdAt | fromdateiso8601)) / 86400 | floor] |
    add / length' 2>/dev/null || echo "N/A")
  echo "Average Age: $avg_age days"

  # Response time to first comment (closed issues)
  local response_time=$(gh issue list -R "$repo" --state closed -L 20 \
    --json createdAt,comments \
    --jq '[.[] | select(.comments | length > 0) |
    ((.comments[0].createdAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 3600 | floor] |
    add / length' 2>/dev/null || echo "N/A")
  echo "Avg First Response: $response_time hours"

  echo ""
  if [ $(echo "$open > $((total / 4))" | bc -l 2>/dev/null || echo 0) -eq 1 ]; then
    log_warning "High number of open issues (>25% of total)"
  fi

  if [ "$unassigned" -gt 0 ]; then
    log_warning "$unassigned issues are unassigned"
  fi
}

# Batch label operations
# Usage: batch-label <repo> <issue_search> <label_to_add> [label_to_remove]
batch-label() {
  local repo=${1:?Repository required}
  local search=${2:?Search criteria required}
  local add_label=${3:?Label to add required}
  local remove_label=${4:-}

  log_section "Batch Label Operation - $repo"
  log_info "Search: $search"
  log_info "Add: $add_label"
  [ -n "$remove_label" ] && log_info "Remove: $remove_label"

  local count=0
  gh issue list -R "$repo" --search "$search" -q --json number | while read issue_num; do
    if [ -n "$remove_label" ]; then
      gh issue edit -R "$repo" "$issue_num" --remove-label "$remove_label" 2>/dev/null || true
    fi
    gh issue edit -R "$repo" "$issue_num" --add-label "$add_label"
    log_success "Issue #$issue_num updated"
    ((count++))
  done

  log_success "Updated $count issues"
}

# Export issues to JSON
# Usage: export-issues <repo> [output_file]
export-issues() {
  local repo=${1:?Repository required}
  local output=${2:-issues-$(date +%Y-%m-%d).json}

  log_info "Exporting issues from $repo"

  gh issue list -R "$repo" --state all -L 200 \
    --json number,title,body,author,state,createdAt,updatedAt,labels,assignees \
    > "$output"

  log_success "Issues exported to $output"
  echo "Total issues: $(jq 'length' "$output")"
}

# Find and report duplicate issues
# Usage: find-duplicates <repo>
find-duplicates() {
  local repo=${1:?Repository required}

  log_section "Searching for Potential Duplicates - $repo"

  gh issue list -R "$repo" --state open \
    --json number,title \
    --jq '[.[] | .title] |
    group_by(.) |
    .[] |
    select(length > 1) |
    {title: .[0], count: length, issues: map(.number // empty)}' \
    --jq '.[] | "Potential duplicate: \(.title)\n  Count: \(.count)\n  Issues: #\(.issues | join(", #"))\n"'
}

echo "✓ Issue automation utilities loaded"
echo "Available functions:"
echo "  - auto-triage-issues          Auto-label issues by priority"
echo "  - issue-digest                Generate daily issue digest"
echo "  - bulk-assign                 Assign issues in bulk"
echo "  - close-issues-by-criteria    Close matching issues"
echo "  - issue-creation-rate         Track issue creation over time"
echo "  - issues-by-assignee          Report issues by assignee"
echo "  - create-issue-from-template  Create issue with template"
echo "  - issue-health-check          Check issue metrics"
echo "  - batch-label                 Batch label operations"
echo "  - export-issues               Export all issues to JSON"
echo "  - find-duplicates             Find potential duplicate issues"
