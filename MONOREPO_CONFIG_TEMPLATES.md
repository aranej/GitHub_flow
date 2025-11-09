# Monorepo Configuration Templates
## Ready-to-Use Configuration Files for 2025 Workflows

---

## 1. NX CONFIGURATION FILES

### 1.1 Complete nx.json for TypeScript Monorepo

**File: `nx.json`**

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
  "nxCloudAccessToken": "${NX_CLOUD_ACCESS_TOKEN}",
  "targetDefaults": {
    "build": {
      "cache": true,
      "inputs": [
        "{projectRoot}/src/**/*",
        "{projectRoot}/package.json",
        "tsconfig.base.json",
        ".env.build"
      ],
      "outputs": ["{projectRoot}/dist"],
      "dependsOn": ["^build"],
      "parallelism": 4
    },
    "test": {
      "cache": true,
      "inputs": [
        "{projectRoot}/src/**/*",
        "{projectRoot}/**/*.spec.ts",
        "{projectRoot}/**/*.test.ts",
        "tsconfig.base.json"
      ],
      "outputs": ["{projectRoot}/coverage"],
      "coverage": true
    },
    "lint": {
      "cache": true,
      "inputs": [
        "{projectRoot}/**/*.ts",
        "{projectRoot}/**/*.tsx",
        "{projectRoot}/.eslintrc.json",
        ".eslintrc.json"
      ],
      "outputs": []
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "serve": {
      "cache": false,
      "persistent": true
    }
  },
  "namedInputs": {
    "default": ["{projectRoot}/**/*"],
    "sourceFiles": [
      "{projectRoot}/src/**/*",
      "{projectRoot}/package.json"
    ],
    "testsFiles": [
      "{projectRoot}/**/*.spec.ts",
      "{projectRoot}/**/*.test.ts"
    ],
    "allSourceFiles": ["sourceFiles", "testsFiles"],
    "sharedFiles": [
      "tsconfig.base.json",
      ".env.build"
    ]
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
    },
    {
      "plugin": "@nx/nest/plugin",
      "options": {
        "targetDefaults": {
          "build": {
            "outputs": ["{projectRoot}/dist"]
          }
        }
      }
    }
  ]
}
```

### 1.2 tsconfig.base.json for Monorepo

**File: `tsconfig.base.json`**

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": false,
    "lib": ["ES2020", "dom", "dom.iterable"],
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "forceConsistentCasingInFileNames": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "baseUrl": ".",
    "paths": {
      "@mymonorepo/shared-types": ["libs/shared-types/src/index.ts"],
      "@mymonorepo/shared-types/*": ["libs/shared-types/src/*"],
      "@mymonorepo/shared-ui": ["libs/shared-ui/src/index.ts"],
      "@mymonorepo/shared-ui/*": ["libs/shared-ui/src/*"],
      "@mymonorepo/shared-utils": ["libs/shared-utils/src/index.ts"],
      "@mymonorepo/shared-utils/*": ["libs/shared-utils/src/*"],
      "@mymonorepo/api-client": ["libs/api-client/src/index.ts"],
      "@mymonorepo/api-client/*": ["libs/api-client/src/*"],
      "@web/*": ["apps/web/src/*"],
      "@admin/*": ["apps/admin/src/*"],
      "@api/*": ["apps/api/src/*"]
    }
  },
  "include": ["**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules", "dist", "build"]
}
```

---

## 2. TURBOREPO CONFIGURATION FILES

### 2.1 Complete turbo.json

