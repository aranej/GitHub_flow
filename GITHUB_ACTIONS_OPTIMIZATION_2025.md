# GitHub Actions Performance Optimization Guide 2025

## Executive Summary

This comprehensive guide covers advanced optimization strategies for GitHub Actions in 2025, including caching, parallelization, cost optimization, and security best practices. Implementing these patterns can reduce build times by up to 80%, cut costs by 77%, and improve workflow efficiency significantly.

---

## 1. CACHING STRATEGIES

### 1.1 Dependency Caching (npm, pip, Maven, etc.)

#### Using Setup Actions with Built-in Caching (Recommended)

The easiest approach is using official setup actions which include automatic caching:

```yaml
name: Node.js Caching
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Setup with automatic caching
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npm run build
```

**Supported cache types:**
- **Node.js**: npm, yarn, pnpm
- **Python**: pip, pipenv, poetry
- **Java**: maven, gradle
- **Ruby**: bundler
- **Go**: go

#### Manual Caching with actions/cache

For advanced scenarios or unsupported package managers:

```yaml
name: Advanced Dependency Caching
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cache npm dependencies
        uses: actions/cache@v4
        with:
          # Cache ~/.npm instead of node_modules
          path: ~/.npm
          key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-npm-

      - name: Install dependencies
        run: npm ci
```

**Key cache paths by language:**

| Language | Cache Path | Note |
|----------|-----------|------|
| npm | ~/.npm | Recommended over node_modules |
| yarn | ~/.yarn/cache | Use yarn cache dir |
| pip | ~/.cache/pip | Only caches downloads |
| pip (better) | ./venv | Cache entire virtualenv |
| Maven | ~/.m2/repository | Cache Maven repository |
| Gradle | ~/.gradle | Cache Gradle cache |
| Go | ~/go/pkg/mod | Cache Go modules |
| Python (venv) | ./venv | Faster than pip caching |

#### Cache Key Strategy

Use `hashFiles()` for automatic cache invalidation when dependencies change:

```yaml
- name: Cache with hash-based key
  uses: actions/cache@v4
  with:
    path: ~/.npm
    # Key changes only when files change
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-npm-
      ${{ runner.os }}-
```

**Benefits:**
- Reduces download time by 60-80%
- Cache miss only when dependencies actually change
- Automatic cleanup after 7 days of non-use (free tier) or 30 days (paid)

#### Aggressive Caching Strategy

Cache the entire installation state for maximum performance:

```yaml
- name: Install and cache dependencies
  uses: actions/cache@v4
  with:
    path: |
      node_modules
      ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

**Trade-offs:**
- Faster installs (+80% improvement)
- Larger cache size (10GB limit per repo)
- May break across Node versions
- npm ci safer than npm install

### 1.2 Build Artifact Caching

Cache build outputs to avoid rebuilding:

```yaml
name: Build Artifact Caching
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Cache build output
        uses: actions/cache@v4
        id: build-cache
        with:
          path: |
            dist
            build
            .next
          key: ${{ runner.os }}-build-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-build-

      - name: Build (only if not cached)
        if: steps.build-cache.outputs.cache-hit != 'true'
        run: npm run build

      - name: Test
        run: npm test
```

### 1.3 Docker Layer Caching

#### Using GitHub Actions Cache Backend (type=gha)

```yaml
name: Docker Build with Layer Caching
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build with layer caching
        uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

**Performance improvements:**
- Reduces Docker build time by up to 90%
- From ~2:20 minutes to ~15 seconds on subsequent runs
- Caches all layers including intermediate steps

#### Registry Cache Backend (for larger images)

```yaml
- name: Build with registry cache
  uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    tags: myregistry/myimage:latest
    cache-from: type=registry,ref=myregistry/myimage:buildcache
    cache-to: type=registry,ref=myregistry/myimage:buildcache,mode=max
```

**Advantages:**
- No 10GB size limit
- Reuse cache across organization
- Works with all build systems

#### Dockerfile Optimization for Caching

```dockerfile
# Place stable layers first
FROM node:20-alpine

# Dependencies rarely change
COPY package*.json ./
RUN npm ci --only=production

# Source code changes frequently
COPY . .

# Build step last
RUN npm run build

CMD ["node", "dist/index.js"]
```

**Optimization principles:**
- Combine RUN commands to reduce layers
- Order by change frequency (stable → volatile)
- Use multi-stage builds to reduce final image size
- Separate dependencies and source code

