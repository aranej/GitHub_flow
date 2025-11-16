# Git Debugging Quick Reference - 2025

## Core Commands

### Git Bisect

```bash
# Start bisect (provide bad and good commits)
git bisect start <bad> <good>

# Mark current commit
git bisect good          # Current is working
git bisect bad           # Current is broken

# Automated bisect (requires test script with proper exit codes)
git bisect run <test-script.sh>

# Cleanup
git bisect reset

# View progress
git bisect log
```

### Exit Codes for Bisect Scripts

```
0    → Good commit (keep searching older)
1    → Bad commit (keep searching newer)
125  → Skip commit (cannot test - broken build)
>127 → Error in script
```

### Search Git History

```bash
# Find commits affecting code pattern
git log -G "<pattern>" --oneline

# Find commits changing specific value
git log -S "<value>" --oneline

# Search commit messages
git log --grep="<pattern>" --oneline

# Combined search
git log -G "pattern" --author="alice" --since="2 days ago" --oneline

# Show patches for search results
git log -G "pattern" -p
```

### Blame & Attribution

```bash
# Show blame for specific file
git blame <file>

# Blame for specific range
git blame -L 50,100 <file>

# Show full commit for blame line
git blame -L 50,100 -C <file>

# Find who deleted code
git log -S "deleted_code" --oneline -- <file>

# Timeline of changes to file
git log -p -- <file> | head -100
```

### Advanced Analysis

```bash
# View commit details
git show <commit>
git show --stat <commit>
git show --unified=3 <commit>

# Compare commits
git diff <commit1> <commit2>

# Log with graph
git log --oneline --graph --all

# Filter by author
git log --author="<name>" --oneline

# Filter by date
git log --since="2 weeks ago" --until="1 week ago" --oneline

# File history
git log --oneline -- <file>
```

---

## Tool Comparison

| Tool | Purpose | Installation | Use Case |
|------|---------|--------------|----------|
| **git bisect** | Binary search for regression | Built-in | Finding exact breaking commit |
| **GitLens** | Code blame visualization | VS Code extension | Quick inline blame view |
| **Hercules** | Repository metrics | GitHub/CLI | Code ownership & trends |
| **git-history** | Temporal data tracking | `pip install` | Historical data analysis |
| **BlameThrower** | Blame + static analysis | `pip install` | Quality metrics by author |
| **gitinspector** | Statistical analysis | `pip install` | Contribution & activity stats |
| **Copilot Review** | AI code review | GitHub feature | Automated PR review |

---

## Common Patterns

### Pattern 1: Find Regression Commit (5 min)

```bash
# When: Feature broke in last few commits
git bisect start HEAD HEAD~20
git bisect run bash test.sh
```

### Pattern 2: Blame Specific Line (2 min)

```bash
# When: Need to understand specific code
git blame -L 45,50 app.js
git show <commit>
```

### Pattern 3: Search Code History (3 min)

```bash
# When: Tracking when feature was added/removed
git log -G "featureName" --oneline
git log -S "deprecated_api" -p
```

### Pattern 4: Performance Regression (10 min)

```bash
# When: App got slower
git bisect start HEAD~50 HEAD
git bisect run bash benchmark.sh
```

### Pattern 5: Data Quality Issue (15 min)

```bash
# When: Data pipeline broken
git bisect run bash validate-output.sh
# Script compares output against baseline
```

---

## Exit Code Reference

### For Bisect Run Scripts

```bash
#!/bin/bash

# Build attempt
npm run build
case $? in
    0)  echo "Build OK" ;;
    *)  echo "Cannot test - build broken"; exit 125 ;;
esac

# Run test
npm test
case $? in
    0)  exit 0  # Good commit
    *)  exit 1  # Bad commit
esac
```

### Common Patterns

```bash
# Skip if build is broken
npm run build || exit 125

# Skip if setup fails
npm install || exit 125

# Run test
npm test || exit 1

# Exit clean if all good
exit 0
```

---

## GitHub Actions Integration

### Minimal Bisect Workflow

```yaml
name: Auto Bisect
on: workflow_dispatch
jobs:
  bisect:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - run: |
          git bisect start HEAD HEAD~50
          git bisect run bash test.sh
      - run: git show $(git rev-parse HEAD)
```

### Enable Debug Logging

```yaml
env:
  ACTIONS_RUNNER_DEBUG: true
  ACTIONS_STEP_DEBUG: true
```

### Use Copilot Review

