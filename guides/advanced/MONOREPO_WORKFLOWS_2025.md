# Monorepo Git Workflow Strategies for 2025
## Comprehensive Guide with Practical Patterns and Configurations

---

## Executive Summary

Modern monorepo strategies for 2025 emphasize performance optimization, selective CI/CD triggering, clear code ownership, and AI-friendly architectures. This guide provides practical patterns for managing large-scale repositories using industry-leading tools.

---

## 1. PATH-BASED WORKFLOWS

### 1.1 Directory Structure Patterns

**Recommended Monorepo Structure:**

```
monorepo/
├── apps/
│   ├── web/                  # Main web application
│   ├── admin/                # Admin dashboard
│   └── mobile/               # Mobile app
├── libs/
│   ├── shared-ui/            # Shared UI components
│   ├── shared-utils/         # Utility functions
│   └── api-client/           # API client library
├── tools/
│   ├── scripts/
│   └── generators/
├── .github/
│   ├── CODEOWNERS
│   └── workflows/
├── nx.json                   # Build orchestration config
├── turbo.json               # (If using Turborepo)
├── pnpm-workspace.yaml      # Package manager workspace
├── tsconfig.base.json       # Shared TypeScript config
└── package.json
```

### 1.2 Package Boundary Patterns

**Strict Path Isolation:**

```yaml
# .github/CODEOWNERS example with path boundaries
# Core infrastructure
/libs/shared-ui/        @team-design
/libs/shared-utils/     @team-platform
/libs/api-client/       @team-api

# Feature teams
/apps/web/              @team-web
/apps/admin/            @team-admin
/apps/mobile/           @team-mobile

# Platform team
/tools/                 @team-platform
```

### 1.3 Dependency Graph Enforcement

**Using Nx to define boundaries (nx.json):**

```json
{
  "extends": "nx/presets/npm.json",
  "defaultBase": "main",
  "targetDefaults": {
    "build": {
      "inputs": [
        "{projectRoot}/**/*",
        "!{projectRoot}/**/*.spec.ts"
      ],
      "outputs": ["{projectRoot}/dist"]
    }
  },
  "namedInputs": {
    "default": ["{projectRoot}/**/*"],
    "sourceFiles": [
      "{projectRoot}/src/**/*",
      "!{projectRoot}/**/*.spec.ts"
    ],
    "testsFiles": ["{projectRoot}/**/*.spec.ts"]
  }
}
```

**Enforce access rules in workspace.json (legacy) or inferred projects:**

```json
{
  "projects": {
    "libs-shared-ui": {
      "tags": ["scope:shared", "type:ui"]
    },
    "apps-web": {
      "tags": ["scope:web", "type:app"],
      "implicitDependencies": ["libs-shared-ui"]
    }
  }
}
```

---

## 2. SELECTIVE CI/CD TRIGGERING

### 2.1 GitHub Actions Path Filters

**Basic Path-Based Workflow:**

```yaml
# .github/workflows/selective-ci.yml
name: Selective CI/CD Pipeline

on:
  pull_request:
    paths:
      - 'apps/web/**'
      - 'libs/shared-ui/**'
      - 'libs/shared-utils/**'
  push:
    branches:
      - main
    paths:
      - 'apps/web/**'
      - 'libs/shared-ui/**'

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      web-changed: ${{ steps.changes.outputs.web }}
      ui-changed: ${{ steps.changes.outputs.ui }}
      utils-changed: ${{ steps.changes.outputs.utils }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            web:
              - 'apps/web/**'
              - 'libs/shared-ui/**'
              - 'libs/shared-utils/**'
            ui:
              - 'libs/shared-ui/**'
            utils:
              - 'libs/shared-utils/**'

  build-web:
    needs: detect-changes
    if: needs.detect-changes.outputs.web-changed == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'pnpm'

      - run: pnpm install
      - run: pnpm build apps/web
      - run: pnpm test apps/web

  build-ui:
    needs: detect-changes
    if: needs.detect-changes.outputs.ui-changed == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'pnpm'

      - run: pnpm install
      - run: pnpm build libs/shared-ui
      - run: pnpm test libs/shared-ui

  deploy:
    needs: [detect-changes, build-web]
    if: github.ref == 'refs/heads/main' && needs.detect-changes.outputs.web-changed == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Deploying web app..."
```

