# Git Workflow Implementation Guides (2025)

This document provides step-by-step implementation guides for each workflow with concrete examples and commands.

---

## GitHub Flow Implementation Guide

### Prerequisites Checklist

```
□ GitHub (free tier minimum)
□ 2-20 developers
□ Basic CI/CD (GitHub Actions, Travis CI, or CircleCI)
□ Automated tests in place
□ Code linting configured
```

### Part 1: Repository Setup

#### Step 1: Create Branch Protection Rules

**In GitHub repository settings → Branches:**

```yaml
Branch name pattern: main

Protection Rules:
  ✓ Require a pull request before merging
  ✓ Dismiss stale pull request approvals
  ✓ Require status checks to pass before merging
    - Select: code-linting
    - Select: automated-tests
    - Select: security-scan (if available)
  ✓ Require branches to be up to date before merging
  ✓ Restrict who can push to matching branches
    - Allow: Repository maintainers
```

#### Step 2: Configure GitHub Actions

**File: `.github/workflows/tests.yml`**

```yaml
name: Tests and Linting

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up environment
      run: npm install

    - name: Run linting
      run: npm run lint

    - name: Run tests
      run: npm run test:coverage

    - name: Run security scan
      run: npm run security-scan

  deploy:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'

    steps:
    - uses: actions/checkout@v3
    - name: Deploy to production
      run: npm run deploy
```

### Part 2: Team Workflow

#### Developer Creating a Feature

```bash
# 1. Create local feature branch from latest main
git checkout main
git pull origin main
git checkout -b feature/user-authentication

# 2. Make changes and commit
git add .
git commit -m "Add user authentication module"

# 3. Keep branch updated (do this regularly)
git fetch origin
git rebase origin/main

# 4. Push feature branch
git push origin feature/user-authentication

# 5. Create Pull Request on GitHub
# (Use GitHub web UI or GitHub CLI)
gh pr create --title "Add user authentication" \
  --body "Implements OAuth2 login flow"
```

#### Code Review Process

```
Reviewer Checklist:
  □ Code follows style guide
  □ Tests are comprehensive
  □ No security issues
  □ Performance acceptable
  □ Documentation updated
  □ No commented-out code
  □ Logic is clear and maintainable

Comment Types:
  "MUST FIX": Blocking issue, needs addressing
  "SHOULD FIX": Important but might be optional
  "NICE TO HAVE": Suggestion for future

GitHub Actions automatically checks:
  ✓ All tests pass
  ✓ Linting passes
  ✓ Security scan clean
  ✓ Coverage threshold met (>80%)
```

#### Merging to Main

```
After PR approval:
  1. Ensure all checks pass (automated)
  2. Ensure branch is up-to-date with main
  3. Click "Squash and merge" (recommended for clean history)
  4. Auto-delete feature branch
  5. Automated deploy to production triggered
  6. Monitor deployment metrics

Rollback if needed:
  git revert <commit-hash>
  git push origin main
  # System automatically redeploys
```

### Part 3: Process Guidelines

#### Branch Naming Convention

```
feature/description           # New features
bugfix/description            # Bug fixes
hotfix/description            # Urgent fixes
refactor/description          # Refactoring
docs/description              # Documentation
chore/description             # Maintenance

Examples:
  feature/user-authentication
  bugfix/login-timeout-issue
  hotfix/payment-processing-fail
  refactor/database-queries
  docs/api-endpoints
  chore/update-dependencies
```

#### Commit Message Guidelines

```
Format:
  <type>: <subject>

  <body>

  <footer>

Types:
  feat:     New feature
  fix:      Bug fix
  refactor: Code refactoring
  docs:     Documentation
  test:     Tests
  chore:    Build/CI/dependency updates

Example:
  feat: add user authentication

  Implement OAuth2 login flow with support
  for Google and GitHub providers.

  - OAuth2 authentication
  - Session management
  - Secure token storage

  Closes #123
```

#### Code Review Standards

```
Review SLA: < 4 hours
Reviewer Count: 1-2 (depends on complexity)
Testing Requirements: 100% automated
Approval Process: 1 approval = mergeable

Large Changes (>400 lines):
  - 2 approvals required
  - Extended review time acceptable
  - Consider breaking into smaller PRs
```