### 1.4 Cross-Job Caching

Share cache between different jobs:

```yaml
name: Cross-Job Cache Sharing
on: [push]

jobs:
  install:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci

  lint:
    needs: install
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      # npm cache is restored from previous job
      - run: npm run lint

  test:
    needs: install
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm test
```

---

## 2. MATRIX BUILDS OPTIMIZATION

### 2.1 Basic Matrix Strategy

```yaml
name: Matrix Build Optimization
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 19, 20]
        os: [ubuntu-latest, macos-latest]

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: npm test
```

### 2.2 Matrix Optimization Techniques

#### Reduce Test Combinations

Test fewer critical versions:

```yaml
strategy:
  matrix:
    include:
      # Only test critical versions
      - node-version: 18
        os: ubuntu-latest
      - node-version: 20
        os: ubuntu-latest
      - node-version: 20
        os: macos-latest
      # Skip less critical combinations like 18 on macOS
```

**Impact:**
- From 6 jobs to 3 jobs = 50% reduction
- Reduces total workflow time by ~33%
- Focus on supported production versions

#### Exclude Combinations

```yaml
strategy:
  matrix:
    node-version: [18, 19, 20]
    os: [ubuntu-latest, macos-latest, windows-latest]
    exclude:
      # Exclude expensive combinations
      - os: windows-latest
        node-version: 18
      - os: windows-latest
        node-version: 19
```

#### Matrix with Caching by Version

```yaml
strategy:
  matrix:
    node-version: [18, 19, 20]

steps:
  - uses: actions/checkout@v4
  - uses: actions/setup-node@v4
    with:
      node-version: ${{ matrix.node-version }}
      # Separate cache per Node version
      cache: 'npm'
  - run: npm ci
```

### 2.3 Fail-Fast Strategy

Control job failure behavior:

```yaml
strategy:
  matrix:
    node-version: [18, 19, 20]
  fail-fast: false  # Continue other jobs even if one fails
```

### 2.4 Maximum Concurrent Jobs

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      max-parallel: 3  # Limit concurrent jobs
      matrix:
        node-version: [18, 19, 20, 21, 22]
```

---

## 3. SELF-HOSTED RUNNERS

### 3.1 Architecture Overview

```yaml
name: Using Self-Hosted Runners
on: [push, pull_request]

jobs:
  build:
    runs-on: [self-hosted, linux, x64]  # Target self-hosted runner
    steps:
      - uses: actions/checkout@v4
      - run: ./build.sh
```

### 3.2 AWS EC2 Self-Hosted Runners

#### Basic Setup

```yaml
name: AWS Self-Hosted Runner
on: [push]

jobs:
  build:
    runs-on: [self-hosted, aws-ec2, linux]
    steps:
      - uses: actions/checkout@v4
      - name: Build with EC2 resources
        run: |
          echo "Running on EC2 with more resources"
          npm run build
```

#### Cost Optimization with Spot Instances

```terraform
resource "aws_ec2_instance" "github_runner" {
  # Use spot instances for ~70% cost savings
  instance_type           = "t3.medium"
  spot_price              = "0.0416"  # vs on-demand $0.0832
  associate_public_ip_address = true

  tags = {
    Name = "github-actions-runner"
  }
}
```

**Cost comparison:**
- On-demand t3.medium: $0.0832/hour
- Spot instance: $0.0416/hour
- Annual savings (24/7): ~$3,504

### 3.3 Kubernetes Self-Hosted Runners

Using EKS Auto Mode:

```yaml
name: Kubernetes Runner Workflow
on: [push]

jobs:
  build:
    runs-on: [self-hosted, k8s, linux]
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t myapp .
```

**Benefits:**
- 77% cost reduction vs GitHub-hosted
- Auto-scaling based on demand
- Better resource utilization
- Ephemeral runners (no cleanup overhead)

### 3.4 Docker Container Runners

Using container image as execution environment:

```yaml
name: Docker Container Runners
on: [push]

jobs:
  build:
    runs-on: [self-hosted]
    container:
      image: node:20-alpine
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build
```

### 3.5 Self-Hosted Runner Scaling Strategy

```yaml
# Scaling metrics
runners_by_usage = {
  "low_traffic":  1,      # Off-hours, single runner
  "standard":     3-5,    # Normal workload
  "high_demand":  10-20   # Peak hours
}

