# GitHub Projects 2025 - Quick Reference Card

## Key Concepts

### Project Boards
- **Purpose**: Organize and track issues/PRs in a project
- **Layouts**: Table (spreadsheet), Board (kanban), Roadmap (timeline)
- **Max Items**: 50,000 per project (2025 update)
- **Views**: Create multiple views for different purposes

### Custom Fields
```
Status      → Todo, In Progress, In Review, Done
Priority    → Low, Medium, High, Critical
Type        → Bug, Feature, Epic, Enhancement
Assignee    → Team member assignment
Dates       → Start Date, Target Date
Complexity  → Story points or effort estimate
Iteration   → Sprint/week assignment
Repository  → Which repository
Milestone   → Release version
```

### Built-in Automations
```
Item Added              → Status: Todo
PR Opened              → Auto-add to project
Issue Closed           → Status: Done
PR Merged              → Auto-close linked issue
Status = Done + 30 days → Auto-archive
```

## Branch Strategy

### Format
```
type/issue-description

Examples:
feature/GH-123-add-oauth
bugfix/GH-456-fix-memory-leak
hotfix/GH-789-security-patch
docs/GH-111-api-guide
```

### Types
- **feature**: New functionality
- **bugfix**: Bug fixes
- **hotfix**: Critical production fixes
- **refactor**: Code refactoring
- **docs**: Documentation
- **chore**: Dependencies, tooling
- **test**: Tests

## Commit Conventions

### Format
```
type(scope): message (issue)

feat(auth): add JWT tokens (closes #123)
fix(api): handle timeout errors
docs: update README
```

### Issue Keywords
```
Closes #123       → Close issue on merge
Fixes #456        → Bug fix keyword
Resolves #789     → General resolution
Related-to #999   → Related without closing
```

## GitHub Actions Workflow

### Auto-add Items
```yaml
uses: actions/add-to-project@v0
with:
  project-url: https://github.com/orgs/ORG/projects/1
  github-token: ${{ secrets.PROJECT_TOKEN }}
```

### Set Custom Fields
```yaml
uses: actions/github-script@v7
with:
  script: |
    const mutation = `mutation { ... }`;
    await github.graphql(mutation);
```

## Roadmap Configuration

### Timeline Views
```
Zoom Levels:    1 month, 3 months, 6 months, 1 year
Date Fields:    Start Date, Target Date
Milestones:     Version markers (v1.0, v2.0, etc)
Grouping:       Status, Priority, Team, Custom Fields
```

## Project Setup Phases

| Phase | Duration | Tasks |
|-------|----------|-------|
| 1 | Week 1 | Assess, plan, align stakeholders |
| 2 | Week 2 | Setup org, repos, access |
| 3 | Week 3 | Configure fields, views, workflows |
| 4 | Week 4 | Deploy automation, test |
| 5 | Week 5 | Train team, setup support |
| 6 | Weeks 6-8 | Pilot, monitor, iterate |
| 7 | Weeks 9-12 | Rollout, governance |
| 8 | Month 4+ | Optimize, scale |

## Key Metrics to Track

### Adoption
```
% Teams using Projects
% Repositories with workflows
Active users per month
Issues in projects
```

### Efficiency
```
Cycle time: Issue creation → completion
Time saved on meetings
Automation coverage (% auto-managed)
PR review turnaround
```

### Quality
```
Issues resolved per sprint
PR approval rate
Time to release
Sprint velocity
```

## Common Workflows

### Small Team (5 people)
```
1 Project with status field
Daily standup using Board view
Auto-add and auto-archive enabled
Simple 4-status workflow
```

### Medium Team (20 people)
```
Shared backlog + team projects
Multiple views (Board, Table, Roadmap)
Custom fields for type, priority
Weekly release planning
```

### Large Org (100+ people)
```
Hierarchical projects
Strategic (roadmap) + Tactical (sprints)
Advanced automation
Metrics dashboards
```

## Automation Best Practices

### What to Automate ✓
- Add items when created
- Update status on PR events
- Archive old completed items
- Link closing keywords
- Notify on blockers

### Avoid Over-automation ✗
- Auto-assign randomly
- Auto-change priorities
- Auto-close without verification
- Create unnecessary sub-issues
- Auto-move on labels only

## Troubleshooting Quick Fixes