### Part 4: Common Scenarios

#### Scenario: Fixing Merge Conflicts

```bash
# During PR, if conflicts reported:
git fetch origin
git rebase origin/main

# Resolve conflicts in editor
vim path/to/conflict.js

# Continue rebase
git add .
git rebase --continue

# Force push (safe after rebase)
git push origin feature/name -f
```

#### Scenario: Need to Update PR

```bash
# Make additional changes
git add .
git commit -m "Address review feedback"
git push origin feature/name

# GitHub automatically updates PR
# No need to close/reopen
```

#### Scenario: Emergency Hotfix

```bash
# Use same flow, just urgent
git checkout main
git pull origin main
git checkout -b hotfix/critical-issue

# Make minimal fix
git add .
git commit -m "hotfix: resolve payment processing"
git push origin hotfix/critical-issue

# Create PR - expedited review
gh pr create --title "[HOTFIX] Payment processing" \
  --body "Critical issue: payment API timeout"

# After merge, auto-deploys immediately
```

### Part 5: Metrics and Monitoring

#### Key Metrics to Track

```
Daily:
  - Number of PRs merged
  - Average PR review time
  - Deployment success rate

Weekly:
  - Lead time for changes
  - Change failure rate
  - Deployment frequency
  - MTTR (mean time to recovery)

Monthly:
  - Merge conflict rate
  - PR size distribution
  - Code review completion rate
  - Team satisfaction survey
```

#### Dashboard Queries

```sql
-- Average review time
SELECT
  pr_title,
  DATEDIFF(merged_at, created_at) as review_hours,
  reviewer
FROM pull_requests
WHERE merged = true
AND created_at > DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY review_hours DESC;

-- Deployment frequency
SELECT
  DATE(deployment_time) as deploy_date,
  COUNT(*) as deployments
FROM deployments
WHERE environment = 'production'
AND created_at > DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(deployment_time);
```

---

## Trunk-Based Development Implementation Guide

### Prerequisites Checklist (CRITICAL)

```
□ Strong automated test suite (>80% coverage)
□ Fast CI/CD pipeline (<10 min)
□ Feature flag infrastructure
□ 24/7 monitoring and alerting
□ Canary deployment capability
□ On-call rotation (2-3 people)
□ Database migration automation
□ Rollback procedures documented
□ Team training completed
```

### Part 1: Infrastructure Setup

#### Step 1: Feature Flag Infrastructure

**Example using Unleash:**

```bash
# Install Unleash SDK
npm install unleash-client

# Create config
cat > features.js << 'EOF'
const { initialize } = require('unleash-client');

const unleash = initialize({
  url: 'https://unleash.example.com/api',
  clientKey: process.env.UNLEASH_KEY,
  appName: 'my-app',
  refreshInterval: 1000
});

module.exports = unleash;
EOF

# Usage in code
const unleash = require('./features');

if (unleash.isEnabled('new-ui-components')) {
  // Show new UI
} else {
  // Show old UI
}
```

**Feature Flag Naming Convention:**

```
<team>/<feature>/<version>
  backend/payment-v2
  frontend/new-dashboard
  mobile/dark-mode

Types:
  experiment/*          # A/B tests
  feature/*             # Features
  bugfix/*              # Bug fixes
  performance/*         # Performance improvements
  deprecated/*          # Gradual deprecation
```

#### Step 2: Canary Deployment

**Example using GitHub Actions:**

```yaml
name: Canary Deployment

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Build
      run: npm run build

    - name: Run tests
      run: npm run test:full

    - name: Deploy to canary (5% traffic)
      run: |
        helm upgrade my-app ./chart \
          --set canary.enabled=true \
          --set canary.weight=5

    - name: Monitor for 5 minutes
      run: ./scripts/monitor-canary.sh

    - name: If stable, increase to 25%
      run: |
        helm upgrade my-app ./chart \
          --set canary.weight=25

    - name: Monitor for 10 minutes
      run: ./scripts/monitor-canary.sh

    - name: If stable, full rollout
      run: |
        helm upgrade my-app ./chart \
          --set canary.enabled=false
```

