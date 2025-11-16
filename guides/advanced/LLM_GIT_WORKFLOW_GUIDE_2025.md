# LLM + Git Workflow Guide 2025

This guide provides step-by-step workflows for integrating LLM coding assistants with visual git tools in 2025.

---

## Part 1: GitKraken MCP + Claude Code Workflow

### The Most Advanced Workflow (Recommended for AI-First Development)

**Setup Time**: 15 minutes | **Complexity**: Moderate | **Best For**: Teams building with AI agents

#### Prerequisites
```bash
# Install GitKraken CLI
# macOS:
brew install gitkraken-cli
# Windows (Chocolatey):
choco install gitkraken-cli
# Linux (snap):
snap install gitkraken

# Install Claude Code VSCode extension
# In VS Code: Extensions > Search "Claude Code" > Install

# Install Node.js (for some MCP features)
node --version  # Should be v18+
```

#### Step 1: Initialize GitKraken MCP Server

```bash
# Navigate to your project
cd /path/to/your/project

# Initialize MCP for the current directory
gk mcp init

# Start the MCP server (runs as service)
gk mcp start

# Verify it's running
gk mcp status
# Output: ✓ MCP Server running on localhost:3001
```

#### Step 2: Configure LLM Provider

```bash
# Option 1: Use Claude (Recommended)
gk config set ai.provider anthropic
gk config set anthropic.api_key "your-api-key"

# Option 2: Use GitHub Copilot
gk config set ai.provider github

# Option 3: Use local Ollama (most private)
gk mcp config --provider ollama
gk config set ollama.endpoint http://localhost:11434
gk config set ollama.model llama2  # or other local model

# Option 4: Use Google Gemini
gk config set ai.provider gemini
gk config set gemini.api_key "your-api-key"

# Verify configuration
gk config get ai.provider
```

#### Step 3: Connect Claude Code to GitKraken MCP

```json
// .anthropic/config.json (create in project root)
{
  "mcp_servers": {
    "gitkraken": {
      "command": "gk",
      "args": ["mcp", "stdio"],
      "enabled": true
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/project"],
      "enabled": true
    }
  }
}
```

#### Step 4: Workflow - Implementing a Feature with AI

**Scenario**: Add dark mode toggle to React app

##### Phase 1: Planning (2 minutes)

```markdown
Open Claude Code in VS Code:
1. Click "Claude Code" panel
2. Ask: "I want to add a dark mode toggle to this React app.
         Can you propose a 3-step implementation plan?
         Keep each step under 15 lines of code change."

Claude will:
- Read git history via GitKraken MCP
- Understand existing patterns
- Propose plan like:
  1. Create DarkModeContext using existing pattern
  2. Add toggle UI in Header component
  3. Update CSS to support dark theme

✓ Review plan, approve "Step 1"
```

##### Phase 2: Branching (2 minutes)

```bash
# Claude can create branch via MCP, or do it manually:
git checkout -b feature/dark-mode

# Push to remote
git push -u origin feature/dark-mode
```

##### Phase 3: Implementation Step 1 (10 minutes)

```markdown
Back in Claude Code:

Ask: "Implement step 1: Create DarkModeContext.
     I'm using TypeScript and React 18.
     Put it in src/context/DarkModeContext.ts
     Make it similar to existing contexts in this project."

Claude will:
- Analyze existing context files via MCP
- Generate TypeScript context matching style
- Create isolated diff (< 50 lines)

✓ Review diff in Claude panel
✓ Approve implementation
✓ Claude applies changes locally
```

##### Phase 4: Testing & Validation (5 minutes)

```bash
# In terminal:
npm test   # Run tests
npm run dev # Start dev server

# Claude can comment on test failures:
"The test failed because DarkModeContext needs
 to be wrapped by DarkModeProvider.
 Should I generate the provider component?"

✓ Approve "yes"
```

##### Phase 5: Implementation Step 2 (15 minutes)