# Auto-scaling with scheduled actions
schedule_runners = {
  "0 8 * * 1-5":   scale_to(5),    # 8 AM weekdays
  "0 18 * * 1-5":  scale_to(10),   # 6 PM weekdays
  "0 22 * * *":    scale_to(1),    # 10 PM daily
}
```

---

## 4. COST OPTIMIZATION

### 4.1 Cost Analysis Framework

#### GitHub-Hosted Runners Pricing (2025)

| Plan | Minutes | Storage | Concurrent Jobs | Cost |
|------|---------|---------|-----------------|------|
| Free | 2,000/mo | 500 MB | 20 | $0 |
| Pro | 3,000/mo | 1 GB | 40 | $4/mo |
| Team | 3,000/mo | 2 GB | 40 | $12/mo |
| Enterprise | 50,000/mo | 50 GB | 180 | Custom |

#### Overage Costs

- Linux: $0.008/minute
- Windows: $0.016/minute
- macOS: $0.016/minute
- Storage: $0.008/GB/day

### 4.2 Cost Optimization Patterns

#### Pattern 1: Smart Concurrency Usage

```yaml
name: Cost-Optimized Workflow
on: [push, pull_request]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true  # Cancel outdated runs

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build
```

**Savings:** 10% reduction in minutes by canceling obsolete runs

#### Pattern 2: Conditional Job Execution

```yaml
jobs:
  lint:
    if: github.event_name == 'pull_request'  # Only on PRs
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run lint

  test:
    if: github.event_name != 'push' || startsWith(github.ref, 'refs/tags/')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

#### Pattern 3: Selective Testing Matrix

```yaml
strategy:
  matrix:
    include:
      # Only test supported versions
      - node: 18
        test: true
      - node: 20
        test: true
      - node: 21
        test: false  # Skip if not supported
```

#### Pattern 4: Cheaper Runner Selection

```yaml
jobs:
  build:
    runs-on: ubuntu-latest  # Cheapest ($0.008/min)

  build-windows:
    runs-on: windows-latest  # More expensive ($0.016/min)
    if: github.event_name == 'release'  # Only when needed
```

#### Pattern 5: Shallow Clone

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 1  # Shallow clone, faster checkout
```

**Savings:** 30-50% faster on large repos

#### Pattern 6: Reuse Build Artifacts

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      artifact-path: ${{ steps.build.outputs.path }}
    steps:
      - uses: actions/checkout@v4
      - name: Build
        id: build
        run: |
          npm run build
          echo "path=dist" >> $GITHUB_OUTPUT

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          path: ${{ needs.build.outputs.artifact-path }}
      - run: npm run deploy
```

### 4.3 Total Cost of Ownership Calculation

```javascript
// Monthly cost calculation
function calculateMonthlyActionsCost(plan, usage) {
  const plans = {
    free: { minutes: 2000, storage: 500, cost: 0 },
    pro: { minutes: 3000, storage: 1000, cost: 4 },
    team: { minutes: 3000, storage: 2000, cost: 12 },
  };

  const selectedPlan = plans[plan];
  let monthlyMinutes = usage.minutes;
  let monthlyStorage = usage.storage;

  // Calculate overage costs
  let overageMinutes = Math.max(0, monthlyMinutes - selectedPlan.minutes);
  let overageStorage = Math.max(0, monthlyStorage - selectedPlan.storage);

  // Assume Linux (cheaper than Windows/macOS)
  let minutesCost = overageMinutes * 0.008;
  let storageCost = overageStorage * 0.008 * 30; // per day

  return {
    baseCost: selectedPlan.cost,
    minutesCost,
    storageCost,
    total: selectedPlan.cost + minutesCost + storageCost
  };
}

// Examples
console.log(calculateMonthlyActionsCost('free', { minutes: 5000, storage: 2000 }));
// { baseCost: 0, minutesCost: 24, storageCost: 240, total: 264 }

console.log(calculateMonthlyActionsCost('pro', { minutes: 5000, storage: 2000 }));
// { baseCost: 4, minutesCost: 16, storageCost: 240, total: 260 }
```

### 4.4 Self-Hosted Runner ROI Analysis

```
Scenario: 50,000 minutes/month with GitHub-hosted runners

GitHub-hosted costs:
  50,000 minutes - 3,000 free minutes = 47,000 overage
  47,000 × $0.008/minute = $376/month
  Annual: $4,512

Self-hosted on AWS EC2 (t3.medium):
  Cost: $0.0832/hour on-demand = $59.9/month
  Or $0.0416/hour spot = $30/month
  Annual: $360-720

Break-even point:
  GitHub-hosted: 375 minutes/day average
  Self-hosted ROI: Immediate with >500 minutes/month
```