#### Step 3: Monitoring and Observability

**Prometheus Config:**

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'my-app'
    static_configs:
      - targets: ['localhost:9090']

alert_rules:
  - alert: HighErrorRate
    expr: rate(http_errors[5m]) > 0.05
    for: 1m
    annotations:
      summary: "High error rate detected"

  - alert: DeploymentLatency
    expr: histogram_quantile(0.95, http_duration) > 1
    for: 5m
    annotations:
      summary: "P95 latency > 1s"
```

### Part 2: Development Workflow

#### Daily Development Cycle

```
9:00 AM - Daily Standup
  Team syncs on current work
  Identify blockers
  Discuss feature flags

9:30 AM - Start First Task
  git checkout main
  git pull origin main
  git checkout -b feature/task-123-auth-page

10:00 AM - First Commit
  npm run test        # All tests pass
  npm run lint        # No lint errors
  git add .
  git commit -m "feat: add auth page header"

10:15 AM - Push and Create PR
  git push origin feature/task-123-auth-page
  gh pr create --title "feat: add auth page header"

10:30 AM - Code Review
  Peer reviews in real-time (video call optional)
  Feedback provided via PR comments

10:45 AM - Address Review
  Make changes
  git add .
  git commit -m "refine: improve auth page styling"
  git push origin feature/task-123-auth-page

11:00 AM - Merge to Main
  All checks pass
  Code review approved
  git merge main (from GitHub UI)
  Automated deployment starts

11:10 AM - Monitor
  Watch deployment progress
  Check error rates
  Verify feature flag behavior

11:20 AM - Continue Next Task
  Delete local branch
  Start next task (repeat)

12:00 PM - Lunch (continue monitoring)

Typical daily merge target: 5-10 merges to main
```

#### Branch Lifecycle (Strict!)

```
CREATE: 9:30 AM
  When: Starting new task
  Duration: Expected < 4 hours
  Who: Individual developer

DEVELOP: 9:45 AM - 11:00 AM
  Small, focused commits
  Keep synchronized with main
  Multiple test runs

SUBMIT: 11:00 AM
  Create PR
  Automated checks run

REVIEW: 11:00 AM - 11:10 AM
  Target: < 10 minutes
  Reviewer: Senior/mid-level dev
  Requirement: Logic correct, tests adequate

MERGE: 11:10 AM
  All checks pass
  Rebase and merge preferred
  Delete branch immediately

MONITOR: 11:10 AM - 11:30 AM
  Watch metrics
  Ready to rollback

DELETE: Automatic
  After merge, branch auto-deleted
  New branch created for next task
```

### Part 3: Feature Flag Best Practices

#### Feature Flag Lifecycle

```
1. CREATION (Day 1)
   - Created when feature branch created
   - Defaults to OFF (hidden from users)
   - Documentation added

2. DEVELOPMENT (Days 1-2)
   - Developers toggle ON/OFF locally
   - Manual testing with flag on/off
   - Code paths exercised

3. INTERNAL TESTING (Day 2-3)
   - Enabled for dev/staging environments
   - QA tests with flag ON
   - QA tests with flag OFF

4. CANARY LAUNCH (Day 4+)
   - Enabled for 1% of production traffic
   - Monitor error rates
   - If stable, increase to 5%
   - If stable, increase to 25%
   - If stable, increase to 100%

5. MONITORING (Week 2+)
   - Continue monitoring metrics
   - Track usage and engagement
   - Gather user feedback

6. CLEANUP (Week 3+)
   - Remove feature flag from code
   - Delete flag definition
   - Document lessons learned
```

#### Flag Management Commands

```bash
# Create flag
unleash-cli flag create \
  --name feature/new-dashboard \
  --description "Redesigned dashboard UI" \
  --type release \
  --enabled false

# Enable for specific strategy
unleash-cli flag strategy add feature/new-dashboard \
  --strategy userIds \
  --parameter userIds=user1,user2,user3

# Gradual rollout
unleash-cli flag strategy add feature/new-dashboard \
  --strategy flexibleRollout \
  --parameter rollout=5,stickiness=userId