**File: `turbo.json`**

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": [
    "tsconfig.json",
    ".env.local",
    ".turborc"
  ],
  "globalEnv": [
    "NODE_ENV",
    "HOME",
    "TURBO_TEAM",
    "TURBO_TOKEN"
  ],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "build/**"],
      "outputMode": "hash-only",
      "cache": true,
      "env": ["NODE_ENV", "BUILD_ENV"]
    },
    "test": {
      "dependsOn": ["^build"],
      "cache": false,
      "outputs": ["coverage/**"],
      "env": ["NODE_ENV", "TEST_ENV"]
    },
    "test:ci": {
      "dependsOn": ["^build"],
      "cache": false,
      "outputs": ["coverage/**"],
      "env": ["NODE_ENV", "CI"]
    },
    "lint": {
      "cache": true,
      "outputs": [],
      "env": ["NODE_ENV"]
    },
    "type-check": {
      "cache": true,
      "outputs": [],
      "env": ["NODE_ENV"]
    },
    "dev": {
      "cache": false,
      "persistent": true,
      "interactive": true,
      "env": ["NODE_ENV", "DATABASE_URL", "API_URL"]
    },
    "generate": {
      "cache": false,
      "outputs": ["src/**"]
    },
    "docs": {
      "cache": true,
      "outputs": ["docs/**"]
    }
  },
  "remoteCache": {
    "enabled": true
  }
}
```

### 2.2 pnpm-workspace.yaml

**File: `pnpm-workspace.yaml`**

```yaml
packages:
  - 'apps/*'
  - 'libs/*'
  - 'tools/*'

catalog:
  react:
    version: '18.2.0'
  'react-dom':
    version: '18.2.0'
  typescript:
    version: '5.2.0'
  eslint:
    version: '8.48.0'
  '@testing-library/react':
    version: '14.0.0'
  jest:
    version: '29.7.0'
  '@types/jest':
    version: '29.5.4'

overrides:
  # Ensure consistent versions across monorepo
  typescript: 5.2.0
  eslint: 8.48.0
```

---

## 3. GIT CONFIGURATION TEMPLATES

### 3.1 .gitconfig for Large Monorepos

**File: `.git/config` or `~/.gitconfig`**

```ini
[core]
    # Performance optimizations for large monorepos
    commitgraph = true
    fsmonitor = true
    writeCommitGraph = true
    untrackedCache = true
    preloadindex = true
    sparseCheckout = true
    logallrefupdates = true

    # Index configuration
    filemode = true
    ignorestat = false

    # Autocrlf for cross-platform compatibility
    autocrlf = input

[feature]
    # Handle repositories with many files
    manyFiles = true
    worktreeConfig = true

[gc]
    # Aggressive garbage collection settings
    auto = 256
    writeCommitGraph = true
    autodetach = true
    runalltasks = true

[index]
    # Version 4 uses compression (default in Git 2.40+)
    version = 4
    # Sparse index for better performance
    sparse = true

[fetch]
    # Parallel object fetching
    parallel = 4

[grep]
    # Line numbers in grep output
    lineNumber = true

[log]
    # Graph format for log visualization
    decorate = auto

[status]
    # Show untracked files separately
    aheadBehind = true
    # Don't show ignored files
    showIgnored = false

[diff]
    # Patience algorithm for better diffs
    algorithm = histogram
    # Rename detection
    renameLimit = 10000

[rebase]
    # Autostash during rebase
    autoStash = true

[push]
    # Safer push defaults
    default = simple
    followTags = true

[pull]
    # Rebase instead of merge when pulling
    rebase = true

[blame]
    # Ignore whitespace in blame
    ignoreRevsFile = .git-blame-ignore-revs

[submodule]
    # Recurse into submodules
    recurse = true

[merge]
    # Use mergetool for conflicts
    tool = vimdiff
    conflictStyle = zdiff3

[diff]
    colorMoved = default

# Sparse checkout configuration
[extensions]
    sparseCheckout = true
    objectFormat = sha256
```

### 3.2 .gitignore Template

**File: `.gitignore`**

```
# Dependencies
node_modules/
/.pnp
.pnp.js

# Production/Build
dist/
build/
.next/
out/
coverage/

# IDE
.vscode/
.idea/
*.swp
*.swo
*.swn
*~
.DS_Store
*.sublime-project
*.sublime-workspace

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
pnpm-debug.log*

