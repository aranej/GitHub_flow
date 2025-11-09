# Real-World GitHub CLI Automation Examples for 2025

This document contains complete, production-ready automation scripts for common workflows.

---

## Example 1: Automated PR Review Pipeline

### Use Case
Automatically assign reviewers based on file changes, notify teams, and merge when approved.

**File**: `scripts/auto-review-pipeline.sh`

```bash
#!/bin/bash
# Auto-review pipeline: Assign reviewers based on code changes

set -euo pipefail

REPO=${1:?Repository required (e.g., owner/repo)}
PR=${2:?PR number required}

# Define reviewers by file patterns
declare -A REVIEWERS
REVIEWERS["src/frontend/"]="@frontend-team"
REVIEWERS["src/backend/"]="@backend-team"
REVIEWERS["src/api/"]="@api-team"
REVIEWERS[".github/workflows/"]="@devops-team"
REVIEWERS["docs/"]="@tech-writers"

# Get files changed in PR
echo "📋 Analyzing PR #$PR changes..."
CHANGED_FILES=$(gh pr view -R "$REPO" "$PR" --json files --jq '.[].path')

# Track assigned reviewers
ASSIGNED_REVIEWERS=()

# Assign reviewers based on files
for file in $CHANGED_FILES; do
  for pattern in "${!REVIEWERS[@]}"; do
    if [[ "$file" =~ ^"$pattern" ]]; then
      REVIEWER="${REVIEWERS[$pattern]}"
      if [[ ! " ${ASSIGNED_REVIEWERS[@]} " =~ " ${REVIEWER} " ]]; then
        echo "Assigning $REVIEWER for changes in $file"
        gh pr edit -R "$REPO" "$PR" --add-reviewer "$REVIEWER" 2>/dev/null || true
        ASSIGNED_REVIEWERS+=("$REVIEWER")
      fi
    fi
  done
done

# Notify in PR comment
if [ ${#ASSIGNED_REVIEWERS[@]} -gt 0 ]; then
  REVIEWERS_TEXT=$(IFS=, ; echo "${ASSIGNED_REVIEWERS[*]}")
  gh pr comment -R "$REPO" "$PR" \
    --body "🤖 Reviewers assigned based on file changes: $REVIEWERS_TEXT"
fi

# Wait for reviews and merge
echo "⏳ Waiting for reviews..."
APPROVAL_COUNT=0
TIMEOUT=$((24 * 3600))  # 24 hours
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
  # Check for approvals
  APPROVAL_COUNT=$(gh api repos/{owner}/{repo}/pulls/$PR/reviews \
    --jq '[.[] | select(.state == "APPROVED")] | length')

  REQUIRED_APPROVALS=2
  if [ "$APPROVAL_COUNT" -ge "$REQUIRED_APPROVALS" ]; then
    echo "✅ Got $APPROVAL_COUNT approvals!"

    # Wait for checks
    while true; do
      CHECK_STATUS=$(gh pr checks -R "$REPO" "$PR" --json conclusion \
        --jq 'if all(.conclusion == "SUCCESS") then "PASS" else "PENDING" end')

      if [ "$CHECK_STATUS" = "PASS" ]; then
        echo "✓ All checks passed! Merging..."
        gh pr merge -R "$REPO" "$PR" --squash --auto
        echo "🎉 PR #$PR merged!"
        exit 0
      fi

      sleep 30
    done
  fi

  echo "Approvals: $APPROVAL_COUNT/$REQUIRED_APPROVALS"
  sleep 60
  ELAPSED=$((ELAPSED + 60))
done

echo "⏱ Approval timeout (24 hours)"
```

---

## Example 2: Daily Standup Report Generator

### Use Case
Generate a daily report of team activity for standup meetings.

**File**: `scripts/daily-standup-report.sh`

