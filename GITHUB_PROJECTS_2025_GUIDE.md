# GitHub Projects 2025 Integration Guide

## Table of Contents

1. [Overview](#overview)
2. [Project Boards Automation](#project-boards-automation)
3. [Issue and PR Linking](#issue-and-pr-linking)
4. [Milestone Tracking](#milestone-tracking)
5. [Roadmap Visualization](#roadmap-visualization)
6. [Git Workflow Integration](#git-workflow-integration)
7. [Automation Scripts](#automation-scripts)
8. [Setup Guides](#setup-guides)
9. [Best Practices](#best-practices)

---

## Overview

GitHub Projects (2025 version) is a fully integrated project management solution that brings planning, tracking, and automation directly into your GitHub workflow. As of April 2025, GitHub introduced significant enhancements including:

- **Sub-issues**: Nested structure for better work breakdown
- **Issue Types**: Standardized classification system (Bug, Feature, Epic, etc.)
- **Advanced Search**: Complex filtering with AND, OR, and nested operators
- **Increased Item Limits**: Support for up to 50,000 items per project (up from 1,200)
- **Enhanced Onboarding**: Improved setup flow with import capabilities
- **Project Insights**: Removed paid gating - now available to all plans

### Key Statistics (2025)
- 230+ repositories created per minute on GitHub
- 986 million commits pushed annually
- Teams shipping smaller, more frequent pull requests
- Feature flags and CI/CD automation are standard practices

---

## Project Boards Automation

### Built-in Workflows

GitHub Projects includes default workflows that update items automatically:

#### 1. Default Status Workflows (Auto-enabled)
```
• Pull request opened → Status: "In Progress"
• Pull request merged → Status: "Done"
• Issue closed → Status: "Done"
• Item added to project → Status: "Todo"
```

#### 2. Auto-archival Rules
You can configure workflows to automatically archive items when they meet criteria:
- Items marked "Done" for X days
- Pull requests merged for X days
- Closed issues for X days

#### 3. Auto-add Items
Configure workflows to automatically add items from repositories:
```yaml
- Add all open issues
- Add specific pull requests
- Add items with specific labels
- Add items matching filters (AND/OR/NOT operators)
```

### Workflow Configuration

Access automation through: **Project Settings → Automation**

Key options:
- **Add items from a repository**: Set filter criteria and repository
- **Auto-archive items**: Define archival conditions
- **Auto-update status**: Map events to status values
- **Default workflows**: Pull request linked to issue status management

### Limitations & Considerations
- Free accounts: 1 auto-add workflow per project
- Pro/Team accounts: 5 auto-add workflows per project
- Enterprise accounts: 20 auto-add workflows per project

---

## Issue and PR Linking

### Linking Mechanisms

#### 1. Closing Keywords (Automatic Linking)
Use in PR descriptions or commit messages:
```
Closes #123
Fixes #456
Resolves #789
```

These automatically:
- Link the PR to the issue
- Update the issue status when PR merges
- Create audit trail in issue activity

#### 2. Linked Issues Section

**In Issues:**
```
Use the "Linked issues" section to manually link related issues
• Blocks / is blocked by
• Duplicates / is duplicated by
• Related to
```

**In Pull Requests:**
```
Use the "Linked issues" section to:
• Link PR to multiple issues
• Auto-populate closing keywords
• Show issue context to reviewers
```

#### 3. Projects Integration

Issues and PRs automatically appear in linked Projects:
- PR status reflects in project status field
- Issue status updates when linked PR status changes
- Linked items show relationship in project view

### Relationship Types

| Relationship | Use Case |
|-------------|----------|
| Closes | PR directly resolves the issue |
| Blocks | Issue prevents other work |
| Duplicates | Issue is duplicate of another |
| Related to | Issues are contextually related |

### Benefits of Linking

- **For Reviewers**: See issue context without switching views
- **For Project Managers**: Track issue resolution progress
- **For Developers**: Understand work dependencies
- **For Organization**: Create audit trail of changes

---

## Milestone Tracking

### Milestone Basics

**Definition**: Milestones group issues and PRs into release goals

**Creating Milestones**:
```
Repository → Issues → Milestones → New milestone
```

**Key Fields**:
- Title (e.g., "v1.2.0", "Q4 2025 Release")
- Due date
- Description
- Associated issues/PRs

### Milestone Progress Tracking

### Viewing Progress

1. **Milestone Dashboard**
   - View all milestones with progress bars
   - See completion percentage
   - Filter by open/closed

2. **Individual Milestone Page**
   - List of associated issues/PRs
   - Open vs. closed counts
   - Due date indicator
   - Time estimates

3. **Custom Metrics**
   - Use project fields to track points/complexity
   - Sum custom fields for workload analysis
   - Track velocity across milestones

### GitHub Projects + Milestones Integration

In your project, you can:

1. **Add Milestone as Custom Field**
   ```
   Project Settings → Fields → Add field "Milestone"
   Type: Single select with milestone names
   ```

2. **Group by Milestone**
   ```
   View options → Group by → Milestone
   ```

3. **Filter by Milestone**
   ```
   Use advanced search: milestone:"v1.2.0"
   ```

### Milestone Naming Convention (Best Practice)

```
• Semantic versioning: v1.0.0, v1.1.0, v2.0.0
• Time-based: Q1-2025, Sprint-05, Month-Nov
• Feature-based: Auth-System, API-Redesign, Mobile-App
• Hybrid: v2.0-Q4-2025, Release-Auth-System
```

---

## Roadmap Visualization

### Roadmap Layout Overview

The roadmap provides a timeline visualization of your project, showing:
- Items across a configurable timespan
- Start dates and target dates
- Iterations and milestones
- Work distribution over time
- Dependencies and blocking relationships

### Roadmap Features

#### 1. Timeline View
```
Zoom levels:
• 1 month view (detailed planning)
• 3 months view (quarterly planning)
• 6 months view (half-year planning)
• 1 year view (strategic planning)

Drag items to update start/target dates
Visual timeline makes dependencies obvious
```

#### 2. Vertical Markers
Display key dates on the roadmap:
- **Iterations**: Sprint boundaries, weekly releases
- **Milestones**: Major release dates
- **Key Dates**: Important internal deadlines
- **Custom Dates**: Any date field from custom fields

#### 3. Grouping Options
Organize roadmap by:
- **Status**: See work in each stage
- **Priority**: Focus on high-impact items
- **Repository**: Separate work by codebase
- **Assignee**: View team workload
- **Custom Fields**: Organize by business logic

#### 4. Filtering on Roadmap
```
Filter by:
• Labels
• Status
• Assignee
• Repository
• Milestone
• Custom fields
• Date ranges
```

### Setting Up Roadmap View

```yaml
Step 1: Create date fields
  - "Start Date" (date field)
  - "Target Date" (date field)
  - "Quarter" (iteration field)

Step 2: Configure roadmap layout
  - View → Add view → Roadmap
  - Set date fields for positioning
  - Add vertical markers for key dates

Step 3: Organize content
  - Group by Status/Priority/Team
  - Filter to relevant items
  - Adjust zoom level
  - Save view configuration
```

### Roadmap Best Practices

1. **Use Consistent Date Formats**
   - Always populate start and target dates
   - Use meaningful milestone markers
   - Update dates as priorities change

2. **Time-bound Milestones**
   - Quarterly milestones for strategic visibility
   - Monthly/weekly for execution
   - Include buffer time (10-20%)

3. **Realistic Timeline Estimation**
   - Factor in dependencies
   - Account for team velocity
   - Include review/testing time
   - Plan for unexpected issues

4. **Regular Updates**
   - Review roadmap weekly
   - Update dates based on progress
   - Mark completed items
   - Communicate changes

---

## Git Workflow Integration

### GitHub Projects in Development Workflow

GitHub Projects integrates seamlessly with git operations:

#### 1. Issue Creation from Git Context

```bash
# Create issue from command line with gh CLI
gh issue create --title "Fix: auth bug" --body "Details..."

# Issues automatically appear in linked projects
```

#### 2. Branch Naming Strategy

Link branches to issues/projects:

```bash
# Format: feature/issue-123-description
git checkout -b feature/GH-123-add-auth

# When PR is created, linking is automatic with closing keywords
```

#### 3. Commit Message Convention

Include issue references in commits:

```
feat: add JWT authentication (closes #123)

- Implement JWT token generation
- Add token validation middleware
- Update tests for auth flow

Closes: #123
Related-to: #456
```

#### 4. Pull Request Workflow

```yaml
1. Create PR with closing keyword:
   "Closes #123"

2. Project status auto-updates:
   - Issue status → "In Progress"
   - PR appears in project

3. Code review in PR:
   - Reviewers see linked issue context
   - Status updates during review

4. Merge PR:
   - Issue auto-closed
   - Project status → "Done"
   - All automated workflows trigger
```

### Workflow Stages in Projects

```
Typical Development Flow:

Todo
  ↓
In Progress (PR created)
  ↓
In Review (PR review requested)
  ↓
Done (PR merged, issue closed)
  ↓
Archived (older items)
```

### Integration Points

| Git Operation | Project Action |
|---------------|-----------------|
| Branch creation | Link to issue via branch name |
| Commit message | Reference issue via #123 |
| PR creation | Auto-add to project, update status |
| PR ready for review | Update status field |
| PR merged | Close issue, set status "Done" |
| Issue closed | Archive or mark complete |

---

## Automation Scripts

### 1. Using GitHub Actions (Official Approach)

#### Setup Requirements

```yaml
# Authentication options:
# 1. GitHub App (recommended for org projects)
# 2. Personal Access Token (PAT) - for user projects
# 3. GITHUB_TOKEN - repo-level only (limited)
```

**Create GitHub App:**
- Settings → Developer settings → GitHub Apps → New
- Give permissions: Issues, Pull requests, Projects
- Generate private key for authentication

**or Create Personal Access Token:**
- Settings → Developer settings → Personal access tokens
- Scope: `repo`, `project`, `read:org`

#### Basic Auto-add Workflow

```yaml
# .github/workflows/auto-add-to-project.yml
name: Add issue to project

on:
  issues:
    types:
      - opened
      - reopened
  pull_request:
    types:
      - opened

jobs:
  add-to-project:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/add-to-project@v0
        with:
          project-url: https://github.com/orgs/YOUR-ORG/projects/PROJECT-NUMBER
          github-token: ${{ secrets.GH_APP_TOKEN }}
          labeled: enhancement,bug
          label-operator: OR
```

#### Add with Custom Fields Workflow

```yaml
# .github/workflows/add-with-fields.yml
name: Add PR to project with fields

on:
  pull_request:
    types:
      - ready_for_review

jobs:
  add-to-project:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/add-to-project@v0
        with:
          project-url: https://github.com/orgs/YOUR-ORG/projects/1
          github-token: ${{ secrets.GH_APP_TOKEN }}
          # Only add PRs marked as ready for review

      - name: Set custom fields via GraphQL
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GH_APP_TOKEN }}
          script: |
            const query = `
              mutation($projectId:ID!, $itemId:ID!) {
                updateProjectV2ItemFieldValue(input: {
                  projectId: $projectId
                  itemId: $itemId
                  fieldId: "FIELD_ID"
                  value: { singleSelectOptionId: "OPTION_ID" }
                }) {
                  clientMutationId
                }
              }
            `;
            await github.graphql(query, {
              projectId: "PROJECT_ID",
              itemId: "ITEM_ID"
            });
```

### 2. GraphQL API Automation

#### Get Project Details

```graphql
{
  organization(login: "YOUR-ORG") {
    projectV2(number: 1) {
      id
      title
      fields(first: 20) {
        nodes {
          ... on ProjectV2Field {
            id
            name
          }
          ... on ProjectV2SingleSelectField {
            id
            name
            options {
              id
              name
            }
          }
        }
      }
    }
  }
}
```

#### Add Item to Project

```graphql
mutation {
  addProjectV2ItemById(
    input: {
      projectId: "PROJECT_ID"
      contentId: "ISSUE_OR_PR_ID"
    }
  ) {
    item {
      id
    }
  }
}
```

#### Update Custom Field

```graphql
mutation {
  updateProjectV2ItemFieldValue(
    input: {
      projectId: "PROJECT_ID"
      itemId: "ITEM_ID"
      fieldId: "FIELD_ID"
      value: {
        singleSelectOptionId: "OPTION_ID"
      }
    }
  ) {
    clientMutationId
  }
}
```

### 3. Marketplace Automation Actions

#### GitHub Project Automation+

```yaml
name: Advanced project automation

on:
  issues:
    types: [opened, edited, labeled]

jobs:
  automate:
    runs-on: ubuntu-latest
    steps:
      - uses: monalabs/github-project-automation-plus@v1.0.0
        with:
          project-url: https://github.com/orgs/YOUR-ORG/projects/1
          github-token: ${{ secrets.GITHUB_TOKEN }}
          # Additional features:
          # - Auto-assign based on labels
          # - Auto-update based on milestones
          # - Auto-move based on status changes
```

### 4. Sub-issue Templating with Automation

```yaml
name: Create sub-issues from template

on:
  issues:
    types: [labeled]

jobs:
  create-sub-issues:
    if: contains(github.event.issue.labels.*.name, 'epic')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            const issue = context.payload.issue;
            const subTasks = [
              "Design phase",
              "Implementation",
              "Testing",
              "Documentation",
              "Deployment"
            ];

            for (const task of subTasks) {
              await github.rest.issues.create({
                owner: context.repo.owner,
                repo: context.repo.repo,
                title: `[${issue.number}] ${task}`,
                body: `Sub-task of #${issue.number}: ${issue.title}`
              });
            }
```

### 5. AI-Powered Automation (GitHub Models)

GitHub now supports AI-powered automation in Actions:

```yaml
name: AI-powered triage

on:
  issues:
    types: [opened]

jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            // Use GitHub Models for AI analysis
            // Summarize issue, suggest labels, identify priority
            const issue = context.payload.issue;
            // Process with AI model for categorization
```

---

## Setup Guides

### Phase 1: Initial Project Creation

#### Step 1: Create Project

```
GitHub Organization/User
  → Projects tab
  → New project
  → Choose template:
     • Table layout
     • Board layout
     • Roadmap layout
```

#### Step 2: Configure Fields

```yaml
Add custom fields:
  Status: Single select (Todo, In Progress, In Review, Done)
  Priority: Single select (Low, Medium, High, Critical)
  Assignee: Text/People field
  Start Date: Date field
  Target Date: Date field
  Complexity: Number field
  Iteration: Iteration field
  Type: Single select (Feature, Bug, Enhancement, Documentation)
```

#### Step 3: Add Default Workflows

```
Settings → Automation
  ✓ Pull request linked to issue
  ✓ Item closed = Status → Done
  ✓ Item closed = Auto-archive (optional)
```

#### Step 4: Set Notifications

```
Settings → Notifications
  • Notify on: Status changes, assignments, mentions
  • Email: Enable for critical items
```

### Phase 2: Git Integration Setup

#### Step 1: Configure Repository

```bash
cd your-repo

# Create branch naming standard
# Documentation in CONTRIBUTING.md
echo "Branch naming: feature/GH-123-description" >> CONTRIBUTING.md

# Create PR template with project linking
mkdir -p .github
cat > .github/pull_request_template.md << 'EOF'
## Description
Brief description of changes

## Closes
Closes #<issue-number>

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Enhancement
- [ ] Documentation

## Testing
Describe testing performed

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CHANGELOG updated
EOF
```

#### Step 2: Create Automation Workflows

```bash
mkdir -p .github/workflows

# Create auto-add workflow
cat > .github/workflows/add-to-project.yml << 'EOF'
name: Add issue/PR to project

on:
  issues:
    types: [opened, reopened]
  pull_request:
    types: [opened, ready_for_review]

jobs:
  add-to-project:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/add-to-project@v0
        with:
          project-url: https://github.com/orgs/YOUR-ORG/projects/PROJECT-NUMBER
          github-token: ${{ secrets.PROJECT_TOKEN }}
EOF
```

#### Step 3: Create Secrets

```
Repository Settings → Secrets → New repository secret
  Name: PROJECT_TOKEN
  Value: <your-personal-access-token or GitHub-app-token>
```

### Phase 3: Team Onboarding

#### Create CONTRIBUTING.md Guide

```markdown
# Contributing to [Project]

## Workflow
1. Create issue describing work
2. Create branch: `feature/GH-<issue>-description`
3. Make changes, commit with references
4. Create PR with "Closes #<issue>"
5. Review and merge

## Project Board Usage
- Check "In Progress" before starting work
- Self-assign items
- Update status as you progress
- Close PR to auto-complete issue
```

#### Setup Team Access

```
Project Settings → Access
  • Add team members
  • Set permissions (Read, Write, Admin)
  • Enable notifications
```

#### Create Views for Different Roles

```
Product Manager View:
  • Filter: All items
  • Group: Status
  • Sort: Target Date

Developer View:
  • Filter: Assigned to me
  • Group: Status
  • Sort: Priority

QA View:
  • Filter: Status = "In Review"
  • Group: Repository
```

### Phase 4: Reporting & Analytics

#### Enable Project Insights

```
Project → Insights tab

Metrics available:
  • Item completion rate
  • Time to resolution
  • Items by status (burndown chart)
  • Work distribution by assignee
  • Historical trends
```

#### Create Custom Dashboard

```
Use project insights for:
  • Sprint velocity tracking
  • Cycle time analysis
  • Team workload balancing
  • Release readiness metrics
```

---

## Best Practices

### 1. Project Structure Best Practices

#### Single Project per Milestone/Sprint

**Benefits:**
- Clear scope and boundaries
- Easier burndown tracking
- Focused team collaboration
- Simpler archival process

**Structure:**
```
Organization
  ├─ v2.0 Project (Active)
  ├─ v1.9 Project (Closed)
  ├─ Roadmap Project (Strategic)
  └─ Backlog Project (Long-term)
```

#### Multi-view Strategy

**Create views for different purposes:**

```yaml
"Team Board":
  - Type: Board layout
  - Group: Status
  - Filter: None (full view)
  - Use: Daily standup, status tracking

"Sprint Backlog":
  - Type: Table layout
  - Sort: Priority, Target Date
  - Filter: Current milestone
  - Use: Work assignment, progress tracking

"Roadmap":
  - Type: Roadmap layout
  - Zoom: 3-month
  - Group: Milestone
  - Use: Quarterly planning

"My Work":
  - Type: Table layout
  - Filter: Assigned to me
  - Group: Status
  - Use: Personal task management
```

### 2. Workflow Best Practices

#### Standardize Issue/PR Process

```
Issue Created
  ↓ (auto add to project)
Status: Todo
  ↓ (assignment + label)
Status: In Progress
  ↓ (PR opened with closing keyword)
Status: In Review
  ↓ (PR approved)
Status: Done (auto on merge)
  ↓ (after 30 days)
Archived (auto-archive)
```

#### Define Clear Status Values

```yaml
Todo:
  - Issue not yet started
  - Waiting for input
  - Blocked on dependencies

In Progress:
  - Developer assigned and working
  - Branch created

In Review:
  - PR opened
  - Under code review
  - Awaiting approval

Done:
  - PR merged
  - Issue closed
  - Work complete

Archived:
  - Completed 30+ days ago
  - Duplicates/won't fix
  - De-prioritized items
```

### 3. Issue Management Best Practices

#### Issue Decomposition

**Large issues → Small sub-issues**

```
Epic: "Refactor authentication system" (parent issue)
  ├─ Sub-issue: "Design new auth flow"
  ├─ Sub-issue: "Implement JWT tokens"
  ├─ Sub-issue: "Migrate existing sessions"
  ├─ Sub-issue: "Add password reset flow"
  └─ Sub-issue: "Update documentation"
```

**Benefits:**
- Parallel work possible
- Smaller PRs easier to review
- Better progress tracking
- Team autonomy

#### Issue Linking Strategy

```
Link all related work:
  • Bug reported by user → Link to root cause issue
  • Feature request → Link to related features
  • Documentation → Link to implementation
  • Tests → Link to tested feature
  • Blocked items → Link to blockers
```

### 4. Milestone Best Practices

#### Time-boxed Milestones

```yaml
Sprint (1-2 weeks):
  Duration: 5 working days
  Items: 10-20 issues
  Review: Daily standups

Release (4-6 weeks):
  Duration: 1 month
  Items: 30-50 issues
  Review: Weekly
  Buffer: 10% extra capacity

Quarterly (13 weeks):
  Duration: 3 months
  Items: 80-120 issues
  Review: Bi-weekly
  Buffer: 20% extra capacity
```

#### Capacity Planning

```
Example: 5-person team, 2-week sprint

Available capacity:
  • 5 people × 10 days × 6 hours = 300 hours
  • Remove meetings/admin (20%) = 240 hours
  • Remove spike/bugs (20%) = 192 hours

Available: ~38 hours per person per sprint

With complexity points:
  • Simple: 2-4 hours
  • Medium: 5-8 hours
  • Complex: 10-16 hours
  • Epic: 20+ hours
```

### 5. Automation Best Practices

#### What to Automate

**Good Automation:**
```
✓ Add items to project when created
✓ Update status when PR status changes
✓ Archive old completed items
✓ Auto-link closing keywords
✓ Assign labels based on patterns
✓ Notify on blocked dependencies
```

**Avoid Over-automation:**
```
✗ Auto-assigning to random person
✗ Changing priorities automatically
✗ Closing issues without verification
✗ Creating unnecessary sub-issues
✗ Auto-moving items based only on labels
```

#### Testing Automation

```bash
# Test workflow locally before deployment
act -j add-to-project

# Monitor GitHub Actions logs
# GitHub → Actions → Workflow runs

# Validate with test issue
# Create test-issue, verify automation runs
# Check project for proper item addition
# Verify custom fields populated correctly
```

### 6. Communication Best Practices

#### Status Communication

```yaml
Daily:
  • Standup: Show board view
  • Updates: "X items completed, Y in progress"

Weekly:
  • Project review: Board overview
  • Metrics: Velocity, cycle time
  • Blockers: Dependencies, issues

Monthly:
  • Release review: Milestone completion
  • Retrospective: Process improvements
  • Roadmap: Next month priorities
```

#### Using Project for Transparency

```
Make projects public when possible:
  • Open source projects: Required
  • Internal products: Check policy
  • Client work: Check contract

Benefits:
  • Stakeholder visibility
  • Community engagement
  • Recruitment (show process)
```

### 7. Performance Best Practices

#### Project Optimization

```yaml
Item Limits:
  Current max: 50,000 items per project
  Recommendation: Keep active < 500 items

Strategy:
  • Archive completed items
  • Use separate projects per milestone
  • Move old issues to "Archive" project

View Performance:
  • Limit filters to 5-10 items max
  • Avoid deep nesting
  • Use appropriate zoom level
  • Archive completed views
```

#### API Rate Limiting

```
GraphQL API:
  • Rate limit: 5,000 points/hour
  • Each mutation: 1 point
  • Large queries: Up to 10 points

Best practices:
  • Batch operations when possible
  • Cache results
  • Implement exponential backoff
  • Use GitHub Apps for higher limits
```

### 8. Documentation Best Practices

#### Maintain Project Documentation

```markdown
# Project: [Name]

## Purpose
What is this project for?

## Milestones
- v1.0: Core features (Q1 2025)
- v1.1: Performance (Q2 2025)

## Custom Fields
- **Status**: Todo, In Progress, In Review, Done
- **Priority**: Low, Medium, High, Critical

## Workflows
- Auto-add on issue creation
- Auto-archive after 30 days

## Views
- Board: Daily standup view
- Roadmap: Quarterly planning

## Links
- GitHub: [link]
- Wiki: [link]
- Docs: [link]
```

---

## Troubleshooting

### Common Issues

#### Issue Not Appearing in Project

```
Checklist:
  ✓ Auto-add workflow enabled
  ✓ Issue matches filter criteria
  ✓ GitHub token has project scope
  ✓ Correct project URL

Solution:
  • Re-run workflow manually
  • Check GitHub Actions logs
  • Verify token permissions
  • Add item manually to verify project works
```

#### Custom Fields Not Populating

```
Causes:
  • Field ID incorrect
  • Option ID doesn't exist
  • Token lacks permission
  • Field type mismatch

Solutions:
  • Query GraphQL to get correct IDs
  • Verify field type matches value
  • Test with manual update first
  • Check token scopes
```

#### Automation Slow/Not Running

```
Debugging:
  • Check workflow runs in Actions
  • Review error logs
  • Test workflow with simple event
  • Monitor API rate limits
  • Check token expiration

Solutions:
  • Increase workflow frequency
  • Batch operations
  • Use GitHub Apps (higher limits)
  • Implement caching
```

---

## Resources & Links

### Official Documentation
- **GitHub Projects Docs**: https://docs.github.com/en/issues/planning-and-tracking-with-projects
- **Automation Guide**: https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project
- **GraphQL API Docs**: https://docs.github.com/en/graphql

### Tools & Actions
- **actions/add-to-project**: https://github.com/actions/add-to-project
- **GitHub Project Automation+**: https://github.com/marketplace/actions/github-project-automation

### Learning Resources
- **GitHub Blog - Projects**: https://github.blog/category/issues-projects/
- **GitHub Skills**: https://skills.github.com

---

## Summary

GitHub Projects 2025 provides a comprehensive, integrated approach to project management within your development workflow:

1. **Automation** reduces manual work through built-in workflows and GitHub Actions
2. **Linking** creates clear traceability from issues through PRs to completed work
3. **Milestones** enable structured release planning and capacity management
4. **Roadmaps** provide strategic visibility across quarters
5. **Git Integration** makes project tracking part of natural developer workflow
6. **Customization** allows tailoring to team processes and practices

By following these guides and best practices, you can establish a streamlined, automated workflow that improves team productivity, visibility, and collaboration.
