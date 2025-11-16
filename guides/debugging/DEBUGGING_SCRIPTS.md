# Production-Ready Debugging Scripts

## Script Collection for Git Bisect & Regression Detection

### 1. Universal Bisect Script Runner

**File: `scripts/bisect-runner.sh`**

```bash
#!/bin/bash
# Universal script for running git bisect with various test scenarios
# Usage: ./bisect-runner.sh <test-type> <good-commit> <bad-commit>

set -euo pipefail

TEST_TYPE="${1:-unit}"
GOOD_COMMIT="${2:-HEAD~50}"
BAD_COMMIT="${3:-HEAD}"

echo "=== Git Bisect Runner ==="
echo "Test Type: $TEST_TYPE"
echo "Good: $GOOD_COMMIT"
echo "Bad: $BAD_COMMIT"

# Create test script based on type
case "$TEST_TYPE" in
    unit)
        TEST_CMD="npm test 2>&1"
        ;;
    integration)
        TEST_CMD="npm run test:integration 2>&1"
        ;;
    e2e)
        TEST_CMD="npm run test:e2e 2>&1"
        ;;
    build)
        TEST_CMD="npm run build 2>&1"
        ;;
    performance)
        TEST_CMD="bash scripts/performance-test.sh 2>&1"
        ;;
    linter)
        TEST_CMD="npm run lint 2>&1"
        ;;
    *)
        echo "Unknown test type: $TEST_TYPE"
        echo "Options: unit, integration, e2e, build, performance, linter"
        exit 1
        ;;
esac

# Run bisect
echo "Starting bisect..."
git bisect start "$BAD_COMMIT" "$GOOD_COMMIT"
git bisect run sh -c "$TEST_CMD || exit 1"

# Report culprit
CULPRIT=$(git rev-parse HEAD)
echo ""
echo "=== Culprit Found ==="
git log -1 --format="%H %s" "$CULPRIT"
echo ""
echo "Reviewing changes:"
git show --stat "$CULPRIT"

# Reset
git bisect reset
```

### 2. Comprehensive Regression Detection

**File: `scripts/check-regression.sh`**

```bash
#!/bin/bash
# Checks for multiple types of regressions
# Returns 0 if all good, 1 if regression detected, 125 if cannot test

set -euo pipefail

BUILD_OK=true
TEST_OK=true
LINT_OK=true
PERF_OK=true

echo "[$(date)] Regression check starting..."

# 1. Build check
echo "✓ Checking build..."
if ! npm run build &>/dev/null; then
    echo "  ✗ Build failed"
    exit 125  # Skip if build is broken
fi

# 2. Linter check
echo "✓ Checking linter..."
if ! npm run lint &>/dev/null; then
    echo "  ✗ Linter errors detected"
    LINT_OK=false
fi

# 3. Unit tests
echo "✓ Running unit tests..."
if npm test -- --passWithNoTests &>/dev/null; then
    echo "  ✓ Unit tests pass"
else
    echo "  ✗ Unit tests failed"
    TEST_OK=false
fi

# 4. Performance baseline check
echo "✓ Checking performance..."
if [ -f "scripts/perf-baseline.txt" ]; then
    CURRENT=$(timeout 5 npm start &>/dev/null & sleep 1; \
              curl -w "%{time_total}" -o /dev/null -s http://localhost:3000/health 2>/dev/null || echo "0")
    BASELINE=$(cat scripts/perf-baseline.txt)

    if (( $(echo "$CURRENT > $BASELINE * 1.2" | bc -l) )); then
        echo "  ✗ Performance regression: ${CURRENT}s vs baseline ${BASELINE}s"
        PERF_OK=false
    else
        echo "  ✓ Performance within acceptable range"
    fi
fi

# Summary
echo ""
echo "=== Regression Check Summary ==="
$LINT_OK && echo "✓ Linting" || echo "✗ Linting"
$TEST_OK && echo "✓ Tests" || echo "✗ Tests"
$PERF_OK && echo "✓ Performance" || echo "✗ Performance"

if $LINT_OK && $TEST_OK && $PERF_OK; then
    exit 0
else
    exit 1
fi
```

### 3. Git History Search Utility

**File: `scripts/search-history.sh`**