# Cache
.eslintcache
.turbo
.nx/cache

# OS
Thumbs.db

# CI/CD
.github/
```

---

## 4. GITHUB ACTIONS WORKFLOWS

### 4.1 Selective CI/CD Workflow

**File: `.github/workflows/selective-ci.yml`**

```yaml
name: Selective CI/CD Pipeline

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    types: [opened, synchronize, reopened]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  NODE_VERSION: '18'
  PNPM_VERSION: '8'

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      web: ${{ steps.filter.outputs.web }}
      admin: ${{ steps.filter.outputs.admin }}
      shared-ui: ${{ steps.filter.outputs.shared-ui }}
      shared-utils: ${{ steps.filter.outputs.shared-utils }}
      api-client: ${{ steps.filter.outputs.api-client }}
      any: ${{ steps.filter.outputs.any }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            web:
              - 'apps/web/**'
              - 'libs/shared-ui/**'
              - 'libs/shared-utils/**'
              - 'libs/api-client/**'
            admin:
              - 'apps/admin/**'
              - 'libs/shared-ui/**'
              - 'libs/shared-utils/**'
              - 'libs/api-client/**'
            shared-ui:
              - 'libs/shared-ui/**'
            shared-utils:
              - 'libs/shared-utils/**'
            api-client:
              - 'libs/api-client/**'
            any:
              - 'apps/**'
              - 'libs/**'

  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v2
        with:
          version: ${{ env.PNPM_VERSION }}

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'

      - run: pnpm install --frozen-lockfile

  lint:
    needs: [detect-changes, setup]
    if: needs.detect-changes.outputs.any == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: ${{ env.PNPM_VERSION }}
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'

      - run: pnpm install --frozen-lockfile
      - run: pnpm nx affected -t lint

  test:
    needs: [detect-changes, setup]
    if: needs.detect-changes.outputs.any == 'true'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - name: "Unit Tests"
            command: "test"
          - name: "Integration Tests"
            command: "test:integration"
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: ${{ env.PNPM_VERSION }}
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'

      - run: pnpm install --frozen-lockfile
      - run: pnpm nx affected -t ${{ matrix.command }}

      - uses: codecov/codecov-action@v3
        if: always()
        with:
          files: ./coverage/coverage-final.json

  build-web:
    needs: [detect-changes, lint, test]
    if: needs.detect-changes.outputs.web == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: ${{ env.PNPM_VERSION }}
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'

      - run: pnpm install --frozen-lockfile
      - run: pnpm build apps/web
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: web-dist
          path: apps/web/dist/

  build-admin:
    needs: [detect-changes, lint, test]
    if: needs.detect-changes.outputs.admin == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: ${{ env.PNPM_VERSION }}
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'

      - run: pnpm install --frozen-lockfile
      - run: pnpm build apps/admin
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: admin-dist
          path: apps/admin/dist/

  deploy:
    needs: [detect-changes, build-web]
    if: github.ref == 'refs/heads/main' && needs.detect-changes.outputs.web == 'true'
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://myapp.com
    steps:
      - uses: actions/checkout@v4

      - name: Download artifact
        uses: actions/download-artifact@v3
        with:
          name: web-dist
          path: apps/web/dist/

      - name: Deploy to production
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: |
          # Add deployment commands here
          echo "Deploying web app to production..."
```

### 4.2 Enforce CODEOWNERS Review

**File: `.github/workflows/enforce-codeowners.yml`**

```yaml
name: Enforce CODEOWNERS Review

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  pull-requests: read
  contents: read

jobs:
  check-codeowners:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Check CODEOWNERS coverage
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const path = require('path');

            // Get changed files
            const { data: files } = await github.rest.pulls.listFiles({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.issue.number
            });

            console.log(`Total files changed: ${files.length}`);

            // Parse CODEOWNERS
            let codeownersContent = '';
            try {
              if (fs.existsSync('.github/CODEOWNERS')) {
                codeownersContent = fs.readFileSync('.github/CODEOWNERS', 'utf-8');
              } else if (fs.existsSync('CODEOWNERS')) {
                codeownersContent = fs.readFileSync('CODEOWNERS', 'utf-8');
              }
            } catch (err) {
              console.log('Warning: Could not read CODEOWNERS file');
            }

            // Check coverage
            const uncoveredFiles = [];
            const patterns = codeownersContent
              .split('\n')
              .filter(line => line.trim() && !line.startsWith('#'));

            files.forEach(file => {
              let isCovered = false;
              for (const pattern of patterns) {
                const [pathPattern] = pattern.split(/\s+/);
                if (pathPattern === '*' || file.filename.includes(pathPattern)) {
                  isCovered = true;
                  break;
                }
              }
              if (!isCovered) {
                uncoveredFiles.push(file.filename);
              }
            });

            if (uncoveredFiles.length > 0) {
              console.warn(`⚠️  Files not covered by CODEOWNERS:\n${uncoveredFiles.join('\n')}`);
              console.log('Consider adding these paths to .github/CODEOWNERS');
            } else {
              console.log('✅ All changed files have CODEOWNERS');
            }
```

---

## 5. CODE OWNERSHIP TEMPLATES

### 5.1 Complete .github/CODEOWNERS

**File: `.github/CODEOWNERS`**

```
# Default owners for everything in the repo
* @platform-team

# Core infrastructure
/tools/ @devops-team @platform-team
/.github/ @devops-team @security-team
/.github/workflows/ @devops-team @security-team
Dockerfile* @devops-team
docker-compose.yml @devops-team
kubernetes/ @devops-team

# Shared libraries
/libs/shared-types/ @platform-team @api-team
/libs/shared-types/types/ @platform-team
/libs/shared-types/schemas/ @api-team

/libs/shared-ui/ @design-team @frontend-lead
/libs/shared-ui/buttons/ @design-team @ux-specialist
/libs/shared-ui/forms/ @design-team @accessibility-expert
/libs/shared-ui/layouts/ @design-team
/libs/shared-ui/hooks/ @frontend-lead

/libs/shared-utils/ @platform-team
/libs/shared-utils/math/ @platform-team @data-science
/libs/shared-utils/date/ @platform-team
/libs/shared-utils/format/ @platform-team

/libs/api-client/ @platform-team @api-team
/libs/api-client/http/ @api-team

# Applications
/apps/web/ @web-team @frontend-lead
/apps/web/src/pages/ @web-team
/apps/web/src/components/ @web-team @design-team
/apps/web/src/hooks/ @web-team @frontend-lead
/apps/web/src/styles/ @design-team

/apps/admin/ @admin-team @security-team
/apps/admin/src/pages/ @admin-team
/apps/admin/src/access-control/ @security-team

/apps/api/ @api-team @backend-lead
/apps/api/src/routes/ @api-team
/apps/api/src/middleware/ @api-team @security-team
/apps/api/src/database/ @api-team @data-engineering
/apps/api/src/auth/ @security-team

# Configuration files
package.json @platform-team
pnpm-workspace.yaml @platform-team
tsconfig.json @platform-team
tsconfig.base.json @platform-team
nx.json @platform-team @devops-team
turbo.json @platform-team
.eslintrc.* @platform-team
.prettierrc.* @platform-team
jest.config.* @platform-team

# Documentation
README.md @platform-team
CONTRIBUTING.md @platform-team
ARCHITECTURE.md @platform-team @technical-lead

# CI/CD specific
.github/workflows/ci.yml @devops-team
.github/workflows/deploy.yml @devops-team @release-manager
.github/workflows/security.yml @security-team
```

---

## 6. GIT SPARSE CHECKOUT TEMPLATE

### 6.1 Setup Script for Sparse Checkout

**File: `scripts/setup-sparse-checkout.sh`**

```bash
#!/bin/bash

# Configure sparse checkout for large monorepo
# Usage: ./scripts/setup-sparse-checkout.sh [patterns...]

set -e

echo "🔧 Setting up sparse checkout..."

# Get the list of patterns
PATTERNS=${@:-"apps/web libs/shared-ui libs/shared-utils"}

# Initialize sparse checkout with cone mode (fastest)
git sparse-checkout init --cone

# Configure git for large monorepos
git config core.fsmonitor true
git config feature.manyFiles true
git config core.untrackedCache true
git config core.sparseCheckout true

# Set the patterns to include
echo "📁 Setting sparse checkout patterns:"
for pattern in $PATTERNS; do
    echo "  - $pattern"
done

git sparse-checkout set $PATTERNS

echo "✅ Sparse checkout configured successfully!"
echo ""
echo "Current sparse checkout configuration:"
git sparse-checkout list

echo ""
echo "To add more directories:"
echo "  git sparse-checkout add <path>"
echo ""
echo "To disable sparse checkout:"
echo "  git sparse-checkout disable"
```

---

## 7. PRE-COMMIT HOOKS

### 7.1 .husky/pre-commit

**File: `.husky/pre-commit`**

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

echo "🔍 Running pre-commit checks..."

# Get changed files
CHANGED_FILES=$(git diff --cached --name-only)

# Lint staged files
echo "📝 Linting..."
pnpm lint:staged

# Check for secrets
echo "🔐 Scanning for secrets..."
pnpm secrets:scan "$CHANGED_FILES"

# Run type check on changed files
echo "🔤 Type checking..."
pnpm nx affected:apps -t type-check --base=HEAD~1

echo "✅ Pre-commit checks passed!"
```

### 7.2 .husky/pre-push

**File: `.husky/pre-push`**

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

echo "🚀 Running pre-push checks..."

# Run tests for affected projects
echo "🧪 Running tests..."
pnpm nx affected -t test --base=main

# Ensure builds succeed
echo "🏗️  Building affected projects..."
pnpm nx affected -t build --base=main

echo "✅ All checks passed! Pushing..."
```

---

## 8. ENVIRONMENT CONFIGURATION

### 8.1 .env.example

**File: `.env.example`**

```
# Node environment
NODE_ENV=development

# API Configuration
API_BASE_URL=http://localhost:3000
API_TIMEOUT=30000

# Database (for API app)
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
DATABASE_POOL_SIZE=10

# Authentication
JWT_SECRET=your-secret-key-here
JWT_EXPIRY=24h

# Build Configuration
BUILD_ENV=development
SOURCE_MAPS=true

# Monorepo Tools
NX_CLOUD_ACCESS_TOKEN=your-token-here
TURBO_TEAM=your-team
TURBO_TOKEN=your-token-here

# CI/CD
CI=false
GITHUB_TOKEN=your-github-token

# Logging
LOG_LEVEL=info
LOG_FORMAT=json
```

---

## 9. PACKAGE.JSON SCRIPTS TEMPLATE

### 9.1 Root package.json

**File: `package.json`**

```json
{
  "name": "mymonorepo",
  "version": "0.0.1",
  "description": "Modern TypeScript monorepo with Nx",
  "private": true,
  "packageManager": "pnpm@8.10.0",
  "scripts": {
    "dev": "nx run-many -t dev --parallel",
    "build": "nx run-many -t build",
    "build:affected": "nx affected -t build",
    "test": "nx run-many -t test",
    "test:affected": "nx affected -t test",
    "test:ci": "nx run-many -t test:ci --coverage",
    "lint": "nx run-many -t lint",
    "lint:affected": "nx affected -t lint",
    "lint:fix": "nx run-many -t lint -- --fix",
    "type-check": "nx run-many -t type-check",
    "format": "prettier --write \"**/*.{ts,tsx,json,md}\"",
    "format:check": "prettier --check \"**/*.{ts,tsx,json,md}\"",
    "graph": "nx graph",
    "graph:affected": "nx affected:graph",
    "clean": "nx run-many -t clean",
    "clean:cache": "rm -rf .nx/cache && rm -rf .turbo",
    "dep:check": "nx run-many -t dep-check",
    "migrate": "nx migrate latest",
    "codeowners:sync": "node scripts/sync-codeowners.js",
    "codeowners:validate": "node scripts/validate-codeowners.js",
    "prepare": "husky install",
    "secrets:scan": "git secrets --scan"
  },
  "devDependencies": {
    "@nrwl/cli": "^17.0.0",
    "@nrwl/workspace": "^17.0.0",
    "nx": "^17.0.0",
    "@nx/js": "^17.0.0",
    "@nx/react": "^17.0.0",
    "@nx/next": "^17.0.0",
    "@nx/nest": "^17.0.0",
    "@nx/eslint-plugin": "^17.0.0",
    "typescript": "^5.2.0",
    "eslint": "^8.48.0",
    "prettier": "^3.0.0",
    "husky": "^8.0.0",
    "lint-staged": "^14.0.0",
    "jest": "^29.7.0",
    "@testing-library/react": "^14.0.0"
  }
}
```

---

## 10. CURSOR AI RULES

### 10.1 .cursor/rules File

**File: `.cursor/rules`**

```markdown
# Monorepo Development Rules for AI Assistance

## Directory Structure Rules
- `apps/*/` - Standalone applications (next.js, express, etc.)
- `libs/*/` - Shared libraries with explicit exports
- `tools/` - Internal tooling, scripts, and generators
- `docs/` - Architecture and project documentation

## Naming Conventions
- Components: PascalCase (Button, TextField, UserCard)
- Utilities: camelCase (formatDate, calculateTotal, parseJSON)
- Types: PascalCase with T prefix or regular (TUser, User, ApiResponse)
- Constants: UPPER_SNAKE_CASE (MAX_RETRIES, API_TIMEOUT)
- Files: kebab-case for components (button.tsx, text-field.tsx)
- Directories: kebab-case (shared-ui, api-client)

## Import Rules
- Always use path aliases from tsconfig.base.json
- Never use relative imports between projects (use aliases instead)
- Library imports: `@mymonorepo/shared-ui/button`
- Type imports: `import type { User } from '@mymonorepo/shared-types'`
- No circular dependencies - always check the dependency graph
- Example: ✅ `import { Button } from '@mymonorepo/shared-ui'`
- Example: ❌ `import { Button } from '../../../../../shared-ui/button'`

## Code Organization
- Each component/file should have a single responsibility
- Collocate tests next to implementation (*.spec.ts, *.test.ts)
- Use barrel exports (index.ts) in lib directories
- Keep component files focused (no util mixing)

## Type Safety
- All functions must have explicit return types
- No `any` types without explicit justification comment
- Use strict null checks (strictNullChecks: true)
- Discriminated unions for complex state
- Example:
  ```typescript
  type Result =
    | { status: 'success'; data: User }
    | { status: 'error'; error: Error }
  ```

## React Component Patterns
- Functional components with hooks only
- Props interface exported from component file
- Use `React.FC<Props>` type annotation
- Memoize expensive components with `React.memo`
- Use custom hooks for logic extraction
- Storybook stories for shared-ui components
- Example:
  ```typescript
  export interface ButtonProps {
    variant: 'primary' | 'secondary';
    children: ReactNode;
  }

  export const Button: React.FC<ButtonProps> = ({
    variant = 'primary',
    children,
  }) => {
    // Implementation
  };
  ```

## API Client Usage
- Always use `@mymonorepo/api-client` for HTTP requests
- Never use `fetch` directly in components
- Use typed response objects from `@mymonorepo/shared-types`
- Implement proper error handling and retry logic

## Build Configuration
- Each app/lib has its own tsconfig.json extending tsconfig.base.json
- Build outputs go in `dist/` directory
- Mark packages as `"sideEffects": false` in package.json
- Define outputs in nx.json or turbo.json for caching

## Testing Requirements
- Unit tests for utilities and helpers
- Component tests using @testing-library/react
- Integration tests for API interactions
- E2E tests using Playwright or Cypress
- Maintain >80% code coverage for libs, >60% for apps

## Commit Message Format (Conventional Commits)
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code refactoring
- `test:` - Test additions/updates
- `docs:` - Documentation updates
- `chore:` - Build/tooling changes
- `perf:` - Performance improvements
- Scope: `feat(shared-ui): add button component`
- Body: Explain the why, not the what
- Example: `feat(web): add user profile page

Implements user profile feature with edit capabilities.

Closes #123`

## Performance Considerations
- Use React.memo for expensive components
- Lazy load routes with React.lazy
- Minimize bundle size (avoid large dependencies)
- Use tree-shaking compatible exports
- Profile builds regularly with `nx build --stats`

## Dependency Management
- Keep dependency versions consistent across workspace
- Review pnpm-workspace.yaml catalog for version pins
- Update dependencies together (avoid scattered versions)
- Use npm audit regularly in CI/CD

## Git Workflow
- Create feature branches from main/develop
- One feature per branch
- PR descriptions reference issue numbers
- Semantic commit messages
- Require CODEOWNERS review for changes
- Never force-push to main branch
- Rebase on main before merging

## CODEOWNERS
- All changes trigger automatic review requests
- Code owners listed in .github/CODEOWNERS
- Scoped to specific paths and directories
- Update when adding new teams/packages

## CI/CD Guidelines
- Path-based triggers run only affected projects
- Use `nx affected` commands to avoid unnecessary builds
- All tests must pass before deployment
- Coverage reports generated for each PR
- Automatic deploys to production on main branch merge

## Common Patterns to Follow
- Look at existing code in same library for examples
- Replicate component structure from shared-ui
- Use existing utility functions from shared-utils
- Follow API client patterns for new endpoints
- Check ARCHITECTURE.md for major patterns

## Files to Check Before Implementation
- ARCHITECTURE.md - Overall system design
- PATTERNS.md - Common code patterns
- Existing similar implementation in codebase
- tsconfig.base.json - Available path aliases
- .github/CODEOWNERS - Package ownership
- nx.json - Build configuration

## When Uncertain
- Ask the user for clarification
- Reference existing similar code
- Suggest looking at ARCHITECTURE.md
- Recommend checking existing tests as examples
- Propose documenting new patterns for future reference
```

---

## 11. QUICK START SCRIPT

### 11.1 setup-monorepo.sh

**File: `scripts/setup-monorepo.sh`**

```bash
#!/bin/bash

set -e

echo "🚀 Setting up monorepo..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed"
    exit 1
fi

if ! command -v pnpm &> /dev/null; then
    echo "❌ pnpm is not installed"
    echo "Install: npm install -g pnpm"
    exit 1
fi

echo -e "${GREEN}✓ Node.js $(node --version)${NC}"
echo -e "${GREEN}✓ pnpm $(pnpm --version)${NC}"

# Install dependencies
echo -e "${BLUE}Installing dependencies...${NC}"
pnpm install

# Setup Git
echo -e "${BLUE}Configuring Git...${NC}"
git config core.fsmonitor true
git config feature.manyFiles true
git config core.untrackedCache true
git config index.version 4

# Setup Husky
echo -e "${BLUE}Setting up Husky...${NC}"
pnpm husky install

# Build all projects
echo -e "${BLUE}Building projects...${NC}"
pnpm build

# Run tests
echo -e "${BLUE}Running tests...${NC}"
pnpm test

echo -e "${GREEN}✅ Monorepo setup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review ARCHITECTURE.md"
echo "2. Check .cursor/rules for AI coding guidelines"
echo "3. Run 'pnpm dev' to start development servers"
echo "4. Run 'pnpm graph' to visualize the dependency graph"
```

---

These templates provide a complete, production-ready foundation for monorepo projects in 2025. Customize paths and team names to match your organization.
