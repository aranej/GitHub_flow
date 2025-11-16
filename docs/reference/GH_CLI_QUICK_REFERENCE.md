# GitHub CLI Quick Reference Guide for 2025

## Installation & Setup

```bash
# Install GitHub CLI
brew install gh              # macOS
sudo apt-get install gh      # Ubuntu/Debian
# Or download from https://cli.github.com

# Authenticate
gh auth login

# Verify installation
gh --version
gh auth status
```

---

## PR Management - One-Liners

### Create and Manage PRs

```bash
# Create PR interactively
gh pr create

# Create PR with all options
gh pr create --title "Fix: auth bug" --body "Closes #123" \
  --draft --head feature-branch

# List PRs by various states
gh pr list                          # Open PRs
gh pr list --state closed -L 20     # Last 20 closed
gh pr list --draft                  # Draft PRs only
gh pr list --search "review-requested:@me"

# Check PR status
gh pr status                        # Your PR activity
gh pr view <number>                 # Details of specific PR
gh pr checks <number> --watch       # Monitor checks in real-time

# Update PR
gh pr edit <number> --add-label "ready" --add-reviewer @john
gh pr edit <number> --body "Updated description"

# Review operations
gh pr review <number> --approve
gh pr review <number> --request-changes -b "Needs changes"
gh pr comment <number> -b "Looks good!"

# Merge PR
gh pr merge <number>                        # Interactive
gh pr merge <number> --squash                # Squash commits
gh pr merge <number> --rebase                # Rebase merge
gh pr merge <number> --squash --auto         # Auto-merge when ready

# Checkout PR branch
gh pr checkout <number>

# Close PR
gh pr close <number> -c "No longer needed"
```

### Advanced PR Queries

```bash
# PRs by author
gh pr list --json author,number,title --search "author:@john"

# PRs lacking reviews
gh pr list --json number,title,reviews \
  --jq '.[] | select(.reviews | length == 0) | "\(.number): \(.title)"'

# PRs with large changes (100+ files)
gh pr list --json number,files \
  --jq '.[] | select((.files | length) > 100)'

# Average review time (days)
gh pr list --state closed -L 50 \
  --json createdAt,mergedAt \
  --jq '[.[] | ((.mergedAt | fromdateiso8601) -
    (.createdAt | fromdateiso8601)) / 86400] |
    add / length | floor'
```

---

## Issue Management - One-Liners

### Create and Track Issues

```bash
# Create issue
gh issue create --title "Bug: login broken" --body "Users can't login"

# List issues
gh issue list                           # Open issues
gh issue list --state closed -L 20      # Last 20 closed
gh issue list --label "bug,critical"    # Specific labels
gh issue list --assignee @me            # Assigned to you

# View issue
gh issue view <number>                  # Full details
gh issue view <number> --web            # Open in browser

# Update issue
gh issue edit <number> --add-label "priority:high"
gh issue edit <number> --add-assignee @john
gh issue edit <number> --body "Updated description"

# Comment on issue
gh issue comment <number> -b "This is a blocker"

# Close/reopen issue
gh issue close <number> -c "Resolved in v2.0"
gh issue reopen <number>
```

### Advanced Issue Queries

```bash
# Unassigned issues
gh issue list --json assignees \
  --jq '.[] | select(.assignees | length == 0)'

# Stale issues (no activity in 30+ days)
gh issue list --search "updated:<$(date -d '30 days ago' +%Y-%m-%d)"

# High priority bugs (critical label, created this month)
gh issue list --label "bug,priority:critical" \
  --search "created:>$(date -d 'start of month' +%Y-%m-%d)"

# Issues by priority
gh issue list --json labels,number,title \
  --jq '.[] | select(.labels | map(.name) | index("priority:critical")) |
    "\(.number): \(.title)"'
```

---

## Workflow & CI/CD - One-Liners

### Manage GitHub Actions

```bash
# List workflows
gh workflow list

# View workflow details
gh workflow view deploy.yml

# Trigger workflow manually (requires workflow_dispatch)
gh workflow run deploy.yml
gh workflow run deploy.yml -f env=prod -f version=v2.0

# List workflow runs
gh run list                         # Recent runs
gh run list --status failure        # Only failures
gh run list --workflow deploy.yml   # Specific workflow

# View run details
gh run view <run_id>
gh run view <run_id> --log          # Full logs
gh run view <run_id> --verbose      # Detailed output

# Monitor runs
gh run watch <run_id>               # Follow in real-time
gh run watch <run_id> --exit-status # Exit with run status

# Retry failed runs
gh run rerun <run_id>
gh run rerun <run_id> --failed      # Rerun only failed jobs

# Cancel runs
gh run cancel <run_id>

# Delete runs
gh run delete <run_id>
```

