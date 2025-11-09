# GitHub CLI (gh) Advanced Usage & Automation for 2025

## Table of Contents
1. [PR Creation and Management Automation](#pr-creation-and-management-automation)
2. [Issue Tracking Workflows](#issue-tracking-workflows)
3. [CI/CD Status Checking](#cicd-status-checking)
4. [Scripting and Automation](#scripting-and-automation)
5. [Extensions and Plugins](#extensions-and-plugins)
6. [AI Tools Integration](#ai-tools-integration)
7. [Advanced Aliases](#advanced-aliases)
8. [Real-World Automation Patterns](#real-world-automation-patterns)

---

## PR Creation and Management Automation

### Basic PR Creation with Metadata

```bash
# Create PR with title, body, reviewers, labels, and milestone
gh pr create \
  --title "feat: Add dark mode toggle" \
  --body "Closes #123\n\n## Description\n...\n## Testing\n..." \
  --reviewer @user1,@user2 \
  --label "enhancement,ui" \
  --milestone "v2.0" \
  --draft
```

### Automated PR Creation with Jira References (2025 Example)

This advanced pattern extracts Jira ticket numbers from commit messages and automatically creates formatted PR descriptions:

```bash
#!/bin/bash
# Script: create-pr-with-jira.sh
# Creates PR with Jira references from commit history

JIRA_BASE_URL="https://your-jira.atlassian.net"

# Extract unique Jira tickets from commits
TICKETS=$(git log --pretty=%B origin/main..HEAD | grep -oE '[A-Z]+-[0-9]+' | sort -u)

# Build Jira references
JIRA_REFS=""
for ticket in $TICKETS; do
  JIRA_REFS+="[$ticket]($JIRA_BASE_URL/browse/$ticket) "
done

# Get commit summary
COMMITS=$(git log --oneline origin/main..HEAD)

# Create PR with formatted body
gh pr create \
  --title "$(git log -1 --pretty=%s)" \
  --body "## Jira References
$JIRA_REFS

## Commits
\`\`\`
$COMMITS
\`\`\`" \
  --reviewer @team
```

### Batch PR Operations

```bash
#!/bin/bash
# Script: batch-pr-operations.sh
# Manage multiple PRs across repositories

REPOS=("repo1" "repo2" "repo3")
LABEL_TO_ADD="ready-for-review"

for repo in "${REPOS[@]}"; do
  # List all draft PRs in repo
  gh pr list -R "org/$repo" --draft -q --json number | while read pr_num; do
    # Mark as ready (remove draft status)
    gh pr ready -R "org/$repo" "$pr_num"
    # Add label
    gh pr edit -R "org/$repo" "$pr_num" --add-label "$LABEL_TO_ADD"
    echo "Processed PR #$pr_num in $repo"
  done
done
```

### Auto-Merge with Checks

```bash
#!/bin/bash
# Script: auto-merge-pr.sh
# Merge PR only after all checks pass

PR=$1
REPO=$2
MAX_WAIT=3600  # 1 hour timeout

echo "Waiting for checks to pass on PR #$PR..."

start_time=$(date +%s)
while true; do
  # Get check status
  STATUS=$(gh pr checks "$PR" -R "$REPO" --json state \
    --jq 'if all(.state == "PASS") then "PASS" elif any(.state == "FAIL") then "FAIL" else "PENDING" end')

  if [ "$STATUS" = "PASS" ]; then
    echo "All checks passed! Merging PR #$PR..."
    gh pr merge "$PR" -R "$REPO" --squash --auto
    break
  elif [ "$STATUS" = "FAIL" ]; then
    echo "Checks failed for PR #$PR"
    exit 1
  fi

  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  if [ $elapsed -gt $MAX_WAIT ]; then
    echo "Timeout waiting for checks"
    exit 1
  fi

  echo "Checks still pending... waiting 30 seconds"
  sleep 30
done
```

---

## Issue Tracking Workflows

### Automated Issue Triage

```bash
#!/bin/bash
# Script: auto-triage-issues.sh
# Automatically label and assign issues based on patterns

REPO="owner/repo"
PRIORITY_LABELS=("bug:critical" "bug:high" "bug:medium" "bug:low")

# Find unlabeled issues
gh issue list -R "$REPO" --label "!bug" --label "!feature" --label "!docs" \
  --json number,title,body \
  --jq '.[]' | while IFS= read -r issue; do

    NUMBER=$(echo "$issue" | jq -r '.number')
    TITLE=$(echo "$issue" | jq -r '.title')
    BODY=$(echo "$issue" | jq -r '.body')

    # Determine priority by keywords
    if [[ "$TITLE" =~ (critical|urgent|blocking) ]]; then
      LABEL="bug:critical"
    elif [[ "$BODY" =~ (crash|data loss|security) ]]; then
      LABEL="bug:critical"
    elif [[ "$TITLE" =~ (error|broken|fail) ]]; then
      LABEL="bug:high"
    elif [[ "$TITLE" =~ (typo|minor|cosmetic) ]]; then
      LABEL="bug:low"
    else
      LABEL="bug:medium"
    fi

    gh issue edit -R "$REPO" "$NUMBER" --add-label "$LABEL"
    echo "Issue #$NUMBER labeled as $LABEL"
done
```

### Issue to Project Automation

```bash
#!/bin/bash
# Script: auto-add-to-project.sh
# Automatically add issues to GitHub Projects

REPO="owner/repo"
PROJECT_ID="PVT_..."  # Project number from gh project list

gh issue list -R "$REPO" --state "open" \
  --json number,labels \
  --jq '.[] | select(.labels | length == 0) | .number' | while read issue_num; do

    echo "Adding issue #$issue_num to project..."

    # Use GraphQL to add issue to project
    gh api graphql -f owner=owner -f name=repo -f issue_number=$issue_num -F project_id=$PROJECT_ID \
      --input - <<'EOF'
mutation AddIssueToProject($owner: String!, $name: String!, $issue_number: Int!, $project_id: ID!) {
  addProjectV2ItemById(input: {projectId: $project_id, contentId: "$(gh issue view $issue_number -R $owner/$name --json id --jq '.id')"}) {
    item {
      id
    }
  }
}
EOF
done
```

### Daily Digest of Open Issues

```bash
#!/bin/bash
# Script: daily-issue-digest.sh
# Generate a daily summary of issues by priority

REPO="owner/repo"
OUTPUT="issue-digest-$(date +%Y-%m-%d).md"

cat > "$OUTPUT" <<EOF
# Daily Issue Digest - $(date +%Y-%m-%d)

## Critical Issues
$(gh issue list -R "$REPO" --label "bug:critical" -q --json number,title,createdAt \
  --jq '.[] | "- #\(.number): \(.title)"')

## High Priority Issues
$(gh issue list -R "$REPO" --label "bug:high" -q --json number,title,createdAt \
  --jq '.[] | "- #\(.number): \(.title)"')

## Medium Priority Issues
$(gh issue list -R "$REPO" --label "bug:medium" -L 10 -q --json number,title,createdAt \
  --jq '.[] | "- #\(.number): \(.title)"')

## Stale Issues (> 30 days)
$(gh issue list -R "$REPO" --search "created:<$(date -d '30 days ago' +%Y-%m-%d)" -q \
  --json number,title,createdAt \
  --jq '.[] | "- #\(.number): \(.title) (Created: \(.createdAt | split(\"T\")[0]))"')

EOF

echo "Digest generated: $OUTPUT"
```

---

## CI/CD Status Checking

### Monitor PR Checks Until Completion

```bash
#!/bin/bash
# Script: monitor-pr-checks.sh
# Watch PR checks with real-time status updates

PR=$1
REPO=${2:-.}

echo "Monitoring checks for PR #$PR..."

# Watch checks with color output
gh pr checks "$PR" -R "$REPO" --watch --fail-fast

if [ $? -eq 0 ]; then
  echo "✓ All checks passed!"
else
  echo "✗ Checks failed"
  # Get failed check details
  gh pr checks "$PR" -R "$REPO" --json name,conclusion,detailsUrl \
    --jq '.[] | select(.conclusion != "SUCCESS") |
    "\(.name): \(.conclusion)\n  Details: \(.detailsUrl)"'
fi
```

### Automated Check Notifications

```bash
#!/bin/bash
# Script: check-notification.sh
# Send notifications when PR checks complete (Linux)

PR=$1
REPO=${2:-.}

# Poll for check completion
while true; do
  STATUS=$(gh pr checks "$PR" -R "$REPO" --json conclusion \
    --jq '[.[] | .conclusion] | if (all(. == "SUCCESS")) then "PASS" elif any(. != "SUCCESS") then "FAIL" else "PENDING" end')

  if [ "$STATUS" != "PENDING" ]; then
    if [ "$STATUS" = "PASS" ]; then
      notify-send "PR #$PR" "✓ All checks passed!" --urgency=low
      echo "Checks passed for PR #$PR"
    else
      notify-send "PR #$PR" "✗ Checks failed!" --urgency=critical
      echo "Checks failed for PR #$PR"
    fi
    break
  fi

  sleep 60
done
```

### Workflow Run Monitoring Dashboard

```bash
#!/bin/bash
# Script: workflow-dashboard.sh
# Display a live dashboard of workflow runs

REPO=${1:-.}
REFRESH_INTERVAL=30

while true; do
  clear
  echo "=== GitHub Actions Workflow Dashboard ==="
  echo "Repository: $REPO"
  echo "Last updated: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""

  # Get recent workflow runs with status
  gh run list -R "$REPO" -L 10 --json name,status,conclusion,createdAt,databaseId \
    --jq '.[] | "\(.status | ascii_upcase) - \(.name) (ID: \(.databaseId)) - \(.createdAt | split("T")[0])"'

  echo ""
  echo "Press Ctrl+C to exit. Refreshing in ${REFRESH_INTERVAL}s..."
  sleep $REFRESH_INTERVAL
done
```

---

## Scripting and Automation

### JSON Output for Advanced Filtering

```bash
# List all PRs with specific reviewers
gh pr list --json number,title,reviewers \
  --jq '.[] | select(.reviewers[].login == "john-doe") | "\(.number): \(.title)"'

# Find PRs that haven't been reviewed
gh pr list --json number,title,reviews \
  --jq '.[] | select(.reviews | length == 0) | "\(.number): \(.title) - No reviews"'

# Get average PR review time (requires additional processing)
gh pr list --state closed -L 50 --json number,createdAt,closedAt,updatedAt \
  --jq '.[] | .number, .createdAt, .closedAt' | paste - - - | \
  awk -F'\t' '{cmd="date -d \""$3"\" +%s"; cmd | getline close_time; \
    cmd="date -d \""$2"\" +%s"; cmd | getline create_time; \
    diff=close_time-create_time; printf "%s: %d days\n", $1, diff/86400}'
```

### Complex Query with jq

```bash
#!/bin/bash
# Script: pr-metrics.sh
# Calculate various PR metrics

REPO="owner/repo"

echo "=== PR Metrics ==="

# Average PR review time
echo "Average review time:"
gh pr list -R "$REPO" --state closed -L 100 \
  --json number,createdAt,mergedAt \
  --jq '[.[] |
    (.mergedAt | fromdateiso8601) - (.createdAt | fromdateiso8601) | . / 86400
  ] | add / length | "\(. | floor) days"'

# PRs by author (top 5)
echo -e "\nTop PR authors:"
gh pr list -R "$REPO" --state closed -L 100 \
  --json author \
  --jq '[.[] | .author.login] | group_by(.) | sort_by(length) | reverse |
  .[0:5] | .[] | "\(.[0]): \(length) PRs"'

# Average number of reviews per PR
echo -e "\nAverage reviews per PR:"
gh pr list -R "$REPO" --state closed -L 50 \
  --json reviews \
  --jq '[.[] | .reviews | length] | add / length | "\(. | floor) reviews"'
```

### Batch Operations Across Repos

```bash
#!/bin/bash
# Script: batch-across-repos.sh
# Perform operations on multiple repositories

ORG="my-org"
LABEL_TO_ADD="archived-check"

# Get all repos in organization
gh repo list "$ORG" --json name --jq '.[].name' | while read repo; do
  echo "Processing $ORG/$repo..."

  # Example: Add label to all open issues
  gh issue list -R "$ORG/$repo" --state open -q --json number | while read issue_num; do
    gh issue edit -R "$ORG/$repo" "$issue_num" --add-label "$LABEL_TO_ADD"
  done

  # Example: Close stale PRs
  gh pr list -R "$ORG/$repo" --search "updated:<$(date -d '60 days ago' +%Y-%m-%d)" -q --json number | while read pr_num; do
    gh pr close -R "$ORG/$repo" "$pr_num" -c "Closing stale PR"
  done
done
```

---

## Extensions and Plugins

### Popular Extensions (2025)

#### 1. **gh-dash** - Interactive Dashboard
```bash
# Install
gh extension install dlvhdr/gh-dash

# Usage
gh dash
# Creates a customizable TUI dashboard showing:
# - Your PRs
# - Review requests
# - Issues assigned to you
# - Repositories you follow
```

Configuration (~/.config/gh-dash/config.yml):
```yaml
prSections:
  - title: "My Pull Requests"
    filters: "is:open assignee:@me"
  - title: "Needs Review"
    filters: "is:open review-requested:@me"

issueSections:
  - title: "My Issues"
    filters: "is:open assignee:@me"

repoPinnedOrder:
  - "owner/important-repo"
  - "owner/another-repo"
```

#### 2. **gh-changelog** - Automated Changelog Generation
```bash
# Install
gh extension install chelnak/gh-changelog

# Usage
gh changelog new -t "v1.0.0"  # Creates changelog entry
gh changelog list               # Lists all changelogs
gh changelog view v1.0.0        # Views specific changelog

# Integrated with releases
gh release create v1.0.0 --generate-notes
```

#### 3. **gh-promote** - Promote issues to PRs
```bash
# Install
gh extension install shunsuke-tamura/gh-promote

# Usage
gh promote issue-number
# Converts issue to PR with context
```

#### 4. **gh-prs** - Enhanced PR Management
```bash
# Install
gh extension install meiji163/gh-prs

# Usage - List PRs with filtering
gh prs --assignee @me
gh prs --reviewed
gh prs --draft
```

### Creating Custom Extensions

```bash
#!/bin/bash
# File: gh-custom-stats (make executable: chmod +x gh-custom-stats)
# Custom extension: Repository statistics

REPO=${1:-.}

echo "📊 Repository Statistics for $REPO"
echo ""

# Total issues
TOTAL_ISSUES=$(gh issue list -R "$REPO" --state all -q --json number | wc -l)
echo "Total Issues: $TOTAL_ISSUES"

# Total PRs
TOTAL_PRS=$(gh pr list -R "$REPO" --state all -q --json number | wc -l)
echo "Total Pull Requests: $TOTAL_PRS"

# Active contributors (last 30 days)
CONTRIBUTORS=$(gh api repos/{owner}/{repo}/commits \
  --paginate --per-page=100 \
  --jq '.[] | select(.commit.author.date > now - 2592000) | .author.login' | sort -u | wc -l)
echo "Active Contributors (30 days): $CONTRIBUTORS"

# Most active files
echo ""
echo "📁 Most Modified Files (last 20 commits):"
gh api repos/{owner}/{repo}/commits -L 20 \
  --jq '.[] | .files[] | .filename' | sort | uniq -c | sort -rn | head -5

# Installation
echo ""
echo "To use: gh extension install ./gh-custom-stats"
```

---

## AI Tools Integration

### GitHub Copilot CLI (Public Preview - October 2025)

GitHub Copilot CLI is the next evolution of terminal-based AI assistance, replacing the deprecated `gh-copilot` extension:

#### Key Features

```bash
# Interactive mode - Ask questions about your code
gh copilot

# Explain shell commands
gh copilot explain "git rebase -i HEAD~5"

# Get command suggestions
gh copilot suggest "How do I list files modified in last commit"

# Agentic capabilities - Complex task execution
gh copilot "Create a new PR with automated tests for the auth module"

# Model selection (Copilot Pro/Business/Enterprise)
gh copilot --model gpt-4o
gh copilot --model gpt-5  # Extended reasoning mode
```

#### Practical Automation Examples with Copilot CLI

```bash
#!/bin/bash
# Script: automated-release-workflow.sh
# Using Copilot CLI for intelligent workflow automation

# 1. Ask Copilot to suggest PR review comments
PR=$1
REVIEW_SCOPE=$(gh copilot suggest \
  "Generate review comments for PR #$PR focusing on performance")

# 2. Get intelligent commit message suggestions
CHANGES=$(git diff --cached)
COMMIT_MSG=$(gh copilot suggest \
  "Suggest a conventional commit message for these changes: $CHANGES")

# 3. Plan complex operations with Copilot
PLAN=$(gh copilot \
  "Plan how to migrate CI/CD from GitHub Actions to another platform \
   in repository owner/repo with 50+ workflows")

echo "AI-Generated Plan:"
echo "$PLAN"
```

#### MCP Server Integration

GitHub Copilot CLI includes built-in MCP (Model Context Protocol) server support:

```bash
# GitHub's MCP server is enabled by default
gh copilot --mcp-server github

# Add custom MCP servers for additional context
gh copilot --mcp-server /path/to/custom/mcp-server

# Use with extended reasoning
gh copilot --model gpt-5 --extended-reasoning \
  "Analyze our repository structure and suggest architectural improvements"
```

### Integration with GitHub CLI and Copilot

```bash
#!/bin/bash
# Script: copilot-assisted-workflow.sh
# Combining gh CLI with Copilot for advanced automation

REPO="owner/repo"

# 1. Get list of stale PRs
STALE_PRS=$(gh pr list -R "$REPO" -q --json number,title,updatedAt \
  --jq '.[] | select(.updatedAt < now - 604800) | .number')

# 2. Use Copilot to generate review guidance
for pr in $STALE_PRS; do
  PR_INFO=$(gh pr view -R "$REPO" "$pr" --json title,body)

  GUIDANCE=$(gh copilot suggest \
    "This PR has been waiting for review for a week: $PR_INFO \
     What specific areas should the reviewer focus on?")

  # Comment on PR with Copilot-generated guidance
  gh pr comment -R "$REPO" "$pr" \
    --body "🤖 Review Focus Areas:\n$GUIDANCE"
done

# 3. Generate release notes intelligently
CHANGES=$(gh pr list -R "$REPO" --state closed -L 20 --json title,body \
  --jq '.[] | .title')

RELEASE_NOTES=$(gh copilot suggest \
  "Generate professional release notes for these changes: $CHANGES")

echo "$RELEASE_NOTES" > release-notes.md
```

---

## Advanced Aliases

### Essential Productivity Aliases

```bash
# Quick PR checkout
gh alias set --shell co 'id="$(gh pr list -L100 | fzf | cut -f1)"; [ -n "$id" ] && gh pr checkout "$id"'

# Create draft PR quickly
gh alias set --shell draft 'gh pr create --draft'

# Open PR in browser
gh alias set open 'gh pr view --web'

# List PRs needing my review
gh alias set --shell review 'gh pr list --search "review-requested:@me"'

# Quick issue creation
gh alias set quick-issue 'gh issue create --title "$1" --body "From CLI"'

# Show my stats
gh alias set --shell mystats 'echo "PRs: $(gh pr list -q | wc -l)"; echo "Reviews: $(gh pr list --search "review-requested:@me" -q | wc -l)"'
```

### Complex Multi-Line Aliases

```bash
# Summary of repository activity
gh alias set -s summary - <<'EOF'
echo "=== $1 Repository Summary ==="
echo "Open PRs: $(gh pr list -R $1 -q | wc -l)"
echo "Open Issues: $(gh issue list -R $1 -q | wc -l)"
echo "Recent Commits: $(gh api repos/$1/commits -L 5 | jq '. | length')"
echo "Watchers: $(gh api repos/$1 --jq '.watchers_count')"
echo "Stars: $(gh api repos/$1 --jq '.stargazers_count')"
EOF

# Advanced filtering and analysis
gh alias set -s filter-prs - <<'EOF'
case "$1" in
  "draft") gh pr list --draft ;;
  "waiting") gh pr list --search "status:pending" ;;
  "approved") gh pr list --search "review:approved" ;;
  "needs-work") gh pr list --search "review-requested:@me" ;;
  *) echo "Usage: gh filter-prs [draft|waiting|approved|needs-work]" ;;
esac
EOF

# Bulk operations
gh alias set -s bulk-label - <<'EOF'
LABEL="$1"
REPOS="$2"
gh repo list "$REPOS" -q --json name | while read repo; do
  gh issue list -R "$repo" --state open -q --json number | while read issue; do
    gh issue edit -R "$repo" "$issue" --add-label "$LABEL"
  done
done
EOF
```

---

## Real-World Automation Patterns

### Complete CI/CD Pipeline Trigger Script

```bash
#!/bin/bash
# Script: deploy-pipeline.sh
# Orchestrate full deployment workflow via GitHub CLI

set -e

REPO="owner/repo"
ENVIRONMENT="staging"
PR=$1

if [ -z "$PR" ]; then
  echo "Usage: ./deploy-pipeline.sh <PR_NUMBER>"
  exit 1
fi

echo "🚀 Starting deployment pipeline for PR #$PR to $ENVIRONMENT..."

# 1. Check PR status
echo "📋 Checking PR status..."
PR_STATE=$(gh pr view -R "$REPO" "$PR" --json state --jq '.state')
if [ "$PR_STATE" != "OPEN" ]; then
  echo "❌ PR is not open"
  exit 1
fi

# 2. Ensure all reviews are approved
echo "✅ Verifying approvals..."
APPROVAL_COUNT=$(gh api repos/{owner}/{repo}/pulls/$PR/reviews \
  --jq '[.[] | select(.state == "APPROVED")] | length')
if [ "$APPROVAL_COUNT" -lt 2 ]; then
  echo "❌ Needs at least 2 approvals (currently: $APPROVAL_COUNT)"
  exit 1
fi

# 3. Trigger deployment workflow
echo "🔄 Triggering deployment workflow..."
WORKFLOW_RUN=$(gh workflow run deploy.yml -R "$REPO" \
  -f environment=$ENVIRONMENT \
  -f pr=$PR \
  --json id --jq '.id')

echo "Workflow run ID: $WORKFLOW_RUN"

# 4. Monitor workflow
echo "⏳ Monitoring workflow (timeout: 30 minutes)..."
TIMEOUT=$((30 * 60))
ELAPSED=0
POLL_INTERVAL=30

while [ $ELAPSED -lt $TIMEOUT ]; do
  STATUS=$(gh run view -R "$REPO" "$WORKFLOW_RUN" \
    --json conclusion --jq '.conclusion // "pending"')

  case "$STATUS" in
    "success")
      echo "✅ Deployment successful!"
      gh pr comment -R "$REPO" "$PR" \
        --body "🚀 Deployment to $ENVIRONMENT completed successfully!"
      exit 0
      ;;
    "failure")
      echo "❌ Deployment failed!"
      gh pr comment -R "$REPO" "$PR" \
        --body "❌ Deployment to $ENVIRONMENT failed. Check the [workflow]($WORKFLOW_URL) for details."
      exit 1
      ;;
    "cancelled")
      echo "⚠️ Deployment cancelled"
      exit 1
      ;;
    *)
      echo "Running... ($ELAPSED/$TIMEOUT seconds)"
      sleep $POLL_INTERVAL
      ELAPSED=$((ELAPSED + POLL_INTERVAL))
      ;;
  esac
done

echo "❌ Deployment timed out"
exit 1
```

### Smart PR Review Assignment

```bash
#!/bin/bash
# Script: smart-review-assignment.sh
# Automatically assign PR reviews based on code changes

REPO="owner/repo"

# Get all open PRs without reviews
gh pr list -R "$REPO" --json number,files,author \
  --jq '.[] | select(.reviewers | length == 0)' | while read -r pr_data; do

  PR_NUM=$(echo "$pr_data" | jq -r '.number')
  AUTHOR=$(echo "$pr_data" | jq -r '.author.login')

  # Determine reviewer based on files changed
  FILES=$(echo "$pr_data" | jq -r '.files[].path' | head -5)

  REVIEWER=""

  if echo "$FILES" | grep -q "frontend"; then
    REVIEWER="@frontend-team"
  elif echo "$FILES" | grep -q "backend"; then
    REVIEWER="@backend-team"
  elif echo "$FILES" | grep -q "docs"; then
    REVIEWER="@docs-team"
  else
    REVIEWER="@default-reviewers"
  fi

  # Assign review
  gh pr edit -R "$REPO" "$PR_NUM" --add-reviewer "$REVIEWER"

  # Add comment
  gh pr comment -R "$REPO" "$PR_NUM" \
    --body "📋 Automatically assigned for review based on changed files."

  echo "PR #$PR_NUM assigned to $REVIEWER"
done
```

### Release Management Automation

```bash
#!/bin/bash
# Script: manage-release.sh
# Automated release creation with changelog

REPO="owner/repo"
VERSION=$1
RELEASE_TYPE=${2:-minor}  # major, minor, patch

if [ -z "$VERSION" ]; then
  echo "Usage: ./manage-release.sh <version> [release-type]"
  exit 1
fi

echo "📦 Creating release v$VERSION..."

# 1. Get changelog entries from PRs since last release
LAST_TAG=$(gh api repos/{owner}/{repo}/tags -L 1 \
  --jq '.[0].name // "initial"')

echo "Generating changelog from $LAST_TAG..."

CHANGELOG=$(gh pr list -R "$REPO" --state closed \
  --search "merged:>$(git log $LAST_TAG --format=%aI | head -1)" \
  --json title,number \
  --jq '.[] | "- \(.title) (#\(.number))"')

# 2. Create release
RELEASE_NOTES="## Changes

$CHANGELOG

## Release Type
$RELEASE_TYPE release"

gh release create "v$VERSION" \
  --title "Release v$VERSION" \
  --notes "$RELEASE_NOTES" \
  -R "$REPO"

echo "✅ Release v$VERSION created!"

# 3. Create follow-up issues if needed
if [ "$RELEASE_TYPE" = "major" ]; then
  gh issue create -R "$REPO" \
    --title "Post-release v$VERSION documentation updates" \
    --body "Update documentation for major release v$VERSION" \
    --label "documentation"
fi
```

### Multi-Repository Sync Script

```bash
#!/bin/bash
# Script: sync-repos.sh
# Synchronize settings and templates across repositories

ORG="my-org"

# Settings to sync
BRANCH_PROTECTION_RULE='{"pattern": "main", "require_pr": true, "require_reviews": 1}'
TOPICS=("maintained" "github-cli")

echo "🔄 Syncing settings across repositories..."

gh repo list "$ORG" -q --json name | while read repo; do
  echo "Processing $ORG/$repo..."

  # Add branch protection
  gh api repos/$ORG/$repo/branches/main/protection \
    -X PUT \
    -f required_status_checks='{"strict": true}' \
    -f required_pull_request_reviews='{"required_approving_review_count": 1}' \
    -f dismiss_stale_reviews=true \
    --silent

  # Set topics
  gh api repos/$ORG/$repo \
    -X PATCH \
    -f topics='["'$(IFS=, ; echo "${TOPICS[*]}")'"]' \
    --silent

  echo "✅ $repo updated"
done

echo "🎉 Sync complete!"
```

---

## Best Practices and Tips for 2025

### Performance and Scalability

1. **Use `--limit` and pagination carefully**
   ```bash
   # Instead of loading all PRs, limit to what you need
   gh pr list -L 50  # Instead of gh pr list (no limit = default 30)
   ```

2. **Leverage `--json` with `--jq` for filtering**
   ```bash
   # Do filtering in jq, not in bash loops
   gh pr list --json state,author,reviews \
     --jq '.[] | select(.state == "OPEN" and (.reviews | length) == 0)'
   ```

3. **Use batch operations for multiple repos**
   ```bash
   # Better: Process all at once
   gh repo list org -q --json name | xargs -I {} gh issue list -R {} --json number

   # Worse: Sequential API calls
   for repo in repos; do gh issue list -R $repo; done
   ```

### Error Handling and Validation

```bash
#!/bin/bash
# Robust script template

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Check authentication
if ! gh auth status >/dev/null 2>&1; then
  echo "Error: Not authenticated with GitHub. Run 'gh auth login'"
  exit 1
fi

# Validate inputs
REPO="${1:?Error: REPO is required}"
PR="${2:?Error: PR is required}"

# Use trap for cleanup
cleanup() {
  echo "Cleaning up..."
}
trap cleanup EXIT

# Try-catch pattern
if ! PR_DATA=$(gh pr view -R "$REPO" "$PR" --json state 2>&1); then
  echo "Error: Failed to fetch PR - $PR_DATA"
  exit 1
fi
```

### Security Considerations

- Use `gh secret set` for sensitive environment variables
- Authenticate with proper scopes: `gh auth login --scopes repo,workflow`
- Be careful with `--json` output containing sensitive data
- Use `gh secret list` to verify configured secrets

---

## Resources and References

- **Official GitHub CLI Manual**: https://cli.github.com/manual/
- **GitHub CLI GitHub Repository**: https://github.com/cli/cli
- **Awesome GitHub CLI Extensions**: https://github.com/kodepandai/awesome-gh-cli-extensions
- **GitHub Blog - Scripting with GitHub CLI**: https://github.blog/engineering/engineering-principles/scripting-with-github-cli/
- **GitHub Copilot CLI Documentation**: https://github.com/github/gh-copilot

---

**Last Updated**: November 2025
**Research Date**: 2025-11-09