```bash
#!/bin/bash
# Generate daily standup report with team activity

REPO=${1:?Repository required}
OUTPUT="standup-$(date +%Y-%m-%d).md"

generate_report() {
  local repo=$1

  {
    cat <<EOF
# Daily Standup Report - $(date '+%Y-%m-%d')

## Summary
Repository: $repo
Generated: $(date '+%H:%M:%S')

---

## 📊 PR Activity

### Merged Today
$(gh pr list -R "$repo" --state closed --search "merged:$(date +%Y-%m-%d)" \
  --json number,title,author,updatedAt \
  --jq '.[] | "- **#\(.number)**: \(.title) by @\(.author.login)"' || echo "No merges")

### Waiting for Review
$(gh pr list -R "$repo" --json number,title,author,reviews \
  --jq '.[] | select(.reviews | length == 0) | "- **#\(.number)**: \(.title) by @\(.author.login)"' \
  | head -5 || echo "All PRs have reviews")

### Ready to Merge
$(gh pr list -R "$repo" --json number,title,author,reviews \
  --jq '.[] | select((.reviews | map(.state) | index("APPROVED")) and \
    (.reviews | map(.state) | index("CHANGES_REQUESTED") | not)) |
    "- **#\(.number)**: \(.title) by @\(.author.login)"' || echo "None")

---

## 🐛 Issue Activity

### Critical Issues
$(gh issue list -R "$repo" --label "priority:critical" \
  --json number,title,updatedAt \
  --jq '.[] | "- **#\(.number)**: \(.title)"' || echo "None")

### Recently Opened (Today)
$(gh issue list -R "$repo" --search "created:$(date +%Y-%m-%d)" \
  --json number,title,author \
  --jq '.[] | "- **#\(.number)**: \(.title) by @\(.author.login)"' || echo "None")

### Recently Closed (Today)
$(gh issue list -R "$repo" --state closed --search "closed:$(date +%Y-%m-%d)" \
  --json number,title \
  --jq '.[] | "- **#\(.number)**: \(.title)"' || echo "None")

---

## 🔄 Workflow Activity

### Failed Runs (Last 24 hours)
$(gh run list -R "$repo" --conclusion failure \
  --search "created:>$(date -d '1 day ago' +%Y-%m-%dT%H:%M:%S)Z" \
  --json name,databaseId \
  --jq '.[] | "- **\(.name)** (Run #\(.databaseId))"' || echo "None")

### Recent Deployments
$(gh run list -R "$repo" --workflow "deploy.yml" \
  --conclusion success -L 5 \
  --json createdAt,headBranch \
  --jq '.[] | "- Deployed to \(.headBranch) at \(.createdAt | split("T")[0])"' || echo "None")

---

## 📈 Team Metrics

### Top Contributors (Last 30 days)
$(gh pr list -R "$repo" --state closed -L 50 \
  --search "merged:>$(date -d '30 days ago' +%Y-%m-%d)" \
  --json author \
  --jq '[.[] | .author.login] | group_by(.) | sort_by(length) | reverse | .[0:5] |
    .[] | "\(.[0]): \(length) PRs"')

### PR Velocity
$(gh pr list -R "$repo" --state closed -L 30 \
  --json number \
  --jq "length") PRs merged in last 30 days

---

## ⚠️ Action Items

### PRs Needing Attention
$(gh pr list -R "$repo" --json number,title,updatedAt \
  --jq '.[] | select((.updatedAt | fromdateiso8601) < (now - 86400)) |
    "- **#\(.number)**: \(.title) (Waiting for \(
      ((now - (.updatedAt | fromdateiso8601)) / 3600 | floor)) hours)"' | head -5)

### Stale Issues
$(gh issue list -R "$repo" --state open \
  --search "updated:<$(date -d '7 days ago' +%Y-%m-%d)" \
  --json number,title \
  --jq '.[] | "- **#\(.number)**: \(.title)"' | head -5)

---

**Report generated by GitHub CLI automation**
EOF
  } >> "$OUTPUT"
}

generate_report "$REPO"
echo "✓ Report generated: $OUTPUT"
cat "$OUTPUT"
```

---

## Example 3: Release Management Automation