```bash
#!/bin/bash
# Comprehensive git history search with multiple strategies
# Usage: ./search-history.sh <search-term> [options]

SEARCH_TERM="$1"
OUTPUT_FORMAT="${2:-text}"

if [ -z "$SEARCH_TERM" ]; then
    echo "Usage: $0 <search-term> [format]"
    echo "Format: text, json, csv"
    exit 1
fi

echo "=== Git History Search: $SEARCH_TERM ==="
echo ""

# Function to format output
format_result() {
    local type="$1"
    local value="$2"

    case "$OUTPUT_FORMAT" in
        json)
            echo "{\"type\":\"$type\",\"value\":\"$value\"}"
            ;;
        csv)
            echo "$type,$value"
            ;;
        *)
            echo "[$type] $value"
            ;;
    esac
}

# 1. Code pattern search
echo "=== Code Pattern Occurrences ==="
PATTERN_COUNT=$(git log -S "$SEARCH_TERM" --oneline | wc -l)
format_result "pattern_commits" "$PATTERN_COUNT"

# 2. Introduction commit
echo ""
echo "=== When Introduced ==="
INTRO=$(git log -S "$SEARCH_TERM" --oneline --reverse | head -1)
format_result "introduced" "$INTRO"

# 3. Last modification
echo ""
echo "=== Last Modified ==="
LAST=$(git log -G "$SEARCH_TERM" --oneline | head -1)
format_result "last_modified" "$LAST"

# 4. Authors involved
echo ""
echo "=== Authors Who Modified ==="
git log --all -G "$SEARCH_TERM" --format="%an" | sort | uniq -c | sort -rn | while read count author; do
    format_result "author" "$author ($count commits)"
done

# 5. Files affected
echo ""
echo "=== Files Affected ==="
git log -G "$SEARCH_TERM" --name-only --oneline | grep -v "^$" | grep -v "^[a-f0-9]" | sort | uniq -c | sort -rn | while read count file; do
    format_result "file" "$file"
done

# 6. Timeline
echo ""
echo "=== Timeline of Changes ==="
git log -G "$SEARCH_TERM" --format="%ai %s" | sort -r | head -10 | while read line; do
    format_result "timestamp" "$line"
done

# 7. Blame current file for string
echo ""
echo "=== Current Occurrences (with blame) ==="
find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" \) -exec grep -l "$SEARCH_TERM" {} \; | while read file; do
    echo "File: $file"
    grep -n "$SEARCH_TERM" "$file" | while read line; do
        LINE_NUM=$(echo "$line" | cut -d: -f1)
        BLAME=$(git blame -L$LINE_NUM,$LINE_NUM "$file" 2>/dev/null | awk '{print $3}')
        format_result "blame" "Line $LINE_NUM: $BLAME"
    done
done
```

### 4. Performance Regression Detector

**File: `scripts/perf-regression-check.sh`**

```bash
#!/bin/bash
# Detect performance regressions against baseline
# Usage: ./perf-regression-check.sh [--save-baseline]

set -euo pipefail

BASELINE_FILE="./perf-baseline.json"
THRESHOLD_MS=100  # Alert if slower than baseline + 100ms

# Function to run benchmarks
run_benchmarks() {
    local output_file="$1"

    npm run build || exit 125

    echo "{" > "$output_file"
    echo '  "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",' >> "$output_file"
    echo '  "benchmarks": {' >> "$output_file"

    # API endpoint benchmark
    echo "    \"api_health\": $(
        timeout 3 npm start >/dev/null 2>&1 &
        sleep 1
        curl -w "%{time_total}" -o /dev/null -s http://localhost:3000/health || echo "0"
    )," >> "$output_file"

    # Build time
    echo "    \"build_time\": $(npm run build 2>&1 | grep -oP 'built in \K[0-9.]+' || echo '0')," >> "$output_file"

    # Bundle size
    echo "    \"bundle_size\": $(wc -c < dist/bundle.js 2>/dev/null || echo '0')" >> "$output_file"

    echo "  }" >> "$output_file"
    echo "}" >> "$output_file"
}

if [ "$#" -gt 0 ] && [ "$1" = "--save-baseline" ]; then
    echo "Creating baseline measurements..."
    run_benchmarks "$BASELINE_FILE"
    echo "Baseline saved to $BASELINE_FILE"
    exit 0
fi

if [ ! -f "$BASELINE_FILE" ]; then
    echo "Error: No baseline file found at $BASELINE_FILE"
    echo "Run with --save-baseline to create one"
    exit 1
fi

echo "Running performance checks..."
CURRENT_FILE=$(mktemp)
run_benchmarks "$CURRENT_FILE"

echo ""
echo "=== Performance Comparison ==="
echo ""

# Compare metrics
BASELINE_API=$(jq '.benchmarks.api_health' "$BASELINE_FILE")
CURRENT_API=$(jq '.benchmarks.api_health' "$CURRENT_FILE")

echo "API Response Time:"
echo "  Baseline: ${BASELINE_API}s"
echo "  Current:  ${CURRENT_API}s"

DIFF=$(echo "$CURRENT_API - $BASELINE_API" | bc 2>/dev/null || echo "0")
if [ "$(echo "$DIFF > 0" | bc -l)" = "1" ]; then
    DIFF_MS=$(echo "$DIFF * 1000" | bc)
    echo "  Increase: ${DIFF_MS}ms"

    if [ "$(echo "$DIFF_MS > $THRESHOLD_MS" | bc -l)" = "1" ]; then
        echo "  ⚠️  REGRESSION DETECTED"
        rm "$CURRENT_FILE"
        exit 1
    fi
else
    echo "  ✓ Improved"
fi

rm "$CURRENT_FILE"
exit 0
```