### 2.2 Nx-based Selective CI/CD

**Using Nx affected command:**

```yaml
# .github/workflows/nx-ci.yml
name: Nx CI/CD

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  affected:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'pnpm'

      - run: pnpm install

      # Run linting, testing, and building only for affected projects
      - run: npx nx affected -t lint
      - run: npx nx affected -t test
      - run: npx nx affected -t build

      # Optional: Generate coverage reports
      - run: npx nx affected -t test --coverage
```

### 2.3 Turborepo Selective Building

**turbo.json Pipeline Configuration:**

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["tsconfig.json", ".env.local"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"],
      "outputMode": "hash-only",
      "cache": true
    },
    "test": {
      "dependsOn": ["^build"],
      "cache": false
    },
    "lint": {
      "cache": true
    },
    "dev": {
      "cache": false,
      "persistent": true
    }
  },
  "remoteCache": {
    "enabled": true
  }
}
```

**Triggering only affected packages:**

```bash
# Build only changed packages and their dependents
turbo build --filter="[HEAD^]"

# Run tests for a specific package and its dependents
turbo test --filter="@mymonorepo/web..."

# Run all tasks for changed packages
turbo run build test lint --filter="[HEAD^]"
```

### 2.4 AWS CodePipeline with Lambda Triggers

**Lambda function for custom path detection:**

```python
import json
import boto3

codepipeline = boto3.client('codepipeline')

def lambda_handler(event, context):
    """
    Evaluates GitHub webhook payload to determine which pipelines to trigger
    """
    # Parse GitHub webhook
    github_payload = json.loads(event['body'])
    changed_files = get_changed_files(github_payload)

    # Determine which services changed
    services_to_deploy = determine_affected_services(changed_files)

    # Put job success/failure
    job_id = event['CodePipeline.job']['id']

    if services_to_deploy:
        put_job_success(job_id, {
            'services': services_to_deploy
        })
    else:
        put_job_success(job_id, {'skip': True})

    return {
        'statusCode': 200,
        'body': json.dumps('Pipeline decision made')
    }

def get_changed_files(payload):
    """Extract changed files from GitHub webhook"""
    changed_files = []
    commits = payload.get('commits', [])
    for commit in commits:
        changed_files.extend(commit.get('added', []))
        changed_files.extend(commit.get('modified', []))
    return changed_files

def determine_affected_services(changed_files):
    """Map changed files to services"""
    service_map = {
        'apps/web': 'deploy-web',
        'apps/admin': 'deploy-admin',
        'libs/shared': 'deploy-all'  # Triggers all if shared lib changes
    }

    affected = set()
    for file_path in changed_files:
        for prefix, service in service_map.items():
            if file_path.startswith(prefix):
                affected.add(service)

    return list(affected)

def put_job_success(job_id, output=None):
    """Notify CodePipeline of job success"""
    codepipeline.put_job_success_result(
        jobId=job_id,
        outputVariables={'services': json.dumps(output or {})}
    )
```

---

## 3. CODE OWNERSHIP (CODEOWNERS)

### 3.1 CODEOWNERS File Structure

**Basic CODEOWNERS Pattern:**

```
# .github/CODEOWNERS

# Global default owners (fallback)
* @platform-team

# UI Libraries
/libs/shared-ui @design-team @frontend-lead
/libs/shared-ui/buttons/ @design-team @ux-specialist
/libs/shared-ui/layouts/ @design-team

# Utilities
/libs/shared-utils/ @platform-team
/libs/shared-utils/math/ @platform-team @data-science
/libs/api-client/ @platform-team @api-team

# Applications
/apps/web/ @web-team @frontend-lead
/apps/web/pages/ @web-team
/apps/web/components/ @web-team @design-team
/apps/admin/ @admin-team @security-team
/apps/mobile/ @mobile-team

