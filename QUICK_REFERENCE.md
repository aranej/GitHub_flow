# GitHub Actions Optimization - Quick Reference 2025

---

## 1. DEPENDENCY CACHING QUICK REFERENCE

### npm

```yaml
# Automatic caching
- uses: actions/setup-node@v4
  with:
    cache: 'npm'

# Manual caching
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
```

### Python

```yaml
# Automatic
- uses: actions/setup-python@v4
  with:
    cache: 'pip'

# Manual (virtualenv, faster)
- uses: actions/cache@v4
  with:
    path: venv
    key: ${{ runner.os }}-venv-${{ hashFiles('**/requirements.txt') }}
```

### Java/Maven

```yaml
- uses: actions/setup-java@v3
  with:
    cache: 'maven'
```

### Go

```yaml
- uses: actions/setup-go@v4
  with:
    go-version: '1.21'
    cache: true
```

---

## 2. MATRIX BUILD OPTIMIZATION QUICK REFERENCE

### Basic Matrix

```yaml
strategy:
  matrix:
    node-version: [18, 20, 21]
    os: [ubuntu-latest, macos-latest]
```

### Optimized Matrix (Fewer Combinations)

```yaml
strategy:
  matrix:
    include:
      - node: 18
        os: ubuntu-latest
      - node: 20
        os: ubuntu-latest
      - node: 20
        os: macos-latest
      # Skip expensive combinations
```

### Limit Parallelization

```yaml
strategy:
  max-parallel: 2
  matrix:
    node: [18, 19, 20, 21, 22]
```

### Fail Fast Control

```yaml
strategy:
  fail-fast: false  # Continue other jobs
  matrix:
    node: [18, 20, 21]
```

---

## 3. JOB PARALLELIZATION QUICK REFERENCE

### Run Jobs in Parallel

```yaml
jobs:
  lint:    # Runs immediately
    runs-on: ubuntu-latest
    steps:
      - run: npm run lint

  test:    # Runs immediately
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  build:   # Runs immediately
    runs-on: ubuntu-latest
    steps:
      - run: npm run build
```

### Sequence Jobs

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build

  test:
    needs: build  # Wait for build
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  deploy:
    needs: test  # Wait for test
    runs-on: ubuntu-latest
    steps:
      - run: npm run deploy
```

### Conditional Execution

```yaml
jobs:
  deploy:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploy to production"
```

### Always Run

```yaml
jobs:
  notify:
    if: always()  # Run even if previous jobs fail
    runs-on: ubuntu-latest
    steps:
      - run: echo "Send notification"
```

---

## 4. CACHING STRATEGIES QUICK REFERENCE

### Docker Layer Cache

```yaml
- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

### Build Artifact Cache

```yaml
- uses: actions/cache@v4
  with:
    path: |
      dist
      build
      .next
    key: ${{ runner.os }}-build-${{ github.sha }}
```

### Cross-Job Artifact Sharing

```yaml
# Job 1: Upload
- uses: actions/upload-artifact@v4
  with:
    name: dist
    path: dist

# Job 2: Download
- uses: actions/download-artifact@v4
  with:
    name: dist
```

### Cache Key Strategy

```yaml
# Simple version
key: ${{ runner.os }}-${{ hashFiles('package.json') }}

# Multiple files
key: ${{ runner.os }}-${{ hashFiles('package-lock.json', 'yarn.lock') }}

# Include date for time-based invalidation
key: ${{ runner.os }}-${{ github.run_id }}-${{ hashFiles('package.json') }}
```

---

## 5. WORKFLOW CONTROL QUICK REFERENCE

### Concurrency (Cancel Outdated Runs)

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true  # Cancel if new run starts
```

### Shallow Clone (Faster Checkout)

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 1
```

### Selective Trigger

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'src/**'
      - 'package.json'
  pull_request:
    branches: [main]
```

### Skip CI

```
[skip ci] message in commit
```

---

## 6. COST OPTIMIZATION QUICK REFERENCE

### Pricing (2025)

```
GitHub-Hosted:
  Linux: $0.008/min
  Windows: $0.016/min
  macOS: $0.016/min

Free Plan: 2,000 min/month (public unlimited)
Pro: 3,000 min/month
Enterprise: 50,000 min/month
```

### Cost Reduction Tactics

| Tactic | Savings |
|--------|---------|
| Caching | 30-60% |
| Parallelization | 20-50% |
| Matrix optimization | 30-70% |
| Concurrency (cancel stale) | 10% |
| Self-hosted runners | 70-80% |
| Total | 80-90% |

### Simple ROI Calculation

```
Current cost: $X/month
Optimization savings: 70% = $X × 0.7/month
Setup hours: 40
Hourly rate: $200
Setup cost: 40 × $200 = $8,000

Break-even: $8,000 / ($X × 0.7) = [months]
```

---

## 7. SECRETS MANAGEMENT QUICK REFERENCE

### OIDC (Replace Long-Lived Tokens)

```yaml
jobs:
  deploy:
    permissions:
      id-token: write
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-actions
          aws-region: us-east-1
```

### Repository Secrets

```yaml
- run: echo ${{ secrets.MY_SECRET }}
```

### Organization Secrets (Scoped)

Define in org settings with repo access list, then use:

```yaml
- run: echo ${{ secrets.ORG_SECRET }}
```

### Environment Secrets (with Approval)

```yaml
jobs:
  deploy:
    environment: production
    steps:
      - run: echo ${{ secrets.PROD_API_KEY }}
```

### Secret Masking

- GitHub automatically masks secret values in logs
- Output will show `***` for any detected secrets

---

## 8. REUSABLE WORKFLOWS QUICK REFERENCE

### Create Reusable Workflow

```yaml
# .github/workflows/test.yml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        type: string
        required: false
        default: '20'
    secrets:
      npm-token:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