### 5. Automated Bisect with Notifications

**File: `scripts/automated-bisect.sh`**

```bash
#!/bin/bash
# Run automated bisect and notify stakeholders
# Usage: ./automated-bisect.sh <test-script> <good-commit> <bad-commit>

set -euo pipefail

TEST_SCRIPT="$1"
GOOD_COMMIT="${2:-}"
BAD_COMMIT="${3:-HEAD}"

if [ -z "$TEST_SCRIPT" ]; then
    echo "Usage: $0 <test-script> [good-commit] [bad-commit]"
    exit 1
fi

if [ ! -f "$TEST_SCRIPT" ]; then
    echo "Error: Test script not found: $TEST_SCRIPT"
    exit 1
fi

# Make test script executable
chmod +x "$TEST_SCRIPT"

# If no good commit specified, find it
if [ -z "$GOOD_COMMIT" ]; then
    echo "Finding last known good commit..."
    GOOD_COMMIT=$(git log --oneline | while read commit msg; do
        if bash "$TEST_SCRIPT" >/dev/null 2>&1; then
            echo "$commit"
            break
        fi
    done | head -1)

    if [ -z "$GOOD_COMMIT" ]; then
        echo "Error: Could not find a good commit"
        exit 1
    fi

    GOOD_COMMIT=$(echo "$GOOD_COMMIT" | awk '{print $1}')
fi

echo "=== Automated Bisect ==="
echo "Test: $TEST_SCRIPT"
echo "Good: $GOOD_COMMIT"
echo "Bad: $BAD_COMMIT"
echo ""

# Start timestamp
START_TIME=$(date +%s)

# Run bisect
git bisect start "$BAD_COMMIT" "$GOOD_COMMIT"
if git bisect run bash "$TEST_SCRIPT"; then
    CULPRIT=$(git rev-parse HEAD)
    STATUS="success"
else
    CULPRIT=$(git rev-parse HEAD)
    STATUS="error"
fi
git bisect reset

# Calculate duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Prepare report
REPORT=$(cat <<EOF
=== Bisect Report ===
Status: $STATUS
Culprit: $CULPRIT
Duration: ${DURATION}s

Commit Details:
$(git show --stat $CULPRIT)

Files Changed:
$(git show --name-only $CULPRIT | grep -v "^$" | tail -20)

Diff Summary:
$(git diff --stat $(git rev-parse $CULPRIT^) $CULPRIT)
EOF
)

echo "$REPORT"

# Save report
REPORT_FILE="bisect-reports/$(date +%Y%m%d-%H%M%S).txt"
mkdir -p bisect-reports
echo "$REPORT" > "$REPORT_FILE"

# Notify via various channels
if [ -n "${SLACK_WEBHOOK:-}" ]; then
    curl -X POST "$SLACK_WEBHOOK" \
        -H 'Content-Type: application/json' \
        -d "{
            \"text\": \"Bisect Complete: $STATUS\",
            \"blocks\": [
                {
                    \"type\": \"section\",
                    \"text\": {
                        \"type\": \"mrkdwn\",
                        \"text\": \"*Regression Bisect Report*\n\`\`\`\n${REPORT}\n\`\`\`\"
                    }
                }
            ]
        }"
fi

# Email notification
if [ -n "${EMAIL_RECIPIENTS:-}" ]; then
    echo "$REPORT" | mail -s "Bisect Report: $STATUS" "$EMAIL_RECIPIENTS"
fi

# GitHub issue creation
if [ -n "${GITHUB_TOKEN:-}" ] && [ "$STATUS" = "success" ]; then
    gh issue create \
        --title "Regression in commit $(git rev-parse --short $CULPRIT)" \
        --body "$REPORT" \
        --label regression \
        --assignee "$(git show -s --format=%an $CULPRIT)"
fi

exit 0
```