# Infrastructure
/tools/ @platform-team @devops-team
/.github/ @devops-team
/Dockerfile* @devops-team

# Config files
package.json @platform-team
tsconfig.json @platform-team
nx.json @platform-team
turbo.json @platform-team

# GitHub configuration
/.github/ @devops-team
/.github/workflows/ @devops-team @security-team
```

### 3.2 Distributed CODEOWNERS Pattern

**For larger teams (place CODEOWNERS in subdirectories):**

```
# /apps/web/.github/CODEOWNERS
* @web-team @frontend-lead
/pages @web-team @ux-designer
/components @web-team @design-team

# /libs/shared-ui/.github/CODEOWNERS
* @design-team
/buttons @ux-specialist
/forms @accessibility-expert
```

**Using codeowners-generator to consolidate:**

```bash
# Install codeowners-generator
npm install -g codeowners-generator

# Generate consolidated CODEOWNERS from distributed files
codeowners-generator generate

# Output: .github/CODEOWNERS (auto-generated, should be committed)
```

### 3.3 Integration with GitHub Workflows

**Require CODEOWNERS review:**

```yaml
# .github/workflows/enforce-codeowners.yml
name: Enforce CODEOWNERS Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  validate-reviews:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Check for required reviews
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const path = require('path');

            // Get changed files
            const { data: pullRequest } = await github.rest.pulls.get({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.issue.number
            });

            const { data: files } = await github.rest.pulls.listFiles({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.issue.number
            });

            // Parse CODEOWNERS
            const codeownersPath = '.github/CODEOWNERS';
            if (!fs.existsSync(codeownersPath)) {
              console.log('No CODEOWNERS file found');
              return;
            }

            const codeownersContent = fs.readFileSync(codeownersPath, 'utf-8');

            // Extract required owners for changed files
            const requiredOwners = new Set();
            files.forEach(file => {
              const owners = matchCodeowners(file.filename, codeownersContent);
              owners.forEach(owner => requiredOwners.add(owner));
            });

            console.log('Required owners:', Array.from(requiredOwners));
```

### 3.4 Syncing CODEOWNERS with package.json

**Automated sync using npm scripts:**

```json
{
  "scripts": {
    "codeowners:sync": "node scripts/sync-codeowners.js",
    "codeowners:validate": "node scripts/validate-codeowners.js"
  }
}
```

**sync-codeowners.js:**

```javascript
const fs = require('fs');
const path = require('path');
const glob = require('glob');

function syncCodeowners() {
  const codeownersEntries = [];

  // Scan all packages for maintainers
  const packages = glob.sync('+(apps|libs)/*/package.json');

  packages.forEach(pkgPath => {
    const dir = path.dirname(pkgPath);
    const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf-8'));

    // Extract maintainers from package.json
    const maintainers = [
      ...(pkg.maintainers || []),
      ...(pkg.contributors || [])
    ].map(m => typeof m === 'string' ? m : m.name || m.email);

    if (maintainers.length > 0) {
      const owners = maintainers.join(' ');
      codeownersEntries.push(`${dir} ${owners}`);
    }
  });

  // Write CODEOWNERS
  const codeownersPath = '.github/CODEOWNERS';
  const content = `# Auto-generated from package.json maintainers
# Last updated: ${new Date().toISOString()}

${codeownersEntries.join('\n')}

# Fallback for unlisted files
* @platform-team
`;

  fs.writeFileSync(codeownersPath, content);
  console.log('✓ CODEOWNERS synced from package.json');
}

syncCodeowners();
```

---

## 4. LARGE REPOSITORY PERFORMANCE

### 4.1 Git Configuration for Large Monorepos

**Optimal git config settings (apply globally or per-repo):**

```bash
# Enable commit graph for faster log operations
git config core.commitgraph true
git config gc.writecommitgraph true

# Use file system monitor for faster status checks
git config core.fsmonitor true
git config core.untrackedCache true

# Handle many files efficiently
git config feature.manyFiles true

# Optimize index version (4 is default in Git 2.40+)
git config index.version 4

# Enable preload index for parallelized operations
git config core.preloadindex true

# Set auto-gc threshold
git config gc.auto 256

