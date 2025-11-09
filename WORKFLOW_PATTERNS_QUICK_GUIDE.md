# Collaborative Coding Workflow Patterns - Quick Reference
## Ready-to-Use Templates for 2025

---

## Quick Start Workflows

### Pattern A: "Standard Distributed Team" (5-15 engineers)

**Setup Time:** 30 minutes
**Tools:** GitHub, GitHub Codespaces, VS Code Live Share (optional), Slack, CodeRabbit

#### Git Configuration

```bash
# Clone and setup
git clone <your-repo>
cd your-project

# Create main branches
git checkout -b develop
git push origin develop

# Set branch protection rules in GitHub:
# - Require PR reviews (1 approver minimum)
# - Require status checks (tests, linting)
# - Auto-delete head branches
```

#### GitHub Actions CI/CD Pipeline

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Format check
        run: npm run format:check

      - name: Type check
        run: npm run type-check

      - name: Run tests
        run: npm run test

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json

  deploy-staging:
    needs: quality
    if: github.event_name == 'push' && github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to staging
        run: npm run deploy:staging
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}

  deploy-prod:
    needs: quality
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to production
        run: npm run deploy:prod
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```

#### Development Workflow (per developer)

```bash
# Day 1: Start feature
git checkout develop
git pull origin develop
git checkout -b feature/user-auth

# Development (commit often)
# Make changes...
git add .
git commit -m "feat: add login form component"

git add .
git commit -m "feat: integrate authentication API"

git add .
git commit -m "test: add login flow tests"

# When ready for review
git push origin feature/user-auth

# On GitHub: Open Pull Request
# - Title: "feat: add user authentication"
# - Description: What changed, why, testing notes
# - Link to issue/ticket

# Wait for review (24h SLA)
# Address feedback in follow-up commits

# Once approved, merge (auto-deploy to staging)
```

#### Code Review Checklist

```markdown
# Code Review Template

## Automated Checks (AI - CodeRabbit)
- [ ] Linting passed
- [ ] Tests passed (>80% coverage)
- [ ] No security vulnerabilities
- [ ] No secrets detected

## Human Review (Peer)
- [ ] Code follows team conventions
- [ ] Logic is correct and tested
- [ ] Documentation updated
- [ ] Performance acceptable

## Architecture Review (Required for major changes)
- [ ] Doesn't duplicate existing code
- [ ] Follows existing patterns
- [ ] Scalable solution

## Approval Criteria
- 1 approval minimum (2 for critical paths)
- All CI checks passing
- No merge conflicts
```

#### Daily Standup (Async)

```markdown
# Daily Standup - November 10, 2025

## Completed (Yesterday)
- @alice: Merged PR #234 (user auth tests) - 2h debugging CORS issue
- @bob: Code review 3 PRs, started feature/payments

## In Progress (Today)
- @alice: Continuing feature/user-auth (blocked on API response format)
- @bob: feature/payments form validation
- @carol: Reviewing infrastructure changes

## Blockers
- @alice: Need clarification on API response format for /auth/login
  └─ Action: Will ask @api-team in #backend channel

## Tomorrow
- @alice: Complete auth feature + open PR for review
- @bob: Unit test coverage for payments
- @carol: Approve infra changes + deploy

**Team Velocity:** 3 features in flight, 2 reviews in queue, 0 critical issues
```

#### Weekly Retro (30 minutes, async first)

```markdown
# Weekly Retro - Week of Nov 10

## What Went Well
✅ Deployed 2 features to production without incidents
✅ CodeRabbit caught 3 potential bugs before review
✅ Live Share session on Friday helped pair through complex debugging

## What Could Be Better
⚠️ 2 PRs took 3 days to review (slow feedback loop)
⚠️ Unclear requirements on feature/payments caused rework
⚠️ No documentation written for new API endpoint

## Action Items
- [ ] Add review checklist to help reviewers prioritize
- [ ] Write requirements template for story cards
- [ ] Add OpenAPI spec for new API endpoints
- [ ] Schedule code review discussions on Monday