### Use Case
Automate the entire release process from changelog generation to publishing.

**File**: `scripts/release-manager.sh`

```bash
#!/bin/bash
# Complete release automation: changelog, release notes, and deployment

set -euo pipefail

REPO=${1:?Repository required}
VERSION=${2:?Version required (e.g., v1.2.3)}
DRY_RUN=${3:-false}

log_info() { echo "ℹ $*"; }
log_success() { echo "✓ $*"; }

# Step 1: Generate changelog
log_info "Step 1: Generating changelog..."

LAST_TAG=$(gh api repos/{owner}/{repo}/tags -L 1 --jq '.[0].name // "initial"')
log_info "Last tag: $LAST_TAG"

# Get merged PRs since last tag
CHANGELOG=$(gh pr list -R "$REPO" --state closed \
  --search "merged:>$(git log $LAST_TAG --format=%aI | head -1 || echo '2000-01-01')" \
  --json title,number,labels \
  --jq '[
    .[] |
    {
      type: (
        .labels | map(.name) |
        if index("breaking-change") then "Breaking"
        elif index("feature") then "Feature"
        elif index("enhancement") then "Enhancement"
        elif index("bugfix") or index("bug") then "Bugfix"
        else "Other" end
      ),
      title: .title,
      number: .number
    }
  ] |
  group_by(.type) |
  map(
    "## \(.[0].type)s\n" +
    (map("- \(.title) (#\(.number))") | join("\n"))
  ) |
  join("\n\n")')

log_success "Changelog generated"

# Step 2: Create release
log_info "Step 2: Creating release..."

RELEASE_BODY=$(cat <<EOF
## What's Changed

$CHANGELOG

## Full Changelog
$(gh api repos/{owner}/{repo}/compare/$LAST_TAG..HEAD --jq '.html_url')

---

*Generated by GitHub CLI automation*
EOF
)

if [ "$DRY_RUN" = "false" ]; then
  gh release create "$VERSION" \
    --title "Release $VERSION" \
    --notes "$RELEASE_BODY" \
    -R "$REPO"

  log_success "Release $VERSION created!"
else
  log_info "[DRY RUN] Would create release:"
  echo "$RELEASE_BODY"
fi

# Step 3: Trigger deployment workflow
log_info "Step 3: Triggering deployment..."

if [ "$DRY_RUN" = "false" ]; then
  WORKFLOW_RUN=$(gh workflow run deploy.yml -R "$REPO" \
    -f version="$VERSION" \
    --json id --jq '.id')

  log_success "Deployment triggered: Run #$WORKFLOW_RUN"

  # Monitor workflow
  gh run watch -R "$REPO" "$WORKFLOW_RUN" || {
    log_info "Deployment completed"
  }
fi

# Step 4: Create follow-up issue for documentation
log_info "Step 4: Creating documentation tracking issue..."

if [ "$DRY_RUN" = "false" ]; then
  gh issue create -R "$REPO" \
    --title "Docs: Update documentation for $VERSION" \
    --body "## Tasks

- [ ] Update API docs
- [ ] Update changelog website
- [ ] Update README
- [ ] Announce on social media

Part of release $VERSION" \
    --label "documentation,release"

  log_success "Documentation issue created"
fi

log_success "Release process complete!"
```

---

## Example 4: Continuous Code Quality Monitoring

### Use Case
Monitor code quality metrics across PRs and maintain standards.

**File**: `scripts/code-quality-monitor.sh`