### Check PR Status

```bash
# Quick check status
gh pr checks <number>

# Watch until complete
gh pr checks <number> --watch

# Only required checks
gh pr checks <number> --required

# Fail fast on first failure
gh pr checks <number> --watch --fail-fast

# Get specific status for scripting
gh pr checks <number> --json name,conclusion \
  --jq '.[] | select(.conclusion == "FAILURE")'
```

---

## Repository Operations

### Manage Repos

```bash
# Create repository
gh repo create my-repo --public
gh repo create my-repo --private --clone

# List repositories
gh repo list                        # Your repos
gh repo list owner                  # Repos by owner
gh repo list org                    # Organization repos

# Clone repository
gh repo clone owner/repo

# View repository info
gh repo view                        # Current repo
gh repo view owner/repo             # Specific repo
gh repo view --web                  # Open in browser

# Edit repository
gh repo edit --visibility public
gh repo edit --enable-issues
gh repo edit --add-topic "github-cli" --add-topic "automation"
```

### Repository Statistics

```bash
# Count stars, watchers, forks
gh api repos/owner/repo --jq \
  '{stars: .stargazers_count, watchers: .watchers_count, forks: .forks_count}'

# List contributors
gh api repos/owner/repo/contributors -L 10 \
  --jq '.[] | "\(.login): \(.contributions) commits"'

# Get commit count
gh api repos/owner/repo/commits -L 1 \
  --jq '.[0].commit.author.date' # Latest commit

# List recent releases
gh release list --limit 10
```

---

## Advanced JSON Querying with jq

### Essential jq Patterns

```bash
# Filter by property
gh pr list --json state,author \
  --jq '.[] | select(.author.login == "john")'

# Count items
gh issue list --json labels \
  --jq '[.[] | .labels | length] | add / length'  # Avg labels per issue

# Group by property
gh pr list --state closed --json author \
  --jq '[.[] | .author.login] | group_by(.) |
    map({author: .[0], count: length}) | sort_by(-.count)[]'

# Transform data
gh run list --json name,conclusion \
  --jq '.[] | {workflow: .name, status: .conclusion}'

# Conditional logic
gh issue list --json number,labels \
  --jq '.[] | if (.labels | length) == 0
    then {issue: .number, status: "unlabeled"}
    else empty end'

# Date calculations
gh pr list --state closed -L 20 \
  --json createdAt,mergedAt \
  --jq '.[] | (.mergedAt | fromdateiso8601) -
    (.createdAt | fromdateiso8601) | . / 86400 | floor'
```

---

## Custom Aliases

### Setup Useful Aliases

```bash
# Quick review
gh alias set review 'pr list --search "review-requested:@me"'

# Draft creation
gh alias set --shell draft 'gh pr create --draft'

# My statistics
gh alias set --shell mystats \
  'echo "Your Stats" &&
   echo "Open PRs: $(gh pr list -q | wc -l)" &&
   echo "Review Requests: $(gh pr list --search "review-requested:@me" -q | wc -l)"'

# Interactive PR checkout
gh alias set --shell co \
  'id="$(gh pr list -q | fzf | cut -f1)";
   [ -n "$id" ] && gh pr checkout "$id"'

# Show PR summary
gh alias set --shell summary \
  'gh api repos/{owner}/{repo}/pulls/$1 |
   jq "{title, author: .user.login, state, comments: .comments}"'
```

---

## GraphQL API Usage

### Using `gh api` for Advanced Queries

```bash
# Get repository information
gh api repos/owner/repo \
  -f query='query($owner:String!, $name:String!) {
    repository(owner: $owner, name: $name) {
      name
      description
      stargazerCount
      forkCount
      issues(first: 10, states: OPEN) {
        nodes {
          number
          title
        }
      }
    }
  }' \
  -f owner=owner \
  -f name=repo

# Search for issues
gh api search/issues -q 'repo:owner/repo is:open label:bug' \
  --jq '.items[] | "\(.number): \(.title)"'

# Get pull request reviews
gh api repos/owner/repo/pulls/123/reviews \
  --jq '.[] | "\(.user.login): \(.state)"'
```

---

## Scripting Patterns

### Common Script Templates

```bash
#!/bin/bash
# Template: Process multiple PRs

REPO="owner/repo"

# Get list of PRs matching criteria
gh pr list -R "$REPO" --state open --json number \
  --jq '.[].number' | while read pr_num; do

  # Get PR details
  pr_data=$(gh pr view -R "$REPO" "$pr_num" --json title,author)

  # Do something with the PR
  echo "Processing PR #$pr_num"

  # Update PR
  gh pr edit -R "$REPO" "$pr_num" --add-label "processed"
done
```