# Sparse index (Git 2.40+)
git config core.sparseCheckout true
git config index.sparseCheckout true

# Apply all at once:
cat >> .git/config << 'EOF'
[core]
    commitgraph = true
    fsmonitor = true
    writeCommitGraph = true
    untrackedCache = true
    preloadindex = true
    sparseCheckout = true
[feature]
    manyFiles = true
[gc]
    auto = 256
    writeCommitGraph = true
[index]
    version = 4
EOF
```

**Performance impact example:**
- Before: `git status` = 0.316 seconds (425% CPU)
- After: `git status` = 0.118 seconds (89% CPU)

### 4.2 Sparse Checkout for Selective Cloning

**Modern sparse-checkout approach (Git 2.37+):**

```bash
# Clone with partial fetch (no blob contents initially)
git clone --sparse --filter=blob:none <repository-url> <directory>

# Initialize cone mode (most performant)
git sparse-checkout init --cone

# Set which directories to include
git sparse-checkout set apps/web libs/shared-ui libs/shared-utils

# Or add directories incrementally
git sparse-checkout add apps/admin

# View current sparse-checkout configuration
git sparse-checkout list

# Re-populate a directory you previously excluded
git sparse-checkout set apps/web apps/admin libs/

# Disable sparse checkout (full repo)
git sparse-checkout disable
```

**Cone Mode vs Non-Cone (deprecated):**
- **Cone Mode** (recommended): Automatically includes all parent directories, faster pattern matching
- **Non-Cone Mode** (deprecated): Complex patterns, slower performance

### 4.3 Partial Cloning with Blob Filtering

**Lazy-download strategy:**

```bash
# Clone with blob filter (don't download file contents)
git clone --filter=blob:none <repository-url>

# Combine with sparse-checkout for maximum efficiency
git clone --sparse --filter=blob:none <repository-url>

# Download blobs only when needed (on checkout/diff)
git checkout <branch>

# Or explicitly fetch what you need
git fetch-pack --all --stdin-commits

# Configure as default for repository
git config remote.origin.filterBlobLimit 256k
```

**Before and After Performance:**

```
Repository: 1.6M files, 214GB total size

Without optimization:
- Clone time: 7.9 minutes
- Storage: 214GB
- Status check: Slow

With sparse-checkout + partial clone:
- Clone time: 5.1 minutes (36% improvement)
- Storage: 87GB (59% reduction)
- Status check: Near instant
```

### 4.4 Maintenance and Cleanup

**Regular repository maintenance:**

```bash
# Optimize repository for large monorepos
git gc --aggressive

# Repack objects for better compression
git repack -Ad

# Prune unreachable objects
git prune

# Clean up reflog (for very old history)
git reflog expire --expire=all --all
git gc --prune=now

# Check repository integrity
git fsck --full

# Get repository statistics
git count-objects -v

# Monitor object growth over time
watch -n 60 'git count-objects -v | head -10'
```

### 4.5 Branching Strategy Impact

**Meta's Sapling approach for directory branches:**

Directory branches (innovation from Meta) address scalability issues with traditional merge commits that have multiple parents in massive monorepos. This allows teams to branch entire directories independently while maintaining repository cleanliness.

```
Traditional: merge commits can have N parents (slows down traversal)
Sapling: directory branches appear as linear commits at monorepo level
Result: O(1) branch operations vs O(N) in traditional approach
```

### 4.6 CI/CD Pipeline Optimization

**Reduce CI concurrency and resource waste:**

```yaml
# .github/workflows/optimized-pipeline.yml
name: Optimized Monorepo CI

on:
  push:
    branches: [main]
  schedule:
    # Stagger scheduled runs to reduce resource peaks
    - cron: '0 2 * * *'    # 2 AM UTC
    - cron: '0 6 * * *'    # 6 AM UTC (4 hours apart)