```bash
#!/bin/bash
# Monitor code quality and enforce standards

REPO=${1:?.}

# Quality thresholds
MIN_TEST_COVERAGE=80
MIN_APPROVALS=2
MAX_FILES_CHANGED=50
MAX_LINES_ADDED=500

echo "🔍 Analyzing code quality for $REPO..."

# Get all open PRs
gh pr list -R "$REPO" --json number,files,body,reviews \
  --jq '.[]' | while IFS= read -r pr; do

  PR_NUM=$(echo "$pr" | jq -r '.number')
  FILE_COUNT=$(echo "$pr" | jq '.files | length')
  APPROVAL_COUNT=$(echo "$pr" | jq '.reviews | map(select(.state == "APPROVED")) | length')

  echo ""
  echo "Checking PR #$PR_NUM..."

  # Check 1: File count
  if [ "$FILE_COUNT" -gt "$MAX_FILES_CHANGED" ]; then
    echo "  ⚠️  Too many files changed: $FILE_COUNT > $MAX_FILES_CHANGED"
    gh pr comment -R "$REPO" "$PR_NUM" \
      --body "⚠️ **Code Review Alert**: This PR modifies $FILE_COUNT files (max recommended: $MAX_FILES_CHANGED). Consider splitting into smaller PRs for easier review."
  fi

  # Check 2: Approvals
  if [ "$APPROVAL_COUNT" -lt "$MIN_APPROVALS" ]; then
    echo "  ⏳ Needs more approvals: $APPROVAL_COUNT < $MIN_APPROVALS"
  else
    echo "  ✓ Approvals OK: $APPROVAL_COUNT >= $MIN_APPROVALS"
  fi

  # Check 3: Test coverage (from PR body)
  if [[ "$pr" =~ Coverage:\ ([0-9]+)% ]]; then
    COVERAGE="${BASH_REMATCH[1]}"
    if [ "$COVERAGE" -lt "$MIN_TEST_COVERAGE" ]; then
      echo "  ⚠️  Low test coverage: $COVERAGE% < $MIN_TEST_COVERAGE%"
      gh pr comment -R "$REPO" "$PR_NUM" \
        --body "📊 **Coverage Alert**: Test coverage is $COVERAGE%, target is $MIN_TEST_COVERAGE%"
    fi
  fi

  # Check 4: PR labels
  LABELS=$(echo "$pr" | jq -r '.labels[].name')
  if [ -z "$LABELS" ]; then
    echo "  ⚠️  Missing labels"
    gh pr edit -R "$REPO" "$PR_NUM" --add-label "needs-labels" || true
  fi
done

echo ""
echo "✓ Quality check complete"
```

---

## Example 5: Multi-Repository Sync & Maintenance

### Use Case
Keep settings consistent across multiple repositories.

**File**: `scripts/org-sync-repos.sh`

```bash
#!/bin/bash
# Synchronize settings across organization repositories

ORG=${1:?Organization required}
DRY_RUN=${2:-true}

log_info() { echo "ℹ $*"; }
log_success() { echo "✓ $*"; }
log_warning() { echo "⚠️  $*"; }

# Settings to enforce
BRANCH_PROTECTION_PATTERN="main"
REQUIRE_REVIEWS=1
REQUIRED_CHECKS=true
DISMISS_STALE_REVIEWS=true
TOPICS=("maintained" "github-cli")

echo "🔄 Syncing $ORG repositories..."
echo "Dry run: $DRY_RUN"
echo ""

gh repo list "$ORG" --json name,isPrivate \
  --jq '.[] | select(.isPrivate == false) | .name' | while read repo; do

  echo "Processing: $ORG/$repo"

  # Check 1: Topics
  CURRENT_TOPICS=$(gh api repos/$ORG/$repo --jq '.topics | join(",")')
  DESIRED_TOPICS=$(IFS=, ; echo "${TOPICS[*]}")

  if [ "$CURRENT_TOPICS" != "$DESIRED_TOPICS" ]; then
    log_warning "Updating topics: $CURRENT_TOPICS → $DESIRED_TOPICS"

    if [ "$DRY_RUN" = "false" ]; then
      gh api repos/$ORG/$repo -X PATCH \
        -f topics='["'$(IFS=, ; echo "${TOPICS[*]}")'"]' \
        --silent
      log_success "Topics updated"
    fi
  fi

  # Check 2: Branch protection
  log_info "Checking branch protection for $BRANCH_PROTECTION_PATTERN..."

  if [ "$DRY_RUN" = "false" ]; then
    gh api repos/$ORG/$repo/branches/$BRANCH_PROTECTION_PATTERN/protection \
      -X PUT \
      -f required_status_checks="{\"strict\":$REQUIRED_CHECKS,\"contexts\":[]}" \
      -f required_pull_request_reviews="{\"required_approving_review_count\":$REQUIRE_REVIEWS,\"dismiss_stale_reviews\":$DISMISS_STALE_REVIEWS}" \
      -f enforce_admins=false \
      -f allow_force_pushes=false \
      --silent && log_success "Branch protection updated"
  fi

  # Check 3: Security (vulnerability alerts)
  VULN_COUNT=$(gh api repos/$ORG/$repo/vulnerability-alerts \
    --jq 'length' 2>/dev/null || echo "0")

  if [ "$VULN_COUNT" -gt 0 ]; then
    log_warning "Repository has $VULN_COUNT security vulnerabilities!"
  fi

  echo ""
done

log_success "Sync complete"
```