```bash
#!/bin/bash
# Template: Wait for action and react

REPO="owner/repo"
PR=$1

# Wait for all checks to pass
while true; do
  status=$(gh pr checks -R "$REPO" "$PR" --json conclusion \
    --jq 'if all(.conclusion == "SUCCESS") then "PASS" else "PENDING" end')

  [ "$status" = "PASS" ] && break

  sleep 30
done

# React to completion
gh pr comment -R "$REPO" "$PR" -b "✓ Checks passed! Ready to merge."
```

```bash
#!/bin/bash
# Template: Batch operations across repos

ORG="my-org"
LABEL="needs-review"

# Get all repos
gh repo list "$ORG" -q --json name | while read repo; do
  echo "Processing $ORG/$repo"

  # Perform operation on each repo
  gh issue list -R "$ORG/$repo" --state open --label "$LABEL" \
    -q --json number | while read issue; do

    gh issue edit -R "$ORG/$repo" "$issue" --remove-label "$LABEL"
  done
done
```

---

## Performance Tips

### Optimize Your Commands

```bash
# ✓ Good: Limit results early
gh pr list -L 20 --state open

# ✗ Slow: Get all PRs then filter
gh pr list | head -20

# ✓ Good: Use jq to filter
gh pr list --json state,author --jq '.[] | select(.state == "OPEN")'

# ✗ Slow: Use grep/awk
gh pr list | grep OPEN | ...

# ✓ Good: Use --json fields you need
gh pr list --json number,title

# ✗ Slow: Get all fields
gh pr list
```

### Parallel Processing

```bash
#!/bin/bash
# Process PRs in parallel

gh pr list -q --json number | \
  xargs -P 4 -I {} bash -c '
    gh pr checks {} --json conclusion | \
      jq ".[] | select(.conclusion != \"SUCCESS\")" && \
    echo "PR {} needs attention"
  '
```

---

## Security Best Practices

### Secure GitHub CLI Usage

```bash
# 1. Use appropriate authentication scopes
gh auth login --scopes repo,workflow,admin:org_hook

# 2. Store secrets securely
gh secret set MY_TOKEN                  # Interactive
echo "secret" | gh secret set MY_TOKEN  # From stdin

# 3. List your secrets (without values)
gh secret list

# 4. Don't hardcode tokens in scripts
# Use gh auth token for authenticated requests

# 5. Audit your GitHub CLI sessions
gh auth status

# 6. Revoke tokens when no longer needed
gh auth logout

# 7. Use short-lived tokens when possible
gh auth refresh --scopes repo,gist
```

---

## Troubleshooting

### Common Issues

```bash
# Authentication issues
gh auth login                   # Re-authenticate
gh auth status                  # Check status
gh auth logout                  # Clear credentials

# Rate limiting
# GitHub API has rate limits (60 requests/hour for unauthenticated,
# 5000 for authenticated)
# Solution: Authenticate with gh auth login

# Permission errors
# Make sure your token has necessary scopes:
gh auth login --scopes repo,workflow,admin:org_hook

# Timeout issues
# Add --timeout flag
gh pr list --timeout 30s

# JSON parsing issues
# Validate jq syntax
echo '{}' | jq '.your.query'

# Debug mode
GH_DEBUG=api gh pr list          # Show API calls
```

---

## 2025 Advanced Features

### GitHub Copilot CLI Integration

```bash
# Ask Copilot for help
gh copilot

# Explain a command
gh copilot explain "git rebase -i HEAD~5"

# Get suggestions
gh copilot suggest "How do I list my open PRs with Python?"

# Use with extended reasoning (GPT-5 with Copilot Enterprise)
gh copilot --model gpt-5 --extended-reasoning \
  "Plan a database migration strategy for our repo"
```

### Extensions

```bash
# Install extensions
gh extension install dlvhdr/gh-dash    # Dashboard
gh extension install chelnak/gh-changelog  # Changelog

# Use extensions
gh dash                         # Interactive dashboard
gh changelog new                # Create changelog entry

# Browse available extensions
gh extension browse

# Search for extensions
gh extension search dashboard
```

---

## Resources

- **Official Docs**: https://cli.github.com/manual/
- **GitHub Repo**: https://github.com/cli/cli
- **Extensions**: https://github.com/topics/github-cli-extension
- **Blog Posts**: https://github.blog/tag/github-cli/

---

**Last Updated**: November 2025
**Platform**: Linux, macOS, Windows