| Issue | Solution |
|-------|----------|
| Item not in project | Check auto-add workflow, re-run manually |
| Custom field not updating | Verify field ID, check token permissions |
| Slow/laggy project | Archive old items, split projects |
| Automation not running | Check workflow logs, verify token |
| Low adoption | Make mandatory for PRs, show ROI |
| Stale issues | Auto-archive enabled, cleanup schedule |

## Essential Links

| Resource | URL |
|----------|-----|
| GitHub Projects Docs | https://docs.github.com/issues/planning-and-tracking-with-projects |
| GitHub Actions | https://docs.github.com/actions |
| GraphQL API | https://docs.github.com/graphql |
| GitHub CLI | https://cli.github.com |
| Conventional Commits | https://www.conventionalcommits.org |

## PR Template with Project Linking

```markdown
## Description
Brief description of changes

## Related Issue
Closes #<issue-number>

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Enhancement

## Testing
- [ ] Tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows guidelines
- [ ] Tests passing
- [ ] Documentation updated
```

## Quick Setup Commands

```bash
# Create GitHub App
# Settings → Developer settings → GitHub Apps → New

# Create Personal Access Token
# Settings → Developer settings → Personal access tokens

# Add to repository secret
gh secret set PROJECT_TOKEN --body "YOUR_TOKEN"

# Get project ID
gh api graphql -f query='
  query {
    organization(login: "ORG") {
      projectV2(number: 1) { id }
    }
  }
'

# Create branch and PR
git checkout -b feature/GH-123-description
# ... make changes ...
git commit -m "feat: description (closes #123)"
gh pr create --fill
```

## Email/Slack Notification Keywords

### Use these in PR descriptions to get notifications:
```
@mentions trigger notifications
Related-to #issue_number
Closes #issue_number
Fixes #issue_number
Resolves #issue_number
```

## Status Workflow Pattern

```
Todo
  ↓ (assign, add to sprint)
In Progress
  ↓ (create PR)
In Review
  ↓ (PR approved)
Done
  ↓ (PR merged, issue closed)
Archived (after 30 days)
```

## Estimation Guide

### For Team Size Adoption

| Team Size | Setup Time | Training Time | Full Adoption |
|-----------|-----------|--------------|--------------|
| 5 people | 1 week | 2 hours | 2 weeks |
| 20 people | 3 weeks | 8 hours | 4-6 weeks |
| 100+ people | 6-8 weeks | 20+ hours | 8-12 weeks |

## Field Definition Best Practices

### Status (Required)
```
Todo         → Not started, waiting
In Progress  → Assigned, actively worked on
In Review    → Code review in progress
Done         → Merged/closed, complete
Blocked      → Can't proceed (optional)
```

### Priority (Recommended)
```
Low         → Can wait
Medium      → Important
High        → Urgent
Critical    → Blocker/showstopper
```

### Type (Recommended for larger teams)
```
Bug         → Defect
Feature     → New capability
Enhancement → Improvement
Epic        → Large feature set
Task        → Administrative work
Docs        → Documentation
```

## Milestones Strategy

### Release-based
```
v1.0, v1.1, v2.0
Month-based: Dec-2024, Jan-2025, Feb-2025
Quarter-based: Q1-2025, Q2-2025, Q3-2025
```

## Sub-issues Pattern

```
Epic: "Build Authentication System"
├── Sub-issue: "Design auth flow"
├── Sub-issue: "Implement JWT"
├── Sub-issue: "Add password reset"
├── Sub-issue: "Write tests"
└── Sub-issue: "Update docs"

Benefits:
- Parallel development
- Better progress tracking
- Smaller PRs
```

## 2025 Feature Highlights

- ✓ Sub-issues with nesting
- ✓ Issue types for classification
- ✓ Advanced search (AND/OR/parentheses)
- ✓ 50,000 item limit per project
- ✓ Project Insights for all plans
- ✓ GitHub MCP Server integration
- ✓ AI-powered automation
- ✓ Improved onboarding flow

## Pro Tips

1. **Use milestones for releases**, not arbitrary groupings
2. **Keep custom fields under 8** for clarity
3. **Auto-add all items** to avoid missing work
4. **Archive items** to keep projects performant
5. **Create views per role**: Board for managers, Table for devs, Roadmap for leadership
6. **Use closing keywords** in every PR
7. **Schedule weekly reviews** of stale items
8. **Link related issues** before starting work
9. **Document your workflows** in team wiki
10. **Measure adoption** with metrics dashboard

---

**Print this card and post it at your desk or team area!**

Last Updated: November 2025 | Version 1.0