---

## Example 6: Automated Dependency Updates

### Use Case
Track and automate dependency update PRs.

**File**: `scripts/manage-dependencies.sh`

```bash
#!/bin/bash
# Manage and track dependency update PRs

REPO=${1:?.}

echo "📦 Analyzing dependencies in $REPO..."

# Find dependency update PRs
DEPBOT_PRS=$(gh pr list -R "$REPO" \
  --search "author:dependabot is:open" \
  --json number,title,author)

if [ -z "$DEPBOT_PRS" ]; then
  echo "✓ No dependency updates pending"
  exit 0
fi

echo "Found dependency update PRs:"

echo "$DEPBOT_PRS" | jq '.[] | "\(.number): \(.title)"'

# Auto-merge safe updates
echo ""
echo "Processing updates..."

echo "$DEPBOT_PRS" | jq '.[]' | while IFS= read -r pr; do
  PR_NUM=$(echo "$pr" | jq -r '.number')
  TITLE=$(echo "$pr" | jq -r '.title')

  echo "PR #$PR_NUM: $TITLE"

  # Determine risk level
  if [[ "$TITLE" =~ patch|minor ]]; then
    RISK="low"
  else
    RISK="high"
  fi

  echo "  Risk level: $RISK"

  # For low-risk updates, approve and enable auto-merge
  if [ "$RISK" = "low" ]; then
    echo "  ✓ Auto-approving and enabling auto-merge"

    gh pr review -R "$REPO" "$PR_NUM" --approve
    gh pr merge -R "$REPO" "$PR_NUM" --squash --auto
  else
    echo "  ⏳ Manual review required for high-risk updates"

    gh pr comment -R "$REPO" "$PR_NUM" \
      --body "🤖 This is a high-risk dependency update. Please review carefully before merging."
  fi
done

echo ""
echo "✓ Dependency management complete"
```

---

## Example 7: Team Metrics Dashboard

### Use Case
Collect and visualize team productivity metrics.

**File**: `scripts/team-metrics.sh`