---

## 5. WORKFLOW PARALLELIZATION

### 5.1 Job-Level Parallelization

GitHub Actions runs jobs in parallel by default (up to 256 concurrent jobs):

```yaml
name: Parallel Jobs
on: [push]

jobs:
  # All jobs run in parallel by default
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test

  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run build

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm audit
```

**Execution time:** ~3 minutes (parallel) vs ~12 minutes (sequential)

### 5.2 Sequential Execution with Dependencies

Control execution order using `needs`:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: dist

  test:
    needs: build  # Wait for build to complete
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with:
          name: build-output
      - run: npm test

  deploy:
    needs: test  # Wait for test to complete
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying application"
```

### 5.3 Conditional Job Execution

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
    steps:
      - uses: actions/checkout@v4
      - id: version
        run: echo "version=$(cat version.txt)" >> $GITHUB_OUTPUT
      - run: npm run build

  publish:
    needs: build
    if: startsWith(github.ref, 'refs/tags/')  # Only on tags
    runs-on: ubuntu-latest
    steps:
      - run: echo "Publishing v${{ needs.build.outputs.version }}"

  notify:
    needs: [build, publish]
    if: always()  # Always run, even if previous jobs fail
    runs-on: ubuntu-latest
    steps:
      - run: echo "Workflow complete"
```

### 5.4 Fan-Out/Fan-In Pattern

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    outputs:
      test-matrix: ${{ steps.set-matrix.outputs.matrix }}
    steps:
      - id: set-matrix
        run: |
          echo 'matrix={"node":[18,20],"browser":["chrome","firefox"]}' >> $GITHUB_OUTPUT

  test:
    needs: setup
    runs-on: ubuntu-latest
    strategy:
      matrix: ${{ fromJson(needs.setup.outputs.test-matrix) }}
    steps:
      - run: npm test --node ${{ matrix.node }} --browser ${{ matrix.browser }}

  results:
    needs: test
    if: always()
    runs-on: ubuntu-latest
    steps:
      - run: echo "All tests complete"
```

### 5.5 Concurrency Control for Parallelization

Limit parallelization to save costs:

```yaml
strategy:
  matrix:
    node-version: [18, 19, 20, 21, 22]
  max-parallel: 2  # Only run 2 at a time

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: npm test
```

---

## 6. SECRETS MANAGEMENT

### 6.1 Secrets Hierarchy

```
Organization Secrets
  ↓
Repository Secrets (override org)
  ↓
Environment Secrets (override both)
  ↓
Job-Level Secrets
```

### 6.2 OIDC Authentication (Recommended)

Replace long-lived credentials with OpenID Connect tokens:

```yaml
name: OIDC AWS Authentication
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write  # Required for OIDC
      contents: read
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          # No static credentials needed!
          role-to-assume: arn:aws:iam::123456789:role/github-actions
          aws-region: us-east-1

      - name: Deploy to AWS
        run: |
          aws s3 cp dist/ s3://my-bucket/ --recursive
```

**Benefits:**
- No long-lived credentials in GitHub
- Fine-grained access control
- Automatic rotation
- Full audit trail in cloud provider

### 6.3 Secret Scoping

#### Repository Secrets

For secrets used in a single repository:

```yaml
- name: Use repository secret
  run: |
    echo "Username: ${{ secrets.DB_USERNAME }}"
    # Secret output is masked in logs
```

#### Organization Secrets with Scoping

```yaml
# Define in org settings with repo access list
- name: Use scoped org secret
  run: |
    echo "API_KEY: ${{ secrets.ORG_API_KEY }}"
```

**Security:** Only specified repos can access

#### Environment Secrets with Approval

```yaml
name: Environment-Specific Secrets
on: [push]

jobs:
  deploy:
    environment: production
    runs-on: ubuntu-latest
    steps:
      - name: Deploy with approval
        run: |
          # Requires designated reviewers to approve
          echo "Deploying with: ${{ secrets.PROD_DEPLOY_KEY }}"
```

### 6.4 Secret Rotation Strategy

```yaml
name: Automatic Secret Rotation
on:
  schedule:
    - cron: '0 0 1 * *'  # Monthly