jobs:
  # Use matrix strategy with limits
  test:
    strategy:
      matrix:
        package:
          - web
          - admin
          - mobile
        include:
          - package: shared-ui
            build-time: 'high'
          - package: shared-utils
            build-time: 'low'
      max-parallel: 3  # Limit concurrent jobs
    runs-on: ubuntu-latest
    steps:
      # Use Nx affected to skip unchanged packages
      - run: |
          AFFECTED=$(npx nx affected:apps --plain 2>/dev/null | tr '\n' ' ')
          if [[ "$AFFECTED" == *"${{ matrix.package }}"* ]]; then
            echo "Building ${{ matrix.package }}"
            pnpm build ${{ matrix.package }}
          else
            echo "Skipping ${{ matrix.package }} (no changes)"
          fi
```

---

## 5. TOOLS COMPARISON: NX, TURBOREPO, LERNA

### 5.1 Feature Comparison Matrix

| Feature | Nx | Turborepo | Lerna |
|---------|----|-----------| ------|
| **Build Caching** | Excellent | Excellent | Good |
| **Task Scheduling** | Excellent | Excellent | Moderate |
| **Learning Curve** | Moderate | Low | Low |
| **Performance** | 5.3x faster* | Fast | Slower |
| **Dependency Graph** | Advanced | Basic | Basic |
| **Code Generation** | Yes | Limited | No |
| **Local Caching** | Yes | Yes | Limited |
| **Remote Caching** | Nx Cloud | Vercel | Limited |
| **Plugin System** | Comprehensive | Limited | Limited |
| **Community** | Large | Growing | Active |
| **TypeScript Support** | Native | Native | Native |
| **Package Publishing** | Via plugins | Limited | Built-in |
| **Monorepo-Only** | No | No | Yes |

*Benchmark: Lerna + Nx vs Turborepo on large repositories

### 5.2 Nx Configuration (2025)

**Modern nx.json (workspace.json is deprecated):**

```json
{
  "$schema": "./node_modules/nx/schemas/nx-schema.json",
  "extends": "nx/presets/npm.json",
  "npmScope": "mymonorepo",
  "defaultBase": "main",
  "defaultRelease": {
    "releaseTagPattern": "{version}",
    "projectChangelogFile": "CHANGELOG.md"
  },
  "nxCloudUrl": "https://nx.app",
  "targetDefaults": {
    "build": {
      "cache": true,
      "inputs": [
        "{projectRoot}/src/**/*",
        "{projectRoot}/package.json",
        "tsconfig.base.json"
      ],
      "outputs": ["{projectRoot}/dist"]
    },
    "test": {
      "cache": true,
      "inputs": [
        "{projectRoot}/src/**/*",
        "{projectRoot}/**/*.spec.ts",
        "tsconfig.base.json"
      ]
    },
    "lint": {
      "cache": true,
      "outputs": []
    }
  },
  "namedInputs": {
    "default": ["{projectRoot}/**/*"],
    "sourceFiles": [
      "{projectRoot}/src/**/*",
      "{projectRoot}/package.json"
    ],
    "testsFiles": ["{projectRoot}/**/*.spec.ts"],
    "allSourceFiles": ["sourceFiles", "testsFiles"]
  },
  "plugins": [
    {
      "plugin": "@nx/js/typescript",
      "options": {
        "analyzeSourceFiles": true
      }
    },
    {
      "plugin": "@nx/react/plugin",
      "options": {
        "staticFilesProject": "web"
      }
    }
  ]
}
```

**Running tasks with Nx:**

```bash
# Build affected projects
nx affected -t build

# Run tests for a specific project and dependents
nx run-many -t test --projects=web

# View dependency graph
nx graph

# View what changed
nx affected:apps

# Run with parallel execution
nx run-many -t build --parallel=4 --maxWorkers=8
```

### 5.3 Turborepo Configuration (2025)

**turbo.json with advanced features:**

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": [
    "tsconfig.json",
    ".env.local",
    ".turborc"
  ],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"],
      "outputMode": "hash-only",
      "cache": true,
      "env": ["NODE_ENV"]
    },
    "test": {
      "dependsOn": ["^build"],
      "cache": false,
      "outputs": ["coverage/**"]
    },
    "lint": {
      "cache": true,
      "outputs": []
    },
    "dev": {
      "cache": false,
      "persistent": true,
      "interactive": true,
      "env": ["NODE_ENV", "DATABASE_URL"]
    }
  },
  "globalEnv": [
    "HOME",
    "TURBO_TEAM",
    "TURBO_TOKEN"
  ],
  "remoteCache": {
    "enabled": true
  }
}
```