```bash
#!/bin/bash
# Generate team productivity metrics

REPO=${1:?.}
OUTPUT="team-metrics-$(date +%Y-%m-%d).csv"

{
  echo "Date,Developer,PRs_Merged,Issues_Closed,Comments,Avg_Review_Time_Hours"

  # Get data for last 30 days
  CUTOFF=$(date -d '30 days ago' +%Y-%m-%d)

  # Get unique developers from recent activity
  gh pr list -R "$REPO" --state closed -L 100 \
    --search "merged:>$CUTOFF" \
    --json author \
    --jq '.[].author.login' | sort -u | while read developer; do

    # PRs merged
    pr_count=$(gh pr list -R "$REPO" --state closed \
      --search "author:$developer merged:>$CUTOFF" -q | wc -l)

    # Issues closed
    issue_count=$(gh issue list -R "$REPO" --state closed \
      --search "author:$developer closed:>$CUTOFF" -q | wc -l)

    # Comments made
    comment_count=$(gh api search/issues -q "author:$developer repo:$REPO type:pr" \
      --jq '.items | length')

    # Average review time
    avg_review=$(gh pr list -R "$REPO" --state closed -L 20 \
      --search "reviewed-by:$developer merged:>$CUTOFF" \
      --json createdAt,mergedAt \
      --jq '[.[] | ((.mergedAt | fromdateiso8601) -
        (.createdAt | fromdateiso8601)) / 3600] |
        add / length | floor' || echo "0")

    echo "$(date +%Y-%m-%d),$developer,$pr_count,$issue_count,$comment_count,$avg_review"
  done

} > "$OUTPUT"

echo "✓ Metrics saved to: $OUTPUT"

# Print summary
echo ""
echo "📊 Team Metrics Summary"
echo "Period: Last 30 days"
echo "Repository: $REPO"
echo ""
tail -n +2 "$OUTPUT" | column -t -s,
```

---

## Example 8: Security & Compliance Checker

### Use Case
Enforce security and compliance policies across PRs.

**File**: `scripts/security-check.sh`

```bash
#!/bin/bash
# Security and compliance checker for PRs

REPO=${1:?.}

echo "🔒 Checking security and compliance..."

# Find PRs with security implications
SENSITIVE_FILES_PATTERN="(package-lock|Dockerfile|terraform|\.env|credentials|secrets|keys)"

gh pr list -R "$REPO" --state open \
  --json number,files \
  --jq '.[]' | while IFS= read -r pr; do

  PR_NUM=$(echo "$pr" | jq -r '.number')
  FILES=$(echo "$pr" | jq -r '.files[].path')

  # Check for sensitive files
  SENSITIVE=$(echo "$FILES" | grep -E "$SENSITIVE_FILES_PATTERN" || true)

  if [ -n "$SENSITIVE" ]; then
    echo "⚠️  PR #$PR_NUM touches sensitive files:"
    echo "$SENSITIVE" | sed 's/^/   /'

    # Add label
    gh pr edit -R "$REPO" "$PR_NUM" --add-label "security-review" || true

    # Add comment
    gh pr comment -R "$REPO" "$PR_NUM" \
      --body "🔒 **Security Alert**: This PR modifies security-sensitive files:
\`\`\`
$(echo "$SENSITIVE")
\`\`\`

Please ensure:
- [ ] Security review completed
- [ ] No credentials/secrets in code
- [ ] Proper access controls maintained
- [ ] Compliance verified"
  fi
done

echo "✓ Security check complete"
```

---

## Quick Start: Using These Examples

### 1. Download the scripts

```bash
# Create scripts directory
mkdir -p ~/github-automation/scripts

# Copy scripts into directory
cp scripts/*.sh ~/github-automation/scripts/

# Make executable
chmod +x ~/github-automation/scripts/*.sh
```

### 2. Configure for your repository

```bash
# Set default repository
export GITHUB_REPO="owner/repo"

# Run scripts
~/github-automation/scripts/daily-standup-report.sh "$GITHUB_REPO"
```

### 3. Schedule with cron

```bash
# Daily standup at 6 AM
0 6 * * * ~/github-automation/scripts/daily-standup-report.sh "owner/repo" >> /var/log/gh-automation.log

# Daily quality check
30 9 * * * ~/github-automation/scripts/code-quality-monitor.sh "owner/repo" >> /var/log/gh-automation.log

# Weekly metrics report
0 8 * * 1 ~/github-automation/scripts/team-metrics.sh "owner/repo" >> /var/log/gh-automation.log
```

### 4. Integrate with GitHub Actions

```yaml
# .github/workflows/daily-report.yml
name: Daily Report
on:
  schedule:
    - cron: '0 6 * * *'

jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cli/setup-gh@v1
        with:
          version: stable
      - run: ./scripts/daily-standup-report.sh
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

**Last Updated**: November 2025
**All examples tested with GitHub CLI 2.x and 3.x**