```markdown
Ask: "Now implement step 2: Add toggle in Header component.
     Use the existing Button style from src/components/Button.tsx
     Place toggle in top-right of header.
     Keep diff < 100 lines."

Claude generates code based on existing patterns.
```

##### Phase 6: Testing Step 2

```bash
# Toggle should now be visible
npm run dev  # Verify in browser
# Test: Click toggle, dark mode applies ✓
```

##### Phase 7: Implementation Step 3 (20 minutes)

```markdown
Ask: "Implement step 3: Update CSS for dark theme.
     Use CSS variables like existing project does.
     Support both light (default) and dark modes.
     Add toggle persistence to localStorage."

Claude writes CSS and localStorage logic.
```

##### Phase 8: Final Validation (5 minutes)

```bash
# Full test suite
npm test

# Manual testing
npm run dev  # Test light/dark toggle
npm run build # Ensure production build works

# Check coverage
npm run coverage
```

#### Step 5: Commit & Staging with GitKraken AI

At this point, you have all changes locally. Now use GitKraken AI for intelligent commits:

##### Option A: Let GitKraken Organize Commits (Recommended)

```
1. Open GitKraken Desktop
2. Stage all changes (Ctrl/Cmd + A)
3. Click "AI" button → "Organize Commits"
4. GitKraken AI groups related changes:

   Commit 1: "Feature: Add dark mode context"
   - src/context/DarkModeContext.ts
   - src/context/index.ts

   Commit 2: "Feature: Add dark mode toggle UI"
   - src/components/Header.tsx
   - src/components/Header.test.tsx

   Commit 3: "Feature: Dark mode styles"
   - src/styles/theme.css
   - src/App.tsx (localStorage integration)

   Commit 4: "Test: Dark mode theme tests"
   - src/__tests__/darkMode.test.ts

5. Click "Apply Organization"
6. Review commits in GitKraken graph
```

##### Option B: Let GitKraken Generate Commit Messages

```
1. Stage related files (by feature)
2. GitKraken AI → "Generate Commit Message"
3. AI analyzes staged changes:
   Input:  Files: Header.tsx, Header.test.tsx
   Output: "Feature: Add dark mode toggle to header"

4. Adjust if needed, commit
5. Repeat for other file groups
```

#### Step 6: Create PR with AI-Generated Description

```
1. Push commits:
   git push origin feature/dark-mode

2. In GitKraken: Create Pull Request
3. Click AI → "Generate PR Description"
4. GitKraken AI writes:

   Title: Add dark mode toggle with theme persistence

   Description:
   ## What changed
   - Created DarkModeContext for theme state management
   - Added toggle UI in Header component
   - Implemented CSS variables for theme colors
   - Added localStorage persistence for user preference

   ## Testing
   - All unit tests pass
   - Dark/light mode toggle works correctly
   - localStorage persistence verified
   - Responsive design maintained

   ## Checklist
   - [x] Tests pass locally
   - [x] No console errors
   - [x] Accessibility verified

5. Review PR description
6. Adjust if needed
7. Open PR
```

#### Step 7: Merge & Cleanup

```bash
# Option 1: Through GitKraken UI
1. In GitKraken, click "Merge" button
2. Choose merge strategy (typically "Create Merge Commit")
3. Delete feature branch

# Option 2: Through git commands
git checkout main
git pull origin main
git merge feature/dark-mode
git push origin main
git branch -d feature/dark-mode
git push origin --delete feature/dark-mode
```

---

## Part 2: VS Code + Claude Code Workflow

### Quick & Integrated (Best for Iterative Development)

**Setup Time**: 5 minutes | **Complexity**: Simple | **Best For**: Individual devs, small teams

#### Setup

```bash
# 1. Install VS Code (if not already)
# 2. Install Claude Code extension
# 3. Get Anthropic API key from console.anthropic.com
# 4. In VS Code: Command Palette (Cmd/Ctrl + Shift + P)
#    → "Claude Code: Set API Key"
#    → Paste your key
```

#### Workflow - Adding a Feature