# Monitor usage
unleash-cli flag usage feature/new-dashboard

# Archive flag
unleash-cli flag archive feature/new-dashboard
```

### Part 4: On-Call Responsibilities

#### On-Call Developer Role

**Shift**: 1 week, weekday; 3 days weekend
**Availability**: Respond within 5 minutes
**Primary Responsibility**: Monitor production

```
Tasks:
  □ Monitor error rates and latency
  □ Review incoming deployments
  □ Watch feature flag metrics
  □ Respond to alerts
  □ Implement quick fixes
  □ Coordinate rollbacks if needed
  □ Communicate issues to team

Escalation Path:
  1. Fix minor issues
  2. Ask team Slack channel
  3. Call senior engineer
  4. Declare incident/P1
  5. Bring in multiple people
```

#### Incident Response Procedure

```
DETECT: Alert fires
  └─ On-call gets paged

ACKNOWLEDGE: < 5 min
  └─ "I have this"

ASSESS: < 10 min
  └─ Error rate? What changed? Which service?

RESPOND:
  Option A: Roll back last deployment
    git revert <latest-commit>
    # Auto-deploys

  Option B: Hotfix with feature flag OFF
    git checkout main
    git pull origin main
    git checkout -b hotfix/issue-name
    # Quick fix with feature flag disabled
    # Fast review, merge, deploy

  Option C: Scale/Infrastructure change
    kubectl scale deployment my-app --replicas=5

  └─ Resolution < 30 min target

COMMUNICATE:
  □ Slack #incidents channel
  □ Customer support notification
  □ Status page update
  □ Team notification

POST-INCIDENT:
  □ RCA (Root Cause Analysis)
  □ Action items
  □ Preventive measures
  □ Team discussion
```

### Part 5: Metrics and Success Criteria

#### Target Metrics (First Month)

```
Deployment Frequency: 10+ per day ✓
Lead Time: < 4 hours ✓
MTTR: < 30 minutes
Change Failure Rate: < 10%
Code Review Time: < 15 minutes
Merge Conflicts: Near zero
On-Call Stability: No cascading failures
```

#### Dashboard (Real-time)

```
Key Charts:
  1. Deployments per day (rolling 7-day)
  2. Error rate (5-min window)
  3. Latency P95 (5-min window)
  4. Feature flag usage
  5. On-call alert frequency
  6. Rollback frequency
  7. Code review time histogram
```

---

## Gitflow Implementation Guide

### Part 1: Repository Setup

#### Branch Configuration

```bash
# Initial setup
git checkout -b main
git checkout -b develop

# Protect branches
git branch -m master main  # Rename if needed
```

**GitHub Branch Protection:**

```yaml
Main Branch:
  ✓ Require PR reviews: 2+
  ✓ Require status checks
  ✓ Dismiss stale PRs
  ✓ Require up-to-date before merge
  ✓ Require branches to be up-to-date

Develop Branch:
  ✓ Require PR reviews: 1+
  ✓ Require status checks
  ✓ Dismiss stale PRs
  ✓ Require up-to-date before merge
```

### Part 2: Workflow

#### Feature Development

```bash
# Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/user-authentication

# Develop feature
# ... make changes ...
git add .
git commit -m "feat: add OAuth2 login"

# Create PR to develop
git push origin feature/user-authentication
gh pr create --title "feat: add OAuth2 login" \
  --body "Implement OAuth2 with Google/GitHub"

# Review and merge to develop
# (after approval)
git checkout develop
git pull origin develop
git merge --no-ff feature/user-authentication
git push origin develop
git branch -d feature/user-authentication
```

#### Release Process

```bash
# Create release branch when ready
git checkout develop
git pull origin develop
git checkout -b release/1.2.0

# Only version bumps and minor fixes
npm version minor  # Updates package.json
git add .
git commit -m "chore: bump version to 1.2.0"

# Create PR to main for final review
git push origin release/1.2.0
gh pr create --title "Release 1.2.0" \
  --base main \
  --body "Release notes here"

# After approval, merge to main
git checkout main
git pull origin main
git merge --no-ff release/1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags

