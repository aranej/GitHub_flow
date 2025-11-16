# GitHub Projects 2025 - Git Workflow Integration Guide

Complete guide for integrating GitHub Projects into your git workflow, from branch creation through deployment.

## Table of Contents

1. [Workflow Overview](#workflow-overview)
2. [Branch Naming Strategy](#branch-naming-strategy)
3. [Commit Message Conventions](#commit-message-conventions)
4. [Pull Request Workflow](#pull-request-workflow)
5. [Issue-Driven Development](#issue-driven-development)
6. [Release Management](#release-management)
7. [Team Workflows](#team-workflows)
8. [Example Workflows by Team Size](#example-workflows-by-team-size)

---

## Workflow Overview

### Complete Development Cycle

```
Issue Created
    ↓ (auto-add to project)
Project Status: Todo
    ↓
Developer assigned
    ↓
Feature branch created (GH-123-feature)
    ↓
Project Status: In Progress
    ↓
Commits with issue references
    ↓
PR created (Closes #123)
    ↓
Project Status: In Review
    ↓
Code review
    ↓
PR approved
    ↓
PR merged
    ↓
Issue auto-closed
Project Status: Done
    ↓
Auto-archive (30 days later)
Removed from active project
```

### Key Integration Points

| Stage | Git Action | Project Update | Automation |
|-------|-----------|-----------------|------------|
| Planning | Issue created | Auto-add to project | Status: Todo |
| Development | Branch created | Manual assignment | Status: In Progress |
| Development | Commits pushed | Refs in history | Activity shown |
| Review | PR opened | Auto-add to project | Status: In Review |
| Review | PR reviewed | Commits linked | Activity shown |
| Completion | PR merged | Auto-link issue | Issue closed |
| Completion | Issue closed | - | Status: Done |
| Cleanup | Archival | - | Removed from board |

---

## Branch Naming Strategy

### Standard Format

```
type/project-issue-description

Where:
- type: feature, bugfix, hotfix, refactor, docs, chore
- project: Optional project prefix (GH-, PROJ-)
- issue: GitHub issue number
- description: Kebab-case short description
```

### Branch Naming Examples

```
# Feature branch
feature/GH-123-add-authentication
feature/add-oauth-integration
feature/PROJ-456-dashboard-redesign

# Bug fix
bugfix/GH-789-auth-token-expiry
bugfix/fix-memory-leak

# Hotfix (critical production fix)
hotfix/GH-999-security-patch

# Refactoring
refactor/GH-111-simplify-auth-logic
refactor/typescript-migration

# Documentation
docs/GH-222-api-docs
docs/update-readme

# Chore
chore/GH-333-update-dependencies
chore/upgrade-nodejs
```

### Best Practices

**DO:**
- Use issue number when available
- Use lowercase and hyphens
- Keep under 50 characters
- Reference the issue number
- Delete after merge

**DON'T:**
- Use underscores
- Use uppercase letters
- Create branches without issue numbers (for tracked work)
- Leave merged branches around
- Use slashes in description part

### Branch Lifecycle

```
On local machine:
  git checkout -b feature/GH-123-description

After PR merge:
  git branch -d feature/GH-123-description

In GitHub (automated):
  Delete head branch when PR is merged
  (Configure in: Repository Settings → General → Auto-delete head branches)
```

---

## Commit Message Conventions

### Format Specification

```
<type>(<scope>): <subject> (<issue>)

<body>

<footer>
```

### Examples

```
# Simple commit
feat: add JWT authentication

# With issue reference
feat: add JWT authentication (closes #123)

# With scope
feat(auth): implement JWT token validation

# Complex commit
fix(api): handle timeout in auth endpoint (fixes #456)

Implement exponential backoff retry logic
to handle transient network failures.

Before: timeout after 3 seconds
After: retry up to 3 times with exponential backoff

Closes #456
Related-to: #123
Tested on: Chrome 120, Firefox 121
```

### Commit Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat: add user profile page` |
| `fix` | Bug fix | `fix: resolve auth loop` |
| `docs` | Documentation | `docs: update API guide` |
| `style` | Code formatting | `style: fix linter issues` |
| `refactor` | Code refactoring | `refactor: simplify auth service` |
| `perf` | Performance improvement | `perf: optimize query performance` |
| `test` | Test additions | `test: add auth integration tests` |
| `ci` | CI/CD changes | `ci: add GitHub Actions workflow` |
| `chore` | Dependency/tooling | `chore: upgrade Node to 20` |

### Issue Reference Keywords

These keywords automatically close issues when PR is merged:

```
Closes #123      # Single issue
Fixes #456       # Bug fixes
Resolves #789    # General issue
Close #111       # Variations
Fix #222
Resolve #333

# Multiple issues
Closes #123, #456, #789
Fixes #111 and #222

# Related without closing
Related-to #999
Ref #888
```

### Commit Message Template

Create `.gitmessage`:

```
<type>(<scope>): <subject> (<issue>)
#
# Types: feat, fix, docs, style, refactor, perf, test, ci, chore
# Scope: optional component (auth, api, ui, etc)
# Subject: imperative mood, lowercase, no period, max 50 chars
# Issue: GitHub issue number that this closes
#
# <body>
# Explain WHAT and WHY, not HOW
# Wrap at 72 characters
#
# <footer>
# Closes #<issue>
# Related-to: #<issue>
# Breaking-change: <description> (if applicable)
#
```

Configure git to use template:

```bash
git config commit.template ~/.gitmessage
```

---

## Pull Request Workflow

### PR Creation Checklist

**Before creating PR:**

- [ ] Branch created from latest `main`
- [ ] Feature complete and tested locally
- [ ] Code follows project style guide
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] No merge conflicts

**PR template** (`.github/pull_request_template.md`):

```markdown
## Description
Brief description of changes

## Related Issue
Closes #<issue-number>

## Type of Change
- [ ] Bug fix (non-breaking change fixing issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality change)
- [ ] Documentation update
- [ ] Dependency update

## Testing
Describe testing performed:
- [ ] Unit tests added/updated
- [ ] Integration tests passed
- [ ] Manual testing completed
- [ ] E2E tests passed (if applicable)

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests passing locally
- [ ] No breaking changes

## Screenshots (if applicable)
[Add screenshots for UI changes]

## Related PRs
[List any related PRs]

## Deployment Notes
[Any special deployment considerations]
```

### PR Template with Project Integration

**`.github/pull_request_template.md`** (Enhanced):

```markdown
# {{TITLE_PLACEHOLDER}}

## Context & Motivation
**Issue**: [Link to related issue]
**Status**: Ready for review

## Summary
Concise description of what was changed and why.

## Changes Made
- Change 1
- Change 2
- Change 3

## Related Issues
Closes #<issue-number>

## Type of Change
Select type of change:
- [ ] Bug fix
- [ ] New feature
- [ ] Enhancement
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests passed
- [ ] Manual testing completed
- [ ] No regressions found

## Checklist
- [ ] Code follows project style guide
- [ ] Self-review completed
- [ ] Inline comments added for complex logic
- [ ] Documentation updated
- [ ] Tests passing (all green)
- [ ] No new warnings generated
- [ ] No breaking changes to public API

## Reviewer Guidance
**Suggested reviewers**: @username1, @username2

**Focus areas**:
1. Specific area needing attention
2. Performance impact review
3. Security implications

## Deployment Checklist
- [ ] Database migrations (if applicable)
- [ ] Environment variables required
- [ ] Feature flags needed
- [ ] Rollback procedure documented
- [ ] Monitoring alerts configured

---
*This PR will automatically be added to the project board and linked to the related issue.*
```

### PR Review Process

```
1. Author creates PR
   └─ Title includes issue number
   └─ Description includes "Closes #123"
   └─ Related milestone selected

2. PR auto-added to project
   └─ Status: "In Review"
   └─ Appears on project board

3. Reviewers assigned
   └─ CODEOWNERS auto-requested
   └─ Required reviewers notified

4. Review comments
   └─ Build status checked
   └─ Tests must pass
   └─ Code review required

5. Approval & merge
   └─ PR approved
   └─ Branch deleted
   └─ Issue auto-closed
   └─ Project status → "Done"
```

### Handling Review Feedback

```
Review comment on PR
    ↓
Author responds/implements
    ↓
Push new commits (don't rebase yet)
    ↓
Re-request review
    ↓
(Repeat as needed)
    ↓
Approved
    ↓
Squash/rebase if needed
    ↓
Merge PR
```

**Commit Strategy:**
- Don't rebase during review (makes feedback confusing)
- Squash on merge if many tiny commits
- Keep meaningful commit history if commits are logical

---

## Issue-Driven Development

### Creating Issues from Code

**Pattern: Comments for future work**

```javascript
// Issue: #123 - Refactor auth validation
// TODO: Move to separate service
// Priority: High
// Assigned: @username
function validateAuth(token) {
  // Current implementation...
}
```

Then create issue:
```bash
gh issue create \
  --title "Refactor: Move auth validation to service" \
  --body "See comment in auth.js line 42 - TODOs #123" \
  --label refactor
```

### Using TODO Comments

**Best Practice:**

```javascript
// TODO(#123): Improve error handling
function processPayment() {
  try {
    // Current code
  } catch (e) {
    // Temporary solution - See #123
    console.error(e);
  }
}
```

**Converting to Issue:**

```bash
# Find all TODOs
grep -rn "TODO(#" src/

# Create issue with reference
gh issue create \
  --title "Fix: Improve error handling in processPayment" \
  --body "See TODO in payment.js - needs better error handling"
```

### Linking Existing Issues

**After code is done, link the issue:**

```bash
# Via PR description
echo "Closes #123" | gh pr create \
  --title "Implement payment processing" \
  --body -

# Via commit message
git commit -m "feat: add payment processing (closes #123)"
```

---

## Release Management

### Release Workflow

```
Milestone Created (e.g., v2.0.0)
    ↓
Features assigned to milestone
    ↓
Track in project → Group by Milestone
    ↓
As features complete → PRs merged
    ↓
Auto-close issues → "Done" status
    ↓
Weekly release readiness check
    ↓
Beta/RC release
    ↓
Final release
    ↓
Tag pushed (v2.0.0)
    ↓
Archive milestone project
```

### Release Checklist

**`.github/RELEASE_CHECKLIST.md`**:

```markdown
# Release Checklist

## Pre-Release (1 week before)
- [ ] All features in milestone completed
- [ ] All bugs fixed
- [ ] All tests passing
- [ ] Code review complete
- [ ] Documentation updated
- [ ] CHANGELOG.md updated

## Release Preparation (2 days before)
- [ ] No open issues in milestone
- [ ] All PRs merged
- [ ] Build successful
- [ ] Deploy to staging
- [ ] QA sign-off
- [ ] Release notes prepared

## Release Day
- [ ] Code freeze confirmed
- [ ] Final build created
- [ ] Tag created: `v1.2.3`
- [ ] Release notes published
- [ ] Package published
- [ ] Deployment completed
- [ ] Monitoring enabled
- [ ] Status page updated

## Post-Release
- [ ] Monitor error rates
- [ ] Check performance metrics
- [ ] Rollback plan ready
- [ ] Team notified
- [ ] Milestone archived
```

### Release Automation

**Release workflow (`.github/workflows/release.yml`)**:

```yaml
name: Create Release

on:
  push:
    tags:
      - 'v*'

jobs:
  create-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Generate changelog
        id: changelog
        run: |
          # Generate changelog from commits since last tag
          CHANGELOG=$(git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"- %h %s")
          echo "content=$CHANGELOG" >> $GITHUB_OUTPUT

      - name: Create GitHub Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref_name }}
          release_name: Release ${{ github.ref_name }}
          body: ${{ steps.changelog.outputs.content }}
          draft: false
          prerelease: false

      - name: Archive milestone
        uses: actions/github-script@v7
        with:
          script: |
            const version = '${{ github.ref_name }}';
            console.log(`Release created: ${version}`);
            // Archive milestone in project
```

---

## Team Workflows

### Feature Team Workflow

**Multiple teams working on same project:**

```
Shared Backlog (Main project)
    ├─ Team A Project
    │  ├─ Sprint planning from backlog
    │  ├─ Parallel development
    │  └─ Sprint review
    ├─ Team B Project
    │  ├─ Sprint planning from backlog
    │  ├─ Parallel development
    │  └─ Sprint review
    └─ Team C Project
       ├─ Sprint planning from backlog
       ├─ Parallel development
       └─ Sprint review

Main Feature Branch
    ├─ Team A feature branch
    ├─ Team B feature branch
    └─ Team C feature branch

Main PR → Merge features → Release
```

**Implementation:**

```
# Backlog project for planning
Create project "Sprint Backlog"
  - View 1: "Backlog" (all items)
  - View 2: "Team A Sprint" (filtered to team A)
  - View 3: "Team B Sprint" (filtered to team B)

# Feature branch strategy
feature/team-a/GH-123-feature
feature/team-b/GH-456-feature
feature/team-c/GH-789-feature

# Integration process
1. Feature branches maintained separately
2. Regular syncs to main (e.g., weekly)
3. Final integration PR for release
4. Single PR with all features
```

### Cross-functional Workflow

**Example: Feature with Design + Engineering + QA**

```
Issue: "New Dashboard Page"
    ├─ Sub-issue: Design mockups (Design)
    │  └─ Assigned to: @designer
    │  └─ Status: In Progress
    ├─ Sub-issue: Backend API (Backend)
    │  └─ Assigned to: @backend-dev
    │  └─ Status: In Progress
    ├─ Sub-issue: Frontend Implementation (Frontend)
    │  └─ Assigned to: @frontend-dev
    │  └─ Status: Todo (blocked by sub-issues)
    └─ Sub-issue: QA Testing (QA)
       └─ Assigned to: @qa
       └─ Status: Todo (blocked by sub-issues)

Dependencies:
  Design → Backend → Frontend → QA → Done
```

**GitHub Projects Setup:**

```yaml
Views:
  - "Design Tasks" (filter: assignee=designer)
  - "Backend Tasks" (filter: assignee=backend-dev)
  - "Frontend Tasks" (filter: assignee=frontend-dev)
  - "QA Tasks" (filter: assignee=qa)
  - "Timeline" (roadmap with dependencies)

Fields:
  - Team (single-select)
  - Status (standardized across teams)
  - Blocked By (link to blocking issue)
```

---

## Example Workflows by Team Size

### Small Team (5 people)

**Setup**: Single project, simple workflow

```
.github/workflows/
├── auto-add-to-project.yml
├── update-status-on-pr.yml
└── auto-archive.yml

Branches:
├── main
├── develop
├── feature/GH-123-description

Project:
├── Status field: Todo, In Progress, In Review, Done
├── Priority field: Low, Medium, High
└── Single view: Board layout grouped by Status
```

**Process:**
1. Issue created → Added to project
2. Developer picks issue, creates branch
3. Commits with `#123` references
4. PR with "Closes #123"
5. Review & merge
6. Auto-close issue, set status Done

### Medium Team (20 people, 4 squads)

**Setup**: Multiple projects per team + shared backlog

```
.github/workflows/
├── auto-add-to-project.yml
├── update-status-on-pr.yml
├── auto-archive.yml
├── create-sub-issues.yml
└── sync-milestone.yml

Projects:
├── Backlog (shared, all teams)
├── Sprint v2.0 (all teams)
├── Team-A Sprint (4 people)
├── Team-B Sprint (4 people)
├── Team-C Sprint (4 people)
└── Team-D Sprint (4 people)

Branches:
├── main
├── develop
├── feature/team-a/GH-123-description
├── feature/team-b/GH-456-description
└── (per team)

Fields:
├── Status
├── Priority
├── Team
├── Sprint
├── Type (Bug, Feature, Epic)
└── Start Date, Target Date
```

**Process:**
1. Backlog planning (weekly)
2. Sprint planning → issues assigned to team projects
3. Parallel development by teams
4. Daily standup review of team projects
5. Weekly integration
6. Release planning 2 weeks out

### Large Organization (100+ people)

**Setup**: Hierarchical projects + automation

```
.github/workflows/
├── auto-add-to-project.yml
├── update-status-on-pr.yml
├── auto-archive.yml
├── create-sub-issues.yml
├── sync-milestone.yml
├── notify-slack.yml
├── generate-metrics.yml
└── validate-pr.yml

Projects (Hierarchy):
├── Organization Roadmap (strategic)
│  └─ Quarters: Q1, Q2, Q3, Q4
├── Release v3.0 (release track)
│  └─ Teams: Backend, Frontend, DevOps, QA
├── Team-Platform (squads: 8 people)
├── Team-Features (squads: 8 people)
├── Team-Infrastructure (squads: 6 people)
└─ Team-DevOps (squads: 5 people)

Custom Fields:
├── Status (standardized)
├── Priority (standardized)
├── Team/Squad
├── Sprint (1-2 week iterations)
├── Type (Epic, Feature, Bug, etc.)
├── Business Value (points)
├── Complexity (story points)
├── Start Date, Target Date
├── OKR Link (links to quarterly goals)
└── Dependencies
```

**Process:**
1. Quarterly OKR planning
2. Feature roadmap alignment (monthly)
3. Sprint planning (every 2 weeks)
4. Daily standups (team projects)
5. Cross-team syncs (weekly)
6. Metrics review (weekly)
7. Release management (structured)

---

## Automation Examples for Git Workflow

### Auto-link Related Issues

**Problem**: Developers forget to link related issues

**Solution** (`.github/workflows/link-related-issues.yml`):

```yaml
name: Link related issues

on:
  issues:
    types: [opened, edited]

jobs:
  auto-link:
    runs-on: ubuntu-latest
    steps:
      - name: Find and link duplicates
        uses: actions/github-script@v7
        with:
          script: |
            const issue = context.payload.issue;

            // Search for similar issues
            const search = await github.rest.search.issuesAndPullRequests({
              q: `repo:${context.repo.owner}/${context.repo.repo} is:issue "${issue.title.split(' ')[0]}" -number:${issue.number}`,
              per_page: 5
            });

            if (search.data.items.length > 0) {
              const similar = search.data.items.slice(0, 2);
              let comment = '**Potentially related issues:**\n';
              similar.forEach(item => {
                comment += `- ${item.html_url}\n`;
              });

              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: issue.number,
                body: comment
              });
            }
```

### Validate Commit Messages

**Problem**: Inconsistent commit messages

**Solution** (`.github/workflows/validate-commits.yml`):

```yaml
name: Validate commit messages

on:
  pull_request:
    types: [opened, reopened, synchronize]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Validate commits
        uses: actions/github-script@v7
        with:
          script: |
            const commits = context.payload.pull_request.commits;
            const pattern = /^(feat|fix|docs|style|refactor|perf|test|ci|chore)(\(.+\))?: .+ (#\d+)?$/;

            for (let commit of commits) {
              if (!pattern.test(commit.commit.message.split('\n')[0])) {
                core.setFailed(`Invalid commit message: ${commit.commit.message}`);
              }
            }
```

### Auto-assign Based on Files Changed

**Problem**: Wrong team reviews code they're not responsible for

**Solution** (`.github/workflows/auto-assign.yml`):

```yaml
name: Auto-assign reviewers

on:
  pull_request:
    types: [opened]

jobs:
  assign:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Get changed files
        id: files
        uses: actions/github-script@v7
        with:
          script: |
            const files = await github.rest.pulls.listFiles({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.issue.number
            });

            let reviewers = [];
            files.data.forEach(file => {
              if (file.filename.includes('auth')) {
                reviewers.push('auth-team');
              }
              if (file.filename.includes('api')) {
                reviewers.push('backend-team');
              }
              if (file.filename.includes('src')) {
                reviewers.push('frontend-team');
              }
            });

            return [...new Set(reviewers)];

      - name: Assign reviewers
        uses: actions/github-script@v7
        with:
          script: |
            const reviewers = ${{ steps.files.outputs.result }};
            await github.rest.pulls.requestReviewers({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.issue.number,
              reviewers: reviewers
            });
```

---

## Best Practices Summary

### DO:
- [ ] Create issues for tracked work
- [ ] Use issue numbers in branch names
- [ ] Reference issues in commits
- [ ] Use "Closes" keyword in PRs
- [ ] Link related issues
- [ ] Keep branches short-lived (< 1 week)
- [ ] Review PRs same day
- [ ] Squash commits on merge
- [ ] Delete branches after merge
- [ ] Archive completed items

### DON'T:
- [ ] Create PRs without issues
- [ ] Use vague commit messages
- [ ] Leave branches unmerged
- [ ] Ignore project status
- [ ] Merge with failing tests
- [ ] Skip code review
- [ ] Create work outside projects
- [ ] Leave PR feedback unaddressed
- [ ] Force push to main
- [ ] Manually close issues (use automation)

---

## Resources

### Git Workflow Guides
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Git Workflow Best Practices](https://git-flow.readthedocs.io/)
- [Conventional Commits](https://www.conventionalcommits.org/)

### GitHub Documentation
- [GitHub Projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Actions](https://docs.github.com/en/actions)

### Tools
- [Commitlint](https://commitlint.js.org/) - Validate commit messages
- [Husky](https://typicode.github.io/husky/) - Git hooks
- [Semantic Release](https://semantic-release.gitbook.io/) - Automated versioning