## Metrics (November 1-10)
- PR merge time: 24h average ✓
- Test coverage: 82% ✓
- Critical bugs: 0 ✓
- Developer satisfaction: 4/5 ✓
```

---

### Pattern B: "Pair Programming Team" (3-8 engineers, same timezone)

**Setup Time:** 45 minutes
**Tools:** VS Code Live Share, GitHub, GitHub Copilot, Codespaces, Discord

#### Daily Schedule

```
9:00 AM   | Daily Standup (15 min, sync)
          │ - What are we building?
          │ - Any blockers?

9:30 AM   | Pair Session 1 (90 min)
          │ ├─ Driver: Engineer A
          │ ├─ Navigator: Engineer B
          │ └─ Feature: User authentication
          │
11:00 AM  │ Pair Session 2 (90 min)
          │ ├─ Driver: Engineer B
          │ ├─ Navigator: Engineer C
          │ └─ Feature: Payment processing
          │
12:30 PM  | Lunch break

1:30 PM   | Solo Development / Code Review (90 min)
          │ - Individual work on issues
          │ - Review morning's PRs
          │ - Copilot for boilerplate

3:00 PM   | Code Review + Merging (60 min)
          │ - Discuss PR comments
          │ - Address feedback
          │ - Merge approved PRs

4:00 PM   | Async Work / Standup prep
          │ - Update issue status
          │ - Write code documentation
          │ - Prepare for next day

5:00 PM   | EOD (Friday: Demo & Retro)
```

#### Live Share Pairing Session Setup

```bash
# Prerequisites
npm install -g @microsoft/vsls-cli

# Host initiates session
# 1. Open VS Code
# 2. Click "Live Share" in status bar
# 3. Click "Share" (creates session)
# 4. Share link with navigator

# Navigator joins
# 1. Paste link in browser or Click link in VS Code
# 2. Host approves join
# 3. Both see same editor

# During session
# Terminal is shared
npm install   # Navigator can see
npm test      # Both can see output
npm run dev   # Port 3000 forwarded to navigator

# Switch roles
# Driver types for 30 min, then navigator takes over
# This reduces fatigue and ensures knowledge sharing
```

#### Pairing Session Template (90 min)

```markdown
# Pair Programming Session - Nov 10, 2025

**Feature:** User Authentication
**Driver:** Alice (codes)
**Navigator:** Bob (reviews, navigates)
**Duration:** 9:30 AM - 11:00 AM
**Tools:** Live Share + Discord for voice

## Pre-Session (10 min)
- [ ] Both pull latest develop branch
- [ ] Driver: Create feature branch `feature/user-auth`
- [ ] Navigator: Review acceptance criteria
- [ ] Open Live Share session

## Session Agenda (70 min)
- [ ] 0-20 min: Setup auth API client (driver: Alice)
- [ ] 20-40 min: Build login form component (switch - driver: Bob)
- [ ] 40-60 min: Add form validation & error handling
- [ ] 60-70 min: Write tests for auth flow

## Post-Session (10 min)
- [ ] Both review code
- [ ] Write commit message together
- [ ] Push to branch
- [ ] Driver creates PR with session notes

## Session Notes
- Decided on JWT token storage (localStorage for now)
- Need to add CSRF protection next session
- Tests coverage: 95% ✓
- No blockers, feature complete

## Next Steps
- Open PR for review (Alice)
- Bob reviews morning code + other PRs
- QA team tests on staging Wednesday
```

#### GitHub Copilot Usage Rules (Pair Programming)

```markdown
# When to Use Copilot During Pairing

## ✅ DO Use Copilot For:
- Test case generation (tests use patterns)
- Boilerplate code (CRUD operations)
- Inline documentation/comments
- Simple refactoring suggestions

Example:
  // Copilot suggestion
  async function fetchUserById(id) {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) throw new Error('User not found');
    return response.json();
  }

## ❌ DON'T Use Copilot For:
- Complex business logic (discuss first)
- Security-sensitive code (auth, encryption)
- Architectural changes (requires team input)
- Code patterns unfamiliar to team

## Process:
1. Driver: Request Copilot suggestion (Ctrl+Enter)
2. Copilot: Suggests code
3. Navigator: Reviews suggestion
   - "That looks good, let's use it"
   - "Can you modify it to use our error handler?"
   - "Let's implement this ourselves - good learning opportunity"