```markdown
1. Open codebase in VS Code
2. File → Open Folder (your project)
3. Open Claude Code panel (bottom right)

Task: "Add user authentication to dashboard"

Claude Code workflow:

1️⃣ PLAN PHASE
Ask: "Create a plan for adding user auth to dashboard"

Claude outputs:
---
## Plan: User Authentication

### Step 1: Setup Auth Context
- Create AuthContext.tsx
- Add useAuth hook
- Estimated: 3 files, ~80 lines

### Step 2: Add Login Form
- Create LoginForm component
- Add email/password inputs
- Form validation
- Estimated: 2 files, ~120 lines

### Step 3: Protect Routes
- Create PrivateRoute component
- Update routing
- Redirect unauthenticated users
- Estimated: 2 files, ~50 lines

2️⃣ IMPLEMENTATION PHASE
Approve Step 1:
"Yes, start with step 1. Use TypeScript."

Claude:
- Reads existing code patterns
- Generates AuthContext.tsx
- Creates useAuth hook
- Updates appropriate imports
- Shows diff for review

Review diff (< 200 lines) ✓

3️⃣ TESTING PHASE
"Does this compile? Run tests."

Claude runs:
npm run type-check
npm test -- AuthContext

4️⃣ ITERATION
If errors:
"Fix the TypeScript error in line 42"

Claude fixes and shows new diff.

5️⃣ REPEAT FOR STEPS 2 & 3
Once Step 1 complete, ask:
"Implement step 2: Add login form"
```

#### Multi-Session Development

```markdown
Session 1: Authentication (30 min)
- Created auth context ✓
- Created login form ✓
- Protected routes ✓

Session 2: User Profile (next day)
Ask: "Based on our auth system, add a user profile page"

Claude:
- Reads git history to understand auth
- Sees existing auth pattern
- Proposes consistent profile implementation
- Generates code matching established style
```

#### Checkpointing (Save Intermediate States)

```markdown
After Step 1 of dark mode feature:
1. Commit with clear message
2. Create checkpoint:
   git tag checkpoint/dark-mode-step1
3. Continue developing
4. If issue found, revert:
   git reset --hard checkpoint/dark-mode-step1
```

---

## Part 3: GitHub Desktop + CLI + Copilot Workflow

### Simple & Free (Best for GitHub Teams, Beginner-Friendly)

**Setup Time**: 2 minutes | **Complexity**: Minimal | **Best For**: GitHub-first teams

#### Workflow - Bug Fix

```bash
# 1. Open GitHub Desktop
# 2. Clone/open repository

# 3. Create feature branch:
#    Branch → New Branch
#    Name: "fix/login-validation"

# 4. Make code changes in your editor
#    (GitHub Desktop only handles Git, not coding)

# 5. When ready to commit, use GitHub Copilot CLI:
copilot suggest-commit-message --timeout 30

# Copilot suggests:
# "fix: Improve email validation in login form"

git add .
git commit -m "fix: Improve email validation in login form"

# 6. In GitHub Desktop:
#    Publish branch

# 7. GitHub.com → Create Pull Request (not in Desktop)
```

#### Using GitHub Copilot Agent Mode

```markdown
For complex tasks, use Copilot Agent in VS Code:

1. Install GitHub Copilot extension
2. Open VS Code
3. Open Copilot Chat (Cmd/Ctrl + Shift + I)
4. Activate "agent mode" (... menu → "Agent Mode")
5. Ask: "Refactor the payment module to use async/await"

Copilot Agent:
- Plans changes
- Implements across multiple files
- Runs tests
- Suggests git operations

Then use GitHub Desktop for the commit.
```

---

## Part 4: Sourcetree + External LLM Workflow

### Feature-Rich + Free (Best for Bitbucket, Complex Git)

**Setup Time**: 10 minutes | **Complexity**: Moderate | **Best For**: Teams valuing free, feature-rich tools

#### Workflow - Complex Rebase & AI Development

