# GitHub CLI Advanced Research & Automation Guide

**Research Date**: November 9, 2025
**Focus**: GitHub CLI (gh) Advanced Usage & Automation for 2025

This comprehensive research package contains everything you need to master GitHub CLI automation, from basic usage to enterprise-scale workflows.

---

## 📚 Contents Overview

### 1. **GH_CLI_ADVANCED_2025.md** (Main Reference)
The most comprehensive document covering all aspects of GitHub CLI:
- PR creation and management automation
- Issue tracking workflows
- CI/CD status checking
- Scripting and automation patterns
- Extensions and plugins
- AI tools integration (GitHub Copilot CLI)
- Advanced aliases
- Real-world automation patterns

**Use this when**: You want deep knowledge about a specific GitHub CLI feature or pattern.

### 2. **GH_CLI_QUICK_REFERENCE.md** (Daily Use Guide)
Quick lookup guide with one-liners and common commands:
- Installation and setup
- PR management one-liners
- Issue management one-liners
- Workflow & CI/CD commands
- Repository operations
- Advanced JSON querying with jq
- Custom aliases
- GraphQL API usage
- Performance tips

**Use this when**: You need to quickly remember a command or syntax.

### 3. **pr-automation-utils.sh** (Reusable Functions)
Production-ready shell functions for PR automation:
- `create-pr-from-issue` - Create PR from issue
- `wait-for-checks` - Wait for checks to pass
- `auto-merge-pr` - Auto-merge when ready
- `list-review-requests` - Find PRs needing review
- `pr-stats` - Get PR statistics
- `close-stale-prs` - Auto-close inactive PRs
- 11 total functions with full error handling

**Use this when**: Building automation scripts; source this file in your scripts.

```bash
source pr-automation-utils.sh
wait-for-checks 123 owner/repo
auto-merge-pr 456 owner/repo squash
```

### 4. **issue-automation-utils.sh** (Issue Management)
Production-ready shell functions for issue automation:
- `auto-triage-issues` - Auto-label by priority
- `issue-digest` - Generate daily digest
- `bulk-assign` - Bulk assign issues
- `issue-health-check` - Monitor issue metrics
- `batch-label` - Batch label operations
- `export-issues` - Export to JSON
- 11 total functions

**Use this when**: Building issue management workflows.

### 5. **workflow-automation-utils.sh** (CI/CD Automation)
Production-ready shell functions for workflow automation:
- `list-workflows` - List all workflows
- `monitor-workflow` - Monitor run with real-time updates
- `trigger-workflow` - Manually trigger with parameters
- `find-failed-runs` - Find failures
- `workflow-stats` - Get statistics
- `retry-failed-workflows` - Auto-retry failures
- 12 total functions

**Use this when**: Building GitHub Actions automation.

### 6. **REAL_WORLD_EXAMPLES.md** (Complete Scripts)
8 complete, production-ready automation scripts:

1. **Auto-Review Pipeline** (`auto-review-pipeline.sh`)
   - Auto-assign reviewers based on file changes
   - Wait for approvals and merge automatically
   - Notify teams of assignments

2. **Daily Standup Report** (`daily-standup-report.sh`)
   - Generate team activity reports
   - Track PR merges, new issues, deployments
   - Include metrics and action items

3. **Release Manager** (`release-manager.sh`)
   - Automated changelog generation
   - Release creation with notes
   - Trigger deployments
   - Track documentation needs

4. **Code Quality Monitor** (`code-quality-monitor.sh`)
   - Enforce quality standards
   - Check file counts, approvals, test coverage
   - Add quality alerts to PRs

5. **Organization Sync** (`org-sync-repos.sh`)
   - Keep settings consistent across repos
   - Enforce branch protection
   - Sync topics and security settings

6. **Dependency Management** (`manage-dependencies.sh`)
   - Track dependency updates
   - Auto-merge safe updates
   - Flag high-risk updates

7. **Team Metrics** (`team-metrics.sh`)
   - Generate productivity metrics
   - Track PRs merged, issues closed
   - Calculate average review times

8. **Security Checker** (`security-check.sh`)
   - Enforce security policies
   - Flag sensitive file changes
   - Require security reviews

**Use this when**: You need a complete, tested automation solution.

---

## 🚀 Quick Start

### Installation

```bash
# 1. Install GitHub CLI
brew install gh  # macOS
sudo apt-get install gh  # Ubuntu/Debian

# 2. Authenticate
gh auth login

# 3. Verify
gh auth status
```

### Your First Automation

```bash
# Clone this research directory
cd ~/github-automation

# Load utilities
source pr-automation-utils.sh

# Create a PR and wait for checks
gh pr create --title "New feature" --body "Does cool stuff"
wait-for-checks 1 owner/repo
```

### Common Tasks

**Create a Draft PR with template**:
```bash
source pr-automation-utils.sh
create-pr-from-template owner/repo "feat: New feature"
```

**Auto-triage all issues**:
```bash
source issue-automation-utils.sh
auto-triage-issues owner/repo
```