**Package-level configuration (turbo.json in package directory):**

```json
{
  "extends": ["//"],
  "pipeline": {
    "build": {
      "outputs": ["dist/**"],
      "cache": true,
      "dependsOn": ["^build", "prebuild"]
    },
    "prebuild": {
      "cache": false
    }
  }
}
```

**Running with Turborepo:**

```bash
# Build affected
turbo build --filter="[HEAD^]"

# Build specific package and dependencies
turbo build --filter="@mymonorepo/web..."

# Run multiple tasks
turbo run build test lint --filter="[HEAD^]"

# With output caching
turbo run build --only --cache-dir=./cache
```

### 5.4 Lerna 6+ (Now with Nx Integration)

**lerna.json for modern Lerna (powered by Nx):**

```json
{
  "$schema": "node_modules/lerna/schemas/lerna-schema.json",
  "version": "0.0.1",
  "npmClient": "pnpm",
  "useWorkspaces": true,
  "nx": true,
  "command": {
    "version": {
      "allowBranch": "main",
      "message": "chore(release): %s",
      "conventionalCommits": true
    },
    "publish": {
      "verifyAccess": true,
      "verifyNpm": true,
      "npmTag": "latest"
    }
  },
  "packages": [
    "packages/*",
    "apps/*"
  ]
}
```

**Running Lerna with Nx:**

```bash
# Install dependencies and link
lerna bootstrap

# Run task across packages (uses Nx under the hood)
lerna run build

# Publish changed packages
lerna publish

# Version bump with conventional commits
lerna version --conventional-commits
```

### 5.5 Recommendation Matrix

**Choose Nx if:**
- Large enterprise monorepo (100+ projects)
- Need advanced code generation
- Require comprehensive workspace analysis
- Want built-in Rust-powered tools
- Heavy TypeScript/Angular focus

**Choose Turborepo if:**
- Want simplicity and speed
- JavaScript/Node.js focused
- Prefer minimal configuration
- Need Vercel ecosystem integration
- Team prefers less "magic"

**Choose Lerna if:**
- Focus on package publishing
- Need version management
- Smaller monorepo (< 20 packages)
- Want minimal tooling overhead
- Better with combination of Nx (Lerna + Nx is now officially supported)

---

## 6. AI CODING IN MONOREPOS

### 6.1 Monorepo Context for AI Assistants

**Problem: Context Rot in Large Codebases**

Research shows that AI performance degrades with longer raw code inputs, despite large context windows. The solution is not feeding more code, but better *codebase architecture*.

### 6.2 AI-Friendly Monorepo Patterns

**Principle 1: Clear Directory Structure**

```
monorepo/
├── apps/
│   ├── web/
│   │   ├── README.md           # AI understands scope
│   │   ├── src/
│   │   │   ├── pages/
│   │   │   ├── components/
│   │   │   ├── hooks/
│   │   │   └── utils/
│   │   └── package.json        # AI reads dependencies
│   └── admin/
├── libs/
│   ├── shared-ui/
│   │   ├── src/
│   │   │   ├── button/         # Component per directory
│   │   │   ├── form/
│   │   │   └── layout/
│   │   └── README.md           # Component guidelines
│   └── shared-utils/
└── docs/                        # AI architecture docs
    ├── ARCHITECTURE.md
    ├── PATTERNS.md
    └── API.md
```

**Principle 2: Example-Driven Development**

```typescript
// libs/shared-ui/src/button/Button.tsx
/**
 * Button Component
 *
 * Example usage for AI learning:
 *
 * @example
 * // Primary button
 * <Button variant="primary" onClick={handleClick}>
 *   Click Me
 * </Button>
 *
 * @example
 * // Secondary button with icon
 * <Button variant="secondary" icon={<ArrowIcon />}>
 *   Next Step
 * </Button>
 *
 * @example
 * // Loading state
 * <Button isLoading disabled>
 *   Processing...
 * </Button>
 */
export interface ButtonProps {
  variant: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  disabled?: boolean;
  children: ReactNode;
}

export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  isLoading = false,
  disabled = false,
  children,
}) => {
  // Implementation with clear patterns
};
```