```markdown
Scenario: Rebase 5 commits, clean up with AI help

1️⃣ CODE DEVELOPMENT (VS Code + Copilot/Claude)
Open code in VS Code with Copilot.
"Implement user roles feature"
Copilot generates code across multiple commits.

2️⃣ ORGANIZE COMMITS (Sourcetree)
Open Sourcetree.

Branch: feature/user-roles (5 messy commits)
- "WIP: start roles"
- "add permission model"
- "fix types"
- "add role components"
- "fix merge conflict"

Right-click branch → "Interactive Rebase"

Sourcetree UI shows each commit:
- Drag to reorder
- Mark "squash" to combine with previous
- Mark "fixup" to silently combine

Result: Clean 3 commits
- "Feature: Add permission model"
- "Feature: Add role components"
- "Test: Role authorization tests"

3️⃣ MERGE (Sourcetree)
Click "Create Pull Request"
Sourcetree shows Jira issues that might relate
Add to pull request description

4️⃣ PUSH & MERGE (Sourcetree)
Push branch
Open GitHub/GitLab
Merge via web UI (or Sourcetree)
```

---

## Part 5: Tower + VS Code Workflow

### Polish + Power Features (Best for Mac Professionals)

**Setup Time**: 5 minutes | **Complexity**: Simple | **Best For**: Mac teams wanting premium experience

#### Workflow - Professional Feature Development

```markdown
Morning Workflow:

1️⃣ FETCH LATEST (Tower)
Open Tower
Press Cmd + Option + F (fetch all)
See which branches updated overnight

2️⃣ CREATE BRANCH (Tower)
Cmd + N → Create feature branch
Set up tracking branch

3️⃣ DEVELOP (VS Code + Copilot)
Open VS Code
Implement feature with Copilot assistance
Generate code, refactor, test locally

4️⃣ COMPLEX GIT (Tower)
Switch to Tower

Scenario: Need to cherry-pick commit from another branch

Tower UI:
- Show commit in History
- Drag and drop to current branch
- Or: Right-click → Cherry-pick

Scenario: Interactive rebase needed

Tower:
- Cmd + Shift + R → Interactive Rebase
- Drag commits to reorder
- Mark "squash" to combine
- Mark "fixup" for hidden combine
- Click "Rebase" button
- Undo with Cmd + Z if needed

5️⃣ CODE REVIEW (Tower)
Tower shows all pull request details:
- Files changed
- Diffs by commit (not cumulative)
- Comments from reviewers
- Request additional info if needed

6️⃣ MERGE (Tower)
Review comments
Address feedback with targeted commits
Final check
Merge via Tower
Delete branch
Undo with Cmd + Z if needed (safety net)
```

---

## Part 6: Best Practices Across All Tools

### Commit Message Standards

```markdown
# Format
<type>: <subject> (< 50 chars)
<blank line>
<body (wrap at 72)>
<blank line>
<footer>

# Examples

GOOD: "feat: Add dark mode toggle with theme persistence"

BETTER (with context):
feat: Add dark mode toggle with theme persistence

- Created DarkModeContext for theme management
- Added toggle UI in Header component
- Implemented CSS variables for theme colors
- Added localStorage for user preference

Closes #1234
Related-to: #5678

BAD: "fix stuff"
BAD: "Work in progress"
BAD: "Updated code"
```

### AI-Generated vs Manual Commits

```markdown
WHEN TO LET AI GENERATE COMMITS:
✓ Refactoring large codebases
✓ Dependency updates
✓ Boilerplate generation
✓ Test suite additions
✓ Documentation updates

WHEN TO WRITE MANUALLY:
✓ Critical bug fixes (explain why)
✓ Breaking changes (explain impact)
✓ Algorithm improvements (document approach)
✓ Complex logic changes (explain reasoning)

HYBRID APPROACH:
1. Let AI generate commit message
2. Review and edit for accuracy
3. Add context if needed
4. Commit
```

### Security: API Keys & Tokens

