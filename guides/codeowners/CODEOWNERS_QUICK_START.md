# CODEOWNERS 2025 - Quick Start Guide

Get your code ownership strategy up and running in 30 days.

---

## Week 1: Foundation

### Step 1.1: Assess Current State (2 hours)

```bash
# Find all code by type
find . -name "*.py" | wc -l
find . -name "*.js" | wc -l
find . -name "*.go" | wc -l

# Check current team structure
# Document: Who owns what areas today?
# Create: doc/current_ownership.md
```

### Step 1.2: Create Team List (4 hours)

```
Teams to Define:
- [ ] Core API Team (members: alice, bob, charlie)
- [ ] Frontend Team (members: david, eve)
- [ ] Backend Team (members: frank, grace)
- [ ] DevOps Team (members: henry, iris)
- [ ] QA Team (members: jack, karen)
- [ ] Security Team (members: leo, maria)

Document in: .github/TEAM_STRUCTURE.md
```

### Step 1.3: Create Initial CODEOWNERS (3 hours)

Use this starter template:

```
# .github/CODEOWNERS

*                          @org/engineering-leads

# Backend
/api/                      @org/api-team
/services/                 @org/backend-team
/database/                 @org/backend-team

# Frontend
/frontend/                 @org/frontend-team
/web-components/           @org/frontend-team

# Infrastructure
/infrastructure/           @org/devops-team
/.github/workflows/        @org/devops-team

# Testing
/tests/                    @org/qa-team

# Security
/security/                 @org/security-team

# Documentation
/docs/                     @org/documentation-team
```

**Action**: Commit this to a branch, no PR yet.

---

## Week 2: Validation & Team Review

### Step 2.1: Validate CODEOWNERS (1 hour)

```bash
# Install validation tool
pip install codeowners-validator

# Run validation
python scripts/validate_codeowners.py --file .github/CODEOWNERS

# Expected output:
# - ✓ No syntax errors
# - ✓ All teams exist
# - ⚠ Consider making /docs shared ownership
```

### Step 2.2: Internal Review (6 hours)

Create PR with CODEOWNERS:

