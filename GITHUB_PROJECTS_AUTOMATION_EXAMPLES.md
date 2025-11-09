# GitHub Projects 2025 - Practical Automation Examples

This document provides ready-to-use automation scripts and workflows for common GitHub Projects scenarios.

## Table of Contents

1. [GitHub Actions Workflows](#github-actions-workflows)
2. [GraphQL Scripts](#graphql-scripts)
3. [CLI Examples](#cli-examples)
4. [Integration Patterns](#integration-patterns)

---

## GitHub Actions Workflows

### 1. Auto-add Issues and PRs to Project

**File**: `.github/workflows/auto-add-to-project.yml`

```yaml
name: Auto-add to Project

on:
  issues:
    types: [opened, reopened]
  pull_request:
    types: [opened, ready_for_review]

jobs:
  add-to-project:
    name: Add issue/PR to project
    runs-on: ubuntu-latest
    steps:
      - name: Add to project
        uses: actions/add-to-project@v0
        with:
          project-url: https://github.com/orgs/YOUR-ORG/projects/PROJECT-NUMBER
          github-token: ${{ secrets.PROJECT_TOKEN }}
```

**Setup**:
1. Create Personal Access Token with `repo`, `project`, `read:org` scopes
2. Add as repository secret: `PROJECT_TOKEN`
3. Replace `YOUR-ORG` and `PROJECT-NUMBER`

---

### 2. Auto-add with Label Filtering

**File**: `.github/workflows/auto-add-labeled.yml`

```yaml
name: Auto-add labeled issues to project

on:
  issues:
    types: [opened, labeled]
  pull_request:
    types: [opened, labeled]

jobs:
  add-to-project:
    runs-on: ubuntu-latest
    if: |
      contains(github.event.issue.labels.*.name, 'bug') ||
      contains(github.event.issue.labels.*.name, 'feature') ||
      contains(github.event.issue.labels.*.name, 'enhancement')
    steps:
      - name: Add to project
        uses: actions/add-to-project@v0
        with:
          project-url: https://github.com/orgs/YOUR-ORG/projects/PROJECT-NUMBER
          github-token: ${{ secrets.PROJECT_TOKEN }}
```

---

### 3. Set Custom Fields on Item Addition

**File**: `.github/workflows/add-with-custom-fields.yml`

```yaml
name: Add to project with custom fields

on:
  pull_request:
    types: [opened]

jobs:
  add-and-set-fields:
    runs-on: ubuntu-latest
    steps:
      - name: Add PR to project
        uses: actions/add-to-project@v0
        id: add-to-project
        with:
          project-url: https://github.com/orgs/YOUR-ORG/projects/PROJECT-NUMBER
          github-token: ${{ secrets.PROJECT_TOKEN }}

      - name: Set custom field values
        uses: actions/github-script@v7
        if: steps.add-to-project.outputs.itemId
        with:
          github-token: ${{ secrets.PROJECT_TOKEN }}
          script: |
            const itemId = '${{ steps.add-to-project.outputs.itemId }}';
            const projectId = 'PVT_YOUR_PROJECT_ID';

            // Query to get field IDs (run once to get values)
            const projectQuery = `
              query {
                organization(login: "YOUR-ORG") {
                  projectV2(number: PROJECT-NUMBER) {
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
            `;

            const projectResult = await github.graphql(projectQuery);

            // Set Status field to "In Progress"
            const setStatusMutation = `
              mutation {
                updateProjectV2ItemFieldValue(input: {
                  projectId: "${projectId}"
                  itemId: "${itemId}"
                  fieldId: "FIELD_1"
                  value: { singleSelectOptionId: "OPTION_1" }
                }) {
                  clientMutationId
                }
              }
            `;

            await github.graphql(setStatusMutation);
            console.log('Status field updated');
```

---

### 4. Auto-archive Completed Items

**File**: `.github/workflows/auto-archive.yml`

```yaml
name: Auto-archive completed items

on:
  schedule:
    # Run daily at 2 AM UTC
    - cron: '0 2 * * *'
  workflow_dispatch:

jobs:
  archive-items:
    runs-on: ubuntu-latest
    steps:
      - name: Archive completed items
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.PROJECT_TOKEN }}
          script: |
            const projectId = 'PVT_YOUR_PROJECT_ID';
            const organizationLogin = 'YOUR-ORG';
            const projectNumber = PROJECT-NUMBER;

            // Get all items with status "Done"
            const itemsQuery = `
              query {
                organization(login: "${organizationLogin}") {
                  projectV2(number: ${projectNumber}) {
                    items(first: 100, after: null) {
                      nodes {
                        id
                        fieldValues(first: 20) {
                          nodes {
                            ... on ProjectV2ItemFieldSingleSelectValue {
                              field {
                                ... on ProjectV2SingleSelectField {
                                  name
                                }
                              }
                              name
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            `;

            const result = await github.graphql(itemsQuery);
            const items = result.organization.projectV2.items.nodes;

            // Archive items with Status = "Done"
            for (const item of items) {
              const statusField = item.fieldValues.nodes.find(
                fv => fv.field?.name === 'Status' && fv.name === 'Done'
              );

              if (statusField) {
                const archiveMutation = `
                  mutation {
                    archiveProjectV2Item(input: {
                      projectId: "${projectId}"
                      itemId: "${item.id}"
                    }) {
                      clientMutationId
                    }
                  }
                `;

                try {
                  await github.graphql(archiveMutation);
                  console.log(`Archived item: ${item.id}`);
                } catch (error) {
                  console.error(`Failed to archive ${item.id}: ${error}`);
                }
              }
            }
```

---

### 5. Auto-update Status on PR Event

**File**: `.github/workflows/update-status-on-pr.yml`

```yaml
name: Update status on PR event

on:
  pull_request:
    types: [opened, ready_for_review, marked_as_draft, synchronize]

jobs:
  update-status:
    runs-on: ubuntu-latest
    steps:
      - name: Determine new status
        id: status
        run: |
          if [[ "${{ github.event.pull_request.draft }}" == "true" ]]; then
            echo "new_status=Draft" >> $GITHUB_OUTPUT
          elif [[ "${{ github.event.action }}" == "ready_for_review" ]]; then
            echo "new_status=In Review" >> $GITHUB_OUTPUT
          elif [[ "${{ github.event.action }}" == "marked_as_draft" ]]; then
            echo "new_status=In Progress" >> $GITHUB_OUTPUT
          else
            echo "new_status=In Progress" >> $GITHUB_OUTPUT
          fi

      - name: Update project status
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.PROJECT_TOKEN }}
          script: |
            const itemId = '${{ github.event.pull_request.node_id }}';
            const projectId = 'PVT_YOUR_PROJECT_ID';
            const statusMap = {
              'Draft': 'OPTION_DRAFT',
              'In Progress': 'OPTION_IN_PROGRESS',
              'In Review': 'OPTION_IN_REVIEW'
            };

            const mutation = `
              mutation {
                updateProjectV2ItemFieldValue(input: {
                  projectId: "${projectId}"
                  itemId: "${itemId}"
                  fieldId: "FIELD_STATUS"
                  value: { singleSelectOptionId: "${statusMap['${{ steps.status.outputs.new_status }}']}" }
                }) {
                  clientMutationId
                }
              }
            `;

            await github.graphql(mutation);
            console.log('Status updated to: ${{ steps.status.outputs.new_status }}');
```

---

### 6. Create Sub-issues from Epic Label

**File**: `.github/workflows/create-sub-issues.yml`

```yaml
name: Create sub-issues from epic

on:
  issues:
    types: [labeled]

jobs:
  create-sub-issues:
    if: contains(github.event.issue.labels.*.name, 'epic')
    runs-on: ubuntu-latest
    steps:
      - name: Create sub-issues
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const epic = context.payload.issue;
            const repo = context.repo;

            // Define sub-task template
            const subTasks = [
              {
                title: 'Design',
                description: 'Design phase - Requirements and specifications'
              },
              {
                title: 'Implementation',
                description: 'Development phase - Code implementation'
              },
              {
                title: 'Testing',
                description: 'QA phase - Testing and bug fixes'
              },
              {
                title: 'Documentation',
                description: 'Documentation phase - Update docs'
              },
              {
                title: 'Deployment',
                description: 'Deployment phase - Release to production'
              }
            ];

            console.log(`Creating sub-issues for epic: ${epic.title}`);

            for (const task of subTasks) {
              const subIssue = await github.rest.issues.create({
                owner: repo.owner,
                repo: repo.repo,
                title: `[${epic.number}] ${task.title}`,
                body: `**Parent Epic**: #${epic.number}\n\n${task.description}`,
                labels: ['sub-task']
              });

              console.log(`Created sub-issue #${subIssue.data.number}: ${task.title}`);
            }
```

---

### 7. Notify on Blocked Dependencies

**File**: `.github/workflows/check-blocked-items.yml`

```yaml
name: Check for blocked items

on:
  schedule:
    # Check daily at 9 AM UTC
    - cron: '0 9 * * *'
  workflow_dispatch:

jobs:
  check-blocked:
    runs-on: ubuntu-latest
    steps:
      - name: Find blocked items
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.PROJECT_TOKEN }}
          script: |
            const projectId = 'PVT_YOUR_PROJECT_ID';
            const organizationLogin = 'YOUR-ORG';

            // Get all items with status "Blocked"
            const query = `
              query {
                organization(login: "${organizationLogin}") {
                  projectV2(number: PROJECT-NUMBER) {
                    items(first: 100) {
                      nodes {
                        id
                        content {
                          ... on Issue {
                            title
                            url
                            number
                          }
                          ... on PullRequest {
                            title
                            url
                            number
                          }
                        }
                        fieldValues(first: 20) {
                          nodes {
                            ... on ProjectV2ItemFieldSingleSelectValue {
                              field {
                                ... on ProjectV2SingleSelectField {
                                  name
                                }
                              }
                              name
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            `;

            const result = await github.graphql(query);
            const items = result.organization.projectV2.items.nodes;

            const blockedItems = items.filter(item => {
              const statusField = item.fieldValues.nodes.find(
                fv => fv.field?.name === 'Status' && fv.name === 'Blocked'
              );
              return statusField;
            });

            if (blockedItems.length > 0) {
              let message = ':warning: **Blocked Items Found**\n\n';
              blockedItems.forEach(item => {
                message += `- [${item.content.title}](${item.content.url})\n`;
              });

              console.log(message);
              // Could post to Slack/Teams here
            }
```

---

### 8. Sync Project with Milestone

**File**: `.github/workflows/sync-milestone.yml`

```yaml
name: Sync project with milestone

on:
  issues:
    types: [milestoned, demilestoned]
  pull_request:
    types: [opened, labeled]

jobs:
  sync-milestone:
    runs-on: ubuntu-latest
    steps:
      - name: Get milestone name
        id: milestone
        run: |
          milestone="${{ github.event.issue.milestone.title || github.event.pull_request.milestone.title }}"
          echo "name=$milestone" >> $GITHUB_OUTPUT

      - name: Add to milestone-specific project
        uses: actions/add-to-project@v0
        if: steps.milestone.outputs.name != ''
        with:
          project-url: https://github.com/orgs/YOUR-ORG/projects/${{ steps.milestone.outputs.name }}
          github-token: ${{ secrets.PROJECT_TOKEN }}

      - name: Update milestone field in project
        uses: actions/github-script@v7
        if: steps.milestone.outputs.name != ''
        with:
          github-token: ${{ secrets.PROJECT_TOKEN }}
          script: |
            const itemId = context.payload.issue?.node_id || context.payload.pull_request?.node_id;
            const projectId = 'PVT_YOUR_PROJECT_ID';
            const milestoneName = '${{ steps.milestone.outputs.name }}';

            const mutation = `
              mutation {
                updateProjectV2ItemFieldValue(input: {
                  projectId: "${projectId}"
                  itemId: "${itemId}"
                  fieldId: "FIELD_MILESTONE"
                  value: { singleSelectOptionId: "OPTION_${milestoneName.toUpperCase().replace(/\s/g, '_')}" }
                }) {
                  clientMutationId
                }
              }
            `;

            await github.graphql(mutation);
```

---

## GraphQL Scripts

### 1. Get Project Information

**File**: `scripts/get-project-info.js`

```javascript
const { graphql } = require('@octokit/graphql');

const graphqlWithAuth = graphql.defaults({
  headers: {
    authorization: `token ${process.env.GITHUB_TOKEN}`,
  },
});

async function getProjectInfo(org, projectNumber) {
  const query = `
    query {
      organization(login: "${org}") {
        projectV2(number: ${projectNumber}) {
          id
          title
          description
          url
          fields(first: 20) {
            nodes {
              ... on ProjectV2Field {
                id
                name
                dataType
              }
              ... on ProjectV2SingleSelectField {
                id
                name
                options {
                  id
                  name
                }
              }
              ... on ProjectV2IterationField {
                id
                name
                configuration {
                  iterations {
                    startDate
                    id
                  }
                }
              }
            }
          }
          items(first: 10) {
            totalCount
            nodes {
              id
              title
              fieldValues(first: 10) {
                nodes {
                  ... on ProjectV2ItemFieldTextValue {
                    field {
                      ... on ProjectV2Field {
                        name
                      }
                    }
                    text
                  }
                }
              }
            }
          }
        }
      }
    }
  `;

  try {
    const result = await graphqlWithAuth({ query });
    console.log(JSON.stringify(result, null, 2));
    return result;
  } catch (error) {
    console.error('Error:', error);
  }
}

// Usage
getProjectInfo('YOUR-ORG', PROJECT-NUMBER);
```

---

### 2. Add Item with Custom Fields

**File**: `scripts/add-item-with-fields.js`

```javascript
const { graphql } = require('@octokit/graphql');

const graphqlWithAuth = graphql.defaults({
  headers: {
    authorization: `token ${process.env.GITHUB_TOKEN}`,
  },
});

async function addItemWithFields(projectId, issueId, fieldUpdates) {
  // First, add the item
  const addItemMutation = `
    mutation {
      addProjectV2ItemById(input: {
        projectId: "${projectId}"
        contentId: "${issueId}"
      }) {
        item {
          id
        }
      }
    }
  `;

  const addResult = await graphqlWithAuth({ query: addItemMutation });
  const itemId = addResult.addProjectV2ItemById.item.id;

  console.log(`Item added: ${itemId}`);

  // Then update fields
  for (const [fieldId, value] of Object.entries(fieldUpdates)) {
    const updateMutation = `
      mutation {
        updateProjectV2ItemFieldValue(input: {
          projectId: "${projectId}"
          itemId: "${itemId}"
          fieldId: "${fieldId}"
          value: ${JSON.stringify(value)}
        }) {
          clientMutationId
        }
      }
    `;

    try {
      await graphqlWithAuth({ query: updateMutation });
      console.log(`Updated field ${fieldId} with value ${JSON.stringify(value)}`);
    } catch (error) {
      console.error(`Error updating field ${fieldId}:`, error);
    }
  }

  return itemId;
}

// Usage example
const fieldUpdates = {
  FIELD_STATUS: { singleSelectOptionId: 'OPTION_IN_PROGRESS' },
  FIELD_PRIORITY: { singleSelectOptionId: 'OPTION_HIGH' },
  FIELD_DATE: { date: '2025-12-31' },
};

addItemWithFields('PVT_PROJECT_ID', 'ISSUE_NODE_ID', fieldUpdates);
```

---

### 3. Bulk Update Items

**File**: `scripts/bulk-update-items.js`

```javascript
const { graphql } = require('@octokit/graphql');

const graphqlWithAuth = graphql.defaults({
  headers: {
    authorization: `token ${process.env.GITHUB_TOKEN}`,
  },
});

async function bulkUpdateItems(projectId, filter, fieldId, newValue) {
  // Get items matching filter
  const query = `
    query {
      organization(login: "YOUR-ORG") {
        projectV2(number: PROJECT-NUMBER) {
          items(first: 100) {
            nodes {
              id
              content {
                ... on Issue {
                  labels(first: 10) {
                    nodes {
                      name
                    }
                  }
                }
              }
              fieldValues(first: 20) {
                nodes {
                  ... on ProjectV2ItemFieldSingleSelectValue {
                    field {
                      ... on ProjectV2SingleSelectField {
                        id
                        name
                      }
                    }
                    id
                  }
                }
              }
            }
          }
        }
      }
    }
  `;

  const result = await graphqlWithAuth({ query });
  const items = result.organization.projectV2.items.nodes;

  // Filter items
  const filteredItems = items.filter(item => {
    if (filter.label) {
      const hasLabel = item.content?.labels?.nodes?.some(
        label => label.name === filter.label
      );
      return hasLabel;
    }
    return true;
  });

  console.log(`Found ${filteredItems.length} items to update`);

  // Update items
  let updated = 0;
  for (const item of filteredItems) {
    const mutation = `
      mutation {
        updateProjectV2ItemFieldValue(input: {
          projectId: "${projectId}"
          itemId: "${item.id}"
          fieldId: "${fieldId}"
          value: ${JSON.stringify(newValue)}
        }) {
          clientMutationId
        }
      }
    `;

    try {
      await graphqlWithAuth({ query: mutation });
      updated++;
    } catch (error) {
      console.error(`Error updating item ${item.id}:`, error);
    }
  }

  console.log(`Updated ${updated} items`);
}

// Usage
bulkUpdateItems(
  'PVT_PROJECT_ID',
  { label: 'bug' },
  'FIELD_PRIORITY',
  { singleSelectOptionId: 'OPTION_HIGH' }
);
```

---

## CLI Examples

### 1. Using GitHub CLI with gh

**Create issue and add to project:**

```bash
#!/bin/bash
# create-and-add-issue.sh

ISSUE_TITLE="$1"
ISSUE_BODY="$2"
ORG="YOUR-ORG"
PROJECT_NUMBER="1"

# Create issue
ISSUE_URL=$(gh issue create \
  --title "$ISSUE_TITLE" \
  --body "$ISSUE_BODY" \
  --label "enhancement" \
  --assignee @me \
  --repo "$ORG/your-repo" \
  --web false \
  --json url \
  --jq '.url')

echo "Created issue: $ISSUE_URL"

# Add to project using GraphQL
gh api graphql -f query='
  query {
    organization(login: "'"$ORG"'") {
      projectV2(number: '"$PROJECT_NUMBER"') {
        id
      }
    }
  }
' --jq '.data.organization.projectV2.id'
```

**Usage:**
```bash
./create-and-add-issue.sh "New Feature" "This is a new feature request"
```

---

### 2. Query Project Status

**File**: `scripts/check-project-status.sh`

```bash
#!/bin/bash
# check-project-status.sh

ORG="YOUR-ORG"
PROJECT_NUMBER="1"

echo "=== Project Status Report ==="
echo ""

# Get project info
PROJECT_INFO=$(gh api graphql -f query='
  query {
    organization(login: "'"$ORG"'") {
      projectV2(number: '"$PROJECT_NUMBER"') {
        title
        items(first: 100) {
          totalCount
          nodes {
            id
            content {
              ... on Issue {
                title
                url
              }
              ... on PullRequest {
                title
                url
              }
            }
            fieldValues(first: 20) {
              nodes {
                ... on ProjectV2ItemFieldSingleSelectValue {
                  field {
                    ... on ProjectV2SingleSelectField {
                      name
                    }
                  }
                  name
                }
              }
            }
          }
        }
      }
    }
  }
')

# Display results
echo "$PROJECT_INFO" | jq -r '
  .data.organization.projectV2 as $project |
  "Project: \($project.title)" |
  "\nTotal Items: \($project.items.totalCount)" |
  "\nItems by Status:" |
  (
    $project.items.nodes
    | map(.fieldValues.nodes[] | select(.field.name == "Status") | .name)
    | group_by(.)
    | map({status: .[0], count: length})
    | .[]
    | "  \(.status): \(.count)"
  )
'
```

---

## Integration Patterns

### 1. Slack Notification Pattern

**File**: `.github/workflows/notify-slack.yml`

```yaml
name: Notify Slack of project updates

on:
  issues:
    types: [opened, assigned, moved]

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: Build Slack message
        id: slack-message
        run: |
          message="Issue #${{ github.event.issue.number }}: ${{ github.event.issue.title }}"
          echo "text=$message" >> $GITHUB_OUTPUT

      - name: Send to Slack
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "${{ steps.slack-message.outputs.text }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Issue Updated*\n${{ github.event.issue.html_url }}\n${{ github.event.issue.body }}"
                  }
                }
              ]
            }
```

---

### 2. Microsoft Teams Pattern

**File**: `.github/workflows/notify-teams.yml`

```yaml
name: Notify Teams of blocked items

on:
  schedule:
    - cron: '0 9 * * 1' # Monday morning

jobs:
  notify-teams:
    runs-on: ubuntu-latest
    steps:
      - name: Find blocked items
        id: blocked
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.PROJECT_TOKEN }}
          script: |
            // Query for blocked items
            const blockedItems = []; // Get from query
            return JSON.stringify(blockedItems);

      - name: Post to Teams
        uses: jdcargile/ms-teams-notification@v1.3
        with:
          github-token: ${{ github.token }}
          ms-teams-webhook-uri: ${{ secrets.TEAMS_WEBHOOK }}
          notification-color: ff0000
          title: Blocked Items Report
          description: ${{ steps.blocked.outputs.result }}
```

---

### 3. Daily Digest Pattern

**File**: `.github/workflows/daily-digest.yml`

```yaml
name: Daily digest

on:
  schedule:
    - cron: '0 17 * * 1-5' # 5 PM weekdays

jobs:
  digest:
    runs-on: ubuntu-latest
    steps:
      - name: Generate digest
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.PROJECT_TOKEN }}
          script: |
            const digest = {
              todayCompleted: 5,
              inProgress: 12,
              blocked: 2,
              upcoming: 8
            };

            console.log(`
            📊 Daily Status Digest
            ✅ Completed today: ${digest.todayCompleted}
            ⏳ In Progress: ${digest.inProgress}
            🚫 Blocked: ${digest.blocked}
            📅 Upcoming: ${digest.upcoming}
            `);
```

---

## Configuration Templates

### 1. Complete Workflow Configuration

**File**: `project-config.yaml`

```yaml
# Project configuration template
project:
  name: "Release v2.0"
  description: "Major release with new features"
  owner: "YOUR-ORG"
  number: 1

# Custom fields configuration
fields:
  - name: "Status"
    type: "single_select"
    options:
      - "Todo"
      - "In Progress"
      - "In Review"
      - "Done"
    default: "Todo"

  - name: "Priority"
    type: "single_select"
    options:
      - "Low"
      - "Medium"
      - "High"
      - "Critical"

  - name: "Assignee"
    type: "assignee"

  - name: "Target Date"
    type: "date"

  - name: "Complexity"
    type: "number"

  - name: "Iteration"
    type: "iteration"

# Automation rules
automations:
  - name: "Auto-add from repo"
    trigger: "item_created"
    action: "add_to_project"
    config:
      repository: "your-repo"

  - name: "Auto-archive done"
    trigger: "item_status_changed"
    condition: "status == 'Done' AND updated_at > 30 days ago"
    action: "archive_item"

  - name: "Close issue on PR merge"
    trigger: "pr_merged"
    action: "close_linked_issue"

# Views configuration
views:
  - name: "Board View"
    type: "board"
    group_by: "Status"
    sort_by: "Priority"

  - name: "Roadmap View"
    type: "roadmap"
    date_field: "Target Date"
    zoom_level: "3_months"

  - name: "My Work"
    type: "table"
    filter: "assignee = me"
```

---

## Getting Project IDs

**Quick script to get IDs needed for automation:**

```bash
#!/bin/bash
# get-project-ids.sh

ORG="YOUR-ORG"
PROJECT_NUMBER="1"

gh api graphql -f query='
  query {
    organization(login: "'"$ORG"'") {
      projectV2(number: '"$PROJECT_NUMBER"') {
        id
        fields(first: 50) {
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
' --jq '
  .data.organization.projectV2 as $project |
  "Project ID: " + $project.id + "\n" +
  "Fields:\n" +
  ($project.fields.nodes | map(
    if .options then
      "  \(.id) - \(.name) (Single Select)\n" +
      "    Options:\n" +
      (.options | map("      \(.id) - \(.name)") | join("\n"))
    else
      "  \(.id) - \(.name)"
    end
  ) | join("\n"))
'
```

---

## Troubleshooting Automation

### Debug Workflow Runs

```bash
# View recent workflow runs
gh run list --repo YOUR-ORG/your-repo

# View specific workflow run
gh run view RUN_ID --repo YOUR-ORG/your-repo

# View logs for failed step
gh run view RUN_ID --log-failed --repo YOUR-ORG/your-repo
```

### Check API Rate Limits

```bash
gh api rate_limit --jq '.resources.graphql | {limit: .limit, used: .used, remaining: .remaining, reset: .reset}'
```

### Validate GraphQL Queries

```bash
# Test GraphQL query
gh api graphql -f query='
  query {
    viewer {
      login
    }
  }
'
```

---

## Summary

These examples provide:
- **Ready-to-use GitHub Actions workflows** for common automation scenarios
- **GraphQL scripts** for advanced project management
- **CLI examples** for command-line automation
- **Integration patterns** for notifications and reporting
- **Configuration templates** for consistent project setup

Customize these examples for your specific organization and project needs.
