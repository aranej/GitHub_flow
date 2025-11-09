# Git Debugging Use Cases & Real-World Scenarios (2025)

## Quick Navigation
1. [Data Engineering](#data-engineering)
2. [Machine Learning Teams](#machine-learning-teams)
3. [Web Development](#web-development)
4. [DevOps & Infrastructure](#devops--infrastructure)
5. [Microservices Architecture](#microservices-architecture)

---

## Data Engineering

### Scenario 1: Data Pipeline Regression

**Problem**: ETL pipeline produces incorrect output. Last successful run was 2 days ago. Commits since then: 15.

**Diagnosis Workflow**:

```bash
# 1. Create test script that validates data quality
cat > check-data-pipeline.sh <<'EOF'
#!/bin/bash

# Build and run pipeline
python -m pytest tests/test_pipeline.py --timeout=30 || exit 125

# Validate data quality
python scripts/validate-output.py \
    --expected tests/fixtures/expected-output.json \
    --actual output/data.json \
    --tolerance 0.01 || exit 1

exit 0
EOF

# 2. Run automated bisect
git bisect start HEAD HEAD~20
git bisect run bash check-data-pipeline.sh

# 3. Examine culprit commit
CULPRIT=$(git rev-parse HEAD)
git show --stat $CULPRIT
git show --unified=3 $CULPRIT -- "dags/*.py"
```

**Tools Used**:
- `git bisect run` for automated detection
- Data validation script
- Git show with unified diff

**Lessons Learned**:
- Keep validation scripts simple and fast
- Use exit code 125 for skippable states
- Validate against fixtures for consistent comparison

---

### Scenario 2: Schema Evolution Issue

**Problem**: Spark job fails inconsistently when processing historical data. Some dates parse, others fail.

**Advanced Debugging**:

```bash
# 1. Search for schema changes in git history
bash scripts/search-history.sh "SCHEMA_VERSION"

# 2. Find when schema handling changed
git log -G "parse.*date" --oneline -- "src/schema.py" | head -5

# 3. Check for migration logic
git log -S "upgrade_schema" -p | head -100

# 4. Use git blame on specific function
git blame -L 50,100 src/schema.py | grep -A5 "parse"

# 5. Analyze repository trends
python -c "
import json
import subprocess

# Get commits affecting schema
result = subprocess.run(
    ['git', 'log', '-G', 'schema', '--format=%H %ai', '-20'],
    capture_output=True, text=True
)

commits = result.stdout.strip().split('\n')
print(f'Schema changed in {len(commits)} recent commits')

# Check if changes coincide with test failures
for commit in commits[:5]:
    subprocess.run(['git', 'show', '--stat', commit.split()[0]])
"
```

---

### Scenario 3: Data Corruption in Production

**Problem**: Production database has duplicate records. Need to identify when corruption started.

**High-Level Approach**:

```bash
# 1. Create validation script checking for duplicates
cat > validate-duplicates.sh <<'EOF'
#!/bin/bash

# Export data from this commit
git checkout HEAD -- etl/export.py

python etl/export.py --output current-export.json

# Count duplicates
DUPLICATES=$(python -c "
import json
with open('current-export.json') as f:
    data = json.load(f)
    ids = [item['id'] for item in data]
    unique_ids = set(ids)
    print(len(ids) - len(unique_ids))
")

if [ "$DUPLICATES" -gt 10 ]; then
    echo "Too many duplicates detected: $DUPLICATES"
    exit 1
else
    exit 0
fi
EOF

# 2. Binary search to find when corruption started
git bisect start production-v1.2 production-v1.1
git bisect run bash validate-duplicates.sh

# 3. Examine root cause
git show $(git rev-parse HEAD) --stat
```

---

### Scenario 4: Performance Degradation in Analytics

**Problem**: Daily report generation time increased from 2 hours to 4 hours.

**Performance Profiling Approach**:

```bash
# 1. Create performance test
cat > benchmark-analytics.sh <<'EOF'
#!/bin/bash

npm run build || exit 125

# Run with time profiling
TIME_OUTPUT=$(/usr/bin/time -v python -m analytics.daily_report 2>&1)

# Extract execution time
DURATION=$(echo "$TIME_OUTPUT" | grep "Elapsed" | awk '{print $3}')

# Convert MM:SS to seconds
SECONDS=$(echo "$DURATION" | awk -F: '{print $1*60 + $2}')

# Threshold: 2.5 hours (150 minutes = 9000 seconds)
if [ "$SECONDS" -gt 9000 ]; then
    echo "Performance regression: ${DURATION} (${SECONDS}s)"
    exit 1
else
    echo "Performance OK: ${DURATION}"
    exit 0
fi
EOF

# 2. Bisect to find regression
git bisect start HEAD~100 HEAD~500
git bisect run bash benchmark-analytics.sh

# 3. Identify bottleneck using git show
git show --stat $(git rev-parse HEAD)

# 4. Profile the specific change
CULPRIT=$(git rev-parse HEAD)
git show $CULPRIT -- "*analytics*" | grep "^+" | head -20
```

---

## Machine Learning Teams

### Scenario 1: Model Output Regression

**Problem**: Model predictions changed in last 3 commits. Need to identify breaking change.

**ML-Specific Debugging**:

```bash
# 1. Create test script comparing model outputs
cat > test-model-regression.py <<'EOF'
#!/usr/bin/env python3

import json
import subprocess
import numpy as np
from scipy.spatial.distance import cosine

# Reference outputs
BASELINE = {
    "test_case_1": [0.1, 0.2, 0.7],
    "test_case_2": [0.5, 0.3, 0.2],
    "test_case_3": [0.3, 0.4, 0.3],
}

TOLERANCE = 0.05  # 5% variation allowed

def get_model_prediction(test_case):
    """Get model output for test case"""
    try:
        result = subprocess.run(
            ['python', 'model.py', '--input', json.dumps(test_case)],
            capture_output=True,
            text=True,
            timeout=30
        )
        return json.loads(result.stdout)['prediction']
    except Exception as e:
        print(f"Model evaluation failed: {e}")
        return None

def check_regression():
    """Compare outputs with baseline"""
    failed = 0

    for test_name, expected in BASELINE.items():
        actual = get_model_prediction({"case": test_name})

        if actual is None:
            print(f"SKIP: {test_name}")
            exit(125)  # Cannot test

        # Calculate similarity
        similarity = 1 - cosine(expected, actual)

        if similarity < (1 - TOLERANCE):
            print(f"REGRESSION: {test_name}")
            print(f"  Expected: {expected}")
            print(f"  Actual:   {actual}")
            print(f"  Similarity: {similarity:.2%}")
            failed += 1

    if failed > 0:
        print(f"\n{failed} test cases failed")
        exit(1)  # Bad commit
    else:
        print("Model outputs within acceptable range")
        exit(0)  # Good commit

if __name__ == "__main__":
    exit(check_regression())
EOF

chmod +x test-model-regression.py

# 2. Run bisect
git bisect start HEAD HEAD~50
git bisect run python test-model-regression.py

# 3. Review culprit
git show $(git rev-parse HEAD)
```

### Scenario 2: Training Data Corruption

**Problem**: Model accuracy dropped 5% in last 2 weeks. Suspect data pipeline issue.

**Data-ML Debugging**:

```bash
# 1. Create training validation script
cat > validate-training-data.sh <<'EOF'
#!/bin/bash

set -e

# Rebuild dataset
python scripts/prepare-dataset.py --output dataset.pkl

# Check dataset statistics
STATS=$(python -c "
import pickle
import numpy as np

with open('dataset.pkl', 'rb') as f:
    X, y = pickle.load(f)

print(f'Shape: {X.shape}')
print(f'Missing values: {np.isnan(X).sum()}')
print(f'Class balance: {np.bincount(y)}')
print(f'Feature ranges: {np.min(X)} to {np.max(X)}')
")

echo "$STATS"

# Expected stats
EXPECTED_SAMPLES=100000
ACTUAL_SAMPLES=$(python -c "
import pickle
with open('dataset.pkl', 'rb') as f:
    X, y = pickle.load(f)
print(X.shape[0])
")

if [ "$ACTUAL_SAMPLES" -lt "$((EXPECTED_SAMPLES / 2))" ]; then
    echo "Data loss detected: $ACTUAL_SAMPLES samples"
    exit 1
fi

# Check for NaNs
NANS=$(python -c "
import pickle
import numpy as np
with open('dataset.pkl', 'rb') as f:
    X, y = pickle.load(f)
print(np.isnan(X).sum())
")

if [ "$NANS" -gt 0 ]; then
    echo "NaN values found: $NANS"
    exit 1
fi

exit 0
EOF

# 2. Train model and test accuracy
cat > test-model-accuracy.sh <<'EOF'
#!/bin/bash

bash validate-training-data.sh || exit 125

# Train model
python scripts/train.py --model model-test.pkl || exit 125

# Evaluate on test set
ACCURACY=$(python -c "
import pickle
from sklearn.metrics import accuracy_score
from scripts.prepare_dataset import load_test_set

with open('model-test.pkl', 'rb') as f:
    model = pickle.load(f)

X_test, y_test = load_test_set()
accuracy = accuracy_score(y_test, model.predict(X_test))
print(f'{accuracy * 100:.2f}')
")

echo "Accuracy: ${ACCURACY}%"

# Expected threshold: 95%
if (( $(echo "$ACCURACY < 95" | bc -l) )); then
    echo "Accuracy below threshold"
    exit 1
else
    exit 0
fi
EOF

chmod +x validate-training-data.sh test-model-accuracy.sh

# 3. Bisect to find regression
git bisect start HEAD~50 HEAD~200
git bisect run bash test-model-accuracy.sh

# 4. Check changes in data pipeline
git show $(git rev-parse HEAD) -- "scripts/prepare*"
```

### Scenario 3: Hyperparameter Sensitivity

**Problem**: Model becomes unstable with recent changes. Not sure if it's hyperparams or code.

**Debugging Approach**:

```bash
# 1. Create comprehensive test
cat > test-model-stability.py <<'EOF'
#!/usr/bin/env python3

import json
import subprocess
import numpy as np

RUNS = 5  # Multiple runs for stability
TOLERANCE = 0.02  # 2% standard deviation allowed

def train_and_evaluate():
    """Train model multiple times and check variance"""
    accuracies = []

    for run in range(RUNS):
        subprocess.run(
            ['python', 'train.py', f'--run-id={run}'],
            capture_output=True
        )

        accuracy = float(subprocess.check_output(
            ['python', 'evaluate.py', f'--model-run-{run}.pkl']
        ).decode().strip())

        accuracies.append(accuracy)

    mean_acc = np.mean(accuracies)
    std_acc = np.std(accuracies)
    cv = std_acc / mean_acc  # Coefficient of variation

    print(f"Mean accuracy: {mean_acc:.2%}")
    print(f"Std deviation: {std_acc:.2%}")
    print(f"Coefficient of variation: {cv:.2%}")

    if cv > TOLERANCE:
        print(f"Model is unstable: CV {cv:.2%} > threshold {TOLERANCE:.2%}")
        return False
    else:
        print("Model is stable")
        return True

if __name__ == "__main__":
    exit(0 if train_and_evaluate() else 1)
EOF

# 2. Bisect with stability check
git bisect start HEAD HEAD~20
git bisect run python test-model-stability.py
```

---

## Web Development

### Scenario 1: Frontend Performance Regression

**Problem**: Lighthouse score dropped from 95 to 78 after recent changes.

**Web Performance Debugging**:

```bash
# 1. Create Lighthouse test script
cat > test-lighthouse.sh <<'EOF'
#!/bin/bash

npm run build || exit 125
npm run start &
SERVER_PID=$!
sleep 3

# Run Lighthouse
npx lighthouse http://localhost:3000 \
    --chrome-flags="--headless" \
    --output-path=lighthouse-report.json \
    --only-categories=performance

# Extract score
SCORE=$(jq '.categories.performance.score * 100' lighthouse-report.json)
echo "Lighthouse score: $SCORE"

kill $SERVER_PID 2>/dev/null || true

# Threshold: 85
if (( $(echo "$SCORE < 85" | bc -l) )); then
    exit 1
else
    exit 0
fi
EOF

chmod +x test-lighthouse.sh

# 2. Bisect
git bisect start HEAD HEAD~20
git bisect run bash test-lighthouse.sh

# 3. Analyze culprit
CULPRIT=$(git rev-parse HEAD)
git show $CULPRIT -- "src/**" | grep "^+" | head -30
```

### Scenario 2: Breaking CSS Change

**Problem**: CSS regression affects specific components. Layout breaks on mobile.

**CSS Debugging**:

```bash
# 1. Visual regression test
cat > test-css-regression.sh <<'EOF'
#!/bin/bash

npm run build || exit 125

# Run visual regression tests using Percy or similar
npx percy exec -- npm run test:visual

# Check for failures
if grep -q "failed" percy-report.json; then
    exit 1
else
    exit 0
fi
EOF

# 2. Pinpoint affected components
git bisect start HEAD HEAD~10
git bisect run bash test-css-regression.sh

# 3. Show only CSS changes
CULPRIT=$(git rev-parse HEAD)
git show $CULPRIT -- "**/*.css" "**/*.scss"

# 4. Search for CSS property changes
git log -G "flex-direction\|grid-template" --oneline -- "**/*.css"
```

### Scenario 3: JavaScript Memory Leak

**Problem**: Heap size grows unboundedly during user interaction.

**Memory Debugging**:

```bash
# 1. Memory leak detection test
cat > test-memory-leak.sh <<'EOF'
#!/bin/bash

npm run build || exit 125

# Start server
npm start &
SERVER_PID=$!
sleep 2

# Get initial memory
INIT_MEM=$(ps aux | grep "node" | grep -v grep | awk '{print $6}')

# Simulate user interactions
for i in {1..100}; do
    curl -s http://localhost:3000/api/data?page=$i > /dev/null
    sleep 0.1
done

# Get final memory
FINAL_MEM=$(ps aux | grep "node" | grep -v grep | awk '{print $6}')

kill $SERVER_PID 2>/dev/null || true

# Check memory growth
GROWTH=$((FINAL_MEM - INIT_MEM))
GROWTH_PERCENT=$((GROWTH * 100 / INIT_MEM))

echo "Memory growth: ${GROWTH}KB (${GROWTH_PERCENT}%)"

# Threshold: 10% growth
if [ "$GROWTH_PERCENT" -gt 10 ]; then
    echo "Memory leak detected"
    exit 1
else
    exit 0
fi
EOF

# 2. Bisect
git bisect start HEAD HEAD~20
git bisect run bash test-memory-leak.sh

# 3. Find event listener registrations
git log -G "addEventListener|onload" --oneline
```

---

## DevOps & Infrastructure

### Scenario 1: Build Time Regression

**Problem**: Docker build time increased from 3 minutes to 8 minutes.

**Build Performance Debugging**:

```bash
# 1. Create build benchmark
cat > benchmark-build.sh <<'EOF'
#!/bin/bash

# Clear Docker cache for consistent timing
docker system prune -a -f

# Measure build time
BUILD_TIME=$(time docker build -t app:test . 2>&1 | grep real | awk '{print $2}')

echo "Build time: $BUILD_TIME"

# Extract seconds
SECONDS=$(echo "$BUILD_TIME" | awk -F'm' '{print $1*60 + $2}' | sed 's/s$//')

# Threshold: 5 minutes = 300 seconds
if [ "$SECONDS" -gt 300 ]; then
    exit 1
else
    exit 0
fi
EOF

# 2. Analyze Dockerfile changes
git log --oneline -- Dockerfile | head -20

# 3. Show specific changes
CULPRIT=$(git bisect start HEAD~50 HEAD)
git show $CULPRIT -- Dockerfile
```

### Scenario 2: Kubernetes Deployment Failure

**Problem**: Recent changes broke Helm deployment. Rollout fails.

**K8s Debugging**:

```bash
# 1. Create deployment test
cat > test-k8s-deployment.sh <<'EOF'
#!/bin/bash

# Build image
docker build -t app:test . || exit 125

# Test Helm chart validation
helm lint charts/app/ || exit 1

# Template rendering
helm template app ./charts/app --values values.yaml > manifests.yaml || exit 1

# Validate manifests
kubeval manifests.yaml || exit 1

# Dry run deployment
kubectl apply -f manifests.yaml --dry-run=client || exit 1

exit 0
EOF

# 2. Bisect
git bisect start HEAD~20 HEAD
git bisect run bash test-k8s-deployment.sh

# 3. Show Helm/K8s changes
CULPRIT=$(git rev-parse HEAD)
git show $CULPRIT -- "charts/" "k8s/"
```

---

## Microservices Architecture

### Scenario 1: Service Integration Failure

**Problem**: Service A calls Service B, but request fails after recent changes. Which service broke?

**Service Integration Debugging**:

```bash
# 1. Create integration test
cat > test-service-integration.sh <<'EOF'
#!/bin/bash

# Start both services
npm run start:service-a &
SERVICE_A_PID=$!

sleep 1

# Mocked Service B (or actual if available)
python -m http.server 8001 &
SERVICE_B_PID=$!

sleep 1

# Test integration
RESPONSE=$(curl -s -X POST http://localhost:3000/api/request \
    -H "Content-Type: application/json" \
    -d '{"data":"test"}')

kill $SERVICE_A_PID $SERVICE_B_PID 2>/dev/null || true

# Verify response
if echo "$RESPONSE" | jq '.status' | grep -q "success"; then
    exit 0
else
    echo "Integration failed: $RESPONSE"
    exit 1
fi
EOF

# 2. Bisect in Service A repository
git bisect start HEAD~30 HEAD
git bisect run bash test-service-integration.sh

# 3. Check API contract changes
CULPRIT=$(git rev-parse HEAD)
git show $CULPRIT -- "src/api.ts" | grep -A5 -B5 "Service B\|external"
```

### Scenario 2: Message Queue Regression

**Problem**: Async messages are being dropped. Last working version: v2.1.0.

**Message Queue Debugging**:

```bash
# 1. Create queue integrity test
cat > test-message-queue.py <<'EOF'
#!/usr/bin/env python3

import redis
import time
import subprocess
import json

def test_message_queue():
    """Test message production and consumption"""

    # Start service
    subprocess.Popen(['python', '-m', 'service'])
    time.sleep(2)

    r = redis.Redis()

    # Send test messages
    MESSAGE_COUNT = 100
    for i in range(MESSAGE_COUNT):
        r.lpush('test_queue', json.dumps({'id': i, 'data': f'msg{i}'}))

    # Process messages
    time.sleep(5)

    # Check how many were processed
    REMAINING = r.llen('test_queue')
    PROCESSED = MESSAGE_COUNT - REMAINING

    print(f"Sent: {MESSAGE_COUNT}")
    print(f"Processed: {PROCESSED}")
    print(f"Remaining: {REMAINING}")

    # Tolerance: 5% loss
    if PROCESSED < (MESSAGE_COUNT * 0.95):
        print("Message loss detected")
        return False

    return True

if __name__ == "__main__":
    exit(0 if test_message_queue() else 1)
EOF

# 2. Bisect
git bisect start HEAD~50 HEAD
git bisect run python test-message-queue.py
```

---

## Quick Decision Tree

```
Regression Detected
├─ If: Specific error message
│  └─> Search history with git log -G or -S
├─ If: Performance degradation
│  └─> Use benchmark script + git bisect run
├─ If: Multiple test failures
│  └─> Create comprehensive test.sh + bisect
├─ If: Data/Output inconsistency
│  └─> Compare outputs against baseline
└─ If: Intermittent failure
   └─> Add stability/reliability tests (run multiple times)

After finding culprit:
1. git show --stat <commit>
2. git show --unified=3 <commit>
3. git log -p <commit>^..<commit>
4. git blame -L <start>,<end> <file>
```

---

## Template for New Scenarios

When you encounter a regression:

```bash
# 1. Define "good" and "bad" commits
GOOD=v1.0.0  # Last known working version
BAD=HEAD     # Current broken state

# 2. Create test-regression.sh that:
#    - Returns 0 if commit is good
#    - Returns 1 if commit is bad
#    - Returns 125 if cannot test (broken build)

cat > test-regression.sh <<'EOF'
#!/bin/bash

# Build/setup (skip broken builds)
npm run build || exit 125

# Run test
npm test || exit 1

# Additional validation
npm run lint || exit 1

exit 0
EOF

chmod +x test-regression.sh

# 3. Run bisect
git bisect start $BAD $GOOD
git bisect run bash test-regression.sh

# 4. Analyze
git show $(git rev-parse HEAD)
```