```

### Call Reusable Workflow

```yaml
jobs:
  test-default:
    uses: ./.github/workflows/test.yml

  test-custom:
    uses: ./.github/workflows/test.yml
    with:
      node-version: '18'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}
```

### From Another Repository

```yaml
jobs:
  test:
    uses: myorg/shared-workflows/.github/workflows/test.yml@v1.0.0
    with:
      node-version: '20'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}
```

---

## 9. COMPOSITE ACTIONS QUICK REFERENCE

### Create Composite Action

```yaml
# .github/actions/my-action/action.yml
name: My Action
inputs:
  version:
    required: false
    default: '20'

runs:
  using: composite
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.version }}
        cache: 'npm'
    - run: npm ci
      shell: bash
    - run: npm run build
      shell: bash
```

### Use Composite Action

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./.github/actions/my-action
        with:
          version: '18'
```

---

## 10. SELF-HOSTED RUNNERS QUICK REFERENCE

### GitHub UI Setup

1. Settings → Actions → Runners
2. New runner → Linux
3. Download and configure
4. `./run.sh`

### Label Runner

```yaml
runs-on: [self-hosted, linux, x64, high-memory]
```

### Docker with Runner

```yaml
jobs:
  build:
    runs-on: [self-hosted]
    container:
      image: node:20-alpine
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build
```

### AWS EC2 Launch Script

```bash
#!/bin/bash
# Install dependencies
sudo yum update -y
sudo yum install git docker -y
sudo usermod -a -G docker ec2-user

# Install GitHub runner
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64.tar.gz \
  -L https://github.com/actions/runner/releases/download/v2.X.X/...
tar xzf ./actions-runner-linux-x64.tar.gz

# Configure
./config.sh --url https://github.com/myorg/myrepo \
  --token YOUR_TOKEN --runnergroup Default

# Install and start
sudo ./svc.sh install
sudo ./svc.sh start
```

---

## 11. DOCKER OPTIMIZATION QUICK REFERENCE

### Optimized Dockerfile

```dockerfile
FROM node:20-alpine

# Stable layer (rarely changes)
COPY package*.json ./
RUN npm ci --only=production

# Variable layer (changes often)
COPY . .

# Build
RUN npm run build

# Entrypoint
CMD ["npm", "start"]
```

### Buildx with Caching

```yaml
- uses: docker/setup-buildx-action@v3
- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

### Multi-Platform Builds

```yaml
- uses: docker/build-push-action@v5
  with:
    platforms: linux/amd64,linux/arm64
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

---

## 12. PERFORMANCE BENCHMARKING QUICK REFERENCE

### Before Optimization

```
Average build time: 12-15 minutes
Cache hit rate: <30%
Docker builds: 2:20 minutes
Monthly cost: $500-1000
```

### After Phase 1 (Week 1)

```
Average build time: 6-8 minutes (50% faster)
Cache hit rate: 75%+
Docker builds: 1-2 minutes (50% faster)
Monthly cost: -30%
```

### After Phase 2 (Week 3)

```
Average build time: 3-4 minutes (75% faster)
Cache hit rate: 85%+
Docker builds: 15-30 seconds (90% faster)
Monthly cost: -60%
```

### After Phase 3 (Month 2)

```
Average build time: 2-3 minutes (80% faster)
Self-hosted + GitHub hybrid
Monthly cost: -80% to -90%
Developer satisfaction: Significantly improved
```

---

## 13. MONITORING QUICK REFERENCE

### Cost Monitoring

```yaml
name: Cost Alert
on:
  schedule:
    - cron: '0 9 * * 1'

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - name: Check costs
        run: |
          # Use GitHub CLI
          gh api repos/${{ github.repository }}/actions/billing/usage
```

### Metrics to Track

```
Daily:
- Jobs run
- Total minutes
- Cache hit rate

Weekly:
- Cost trend
- Slowest jobs
- Failed jobs

Monthly:
- Total cost vs budget
- Cost per engineer
- ROI of optimizations
```

---

## 14. TROUBLESHOOTING QUICK REFERENCE

### Cache Not Working

1. Check key hasn't changed
2. Verify path exists
3. Cache size < 5GB
4. Path syntax correct

### Jobs Running Sequentially

1. Check for unnecessary `needs:`
2. Remove circular dependencies
3. Verify `if:` conditions

### High Costs

1. Check matrix combinations
2. Verify cancel-in-progress enabled
3. Review OS selection (macOS expensive)
4. Check artifact retention

### Slow Docker Builds

1. Enable layer caching
2. Reorder Dockerfile
3. Combine RUN commands
4. Use .dockerignore

### Secret Leaks

1. Rotate secret immediately
2. Check git history
3. Enable secret scanning
4. Use pre-commit hooks

---

## 15. CHEAT SHEET: COMMON PATTERNS

### Minimal CI

```yaml
name: CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          cache: 'npm'
      - run: npm ci && npm test
```

### Full-Featured CI/CD

```yaml
name: CI/CD
on: [push, pull_request]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 1
      - uses: actions/setup-node@v4
        with:
          cache: 'npm'
      - run: npm ci && npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          cache: 'npm'
      - run: npm ci && npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: production
    permissions:
      id-token: write
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: dist
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-actions
          aws-region: us-east-1
      - run: aws s3 sync dist/ s3://my-bucket/
```

---

## Resources & Links

- **Official Docs**: https://docs.github.com/en/actions
- **Marketplace**: https://github.com/marketplace?type=actions
- **Security**: https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions
- **Pricing**: https://github.com/pricing/features/actions

---