```markdown
# Title: Initial CODEOWNERS Configuration

## Changes
- Created `.github/CODEOWNERS` with domain-based ownership
- Defined 6 teams with clear responsibilities

## Team Assignments
- API Team owns `/api/*`
- Frontend Team owns `/frontend/*`
- DevOps owns infrastructure

## SLAs
- Expected review time: 24 hours
- Critical paths (security, infra): 4 hours

cc: @team-leads
```

Review checklist:
- [ ] Do teams agree with their ownership areas?
- [ ] Are there conflicts or gaps?
- [ ] Does pattern matching work for your repo structure?
- [ ] Are critical paths identified (security, infra)?

### Step 2.3: Make Adjustments (3 hours)

Based on team feedback:

```bash
# Common adjustments:

# Add sub-team ownership
/api/auth/                 @org/security-team @org/api-team

# Handle shared responsibility
/tests/integration/        @org/qa-team @org/api-team @org/backend-team

# Create exceptions
/tests/security/           @org/security-team
```

---

## Week 3: Automation & Governance

### Step 3.1: Enable Branch Protection (2 hours)

GitHub Settings → Repositories → Branch protection rules

```
Rule: Require code owner review
- ✓ Enabled
- Require approval from code owners
- ✓ Require review from specified teams available (2025 feature)
```

### Step 3.2: Create Escalation Workflow (4 hours)

File: `.github/workflows/escalation.yml`

```yaml
name: PR Escalation
on:
  schedule:
    - cron: '0 9 * * 1-5'  # 9am weekdays
  pull_request:
    types: [opened]

jobs:
  check-escalation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Check Review SLA
        uses: actions/github-script@v6
        with:
          script: |
            const pr = context.payload.pull_request;
            if (!pr) return;

            const created = new Date(pr.created_at);
            const hours = (Date.now() - created) / 3600000;

            if (hours > 24) {
              await github.rest.issues.addLabels({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: pr.number,
                labels: ['escalation-24h']
              });
            }
```

**Test**: Create a test PR, verify labels appear

### Step 3.3: Set Up Rotation (2 hours)

Create: `.github/config/rotation-schedule.yml`

```yaml
rotation_2025:
  q1:
    api-team:
      primary: alice
      secondary: bob
    frontend-team:
      primary: david
      secondary: eve

  q2:
    api-team:
      primary: bob
      secondary: alice
    # ... continue pattern
```

---

## Week 4: Launch & Monitoring

### Step 4.1: Final Communication (1 hour)

Send team email:

```
Subject: CODEOWNERS Configuration Live - 24hr Review SLA

Team,

We've implemented code ownership tracking. Here's what changed:

1. CODEOWNERS file now defines who reviews what
2. All PRs affecting your code will be auto-assigned
3. We have a 24-hour review SLA for all areas
4. Critical paths (security, infra) escalate after 4 hours

See .github/CODEOWNERS for full details.

Questions? Ask in #engineering-ops
```

### Step 4.2: Enable and Monitor (2 hours)

```bash
# Merge CODEOWNERS PR
# Enable branch protection requiring code owner reviews
# Watch metrics for Week 1
```

Dashboard to monitor:

```sql
-- Review time by team (should be < 24h)
SELECT team, AVG(review_hours) FROM reviews WHERE week = current_week;

-- Escalations (should be rare)
SELECT team, COUNT(*) FROM escalations WHERE week = current_week;

-- Coverage (should be 100%)
SELECT COUNT(uncovered_files) FROM codeowners WHERE coverage = 0;
```

### Step 4.3: First Week Check-In (1 hour)

Schedule sync with team leads:
- How are review times?
- Any unexpected ownership conflicts?
- Need to adjust patterns?

Common fixes:
- Pattern too broad → split into sub-teams
- Pattern too narrow → merge related paths
- Team not responding → add backup reviewer

---

## Configuration Files - Copy These

### `.github/CODEOWNERS` (Basic)

```
*                          @org/engineering-leads
/api/                      @org/api-team
/frontend/                 @org/frontend-team
/infrastructure/           @org/devops-team
/security/                 @org/security-team
```

### `.github/workflows/escalation.yml`

```yaml
name: Auto-Escalate Stale PRs
on:
  schedule:
    - cron: '0 9 * * *'
  pull_request:
    types: [opened]

jobs:
  escalate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/github-script@v6
        with:
          script: |
            const prs = await github.rest.pulls.list({
              owner: context.repo.owner,
              repo: context.repo.repo,
              state: 'open'
            });

            for (const pr of prs.data) {
              const created = new Date(pr.created_at);
              const hours = (Date.now() - created) / 3600000;

              // Check no approvals
              const reviews = await github.rest.pulls.listReviews({
                owner: context.repo.owner,
                repo: context.repo.repo,
                pull_number: pr.number
              });

              const hasApproval = reviews.data.some(r => r.state === 'APPROVED');

              if (hours > 24 && !hasApproval) {
                await github.rest.issues.addLabels({
                  owner: context.repo.owner,
                  repo: context.repo.repo,
                  issue_number: pr.number,
                  labels: ['needs-review', 'escalated']
                });
              }
            }
```

### `.github/config/rotation.json`

```json
{
  "rotation_period": "quarterly",
  "teams": [
    {
      "name": "api-team",
      "members": ["alice", "bob", "charlie"],
      "2025_q1": {
        "primary": "alice",
        "secondary": "bob",
        "backup": "charlie"
      },
      "2025_q2": {
        "primary": "bob",
        "secondary": "charlie",
        "backup": "alice"
      }
    }
  ]
}
```

---

## Day-by-Day Checklist (Week 1 Launch)

### Day 1: Preparation
- [ ] CODEOWNERS file reviewed by team leads
- [ ] Branch protection rules configured
- [ ] Escalation workflow created
- [ ] Team notified

### Day 2: Launch
- [ ] CODEOWNERS merged to main
- [ ] Require code owner reviews enabled
- [ ] First test PR opened
- [ ] Verify auto-assignment works

### Day 3: Monitoring
- [ ] Check review times
- [ ] Monitor escalation labels
- [ ] Fix any pattern issues
- [ ] Communication sent to teams

### Day 4: Adjust
- [ ] Gather team feedback
- [ ] Fix overlapping ownership
- [ ] Refine SLA expectations
- [ ] Update escalation rules

### Day 5: Stability
- [ ] Run metrics
- [ ] Weekly team sync
- [ ] Document learnings
- [ ] Plan next improvements

---

## Common Issues & Fixes

### Issue: "Pattern Too Broad"

**Symptom**: All changes assigned to one person

**Fix**:
```diff
- /src/                         @alice
+ /src/api/                     @alice
+ /src/frontend/                @bob
```

### Issue: "Multiple Reviewers Not Required"

**Symptom**: Only one of many owners reviews

**Fix**: Use GitHub branch protection rules
```
Required: ✓ Require code owner review
Required reviewers: 2
```

### Issue: "Rotation Not Happening"

**Symptom**: Same reviewer every time

**Fix**: Enable random assignment
```yaml
# .github/config/settings.yml
auto_assign:
  enabled: true
  algorithm: random
  count: 1
```

### Issue: "Escalation Not Triggering"

**Symptom**: Old PRs not getting escalated

**Fix**: Check workflow logs
```bash
# View recent workflow runs
gh run list --repo owner/repo --limit 10

# View specific run
gh run view RUN_ID --log
```

---

## Success Metrics (Track After 30 Days)

| Metric | Target | Actual |
|--------|--------|--------|
| Avg review time | < 24h | __ h |
| % SLA Met | > 95% | __ % |
| Escalations/week | < 5 | __ |
| Code coverage | 100% | __ % |
| Team satisfaction | > 4/5 | __ /5 |

---

## Next Steps (Month 2)

### AI Code Tracking
- [ ] Create `.ai-code-manifest.json` template
- [ ] Add AI code review checklist
- [ ] Integrate license scanning

### Advanced Escalation
- [ ] Configure multi-level escalation
- [ ] Add Slack notifications
- [ ] Create escalation dashboard

### Review Rotation
- [ ] Implement quarterly rotation
- [ ] Automate rotation script
- [ ] Track rotation metrics

### Documentation
- [ ] Create team runbooks
- [ ] Document escalation paths
- [ ] Set up metrics dashboard

---

## Useful Commands

```bash
# Validate CODEOWNERS
python scripts/validate_codeowners.py

# Check file coverage
python scripts/check_coverage.py

# Generate rotation
python scripts/rotate_reviewers.py --team api-team

# View metrics
gh api repos/owner/repo/pulls --state closed --limit 100

# Find uncovered files
git ls-files | while read f; do grep -q "$f" .github/CODEOWNERS || echo "$f"; done
```

---

## Need Help?

### Slack Channels
- `#code-owners` - General questions
- `#code-review-guidelines` - Best practices
- `#engineering-ops` - Automation issues

### Documents
- `/docs/CODEOWNERS_RESEARCH_2025.md` - Full research
- `/docs/TEMPLATES_CODEOWNERS_PATTERNS.md` - More patterns
- `/.github/CODEOWNERS` - Your config

### Tools
- Script: `scripts/validate_codeowners.py`
- Script: `scripts/rotate_reviewers.py`
- GitHub Actions: `.github/workflows/escalation.yml`

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-09 | Initial guide |

**Last Updated**: 2025-11-09
**Maintainer**: Engineering Operations Team