```yaml
- uses: github/copilot-code-review-action@v1
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

---

## Performance Tips

| Scenario | Optimization |
|----------|-------------|
| Large repo | Use `git bisect skip` for broken commits |
| Slow tests | Increase timeout in bisect |
| Many commits | Use `--no-merges` in log |
| Large files | Use `git log -p -- <file>` with head limit |
| Network slow | Use local clones |

---

## Debugging Checklist

When regression detected:

- [ ] Identify good vs bad commits
- [ ] Write test script with proper exit codes
- [ ] Run `git bisect start <bad> <good>`
- [ ] Execute `git bisect run <test-script>`
- [ ] Review culprit with `git show --stat <commit>`
- [ ] Check changes with `git show <commit>`
- [ ] Search related commits with `git log -G "<pattern>"`
- [ ] Blame affected lines with `git blame -L <range>`
- [ ] Create issue or fix

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Wrong exit codes | Use 0 for good, 1 for bad, 125 for skip |
| Test script times out | Add timeout handling |
| Dependencies not installed | Include install step in bisect script |
| Build artifacts stale | Clean before build in script |
| Bisecting wrong direction | Check bad/good assignment |
| Skipping too many commits | Make test script more robust |

---

## One-Liners

```bash
# Find all commits changing a function
git log -G "function_name" --oneline

# Show commits by author in date range
git log --author="alice" --since="2025-01-01" --oneline

# Find when code was deleted
git log -S "deleted_code" --diff-filter=D --oneline

# Show blame for entire file
git blame <file> | head -20

# Compare current vs commit
git diff <commit> HEAD -- <file>

# Show detailed stats for commit
git show --stat <commit>

# Get all commits affecting file
git log --oneline -- <file>

# Find commits by commit message
git log --grep="bug fix" --oneline

# Show file at specific commit
git show <commit>:<file>

# Count commits by author
git log --format='%an' | sort | uniq -c | sort -rn
```

---

## Workflow Decision Tree

```
Regression Found
│
├─ Know when it broke?
│  ├─ NO → Search with git log -G
│  └─ YES → Use git bisect
│
├─ Know which file?
│  ├─ NO → Search with grep + git log
│  └─ YES → Use git blame
│
├─ Need historical context?
│  ├─ Trends → Use Hercules
│  ├─ Timeline → Use git-history
│  └─ Quality → Use BlameThrower
│
└─ Integration with CI?
   ├─ GitHub → Use GitHub Actions
   ├─ GitLab → Use GitLab CI
   └─ Other → Integrate shell script
```

---

## File Structure for New Projects

```
project/
├── scripts/
│   ├── bisect-runner.sh          # Universal bisect wrapper
│   ├── check-regression.sh       # Comprehensive regression check
│   ├── search-history.sh         # Git history search utility
│   └── perf-regression-check.sh  # Performance testing
│
├── .github/workflows/
│   ├── auto-bisect.yml           # Automated bisect workflow
│   ├── regression-tests.yml      # Scheduled regression check
│   └── quality-history.yml       # Daily quality metrics
│
├── tests/
│   ├── regression/
│   │   ├── performance.test.js
│   │   ├── data-quality.test.js
│   │   └── api-contract.test.js
│   └── fixtures/
│       └── expected-output.json
│
├── perf-baseline.txt             # Performance baseline
└── bisect-reports/               # Historical bisect results
    └── 20250109-120000.txt
```

---

## Learning Resources

- **Official Docs**: https://git-scm.com/docs/git-bisect
- **Interactive Tutorial**: https://github.com/lwjgl/lwjgl3/wiki/Building-LWJGL
- **Video Guide**: Git Bisect by Traversy Media
- **Practice**: Create test repos with intentional bugs, practice bisecting

---

## Advanced Techniques

### Bisect with Custom Test

```bash
# Test can be any command that exits with proper codes
git bisect run python test_regression.py --model v1.0

# Or complex bash with multiple conditions
git bisect run sh -c 'npm build && npm test && npm lint'

# With conditional skipping
git bisect run sh -c 'npm build || exit 125; npm test'
```

### Resume Bisect

```bash
# If interrupted, resume from where you left off
git bisect log       # See progress
git bisect replay <log-file>  # Replay from saved log
```

### Bisect Automation via cron

```bash
# Run weekly automated bisect check
0 2 * * * /path/to/auto-bisect.sh

# Parse results and alert
git bisect log | mail -s "Weekly Bisect Report" team@example.com
```

---

## Real-World Example Command

**Finding performance regression in last 100 commits:**

```bash
#!/bin/bash

# 1. Create test script
cat > perf-test.sh <<'EOF'
#!/bin/bash
npm run build || exit 125
TIME=$( { time npm test; } 2>&1 | grep real | awk '{print $2}' )
echo "Test time: $TIME"
[ "$TIME" < "2m30s" ] && exit 0 || exit 1
EOF

# 2. Run bisect
git bisect start HEAD HEAD~100
git bisect run bash perf-test.sh

# 3. Examine result
CULPRIT=$(git rev-parse HEAD)
echo "Found culprit: $CULPRIT"
git show --stat $CULPRIT
git show -U5 $CULPRIT | head -50

# 4. Cleanup
git bisect reset
```

---

**Updated: 2025-11-09** | **Version: 1.0.0**