4. Driver: Accepts, modifies, or rejects
5. Both move forward
```

---

### Pattern C: "Global Async Team" (10+ engineers, 3+ time zones)

**Setup Time:** 1 hour (with docs)
**Tools:** GitHub, Codespaces, CodeRabbit, Slack, Notion, async.com

#### Time Zone Coordination

```
Timezone Distribution:

UTC-8 (Pacific US)  | 8 AM - 5 PM  | Alice, Bob
UTC-5 (Eastern US)  | 11 AM - 8 PM | Carol, David
UTC+0 (London)      | 4 PM - 1 AM  | Eve, Frank
UTC+5:30 (India)    | 9:30 PM - 6:30 AM | Gavi, Haris

Overlap Windows:
├─ Pacific + Eastern: 8 AM - 5 PM PT (full overlap)
├─ Eastern + London: 11 AM - 8 PM ET / 4 PM - 1 AM UTC
├─ London + India: 4 PM - 1 AM UTC (4:30 PM - 1:30 AM IST)
└─ Limited: Pacific + India (no natural overlap)

Solution: Async-first with intentional sync meetings
```

#### Async Development Workflow

```bash
# When developer in Pacific starts day (8 AM PT):
├─ Review Slack updates from Eastern/London/India teams
├─ Read PR comments and GitHub notifications
├─ Prioritize: Are there blockers?
└─ Plan work for their 8-hour window

# During their 8 AM - 5 PM PT:
├─ 8-11 AM: Heads-down development (no meetings)
├─ 11 AM - 12:30 PM: East Coast overlap
│         └─ Quick sync for design decisions
├─ 1-4 PM: More development + code review
└─ 4-5 PM: Prepare handoff for Europe/India teams