### 6. Code Quality History Analysis

**File: `scripts/quality-history.sh`**

```bash
#!/bin/bash
# Analyze code quality metrics over time
# Integrates with git history to show trends

set -euo pipefail

OUTPUT_DIR="quality-history"
mkdir -p "$OUTPUT_DIR"

echo "=== Code Quality History Analysis ==="

# 1. Test coverage trend
echo "Calculating test coverage trend..."
{
    echo "date,coverage,tests"
    for commit in $(git log --oneline -n 30 | awk '{print $1}'); do
        git checkout "$commit" >/dev/null 2>&1

        DATE=$(git log -1 --format=%ai "$commit" | cut -d' ' -f1)
        COVERAGE=$(npm test -- --coverage --coverageReporters=json-summary 2>/dev/null | \
                   jq '.total.lines.pct' 2>/dev/null || echo "0")
        TESTS=$(npm test -- --listTests 2>/dev/null | wc -l || echo "0")

        echo "$DATE,$COVERAGE,$TESTS"
    done
} > "$OUTPUT_DIR/coverage-trend.csv"

# 2. Code complexity trend
echo "Analyzing code complexity..."
{
    echo "commit,date,files,functions,complexity"
    for commit in $(git log --oneline -n 10 | awk '{print $1}'); do
        git checkout "$commit" >/dev/null 2>&1

        DATE=$(git log -1 --format=%ai "$commit" | cut -d' ' -f1)
        FILE_COUNT=$(find src -name "*.js" -o -name "*.ts" | wc -l)
        FUNCTION_COUNT=$(grep -r "^export\|^function\|=> {" src --include="*.js" --include="*.ts" | wc -l)

        echo "$commit,$DATE,$FILE_COUNT,$FUNCTION_COUNT,0"
    done
} > "$OUTPUT_DIR/complexity-trend.csv"

# 3. Author contribution trend
echo "Calculating author contributions..."
{
    echo "author,commits,additions,deletions,last_commit"
    git log --format="%an" -n 100 | sort | uniq | while read author; do
        COMMITS=$(git log --author="$author" -n 100 | grep -c "^commit")
        STATS=$(git log --author="$author" -n 100 --numstat | \
                awk '{add+=$1; del+=$2} END {print add","del}')
        LAST=$(git log -1 --author="$author" --format=%ai -n 100 | cut -d' ' -f1)

        echo "$author,$COMMITS,$STATS,$LAST"
    done
} > "$OUTPUT_DIR/author-stats.csv"

# 4. File hotspots
echo "Identifying file hotspots..."
{
    echo "file,modifications,authors,last_modified"
    git log --name-only --pretty=format: -n 100 | grep -v "^$" | sort | uniq -c | sort -rn | \
    while read count file; do
        AUTHOR_COUNT=$(git log --follow "$file" -n 50 --format="%an" 2>/dev/null | sort -u | wc -l)
        LAST=$(git log -1 --follow --format=%ai "$file" 2>/dev/null | cut -d' ' -f1)

        echo "$file,$count,$AUTHOR_COUNT,$LAST"
    done
} > "$OUTPUT_DIR/hotspots.csv"

# Generate HTML report
cat > "$OUTPUT_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Code Quality History</title>
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
    <style>
        body { font-family: Arial; margin: 20px; }
        .chart { display: inline-block; width: 45%; margin: 10px; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Code Quality Metrics Over Time</h1>

    <div class="chart">
        <h2>Test Coverage Trend</h2>
        <div id="coverage"></div>
    </div>

    <div class="chart">
        <h2>File Hotspots</h2>
        <div id="hotspots"></div>
    </div>

    <script>
        // Charts will be rendered by Plotly
        console.log("Quality history analysis complete");
    </script>
</body>
</html>
HTML

echo ""
echo "✓ Analysis complete. Results in $OUTPUT_DIR/"
echo "  - coverage-trend.csv"
echo "  - complexity-trend.csv"
echo "  - author-stats.csv"
echo "  - hotspots.csv"
```

