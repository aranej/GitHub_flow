# Advanced Git Debugging Workflows for 2025

## Table of Contents
1. [Git Bisect Automation](#git-bisect-automation)
2. [CI/CD Integration](#cicd-integration)
3. [Git Blame Alternatives](#git-blame-alternatives)
4. [Historical Analysis Tools](#historical-analysis-tools)
5. [Debug Workflow Patterns](#debug-workflow-patterns)
6. [GitHub Integration](#github-integration)
7. [AI Code Regression Detection](#ai-code-regression-detection)
8. [Practical Examples](#practical-examples)

---

## Git Bisect Automation

### Overview

`git bisect run` automates the debugging process by performing binary search through commit history. A script automatically determines if each commit is "good" or "bad" based on exit codes.

### Exit Code Convention

- **Exit 0**: Commit is "good" (working)
- **Non-zero (except 125)**: Commit is "bad" (broken)
- **Exit 125**: Skip this commit (cannot test - broken build)
- **Exits > 127**: Special error handling

### Basic Automated Bisect Workflow

```bash
# Start bisect with a known good commit and bad commit
git bisect start HEAD v2.1.0

# Run automated test script
git bisect run ./test-regression.sh

# Reset when done
git bisect reset
```

### Advanced Script Patterns

#### 1. Build Verification Script
```bash
#!/bin/bash
# Exit with 0 if good, 1 if bad, 125 if cannot test

# Try to build
make clean && make || exit 125

# Run specific test
npm test -- --testNamePattern="regression" || exit 1

exit 0
```

#### 2. Single-Line Command Variant
```bash
git bisect run sh -c "make || exit 125; npm test -- --testNamePattern=regression"
```

#### 3. Performance Regression Detection
```bash
#!/bin/bash
# Detect if performance has regressed beyond threshold

make || exit 125

# Benchmark current version
CURRENT_TIME=$( ./benchmark.sh )
THRESHOLD=1000  # milliseconds

if (( $(echo "$CURRENT_TIME > $THRESHOLD" | bc -l) )); then
    exit 1  # Performance regression detected
else
    exit 0  # Performance is acceptable
fi
```

#### 4. Handling Complex Build Systems
```bash
#!/bin/bash

# For multi-step builds that might fail partially
if ! npm run build; then
    exit 125  # Skip: build is broken
fi

if ! npm run test; then
    exit 1    # Bad commit: tests fail
fi

# Check for specific regression
if grep -q "ERROR: Feature X broken" test-output.log; then
    exit 1
else
    exit 0
fi
```

### Key Advantages

- **Speed**: Binary search reduces iterations from O(n) to O(log n)
- **Automation**: No manual testing between commits
- **Precision**: Identifies exact commit causing regression
- **Documentation**: Script serves as regression test specification

### Best Practices

1. **Keep scripts external** to repository to avoid interference
2. **Test script thoroughly** before running bisect
3. **Handle build failures** with exit code 125
4. **Use short script timeouts** to prevent hanging
5. **Log results** for post-analysis

---

## CI/CD Integration

### GitHub Actions: Automated Bisect Workflow

```yaml
name: Automated Bisect on Regression
on:
  workflow_dispatch:
    inputs:
      bad_commit:
        description: 'Bad commit (has regression)'
        required: true
      good_commit:
        description: 'Good commit (works correctly)'
        required: true

jobs:
  bisect:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Run Automated Bisect
        run: |
          git bisect start ${{ github.event.inputs.bad_commit }} ${{ github.event.inputs.good_commit }}
          git bisect run bash -c 'npm install && npm test || exit 1'

      - name: Report Results
        if: always()
        run: |
          git bisect log > bisect-results.txt
          cat bisect-results.txt

      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: bisect-results
          path: bisect-results.txt
```

### GitLab CI: Scheduled Regression Detection

```yaml
automated_bisect:
  stage: test
  script:
    - git bisect start HEAD HEAD~100
    - git bisect run ./scripts/regression-check.sh
    - git bisect log
  artifacts:
    paths:
      - bisect-results.txt
  only:
    - schedules
  tags:
    - docker
```

### Nightly Build Integration Pattern

```bash
#!/bin/bash
# Run as part of nightly CI pipeline

RESULTS_DIR="bisect-results/$(date +%Y-%m-%d)"
mkdir -p "$RESULTS_DIR"

# Find recent regressions in build
if npm run test &> /dev/null; then
    echo "Tests passing"
    exit 0
else
    echo "Regression detected, running bisect"

    # Find last passing commit
    LAST_PASS=$(git log --oneline -n 100 | while read commit msg; do
        git checkout "$commit" 2>/dev/null
        if npm test &>/dev/null; then
            echo "$commit"
            break
        fi
    done)

    git bisect start HEAD "$LAST_PASS"
    git bisect run ./test-suite.sh

    CULPRIT=$(git bisect log | tail -1)
    echo "Regression introduced in: $CULPRIT" > "$RESULTS_DIR/results.txt"

    # Alert team
    curl -X POST "$SLACK_WEBHOOK" -d "{\"text\":\"Regression found: $CULPRIT\"}"
fi
```

---

## Git Blame Alternatives

### 1. GitLens (VS Code)

**Installation**
```bash
# Install extension in VS Code marketplace
# Search for "GitLens" by Eric Amodio
```

**Features**
- Inline blame annotations
- Commit history heatmap
- Code lens showing blame context
- File/line-level drill-down
- Git graph visualization

**Usage**
```
// Press Ctrl+K Ctrl+B to show blame
// Hover over code for commit details
// Click to view full commit
```

### 2. Flame (Terminal/CLI)

**Installation & Usage**
```bash
git clone https://github.com/lingo/flame.git
cd flame

# Show prettier git blame output
./flame.py <file>

# With line numbers
./flame.py -n <file>

# Compare authors
./flame.py --author-stats <file>
```

**Advantages**
- Terminal-friendly formatting
- Syntax highlighting support
- Faster than `git blame` for large files
- Minimal dependencies

### 3. BlameThrower - Blame + Static Analysis

**Installation**
```bash
pip install blamethrower
```

**Usage Pattern**
```bash
# Analyze Python code for bugs and show authors
blamethrower --repo . --analyzer pylint

# Generate JSON report
blamethrower --repo . --analyzer pylint --format json > blame-report.json

# Cross multiple analyzers
blamethrower --repo . --analyzer pylint,mypy --output-file bug-report.tsv
```

**Key Insight**: Combines "who wrote it" with "what bugs exist" for actionable debugging metrics.

### 4. Git Log Pickaxe - Search Code Changes

```bash
# Find all commits that added or removed specific line
git log -S "function_name" --oneline

# With patch details
git log -S "critical_value" -p

# By author who changed specific pattern
git log -S "security_token" --all -- <file>

# Range of commits
git log -S "deprecated_api" v2.0..v3.0 -p
```

### 5. Advanced Filtering Workflows

```bash
# Show commits affecting specific code pattern
git log --all -G "try.*catch" -- "*.js"

# Date-based blame (commits in timeframe)
git log --since="2 weeks ago" --until="1 week ago" -- <file>

# Author + file + pattern (triple filter)
git log --author="alice" --grep="regression" -- tests/

# Find who deleted critical code
git log -S "ENCRYPTION_KEY" --diff-filter=D

# Trace function lifetime
git log -p -S "function myFunc" -- src/
```

---

## Historical Analysis Tools

### 1. Hercules - Repository Analysis Engine

**Installation**
```bash
# Download binary
wget https://github.com/src-d/hercules/releases/download/v<version>/hercules

# Or via Docker
docker pull srcd/hercules
```

**Usage**
```bash
# Analyze full repository
hercules -r /path/to/repo

# Generate burndown chart
hercules -r /path/to/repo --burndown > burndown.pb

# Export as JSON
hercules -r /path/to/repo --json > analysis.json
```

**Key Metrics**
- **Line burndown**: Track code age and evolution
- **Code ownership**: Attribution over time
- **File coupling**: Files modified together
- **Developer analytics**: Contribution patterns
- **Structural analysis**: Function modification frequency

**GitHub Actions Integration**
```yaml
- name: Repository Analysis with Hercules
  run: |
    hercules -r . --json > repo-analysis.json
    echo "Code ownership trends:"
    jq '.OwnershipMatrix' repo-analysis.json
```

### 2. git-history - SQLite-Based History Tracking

**Installation**
```bash
pip install git-history
```

**Usage**
```bash
# Basic file tracking
git-history -r <repo> <file.json> tracked_changes.db

# Track individual records with deduplication
git-history -r <repo> <file.json> tracked_changes.db --id id

# Analyze multiple files
git-history -r <repo> data/*.json history.db --id record_id

# Query results with sqlite3
sqlite3 tracked_changes.db "SELECT * FROM item_changed LIMIT 10;"
```

**Database Schema** (with --id)
```
commits          - Git metadata (hash, author, date)
item             - Current state of records
item_version     - Historical snapshots
columns          - Field name registry
item_changed     - Many-to-many change mapping
namespaces       - Multi-file support
```

**Analysis Query Examples**
```sql
-- Track changes to specific item over time
SELECT commit_id, columns.name, item_version.value
FROM item_version
JOIN columns ON item_version.column_id = columns.id
WHERE item_id = 42
ORDER BY commit_id DESC;

-- Find when field last changed
SELECT MAX(commit_id) as last_change
FROM item_changed
WHERE item_id = 42 AND column_id = 3;

-- Identify high-churn files
SELECT namespace, COUNT(DISTINCT item_id) as items_changed
FROM item_version
GROUP BY namespace
ORDER BY items_changed DESC;
```

### 3. gitinspector - Statistical Analysis

**Installation**
```bash
pip install gitinspector
```

**Usage**
```bash
# Generate HTML report
gitinspector.py -r /path/to/repo --format html > report.html

# Timeline analysis
gitinspector.py -r /path/to/repo --timeline

# Author statistics
gitinspector.py -r /path/to/repo --authors

# JSON output for custom analysis
gitinspector.py -r /path/to/repo --format json > stats.json
```

**Metrics Provided**
- Commits per author
- Code churn trends
- Cumulative work by author
- Timeline of activity

---

## Debug Workflow Patterns

### Pattern 1: Root Cause Analysis Flow

```
Symptom Detected
    ↓
Enable Debug Logging
    ↓
Run Reproduction Script
    ↓
Analyze Error Logs
    ↓
Narrow with Git Log Search
    ↓
Run Git Bisect
    ↓
Inspect Culprit Commit
    ↓
Review Code Changes
    ↓
Implement Fix
    ↓
Verify with Regression Test
```

### Pattern 2: Historical Investigation

```bash
#!/bin/bash
# Comprehensive historical debugging

TARGET_FEATURE="$1"
REPO_PATH="$2"

echo "=== Searching history for $TARGET_FEATURE ==="

# 1. Find introduction commit
echo "When was it introduced?"
git log -S "$TARGET_FEATURE" --oneline | head -5

# 2. Find modifications
echo "Recent modifications:"
git log --all -G "$TARGET_FEATURE" --oneline -n 10

# 3. Track author changes
echo "Authors who worked on this:"
git log --all -G "$TARGET_FEATURE" --format="%an" | sort | uniq -c | sort -rn

# 4. Timeline of changes
echo "Timeline:"
git log --all -G "$TARGET_FEATURE" --format="%ai %s" | sort

# 5. Current state
echo "Current usage:"
grep -rn "$TARGET_FEATURE" "$REPO_PATH" --include="*.js" --include="*.py"
```

### Pattern 3: Performance Regression Investigation

```bash
#!/bin/bash
# Identify performance degradation

BASELINE_COMMIT="${1:-HEAD~50}"
BASELINE_TIME=$(git show $BASELINE_COMMIT:src/performance.txt | grep "runtime:" | cut -d' ' -f2)

echo "Baseline performance: ${BASELINE_TIME}ms"

# Test recent commits
for commit in $(git log --oneline -n 20 | awk '{print $1}'); do
    git checkout "$commit" 2>/dev/null
    CURRENT_TIME=$(./ benchmark.sh 2>/dev/null | grep "runtime:" | cut -d' ' -f2)

    if [ -z "$CURRENT_TIME" ]; then
        echo "$commit: FAILED TO TEST"
    else
        DEGRADATION=$((CURRENT_TIME - BASELINE_TIME))
        if [ "$DEGRADATION" -gt 100 ]; then
            echo "$commit: REGRESSION DETECTED (+${DEGRADATION}ms)"
        else
            echo "$commit: OK (${CURRENT_TIME}ms)"
        fi
    fi
done
```

### Pattern 4: Feature Flag Debugging

```bash
#!/bin/bash
# Trace feature flag changes across commits

FEATURE_FLAG="FEATURE_X_ENABLED"

echo "=== Tracing $FEATURE_FLAG ==="

# Find commits that changed this flag
git log -p -S "$FEATURE_FLAG" --all -- "*.py" "*.js" |
    grep -A 5 -B 5 "$FEATURE_FLAG"

# Show current usage
echo "Current usage:"
git grep "$FEATURE_FLAG"

# Timeline
git log --oneline -G "$FEATURE_FLAG" --all
```

---

## GitHub Integration

### GitHub Actions: Enhanced Debugging Workflow

#### 1. Enable Debug Logging

```yaml
name: Debug-Enabled CI
on: [push, pull_request]

env:
  ACTIONS_RUNNER_DEBUG: true      # Runner-level debugging
  ACTIONS_STEP_DEBUG: true         # Step-level debugging

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run tests with debug output
        run: |
          set -x  # Shell debug mode
          npm test
```

#### 2. Interactive SSH Debugging with tmate

```yaml
name: Debug with SSH
on:
  push:
    branches:
      - debug/*
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Run tests
        run: npm test

      - name: Debug session on failure
        if: failure()
        uses: mxschmitt/action-tmate@v3
        with:
          timeout-minutes: 15
          # Connect via: ssh <session-url>
```

#### 3. GitHub Copilot Code Review Integration

```yaml
name: PR Review with Copilot
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Copilot Code Review
        uses: github/copilot-code-review-action@v1
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          instructions: |
            Focus on:
            - Performance issues
            - Potential regressions
            - Type safety violations
            - Test coverage gaps
```

### GitHub Copilot Debugging Commands

```markdown
## In Pull Request Comments

@copilot review
- Performs comprehensive review with full codebase context

@copilot explain /path/to/file.js
- Explains code changes and their impact

@copilot fix
- Applies suggested fixes in stacked PR

@copilot test
- Reviews test coverage and suggests improvements
```

### Custom Instructions for Code Review

**File: `.github/copilot-instructions.md`**

```markdown
# Code Review Priorities

You are reviewing pull requests for a TypeScript/Node.js application.

## What to focus on:

1. **Performance**:
   - Flag O(n²) algorithms
   - Identify unnecessary re-renders
   - Check database query efficiency

2. **Testing**:
   - Verify test coverage > 80%
   - Ensure integration tests exist
   - Check regression test additions

3. **Regression Risk**:
   - Flag breaking changes
   - Highlight API modifications
   - Check deprecation handling

## Code Standards:
- Enforce strict type checking
- Require unit tests for complex logic
- Prefer composition over inheritance
- Use error boundaries for React code

## AI Code Specific:
- Verify LLM outputs have safeguards
- Check for prompt injection vulnerabilities
- Validate model version compatibility
```

### GitHub CLI for Bisect Automation

```bash
#!/bin/bash
# Automate bisect workflow via GitHub

# Get last 10 failed checks
gh run list --status failure --limit 10

# Check which commit broke the build
FIRST_FAIL=$(gh run list --status failure --limit 1 --json headSha --query '.[0].headSha')

# Get previous passing commit
LAST_PASS=$(git log --oneline | grep -v "$FIRST_FAIL" | head -1 | awk '{print $1}')

echo "Bisecting between $LAST_PASS (good) and $FIRST_FAIL (bad)"

git bisect start "$FIRST_FAIL" "$LAST_PASS"
git bisect run ./github-bisect-test.sh

# Create issue for team
gh issue create \
    --title "Regression found in commit $(git rev-parse --short HEAD)" \
    --body "$(git log -1)" \
    --label regression \
    --assignee "@author"
```

---

## AI Code Regression Detection

### Quick AI Code Debugging Methodology

**The 3-Minute Rule**: Most AI-generated code failures reveal themselves quickly:

1. **Run the linter** (30 seconds)
   ```bash
   eslint --fix generated-code.js
   ```

2. **Check the types** (30 seconds)
   ```bash
   tsc --noEmit generated-code.ts
   ```

3. **Run existing tests** (60+ seconds)
   ```bash
   npm test generated-code.test.js
   ```

### Common AI Code Failure Patterns

| Pattern | Detection | Fix |
|---------|-----------|-----|
| Hallucinated APIs | `npm test` fails with "undefined method" | Verify API docs, check imports |
| Type Mismatches | `tsc` errors | Add explicit type annotations |
| Off-by-one errors | Test output is shifted/incomplete | Review loop conditions |
| Missing null checks | Runtime errors on `null` | Add guard clauses |
| Performance regression | Benchmarks slow down 2x+ | Check nested loops, cache results |
| Infinite recursion | Stack overflow in tests | Verify base case exists |

### Automated AI Code Verification

```bash
#!/bin/bash
# Comprehensive AI-generated code quality check

FILE="$1"

echo "=== AI Code Quality Check: $FILE ==="

# 1. Linting
echo "[1/5] Running linter..."
eslint "$FILE" --fix
if [ $? -ne 0 ]; then
    echo "FAILED: Syntax/style errors"
    exit 1
fi

# 2. Type checking
echo "[2/5] Type checking..."
tsc --noEmit "$FILE"
if [ $? -ne 0 ]; then
    echo "FAILED: Type errors"
    exit 1
fi

# 3. Static analysis
echo "[3/5] Static analysis..."
npm run analyze -- "$FILE" 2>/dev/null || echo "Skipped"

# 4. Unit tests
echo "[4/5] Running unit tests..."
npm test -- "$FILE.test.js" --coverage
COVERAGE=$?
if [ $COVERAGE -lt 80 ]; then
    echo "WARNING: Coverage below 80%"
fi

# 5. Integration test
echo "[5/5] Integration tests..."
npm run test:integration -- "$FILE"
if [ $? -ne 0 ]; then
    echo "FAILED: Integration test"
    exit 1
fi

echo "✓ All checks passed"
```

### Regression Testing with ML Model Changes

```yaml
name: AI Model Regression Tests
on:
  pull_request:
    paths:
      - 'src/ai/**'
      - 'models/**'

jobs:
  regression-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Test backwards compatibility
        run: |
          # Compare outputs with previous model version
          python tests/regression_test.py \
            --old-model models/v1.0.pt \
            --new-model models/v1.1.pt \
            --tolerance 0.05

      - name: Performance benchmark
        run: |
          python benchmark.py \
            --model models/v1.1.pt \
            --baseline 500ms \
            --fail-threshold 600ms

      - name: Output stability test
        run: |
          # Verify deterministic output
          python tests/stability_test.py
```

### BlameThrower for AI Code Quality

```bash
#!/bin/bash
# Identify which AI-generated code sections have the most defects

# Analyze Python files for bugs, show contributors
blamethrower --repo . --analyzer pylint --format json > ai-analysis.json

# Parse results
jq '.blame_summary | sort_by(.error_count) | reverse | .[:10]' ai-analysis.json

# Identify patterns
echo "Most error-prone authors:"
jq '.author_stats | sort_by(.errors) | reverse' ai-analysis.json
```

---

## Practical Examples

### Example 1: Debugging a Memory Leak with Bisect

```bash
#!/bin/bash
# memory-leak-test.sh

# Compile and run with memory limits
npm run build || exit 125

# Run application with memory tracking
MEMORY_BEFORE=$(free -m | awk 'NR==2{print $3}')
timeout 10 npm start &>/dev/null &
PID=$!
sleep 5
MEMORY_AFTER=$(free -m | awk 'NR==2{print $3}')
MEMORY_DIFF=$((MEMORY_AFTER - MEMORY_BEFORE))

kill $PID 2>/dev/null

# Check if memory increased abnormally
if [ "$MEMORY_DIFF" -gt 50 ]; then
    echo "Memory leak detected: ${MEMORY_DIFF}MB growth"
    exit 1
else
    echo "Memory usage acceptable"
    exit 0
fi
```

**Run automated bisect:**
```bash
git bisect start HEAD v1.0.0
git bisect run bash memory-leak-test.sh
```

### Example 2: Regression in ML Model Output

```python
#!/usr/bin/env python3
# ml-regression-test.py

import json
import subprocess
import numpy as np
from scipy.spatial.distance import cosine

def get_model_output(input_data):
    """Get prediction from current model version"""
    result = subprocess.run(
        ['python', 'model.py', '--input', json.dumps(input_data)],
        capture_output=True,
        text=True,
        timeout=10
    )
    return json.loads(result.stdout)

def check_regression():
    """Compare outputs with baseline"""
    baseline = {
        "test_case_1": [0.1, 0.2, 0.7],
        "test_case_2": [0.5, 0.3, 0.2],
    }

    TOLERANCE = 0.05  # Allow 5% variation

    for test_name, expected in baseline.items():
        actual = get_model_output({"case": test_name})['prediction']

        # Calculate similarity
        similarity = 1 - cosine(expected, actual)

        if similarity < (1 - TOLERANCE):
            print(f"REGRESSION: {test_name} similarity {similarity:.2%}")
            return 1

    print("No regressions detected")
    return 0

if __name__ == "__main__":
    exit(check_regression())
```

**Use in bisect:**
```bash
git bisect run python ml-regression-test.py
```

### Example 3: Finding Performance Regression in API

```bash
#!/bin/bash
# api-performance-bisect.sh

# Start test server
npm run server &
SERVER_PID=$!
sleep 2

# Warm up
curl -s http://localhost:3000/api/data > /dev/null

# Benchmark endpoint
RESPONSE_TIME=$(
    curl -w "%{time_total}\n" -o /dev/null -s \
        http://localhost:3000/api/expensive-operation
)

# Kill server
kill $SERVER_PID 2>/dev/null

# Check threshold (baseline: 200ms)
THRESHOLD=250
if (( $(echo "$RESPONSE_TIME > $THRESHOLD" | bc -l) )); then
    echo "Performance regression: ${RESPONSE_TIME}s > ${THRESHOLD}ms"
    exit 1
else
    echo "Performance OK: ${RESPONSE_TIME}s"
    exit 0
fi
```

### Example 4: Integrated Debug Dashboard

```yaml
name: Debug Dashboard
on:
  schedule:
    - cron: '0 9 * * *'  # Daily at 9 AM
  workflow_dispatch:

jobs:
  analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Repository Analysis
        run: |
          # Install analysis tools
          pip install gitinspector git-history

          # Generate reports
          gitinspector -r . --format html > analysis.html
          git-history -r . data.json history.db --id id

      - name: Recent Regressions
        run: |
          # Check recent test failures
          npm test 2>&1 | tee test-results.txt

      - name: Code Quality Metrics
        run: |
          npm run lint -- --format json > lint-report.json
          npm run test -- --coverage --coverageReporters=json

      - name: Generate Dashboard
        run: |
          python scripts/generate_dashboard.py \
            --analysis analysis.html \
            --tests test-results.txt \
            --lint lint-report.json \
            --output dashboard.html

      - name: Deploy Dashboard
        run: |
          # Deploy to GitHub Pages or internal dashboard
          aws s3 cp dashboard.html s3://debug-dashboard/

      - name: Slack Notification
        if: failure()
        run: |
          curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
            -d '{"text":"Daily debug dashboard generated"}'
```

---

## Summary: 2025 Best Practices

### Tool Stack
- **Binary Search**: `git bisect run` for automated regression detection
- **Visualization**: GitLens or GitKraken for blame visualization
- **Analysis**: Hercules for repository metrics, git-history for temporal data
- **Code Review**: GitHub Copilot for AI-assisted review
- **CI Integration**: GitHub Actions with automated bisect workflows

### Workflow Principles
1. **Automation First**: Write scripts for automated testing in bisect
2. **Exit Codes Matter**: Proper exit codes (0/1/125) are critical
3. **CI Integration**: Build bisect into nightly pipelines
4. **Historical Context**: Use analysis tools alongside blame
5. **AI Code Vigilance**: Apply 3-minute methodology to generated code

### Performance Considerations
- Bisect speed depends on test script efficiency
- Larger repositories benefit from shallow clones during bisect
- Cache dependencies to speed up rebuild between commits
- Use exit code 125 to skip broken commits

### GitHub Integration Checklist
- [ ] Enable debug logging in GitHub Actions
- [ ] Set up Copilot code review on PRs
- [ ] Create custom review instructions
- [ ] Integrate bisect scripts in CI/CD
- [ ] Use tmate for interactive debugging when needed
- [ ] Monitor bisect results with dashboard

---

## References

- **Git Bisect Documentation**: https://git-scm.com/docs/git-bisect
- **Hercules Repository Analysis**: https://github.com/src-d/hercules
- **git-history**: https://github.com/simonw/git-history
- **GitLens**: https://www.gitlens.dev/
- **GitHub Copilot**: https://github.com/features/copilot
- **BlameThrower**: https://github.com/jkleint/blamethrower