# Before leaving (5 PM PT):
├─ Summarize progress in GitHub issue
├─ List blockers in Slack (#blockers channel)
├─ Tag people in Asia who'll review overnight
└─ Link to any PRs waiting for review

# When Europe wakes up (4 PM UTC):
├─ Read Pacific team's summary
├─ Review PRs while Pacific sleeps
├─ Leave detailed feedback in PR comments
├─ Prepare handoff for Asia team

# When Asia wakes up (9:30 PM IST):
├─ Implement feedback from Europe
├─ Merge PRs if approved
├─ Push new features for Pacific team to review
```

#### 24-Hour Relay Workflow

```
Monday Morning (US) → Monday Evening (EU) → Tuesday Morning (APAC)

┌─────────────────────────────────────────────────────────┐
│ MONDAY 9 AM PT (Alice, Pacific)                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Task: Implement user dashboard                          │
│                                                         │
│ 1. Creates issue + branch                              │
│ 2. Implements feature (4 hours work)                    │
│ 3. Opens PR with description + screenshots             │
│ 4. Tags @europe-team "ready for review"               │
│ 5. Leaves note: "Tested locally, ready for staging"    │
│                                                         │
│ PR Status: Open, waiting for Europe review             │
│                                                         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ MONDAY 4 PM UTC (Eve, London)                           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 1. Reads PR from Alice (Pacific team)                  │
│ 2. CodeRabbit already ran automated checks             │
│ 3. Eve does code review (30 min)                       │
│ 4. Comments: "Looks good! One question on line 47..."  │
│ 5. Approves with requested changes                     │
│ 6. Leaves note: "@asia-team, please test on staging"  │
│                                                         │
│ PR Status: Approved, waiting for Asia feedback         │
│                                                         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ TUESDAY 9:30 AM IST (Gavi, India)                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 1. Wakes up, reviews PR from Europe                    │
│ 2. Pulls feature branch to staging environment         │
│ 3. Runs QA tests (30 min)                              │
│ 4. All green, merges to develop                        │
│ 5. Deploys to staging                                  │
│ 6. Posts in Slack: "Dashboard feature deployed ✓"     │
│                                                         │
│ Status: Complete, moving to next task                  │
│                                                         │
└─────────────────────────────────────────────────────────┘

Timeline: 24-hour continuous development
Result: Feature complete in 1 business day
```

#### Async PR Review Standards

```markdown
# Code Review Response Times

## Tier 1 (Quick, <4h expected)
- Trivial bug fixes
- Typo/documentation fixes
- Simple refactoring (no logic change)

## Tier 2 (Standard, <24h expected)
- New features
- API changes
- Database changes
- Dependency updates

## Tier 3 (Deliberate, <48h expected)
- Architecture changes
- Major refactoring
- Security-related changes
- Infrastructure changes

## Process:
1. PR created with detailed description
2. CodeRabbit auto-review (5-10 min)
3. Engineer A reviews (12-24h)
4. Engineer B reviews from different timezone (12-24h)
5. Merge when all approve + CI passes
```

#### Documentation Repository Structure

```
docs/
├─ architecture/
│  ├─ decisions/          (ADRs)
│  │  ├─ 001-use-postgres.md
│  │  ├─ 002-react-components.md
│  │  └─ 003-rest-vs-graphql.md
│  │
│  ├─ diagrams/           (C4 Model)
│  │  ├─ system-context.md
│  │  ├─ containers.md
│  │  └─ deployment.md
│  │
│  └─ data-model.md       (ER diagram)
│
├─ api/
│  ├─ openapi.yaml        (Swagger spec)
│  ├─ authentication.md
│  ├─ rate-limiting.md
│  └─ error-codes.md
│
├─ deployment/
│  ├─ environments.md     (dev, staging, prod)
│  ├─ rollback.md         (how to rollback)
│  ├─ scaling.md          (horizontal/vertical)
│  └─ disaster-recovery.md
│
├─ runbooks/
│  ├─ incident-response.md
│  ├─ database-backup.md
│  ├─ deploy-production.md
│  └─ performance-monitoring.md
│
├─ team/
│  ├─ engineering-handbook.md
│  ├─ code-standards.md
│  ├─ review-process.md
│  └─ on-call-schedule.md
│
└─ README.md              (start here)
```

---

### Pattern D: "Enterprise AI-First Team"

**Setup Time:** 2 hours
**Tools:** GitHub Codespaces, Ona (formerly Gitpod), CodeRabbit, GitHub Copilot, Slack, Jira

#### AI-Assisted Development Workflow

```bash
# Start your day in Ona environment

ona init my-project
# ✓ Loads your repo + project context

# AI agent helps with task planning
/ask "What's the best way to add OAuth2 to our app?"
# AI suggests architecture, standards, security considerations

# Create branch
git checkout -b feature/oauth2

# Start implementing with Copilot
# Type function signature, Copilot suggests implementation
/**
 * Verify OAuth2 token and return user claims
 * @param {string} token - JWT token from OAuth2 provider
 * @returns {Promise<UserClaims>} - User identity
 */
async function verifyOAuth2Token(token) {
  // Copilot suggests:
  // 1. Validate token signature
  // 2. Check expiration
  // 3. Extract claims
}

# Request AI review
/review-code
# CodeRabbit + Copilot flag:
# - Missing error handling
# - Should validate claims structure
# - Consider rate limiting

# Apply suggestions
/fix "Add comprehensive error handling"
# AI refines implementation

# Generate tests
/test-coverage
# Copilot generates test cases:
# - Valid token scenario
# - Expired token scenario
# - Invalid signature scenario
# - Missing claims scenario

# Commit and create PR
/commit-summary
# AI writes: "feat: Add OAuth2 token verification with comprehensive security checks"

/create-pr
# Opens PR, AI fills description:
# - What changed
# - Why
# - How to test
# - Security considerations

# During review
# AI agent monitors for conflicts:
/check-conflicts
# Notifies: "Someone else modified /auth/verify-token.ts, conflicts possible"

# All green, ready to merge
/merge
# Auto-merges to develop, triggers CI/CD
```

#### Recommended Team Structure with AI

```
Team Composition:

┌─────────────────────────────────┐
│  Engineering Team (3 Humans)    │
├─────────────────────────────────┤
│                                 │
│ Role 1: Feature Engineer        │
│ └─ Builds product features      │
│    with Copilot assistance      │
│                                 │
│ Role 2: Platform Engineer       │
│ └─ Infrastructure, scalability  │
│    with Copilot infrastructure  │
│    templates                    │
│                                 │
│ Role 3: QA Engineer             │
│ └─ Testing, quality assurance   │
│    with Copilot test generation │
│                                 │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│    AI Pair Programming (1)      │
├─────────────────────────────────┤
│                                 │
│ GitHub Copilot                  │
│ ├─ Real-time code suggestions   │
│ ├─ Test case generation         │
│ ├─ Documentation                │
│ └─ Refactoring hints            │
│                                 │
│ CodeRabbit                       │
│ ├─ Automated PR reviews         │
│ ├─ Security scanning            │
│ ├─ Performance analysis         │
│ └─ Conflicting pattern detection│
│                                 │
│ Ona Agents                       │
│ ├─ Task breakdown               │
│ ├─ Architecture suggestions     │
│ ├─ Problem solving              │
│ └─ Command automation           │
│                                 │
└─────────────────────────────────┘

Effectiveness:
├─ 50% reduction in boilerplate work
├─ 30% faster PR cycle (AI review first)
├─ 2x test coverage improvement
└─ Humans focus on high-value design
```

---

## Comparison Matrix

| Aspect | Pattern A | Pattern B | Pattern C | Pattern D |
|--------|-----------|-----------|-----------|-----------|
| **Team Size** | 5-15 | 3-8 | 10+ | 20+ |
| **Timezone Distribution** | 2-3 | 1 | 4+ | Global |
| **Sync Meetings** | 1-2 per week | Daily | Weekly | Minimal |
| **Pair Programming** | Optional | Daily | None | None |
| **AI Usage** | Copilot (optional) | Copilot (active) | CodeRabbit only | Full AI (Copilot, Ona, CodeRabbit) |
| **PR Review Time** | 24h | 4h | 24-48h | 8h |
| **Documentation** | Moderate | Light | Heavy | Heavy |
| **Complexity** | Medium | Low | High | Very High |
| **Setup Cost** | 30 min | 45 min | 1 hour | 2 hours |

---

## Configuration Files to Commit

### .gitignore
```
# Dependencies
node_modules/
package-lock.json
yarn.lock
pnpm-lock.yaml

# Environment
.env
.env.local
.env.*.local

# Build outputs
dist/
build/
.next/
out/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Testing
coverage/
.nyc_output/
```

### .editorconfig
```
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{js,jsx,ts,tsx,json}]
indent_style = space
indent_size = 2