**Generate daily report**:
```bash
./scripts/daily-standup-report.sh owner/repo
```

---

## 📊 Feature Matrix

| Feature | Easy (Ref) | Functions | Complete Script | AI |
|---------|-----------|-----------|-----------------|-----|
| PR Creation | ✓ | ✓ | ✓ | - |
| PR Review | ✓ | ✓ | ✓ | ✓ |
| PR Merging | ✓ | ✓ | ✓ | - |
| Issue Tracking | ✓ | ✓ | ✓ | ✓ |
| Workflow Management | ✓ | ✓ | - | - |
| Release Management | - | - | ✓ | - |
| Team Metrics | - | ✓ | ✓ | - |
| Automation | ✓ | ✓ | ✓ | ✓ |

Legend:
- **Easy (Ref)**: Commands in quick reference guide
- **Functions**: Reusable shell functions in utility files
- **Complete Script**: Full production script example
- **AI**: GitHub Copilot CLI integration

---

## 2025 Highlights

### New Features This Year

1. **GitHub Copilot CLI (Public Preview - October 2025)**
   - Replaces deprecated `gh-copilot` extension
   - Agentic capabilities for complex tasks
   - Model selection (GPT-4o, GPT-5 with extended reasoning)
   - MCP server integration for custom context

2. **Enhanced JSON Output**
   - Better jq filtering support
   - Improved schema documentation
   - GraphQL API improvements

3. **Workflow Improvements**
   - Better run monitoring with `gh run watch`
   - Enhanced scheduling support
   - Improved error reporting

4. **Popular Extensions**
   - **gh-dash**: Interactive dashboard TUI
   - **gh-changelog**: Changelog generation
   - **gh-promote**: Issue to PR conversion
   - **gh-prs**: Enhanced PR management

---

## 📖 Learning Path

### Beginner
1. Read: GH_CLI_QUICK_REFERENCE.md (first 3 sections)
2. Try: Basic commands from quick reference
3. Do: Create a simple PR with `gh pr create`

### Intermediate
1. Read: GH_CLI_ADVANCED_2025.md (Sections 1-3)
2. Load: Source one of the utility files
3. Try: Use a reusable function like `wait-for-checks`

### Advanced
1. Read: REAL_WORLD_EXAMPLES.md
2. Adapt: Modify a complete script for your needs
3. Deploy: Schedule scripts with cron or GitHub Actions
4. Integrate: Add GitHub Copilot CLI to your workflow

---

## 🛠️ Common Patterns

### Pattern 1: Wait for PR to be ready, then merge

```bash
source pr-automation-utils.sh
wait-for-checks 123 owner/repo && auto-merge-pr 123 owner/repo squash
```

### Pattern 2: Daily operations

```bash
#!/bin/bash
# Run multiple checks daily
source issue-automation-utils.sh
source pr-automation-utils.sh

auto-triage-issues owner/repo
list-review-requests owner/repo
issue-digest owner/repo
```

### Pattern 3: Release workflow

```bash
source workflow-automation-utils.sh
trigger-workflow release.yml owner/repo main version=1.2.0
monitor-workflow release.yml owner/repo
```

### Pattern 4: Bulk operations

```bash
# Label all critical bugs
source issue-automation-utils.sh
batch-label owner/repo "is:open label:bug" priority:critical

# Close stale PRs
source pr-automation-utils.sh
close-stale-prs 30 owner/repo
```

---

## 🔑 Key Takeaways

### Top 10 Most Useful Commands

1. `gh pr create` - Create PR
2. `gh pr list --json` - Query PRs
3. `gh pr checks <num> --watch` - Monitor PR
4. `gh issue list --json` - Query issues
5. `gh workflow run` - Trigger workflow
6. `gh run watch` - Monitor workflow
7. `gh api` - Raw GraphQL/REST API access
8. `gh alias set` - Create custom commands
9. `gh extension install` - Install extensions
10. `gh auth status` - Check authentication

### Best Practices

1. **Always use `--json` for scripting** - Better than parsing text output
2. **Learn jq basics** - Enables powerful filtering
3. **Use aliases for repetitive tasks** - Save time and reduce errors
4. **Handle errors gracefully** - Always check return codes
5. **Cache API responses** - Minimize API calls and rate limits
6. **Test on small datasets first** - Before running on large repos
7. **Use dry-run modes** - Test scripts before executing
8. **Monitor token expiration** - Rotate credentials regularly
9. **Document your scripts** - Future you will thank you
10. **Keep scripts version controlled** - Track changes over time

---

## 🔗 External Resources

- **Official GitHub CLI Manual**: https://cli.github.com/manual/
- **GitHub CLI Repository**: https://github.com/cli/cli
- **Extensions Repository**: https://github.com/topics/github-cli-extension
- **GitHub Blog (GitHub CLI posts)**: https://github.blog/tag/github-cli/
- **Go-GH Library**: https://github.com/cli/go-gh (for extension development)

---

## 📝 Documentation Structure