### 6.3 Cursor/Copilot Configuration for Monorepos

**.cursor/rules file:**

```markdown
# Monorepo Architecture Rules

## Directory Patterns
- `apps/*/` - Standalone applications
- `libs/*/` - Shared libraries with explicit exports
- `tools/` - Internal tooling and scripts

## Naming Conventions
- Components: PascalCase (Button, TextField)
- Utilities: camelCase (formatDate, calculateTotal)
- Types: PascalCase with T prefix (TUser, TConfig)
- Tests: *.spec.ts or *.test.ts

## Code Generation Rules
- Always check tsconfig.baseUrl paths before importing
- Use barrel exports (index.ts) for library packages
- Maintain dependency graph - never create circular dependencies
- Test files collocated with source files

## API Client Pattern
- Use shared-utils/api-client for all HTTP calls
- Follow REST conventions (GET, POST, PUT, DELETE)
- Add error handling and retry logic
- Type responses with generated types from OpenAPI

## Component Patterns (React)
- Functional components with hooks
- Props interface exported from component file
- Storybook stories for shared-ui components
- Unit tests in same directory as component

## Build Configuration
- Each app/lib has its own tsconfig.json extending tsconfig.base.json
- Build output in dist/ directory
- No side effects during imports (mark as "sideEffects": false in package.json)

## Git Workflow
- One feature per branch
- PR descriptions reference issues
- Semantic commit messages (feat:, fix:, refactor:)
- CODEOWNERS auto-request reviewers
```

**Prompting strategy for AI assistants:**

```
Effective prompt template:

"I'm working in a monorepo with the following structure:
- apps/web - React frontend
- apps/api - Node.js backend
- libs/shared-types - TypeScript type definitions
- libs/shared-ui - Reusable React components

I need to [TASK].

Please:
1. Check the existing patterns in [REFERENCE_LOCATION]
2. Follow the same code style and structure
3. Ensure types are imported from libs/shared-types
4. Update both implementation and tests
5. Suggest any CODEOWNERS who should review this

Current project structure at /apps/web is:
src/
  components/ - React components
  pages/ - Next.js pages
  hooks/ - Custom React hooks
  utils/ - Utility functions
"
```

### 6.4 Agentic Refactoring in Monorepos

**AI-assisted large-scale migrations:**

Example: Migrating from CommonJS to ESM across entire monorepo

```bash
# With Nx migration capabilities enhanced by AI
npx nx migrate --from=v14 --to=v15

# AI can complete this process:
# 1. Update all package.json files
# 2. Convert tsconfig.json files
# 3. Rewrite import statements
# 4. Handle edge cases (dynamic requires, etc.)
# 5. Update build configurations
# 6. Fix broken tests (80% auto-fix, 20% manual review)
# Result: Weeks of work reduced to days
```

### 6.5 Sourcegraph Cody for Monorepos

**Querying across entire monorepo:**

```
Cody prompts for monorepo:

1. "Show me all implementations of the UserService interface"
2. "Find all uses of the deprecated formatDate function and suggest replacements"
3. "List all places where we're making HTTP calls outside of api-client"
4. "Show all React components that don't have unit tests"
5. "Find dependency version mismatches across packages"
```

**Cody configuration (cody.json):**

```json
{
  "cody.editorTabs": true,
  "cody.autocomplete.enabled": true,
  "cody.chat.enabled": true,
  "cody.contextSize": "medium",
  "cody.experimental.symf": false,
  "codebase": {
    "indexing": {
      "excludePatterns": [
        "node_modules/**",
        "dist/**",
        ".next/**",
        "coverage/**"
      ],
      "indexDependencies": true
    },
    "maxPackageSize": 100000000
  }
}
```

### 6.6 Best Practices for AI in Monorepos