[*.{py}]
indent_style = space
indent_size = 4

[*.md]
trim_trailing_whitespace = false
```

### .prettierrc
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 80,
  "arrowParens": "always"
}
```

### .pre-commit-config.yaml
```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.0.0
    hooks:
      - id: prettier

  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v8.45.0
    hooks:
      - id: eslint
        args: [--fix]
```

---

## Troubleshooting Common Issues

### Issue: "Works on my machine" but fails in CI
**Solution:**
```bash
# Use devcontainer.json to ensure consistency
cp .devcontainer/devcontainer.json ~/.config/dev-config.json

# Or use Docker locally
docker-compose up -d
# All services now identical to CI environment
```

### Issue: Merge conflicts block multiple branches
**Solution:**
- Merge `develop` into feature branches more frequently (daily)
- Keep PRs smaller (<400 lines of code)
- Assign clear code ownership to avoid conflicts

### Issue: Codespace cost runaway
**Solution:**
```bash
# Check Codespaces in use
gh codespace list

# Stop unused ones
gh codespace stop --codespace <codespace-name>

# Auto-stop configuration
# In GitHub: Settings → Codespaces → Set stop timeout to 15 minutes
```

### Issue: Slow Live Share sessions
**Solution:**
- Limit participants to 2-3 people
- Close unnecessary VS Code extensions
- Use dedicated low-latency network (not WiFi)
- Max session 2 hours, take breaks

### Issue: AI review caught nothing, human found bug
**Solution:**
- Add this bug pattern to team's security checklist
- Consider training CodeRabbit with feedback
- Use for automated checks only; humans make final decision

---

## Success Checklist

- [ ] Git workflow agreed upon (main/develop/feature branches)
- [ ] CI/CD pipeline green (linting, tests, type checks)
- [ ] Code review SLAs defined (e.g., 24h response time)
- [ ] Async communication as default (Slack for discussions)
- [ ] Documentation updated in same PR
- [ ] Pre-commit hooks installed locally
- [ ] Branch protection rules enabled
- [ ] Incident response plan created
- [ ] On-call rotation established
- [ ] Team trained on tool usage

---

**Version:** 1.0
**Updated:** November 2025
**Ready to Use:** Yes