jobs:
  rotate-secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Rotate database password
        run: |
          # 1. Generate new password
          NEW_PASSWORD=$(openssl rand -base64 32)

          # 2. Update in database
          mysql -h ${{ secrets.DB_HOST }} \
                 -u admin \
                 -p${{ secrets.ADMIN_PASSWORD }} \
                 -e "ALTER USER 'app'@'%' IDENTIFIED BY '$NEW_PASSWORD'"

          # 3. Update GitHub secret via API
          curl -X PATCH \
               -H "Authorization: token ${{ secrets.GH_TOKEN }}" \
               -H "Accept: application/vnd.github.v3+json" \
               https://api.github.com/repos/${{ github.repository }}/actions/secrets/DB_PASSWORD \
               -d "{\"encrypted_value\":\"$NEW_PASSWORD\"}"
```

### 6.5 Secret Scanning and Prevention

```yaml
name: Prevent Secret Leaks
on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: TruffleHog Secret Scanning
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD
```

### 6.6 Least Privilege Access Pattern

```yaml
name: Least Privilege Secrets
on: [push]

env:
  # Application user with read-only permissions
  DB_USER: app_readonly
  DB_HOST: ${{ secrets.DATABASE_HOST }}

jobs:
  read-data:
    runs-on: ubuntu-latest
    steps:
      - name: Query database (read-only)
        run: |
          mysql -h ${{ env.DB_HOST }} \
                 -u ${{ env.DB_USER }} \
                 -p${{ secrets.DB_PASSWORD_READONLY }} \
                 -e "SELECT * FROM data"

  write-data:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Migrate database (write)
        run: |
          mysql -h ${{ env.DB_HOST }} \
                 -u admin \
                 -p${{ secrets.DB_PASSWORD_ADMIN }} \
                 -e "ALTER TABLE data ADD COLUMN new_field VARCHAR(255)"
```

---

## 7. REUSABLE WORKFLOWS

### 7.1 Creating Reusable Workflows

Store workflows in `.github/workflows/` with `on: workflow_call`:

```yaml
# .github/workflows/test.yml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        description: 'Node version to test'
        required: false
        type: string
        default: '20'
      test-command:
        description: 'Command to run tests'
        required: false
        type: string
        default: 'npm test'
    secrets:
      npm-token:
        description: 'NPM registry token'
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          registry-url: 'https://registry.npmjs.org'

      - run: npm ci
        env:
          NODE_AUTH_TOKEN: ${{ secrets.npm-token }}

      - run: ${{ inputs.test-command }}
```

### 7.2 Calling Reusable Workflows

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on: [push, pull_request]

jobs:
  test-default:
    uses: ./.github/workflows/test.yml

  test-node-18:
    uses: ./.github/workflows/test.yml
    with:
      node-version: '18'
      test-command: 'npm run test:ci'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}

  test-node-21:
    uses: ./.github/workflows/test.yml
    with:
      node-version: '21'
      test-command: 'npm run test:ci'
```

### 7.3 Composite Actions vs Reusable Workflows

#### Composite Actions (Step-Level)

```yaml
# .github/actions/build/action.yml
name: 'Build Application'
description: 'Build application with caching'

inputs:
  node-version:
    description: 'Node version'
    required: false
    default: '20'

runs:
  using: 'composite'
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'

    - run: npm ci
      shell: bash

    - run: npm run build
      shell: bash
```

Usage:
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./.github/actions/build
        with:
          node-version: '20'
```

#### Reusable Workflows (Job-Level)

- Run as complete job(s)
- Can use different runners per job
- Can include multiple jobs
- Cannot be composed within a step

**Decision matrix:**

| Requirement | Composite | Reusable |
|-------------|-----------|----------|
| Step-level reuse | ✓ | ✗ |
| Job-level reuse | ✗ | ✓ |
| Multiple jobs | ✗ | ✓ |
| Different runner | ✗ | ✓ |
| Simpler actions | ✓ | ✗ |

### 7.4 Reusable Workflow Best Practices

#### Structure

```
.github/
├── workflows/
│   ├── ci.yml (entry point)
│   ├── test.yml (reusable)
│   ├── build.yml (reusable)
│   └── deploy.yml (reusable)
└── actions/
    ├── setup-environment/
    └── notify-slack/
```

#### Clear Inputs/Outputs

```yaml
name: Reusable Build Workflow