```
/home/user/GitHub_flow/
├── README_RESEARCH.md                    # This file - navigation guide
├── GH_CLI_ADVANCED_2025.md               # Comprehensive reference (26KB)
├── GH_CLI_QUICK_REFERENCE.md             # Quick lookup guide (15KB)
├── REAL_WORLD_EXAMPLES.md                # Complete automation scripts (20KB)
│
├── pr-automation-utils.sh                # PR functions (6KB)
├── issue-automation-utils.sh             # Issue functions (7KB)
├── workflow-automation-utils.sh          # Workflow functions (8KB)
│
└── scripts/                              # (Not in repo, for your use)
    ├── auto-review-pipeline.sh
    ├── daily-standup-report.sh
    ├── release-manager.sh
    ├── code-quality-monitor.sh
    ├── org-sync-repos.sh
    ├── manage-dependencies.sh
    ├── team-metrics.sh
    └── security-check.sh
```

---

## 🎯 Recommended Reading Order

For different roles and use cases:

### Software Developer
1. GH_CLI_QUICK_REFERENCE.md (sections: PR Management, Issue Management)
2. pr-automation-utils.sh
3. REAL_WORLD_EXAMPLES.md (Auto-Review Pipeline)

### DevOps/Platform Engineer
1. GH_CLI_ADVANCED_2025.md (CI/CD Status Checking, Extensions)
2. workflow-automation-utils.sh
3. REAL_WORLD_EXAMPLES.md (Release Manager, Org Sync)

### Engineering Manager/Lead
1. GH_CLI_ADVANCED_2025.md (Overview)
2. GH_CLI_QUICK_REFERENCE.md (entire document)
3. REAL_WORLD_EXAMPLES.md (Team Metrics, Daily Standup)

### Security/Compliance Officer
1. GH_CLI_ADVANCED_2025.md (Extensions, API Access)
2. REAL_WORLD_EXAMPLES.md (Security Checker)
3. GH_CLI_QUICK_REFERENCE.md (GraphQL API section)

### Enterprise Architect
1. GH_CLI_ADVANCED_2025.md (entire document)
2. REAL_WORLD_EXAMPLES.md (entire document)
3. GH_CLI_QUICK_REFERENCE.md (for reference)

---

## 🚨 Important Notes

### API Rate Limits
- Unauthenticated: 60 requests/hour
- Authenticated: 5,000 requests/hour
- Solution: Always use `gh auth login`

### Deprecations to Be Aware Of
- `gh-copilot` extension: **Deprecated September 2025, disabled October 25, 2025**
- Use: New `gh copilot` commands in GitHub Copilot CLI instead

### Compatibility
- Minimum gh version: 2.0+
- Recommended: 2.20.0+ (for new features like `gh extension browse`)
- Latest stable: 3.x+

### Token Management
- Store tokens securely (use system keychain)
- Use minimal required scopes
- Rotate regularly
- Never commit tokens to version control

---

## 💡 Pro Tips

1. **Use `--dry-run` flags** in your scripts before real operations
2. **Chain commands with `&&`** for dependent operations
3. **Use `gh api --paginate`** to get all results
4. **Leverage aliases** for personal productivity
5. **Create wrapper scripts** for complex multi-step operations
6. **Version your scripts** in git
7. **Use `GH_DEBUG=api`** for troubleshooting
8. **Test on sample data** before running on production repos
9. **Monitor GitHub Status** for API issues: https://www.githubstatus.com/
10. **Join GitHub CLI discussions**: https://github.com/cli/cli/discussions

---

## ❓ FAQ

**Q: Can I use GitHub CLI in GitHub Actions?**
A: Yes! It comes pre-installed in GitHub Actions runners. Set `GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` in your workflow.

**Q: How do I handle errors in bash scripts?**
A: Use `set -euo pipefail` at the top and check return codes with `if ! command; then`.

**Q: Is GitHub CLI production-ready?**
A: Yes! It's actively maintained and used by many enterprises.

**Q: Can I use GitHub CLI with GitHub Enterprise?**
A: Yes, with `gh auth login --hostname your-ghe-host.com`.

**Q: How do I extend GitHub CLI?**
A: Create a script starting with `gh-` prefix and it auto-registers as a command.

---

## 🤝 Contributing & Improvements

These documents are based on 2025 research. To stay current:

1. Check official documentation: https://cli.github.com/manual/
2. Follow GitHub Blog: https://github.blog/tag/github-cli/
3. Monitor GitHub CLI releases: https://github.com/cli/cli/releases
4. Join discussions: https://github.com/cli/cli/discussions

---

## 📄 License & Attribution

This research compilation was created November 2025 using:
- Official GitHub CLI documentation
- GitHub Blog articles and announcements
- Community examples and best practices
- Real-world automation patterns

All code examples are provided as-is for educational and practical use.

---

**Last Updated**: November 9, 2025
**Status**: Complete Research Package
**Files**: 6 documents + this index
**Total Content**: ~80KB of guides, scripts, and examples