```bash
# NEVER commit these:
.env           # Add to .gitignore
.env.local     # Add to .gitignore
credentials/   # Add to .gitignore
secrets.json   # Add to .gitignore

# SAFE: Use environment variables
export ANTHROPIC_API_KEY="sk-ant-..."
# Or GitHub encrypted secrets for CI/CD

# SAFER: Use local LLM (Ollama)
# Zero external API calls, stays on device

# MCP SAFETY (GitKraken):
# - No tokens passed to agents
# - Role-based permissions
# - Scoped access per repository
```

---

## Part 7: Troubleshooting LLM + Git Issues

### Problem: AI Generated Code Has Bugs

```markdown
Solution:

1. Claude Code: Run tests first
   "Run tests: npm test"
   → Identify failing tests

2. Ask Claude to fix:
   "Test failed: expected true, got false
    in src/__tests__/component.test.ts line 23
    Please fix the implementation"

3. Claude fixes, shows new diff

4. Verify: npm test passes ✓

5. Stage, commit, push
```

### Problem: AI Generated Commit Has Wrong Scope

```markdown
Solution:

1. GitKraken: Don't use AI-generated message
2. Manually edit commit message:

   Wrong: "Refactor: Update database queries"
   Right: "Refactor: Optimize user search queries (10x faster)"

3. Explain the change in message
4. Commit
```

### Problem: MCP Connection Failing

```bash
# Debug GitKraken MCP

# Check if MCP server is running
gk mcp status

# If not running:
gk mcp start

# If server crashes:
gk mcp stop
gk mcp restart

# Check MCP logs
gk mcp logs --tail 50

# Reset MCP
gk mcp reset

# Verify Git connection
gk git status  # Should show current repo status
```

### Problem: VS Code Claude Code Not Accessing Files

```markdown
Solution:

1. Verify MCP filesystem server is running:
   .anthropic/config.json has filesystem enabled

2. Check file permissions:
   ls -la file.ts
   Should be readable

3. Verify path is correct in MCP config:
   "args": ["/path/to/project"]  ✓

4. Restart VS Code
   Cmd/Ctrl + Shift + P → Reload Window
```

### Problem: Large Commit History Slows Down AI

```markdown
Solution:

1. Limit history for AI context:
   .anthropic/config.json:
   {
     "git_history_limit": 50  # Last 50 commits only
   }

2. Or use shallow clone:
   git clone --depth=1 repo.git
   # Fetch more history as needed:
   git fetch --unshallow

3. Or let AI know to ignore history:
   Claude: "Ignore git history. Just implement..."
```

---

## Part 8: Team Coordination with LLM Tools

### Establishing Team Standards

```markdown
# .github/CONTRIBUTING.md

## Development Workflow

### 1. Branch Naming
- Feature: feature/description
- Bug: fix/description
- Chore: chore/description

### 2. Commits
- Use AI to generate commit messages
- Minimum: Semantic message type
- Preferred: Include context/why in body
- Never: Generic messages like "fix" or "update"

### 3. Code Review
- Verify AI-generated code behaves correctly
- Check security implications
- Ensure style matches project
- Test locally before approval

### 4. LLM Tools Setup
- Use GitKraken Pro + MCP for team
- Or VS Code + Copilot/Claude Code
- Avoid mixing tools (standardize)

### 5. AI Agent Guidelines
- Agents should only modify files in:
  src/, tests/, docs/
- Agents should NOT modify:
  .env, secrets, infrastructure/
- All agent commits require human review
- Tag AI-generated commits: AI-generated
```

### Example Team MCP Policy

```yaml
# .mcp-policy.yaml

# GitKraken MCP access control for team

roles:
  developer:
    permissions:
      - read:repo
      - write:commits
      - read:pr
      - create:branch
    restricted_paths:
      - Dockerfile
      - infrastructure/
      - .env*

  lead:
    permissions:
      - read:repo
      - write:commits
      - write:pr
      - write:force-push
      - admin:team

  agent:
    permissions:
      - read:repo
      - write:commits
      - create:branch
    required_review: true
    scope: ['src/', 'tests/', 'docs/']
```

---

## Part 9: Metrics & Monitoring

### Track AI Improvement