on:
  workflow_call:
    inputs:
      build-target:
        type: string
        description: 'Build target (dev, staging, prod)'
        required: true
      skip-tests:
        type: boolean
        description: 'Skip tests'
        default: false
    outputs:
      artifact-id:
        description: 'Build artifact ID'
        value: ${{ jobs.build.outputs.artifact-id }}
      version:
        description: 'Build version'
        value: ${{ jobs.build.outputs.version }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      artifact-id: ${{ steps.build.outputs.id }}
      version: ${{ steps.build.outputs.version }}
    steps:
      - uses: actions/checkout@v4
      - name: Build
        id: build
        run: |
          VERSION=$(date +%s)
          ARTIFACT_ID="build-$VERSION"
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "id=$ARTIFACT_ID" >> $GITHUB_OUTPUT
```

### 7.5 Versioning Reusable Workflows

```yaml
# Always pin to versions for stability
jobs:
  test:
    uses: myorg/shared-workflows/.github/workflows/test.yml@v1.2.0

  deploy:
    uses: myorg/shared-workflows/.github/workflows/deploy.yml@main  # Or main branch
```

### 7.6 Testing Reusable Workflows

```yaml
# .github/workflows/test-workflows.yml
name: Test Reusable Workflows

on: [push, pull_request]

jobs:
  test-build-workflow:
    uses: ./.github/workflows/build.yml
    with:
      build-target: 'dev'
      skip-tests: false

  test-build-workflow-prod:
    uses: ./.github/workflows/build.yml
    with:
      build-target: 'prod'
      skip-tests: false

  verify-outputs:
    needs: [test-build-workflow, test-build-workflow-prod]
    runs-on: ubuntu-latest
    steps:
      - name: Verify build artifacts
        run: |
          echo "Build 1: ${{ needs.test-build-workflow.outputs.artifact-id }}"
          echo "Build 2: ${{ needs.test-build-workflow-prod.outputs.artifact-id }}"
```

---

## PRACTICAL IMPLEMENTATION EXAMPLE

### Complete Optimized Workflow

```yaml
name: Optimized CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # Setup
  setup:
    runs-on: ubuntu-latest
    outputs:
      should-deploy: ${{ steps.check.outputs.deploy }}
    steps:
      - uses: actions/checkout@v4
      - id: check
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "deploy=true" >> $GITHUB_OUTPUT
          else
            echo "deploy=false" >> $GITHUB_OUTPUT
          fi

  # Parallel jobs (all start immediately)
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: npm test

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm audit --audit-level=moderate

  # Build after checks pass
  build:
    needs: [lint, test, security]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - name: Cache build
        uses: actions/cache@v4
        with:
          path: dist
          key: ${{ runner.os }}-build-${{ github.sha }}
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist

  # Docker build with layer caching
  docker:
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # Deploy only on main
  deploy:
    needs: [build, setup]
    if: needs.setup.outputs.should-deploy == 'true'
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    permissions:
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with:
          name: dist
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-actions
          aws-region: us-east-1
      - run: aws s3 cp dist/ s3://my-bucket/ --recursive
```

---

## COST SAVINGS SUMMARY

| Optimization | Impact | Implementation Time |
|--------------|--------|-------------------|
| Dependency Caching | 60-80% faster builds | 5 minutes |
| Docker Layer Caching | 85-90% faster Docker builds | 10 minutes |
| Concurrency Management | 10% cost reduction | 5 minutes |
| Selective Matrix | 30-50% fewer jobs | 10 minutes |
| Self-Hosted Runners | 77% cost reduction | 1-2 hours |
| OIDC Auth | Eliminate credential rotation | 30 minutes |
| Reusable Workflows | 30-40% code reduction | Ongoing |
| **Total Potential Savings** | **77-90% cost reduction** | **2-3 hours setup** |

---

## PERFORMANCE BENCHMARKS (2025)

### Before Optimization
- Build time: 12-15 minutes
- Docker build: 2:20 minutes
- Monthly costs: $500+

### After Optimization
- Build time: 2-3 minutes (75% reduction)
- Docker build: 15-30 seconds (90% reduction)
- Monthly costs: $50-100 (80% reduction)

### ROI Timeline
- Setup: 2-3 hours
- Monthly savings: $400-450
- Break-even: Less than 1 hour
- Annual savings: $4,800-5,400

---

## RESOURCES

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)
- [Composite Actions Documentation](https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions#composite-run-steps-syntax)
- [Reusable Workflows Documentation](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