**1. Scaffolding Consistency**

```bash
# Use generators to maintain patterns
nx generate @nx/react:library --name=my-feature
nx generate @nx/node:library --name=my-service

# Generators ensure AI reads consistent patterns
```

**2. Type Safety Enables Better AI**

```typescript
// ❌ AI struggles with this
const getData = async (id) => {
  const result = await fetch(`/api/users/${id}`);
  return result.json();
};

// ✅ AI understands this clearly
interface User {
  id: string;
  name: string;
  email: string;
}

async function getUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return response.json() as Promise<User>;
}
```

**3. Document Architectural Decisions**

```markdown
# ARCHITECTURE.md

## Data Flow
1. API calls → api-client library
2. Types → shared-types library
3. State management → (React Context | Redux)
4. Components → shared-ui library

## Package Dependencies
- web depends on: shared-ui, shared-utils, shared-types, api-client
- admin depends on: shared-ui, shared-utils, shared-types, api-client
- api depends on: shared-types, shared-utils

## Forbidden Patterns
- No direct HTTP calls (use api-client)
- No duplicated types (use shared-types)
- No circular dependencies
- No apps depending on other apps
```

**4. Pre-commit Hooks with AI Review**

```yaml
# .husky/pre-commit
#!/bin/bash

# Run linters
pnpm lint:fix

# Run tests for changed files
nx affected -t test

# Ask AI to review the commit diff
# (requires integration with AI API)
cody-review-commit --auto-fix
```

---

## 7. PRACTICAL IMPLEMENTATION ROADMAP

### Phase 1: Foundation (Week 1-2)

```bash
# 1. Choose tool (Nx recommended for large monorepos)
npm create nx-workspace@latest

# 2. Setup git configuration
git config core.fsmonitor true
git config feature.manyFiles true

# 3. Create CODEOWNERS
touch .github/CODEOWNERS

# 4. Initialize CI/CD pipeline
mkdir .github/workflows
touch .github/workflows/ci.yml
```

### Phase 2: Scaling (Week 3-4)

- Implement path-based selective CI/CD
- Add sparse-checkout for large repos
- Setup distributed CODEOWNERS pattern
- Configure Nx/Turborepo caching

### Phase 3: Optimization (Week 5-6)

- Implement git config optimizations
- Setup remote caching (Nx Cloud / Vercel)
- Add affected command checks to CI
- Performance monitoring

### Phase 4: AI Integration (Week 7-8)

- Add .cursor/rules configuration
- Generate comprehensive docs
- Setup Cody for code queries
- Train team on patterns

---

## 8. RESOURCE REFERENCES

### Official Documentation

- **Nx**: https://nx.dev/docs
- **Turborepo**: https://turbo.build/repo/docs
- **Lerna**: https://lerna.js.org
- **Git**: https://git-scm.com/doc

### Key Articles & Guides

- Monorepo.tools comparison matrix
- GitHub Well-Architected library on monorepos
- GraphiteApp guides on Git monorepos
- Buildkite monorepo CI best practices

### Tools & Extensions

- dorny/paths-filter: Path-based GitHub Actions
- codeowners-generator: Auto-generate CODEOWNERS
- Sourcegraph Cody: Monorepo AI queries
- Cursor IDE: Built-in AI coding support

---

## 9. CONCLUSION

Modern monorepo strategies in 2025 focus on:

1. **Performance**: Sparse checkouts, partial clones, optimized git config
2. **Scalability**: Nx/Turborepo for dependency management and caching
3. **Ownership**: CODEOWNERS for clear responsibility
4. **Automation**: Path-based CI/CD for efficient resource usage
5. **AI-Readiness**: Clear structure and patterns for AI assistance

The best monorepo strategy combines the right tool (Nx for complexity, Turborepo for simplicity), proper Git configuration for performance, clear ownership structures, and AI-friendly code organization.

For 2025, teams should prioritize:
- Adopting sparse-checkout with partial clones
- Implementing Nx (or Turborepo) for dependency management
- Setting up selective CI/CD triggers
- Creating clear CODEOWNERS structures
- Preparing codebases for AI-assisted development