```markdown
Metric 1: Commit Quality
- Before: Generic commits, poor history
- After: Semantic commits, clear intent
- Measure: Code review comments decreased 40%

Metric 2: Development Speed
- Before: 3 hours to implement feature
- After: 1.5 hours (code gen + review)
- Measure: Sprint velocity increased 25%

Metric 3: Code Coverage
- AI generating tests increases coverage
- Measure: Test coverage: 65% → 85%

Metric 4: Bug Escape Rate
- AI-generated code needs testing
- Measure: QA bugs stable or decreased

Metric 5: Team Satisfaction
- Survey: 80% prefer AI-assisted development
- Feedback: Faster feedback loop appreciated
```

---

## Part 10: Advanced Patterns (2025)

### Multi-Agent Coordination

```markdown
Scenario: Large refactoring across multiple services

Agent 1 (Claude Code):
"Refactor auth service to use new pattern"
- Generates implementation
- Creates commit: "refactor: auth-service"
- Creates PR

Agent 2 (Copilot Agent):
"Update all services to use new auth pattern"
- Reads Agent 1's PR
- Updates services similarly
- Creates coordinated PRs

Agent 3 (GitKraken):
"Organize all auth refactoring PRs, generate descriptions"
- Consolidates related commits
- Creates coordinated PR descriptions
- Aligns across services

Result: Coordinated 3-service refactoring
      All changes traceable to original intent
      All changes use consistent patterns
```

### Autonomous PR Creation

```markdown
Using GitKraken MCP + LLM agent:

Request: "Update all npm dependencies
          across 5 repositories
          test changes locally
          create PRs for review"

GitKraken MCP + Agent:
1. Checks each repo status
2. Creates feature branches (gk git branch ...)
3. Updates package.json (via agent)
4. Runs npm install, npm test
5. Commits changes (gk git commit)
6. Creates PRs (gk github pr create)

Each PR includes:
- Updated dependencies listed
- Test results
- Changelog generated
- Ready for review

Human review + merge completes.
```

### Local-Only Development (Maximum Privacy)

```markdown
Setup:

1. Use local Ollama for code generation
   ollama pull llama2
   ollama serve

2. Use GitKraken with local Ollama
   gk config set ollama.endpoint http://localhost:11434

3. Use VS Code with Continue extension + Ollama
   No external API calls

4. All development stays on device
   No code sent to cloud
   No API costs

Trade-off: Slower generation, simpler models
         But: Perfect privacy for sensitive code
```

---

## Quick Reference: Commands by Tool

### GitKraken CLI
```bash
gk mcp init               # Initialize MCP
gk mcp start              # Start MCP server
gk mcp status             # Check server status
gk config set ...         # Configure settings
gk auth login             # Authenticate
```

### Claude Code (VS Code)
```
Cmd/Ctrl + Shift + I      # Open Claude chat
/plan                     # Ask for plan
/implement                # Implement selected
/test                     # Run tests
/explain                  # Explain changes
```

### GitHub CLI
```bash
gh repo clone             # Clone repo
gh pr create              # Create PR
gh pr view                # View PR details
gh issue list             # List issues
```

### Git Commands (Terminal)
```bash
git checkout -b feature/name  # Create branch
git add .                     # Stage changes
git commit -m "..."           # Commit
git push                      # Push branch
git pull                      # Pull latest
git rebase main               # Rebase on main
git rebase -i HEAD~5          # Interactive rebase
```

---

## Summary

**Recommended Stack for 2025**:

| Role | Tools | Focus |
|------|-------|-------|
| **Individual Developer** | VS Code + Claude Code | Maximum integration |
| **GitHub Team** | GitHub Desktop + Copilot | Simplicity |
| **Multi-Platform Team** | GitKraken + MCP | Consistency + AI |
| **Bitbucket Team** | Sourcetree + VS Code | Free + powerful |
| **Enterprise** | GitKraken Enterprise + Local LLM | Security + privacy |

**Start Here**: Choose one stack, learn it deeply, then optimize.

---

**Last Updated**: November 2025
**Next Review**: Q1 2026