### 7. GitHub Actions Bisect Template

**File: `.github/workflows/auto-bisect.yml`**

```yaml
name: Automated Regression Bisect

on:
  workflow_dispatch:
    inputs:
      test_type:
        description: 'Type of regression test'
        required: true
        default: 'unit'
        type: choice
        options:
          - unit
          - integration
          - e2e
          - performance
      good_commit:
        description: 'Last known good commit (SHA or ref)'
        required: false
      bad_commit:
        description: 'Bad commit with regression (SHA or ref)'
        required: true

  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC

jobs:
  bisect:
    runs-on: ubuntu-latest
    timeout-minutes: 120

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Determine commits
        id: commits
        run: |
          GOOD="${{ github.event.inputs.good_commit }}"
          BAD="${{ github.event.inputs.bad_commit || 'HEAD' }}"

          if [ -z "$GOOD" ]; then
            # Find last passing commit
            for commit in $(git log --oneline -n 50 | awk '{print $1}'); do
              git checkout "$commit" 2>/dev/null
              if npm test 2>/dev/null | grep -q "passed"; then
                GOOD="$commit"
                break
              fi
            done
          fi

          echo "good=$GOOD" >> $GITHUB_OUTPUT
          echo "bad=$BAD" >> $GITHUB_OUTPUT

      - name: Run automated bisect
        id: bisect
        run: |
          TEST_TYPE="${{ github.event.inputs.test_type || 'unit' }}"
          bash scripts/bisect-runner.sh "$TEST_TYPE" \
            "${{ steps.commits.outputs.good }}" \
            "${{ steps.commits.outputs.bad }}" | tee bisect-output.txt

      - name: Extract culprit
        id: culprit
        run: |
          CULPRIT=$(git rev-parse HEAD)
          COMMIT_MSG=$(git log -1 --format=%s)
          AUTHOR=$(git log -1 --format=%an)

          echo "commit=$CULPRIT" >> $GITHUB_OUTPUT
          echo "message=$COMMIT_MSG" >> $GITHUB_OUTPUT
          echo "author=$AUTHOR" >> $GITHUB_OUTPUT

      - name: Create issue
        if: always()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Regression found: ${{ steps.culprit.outputs.commit }}`,
              body: `
                ## Regression Detected

                **Type**: ${{ github.event.inputs.test_type || 'unit' }}
                **Culprit**: ${{ steps.culprit.outputs.commit }}
                **Author**: ${{ steps.culprit.outputs.author }}
                **Message**: ${{ steps.culprit.outputs.message }}

                \`\`\`
                $(cat bisect-output.txt)
                \`\`\`
              `,
              labels: ['regression', 'automated'],
              assignee: '${{ steps.culprit.outputs.author }}'
            })

      - name: Upload artifact
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: bisect-results
          path: |
            bisect-output.txt
            quality-history/

      - name: Slack notification
        if: always()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "Bisect ${{ job.status }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Automated Bisect Report*\nCulprit: `${{ steps.culprit.outputs.commit }}`\nAuthor: ${{ steps.culprit.outputs.author }}\nStatus: ${{ job.status }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

---

## Quick Reference

### Common Regression Types & Detection Scripts

| Regression Type | Detection Command | Script |
|---|---|---|
| Build failure | `npm run build` | bisect-runner.sh build |
| Test failure | `npm test` | bisect-runner.sh unit |
| Performance slowdown | `perf-regression-check.sh` | bisect-runner.sh performance |
| Type errors | `tsc --noEmit` | bisect-runner.sh linter |
| API response time | Custom benchmark | perf-regression-check.sh |
| Code quality decline | `npm run lint` | quality-history.sh |

### Running Scripts

```bash
# Basic bisect
bash scripts/bisect-runner.sh unit HEAD~100 HEAD

# With performance check
bash scripts/perf-regression-check.sh

# Search history
bash scripts/search-history.sh "function_name"

# Analyze quality trends
bash scripts/quality-history.sh
```