# Merge back to develop
git checkout develop
git pull origin develop
git merge --no-ff release/1.2.0
git push origin develop

# Delete release branch
git branch -d release/1.2.0
git push origin --delete release/1.2.0
```

#### Hotfix Process

```bash
# Create from main when urgent issue
git checkout main
git pull origin main
git checkout -b hotfix/payment-timeout

# Quick fix
# ... make minimal changes ...
git add .
git commit -m "fix: resolve payment API timeout"

# Merge to main
git checkout main
git merge --no-ff hotfix/payment-timeout
git tag -a v1.2.1 -m "Hotfix version 1.2.1"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge --no-ff hotfix/payment-timeout
git push origin develop

# Delete hotfix branch
git branch -d hotfix/payment-timeout
git push origin --delete hotfix/payment-timeout
```

### Part 3: Release Management

#### Release Checklist

```
Before Release:
  □ All features merged to develop
  □ All tests pass
  □ Code review complete
  □ Documentation updated
  □ Version bumped
  □ Release notes drafted
  □ Security audit completed

During Release:
  □ Release branch created
  □ Final testing in release branch
  □ Only critical bugs fixed
  □ PR to main created
  □ Final approval received

After Release:
  □ Merged to main with tag
  □ Merged back to develop
  □ Release branch deleted
  □ Deployment monitored
  □ Release notes published
  □ Team notified
```

---

## GitLab Flow Implementation Guide

### Part 1: Repository Setup

```yaml
Main Branch:
  ✓ Always deployable
  ✓ Require 1+ review
  ✓ Require status checks

Staging Branch:
  ✓ Pre-production environment
  ✓ Require 1 review
  ✓ Auto-deploy to staging

Production Branch:
  ✓ Production environment
  ✓ Require 1 review
  ✓ Auto-deploy to production
```

### Part 2: Workflow

#### Feature Development

```bash
# Create feature from main
git checkout main
git pull origin main
git checkout -b feature/new-payment-system

# Develop feature
git add .
git commit -m "feat: implement Stripe integration"

# Create MR to main
git push origin feature/new-payment-system
gh pr create --title "feat: Stripe integration" \
  --body "Implement Stripe payment processing"

# After review, merge to main
# → Auto-deploys to staging
# → Run staging tests
# → Manual approval for production

# Create PR main → production
gh pr create --title "Release to production" \
  --base production --head main \
  --body "Deploy latest to production"

# After approval, merge to production
# → Auto-deploys to production
```

---

## Troubleshooting Guide

### GitHub Flow Issues

**Issue: Too many merge conflicts**
```
Root cause: Branches too long-lived
Solution:
  1. Merge more frequently
  2. Better communication between developers
  3. Implement feature flags to avoid conflicts
```

**Issue: PR reviews taking too long**
```
Root cause: Too many PRs or large PRs
Solution:
  1. Limit PR size to <400 lines
  2. Set review SLA (< 4 hours)
  3. Rotate reviewers
  4. Use code owners rules
```

### Trunk-Based Issues

**Issue: Feature flags getting out of control**
```
Root cause: Lack of lifecycle management
Solution:
  1. Implement flag archive policy
  2. Review flags monthly
  3. Remove unused flags (< 3 days)
  4. Auto-archive after 30 days
```

**Issue: On-call burnout**
```
Root cause: Too many alerts/incidents
Solution:
  1. Improve test coverage
  2. Better monitoring (alert tuning)
  3. Adequate on-call team size
  4. Better incident response procedures
```

**Issue: Merge conflicts still happening**
```
Root cause: Long-lived branches despite intent
Solution:
  1. Enforce 4-hour max branch lifetime
  2. Auto-close branches after 4 hours
  3. Better feature slicing
  4. More frequent syncs with main
```

### Gitflow Issues

**Issue: Release branch coordination complex**
```
Root cause: Multiple people on release branch
Solution:
  1. Single release manager
  2. Strict commit policy (version/docs only)
  3. Clear communication
  4. Automated version bumping
```

---

**Document Version**: 1.0
**Last Updated**: November 2025
**Status**: Implementation Guides
