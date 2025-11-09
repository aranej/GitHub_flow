# Configuration Templates for Collaborative Workflows 2025
## Copy-Paste Ready Configurations

---

## Table of Contents
1. [GitHub Codespaces Setup](#github-codespaces-setup)
2. [Pre-commit Hooks](#pre-commit-hooks)
3. [GitHub Actions CI/CD](#github-actions-cicd)
4. [Development Environment](#development-environment)
5. [AI Tool Configuration](#ai-tool-configuration)
6. [Code Quality Standards](#code-quality-standards)

---

## GitHub Codespaces Setup

### .devcontainer/devcontainer.json

Use this for Node.js/Full-Stack projects:

```json
{
  "name": "Full Stack Development Environment",
  "image": "mcr.microsoft.com/devcontainers/javascript-node:20-bullseye",
  "features": {
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
  "forwardPorts": [3000, 5432, 5173, 6379, 8080],
  "portAttributes": {
    "3000": {
      "label": "Dev Server",
      "onAutoForward": "notify"
    },
    "5432": {
      "label": "PostgreSQL",
      "onAutoForward": "silent"
    },
    "5173": {
      "label": "Vite Dev Server",
      "onAutoForward": "notify"
    },
    "6379": {
      "label": "Redis",
      "onAutoForward": "silent"
    }
  },
  "postCreateCommand": "npm ci && npm run db:migrate && npm run seed:dev",
  "customizations": {
    "vscode": {
      "extensions": [
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "ms-vscode.remote-explorer",
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "ms-vscode.vscode-typescript-next",
        "EditorConfig.EditorConfig",
        "ms-azuretools.vscode-docker",
        "ms-python.python",
        "ms-python.vscode-pylance",
        "github.vscode-pull-request-github",
        "GitHub.gitignore",
        "eamodio.gitlens",
        "ms-vscode-remote.remote-containers"
      ],
      "settings": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
          "source.fixAll.eslint": true
        },
        "[javascript]": {
          "editor.defaultFormatter": "esbenp.prettier-vscode"
        },
        "[typescript]": {
          "editor.defaultFormatter": "esbenp.prettier-vscode"
        },
        "[json]": {
          "editor.defaultFormatter": "esbenp.prettier-vscode"
        },
        "files.trimTrailingWhitespace": true,
        "files.insertFinalNewline": true,
        "git.autofetch": true
      }
    }
  },
  "onCreateCommand": "npm run setup:codespace",
  "remoteUser": "node"
}
```

### .devcontainer/Dockerfile (for custom setup)

```dockerfile
FROM mcr.microsoft.com/devcontainers/javascript-node:20-bullseye

# Install additional tools
RUN apt-get update && apt-get install -y \
    postgresql-client \
    redis-tools \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install global Node tools
RUN npm install -g \
    pnpm \
    tsx \
    turbo \
    @vercel/ncc

# Create workspace user
USER node
WORKDIR /workspace
```

### .devcontainer/docker-compose.yml

```yaml
version: '3.9'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ..:/workspace:cached
      - /workspace/node_modules
    ports:
      - "3000:3000"
      - "5173:5173"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://devuser:devpass@db:5432/devdb
      - REDIS_URL=redis://redis:6379
      - API_URL=http://localhost:3000
    depends_on:
      - db
      - redis
    command: npm run dev

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: devuser
      POSTGRES_PASSWORD: devpass
      POSTGRES_DB: devdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

volumes:
  postgres_data:
```

---

## Pre-commit Hooks

### package.json Scripts

```json
{
  "scripts": {
    "setup:codespace": "npm ci && husky install && npm run db:migrate",
    "prepare": "husky install",
    "lint": "eslint . --ext .ts,.tsx,.js,.jsx",
    "lint:fix": "eslint . --ext .ts,.tsx,.js,.jsx --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "type-check": "tsc --noEmit",
    "test": "jest --coverage",
    "test:watch": "jest --watch",
    "db:migrate": "npm run db:migrate:pending && npm run db:migrate:apply",
    "db:seed": "node scripts/seed.js",
    "build": "tsc && esbuild src/index.ts --bundle --outfile=dist/index.js"
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "commit-msg": "commitlint -E HUSKY_GIT_PARAMS",
      "pre-push": "npm run type-check && npm test"
    }
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md,yaml}": ["prettier --write"],
    "package.json": ["npm run format:check"]
  },
  "commitlint": {
    "extends": ["@commitlint/config-conventional"]
  }
}
```

### .husky/pre-commit

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Check for large files
if git diff --cached --name-only | xargs du -h | awk '$1 ~ /[0-9]{3}[M|G]/ {print "⚠️  Large file detected: " $2; exit 1}'
then
  exit 1
fi

# Run linting and formatting
npx lint-staged

# Type checking
npm run type-check
```

### .husky/commit-msg

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx --no -- commitlint --edit "$1"
```

### .husky/pre-push

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

echo "🧪 Running tests before push..."
npm test

if [ $? -ne 0 ]; then
  echo "❌ Tests failed, push cancelled"
  exit 1
fi

echo "✅ All tests passed, proceeding with push"
```

### commitlint.config.js

```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',      // New feature
        'fix',       // Bug fix
        'docs',      // Documentation
        'style',     // Formatting
        'refactor',  // Code refactoring
        'perf',      // Performance improvement
        'test',      // Test addition/modification
        'chore',     // Maintenance
        'ci',        // CI/CD changes
        'revert',    // Revert previous commit
      ],
    ],
    'subject-case': [2, 'never', ['upper-case', 'start-case', 'pascal-case']],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'type-case': [2, 'always', 'lowercase'],
    'type-empty': [2, 'never'],
  },
};
```

---

## GitHub Actions CI/CD

### .github/workflows/ci.yml (Comprehensive)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  NODE_VERSION: '20'
  REGISTRY: ghcr.io

jobs:
  lint-and-test:
    name: Lint & Test
    runs-on: ubuntu-latest
    timeout-minutes: 20

    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_USER: testuser
          POSTGRES_PASSWORD: testpass
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Lint code
        run: npm run lint

      - name: Check formatting
        run: npm run format:check

      - name: Type checking
        run: npm run type-check

      - name: Run tests
        run: npm run test
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
          REDIS_URL: redis://localhost:6379

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
          flags: unittests
          fail_ci_if_error: true
          verbose: true

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

      - name: Detect secrets
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD
          extra_args: --debug --only-verified

  build:
    name: Build Image
    runs-on: ubuntu-latest
    needs: [lint-and-test, security]
    timeout-minutes: 20

    permissions:
      contents: read
      packages: write

    if: github.event_name == 'push'

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ github.repository }}
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=sha
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build
    if: github.event_name == 'push' && github.ref == 'refs/heads/develop'
    timeout-minutes: 15

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to Staging
        run: |
          echo "🚀 Deploying to staging..."
          # Add your deployment script here
          # Example: npm run deploy:staging
        env:
          DEPLOY_KEY: ${{ secrets.STAGING_DEPLOY_KEY }}
          DEPLOYMENT_ENV: staging

      - name: Run smoke tests
        run: npm run test:smoke
        env:
          TEST_URL: https://staging.example.com

      - name: Slack notification
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "✅ Staging deployment successful",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Staging Deployment*\n*Commit:* ${{ github.sha }}\n*Author:* ${{ github.actor }}\n*Branch:* ${{ github.ref }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: build
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    timeout-minutes: 30

    environment:
      name: production
      url: https://example.com

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to Production
        run: npm run deploy:prod
        env:
          DEPLOY_KEY: ${{ secrets.PROD_DEPLOY_KEY }}
          DEPLOYMENT_ENV: production

      - name: Health check
        run: |
          echo "🏥 Running health checks..."
          curl -f https://example.com/health || exit 1

      - name: Slack notification
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "🎉 Production deployment successful",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Production Deployment*\n*Commit:* ${{ github.sha }}\n*Author:* ${{ github.actor }}\n*Version:* ${{ github.ref }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### .github/workflows/coderabbit.yml

```yaml
name: CodeRabbit PR Review

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  coderabbit:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: read

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: CodeRabbit Review
        uses: coderabbitai/github-action@latest
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          openai-api-key: ${{ secrets.OPENAI_API_KEY }}
```

---

## Development Environment

### docker-compose.yml (Complete Stack)

```yaml
version: '3.9'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    container_name: app-dev
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
      - "5173:5173"
      - "9229:9229"  # Node debugger
    environment:
      - NODE_ENV=development
      - DEBUG=app:*
      - DATABASE_URL=postgresql://devuser:devpass@postgres:5432/appdb
      - REDIS_URL=redis://redis:6379/0
      - JWT_SECRET=dev-secret-key-not-for-production
      - API_URL=http://localhost:3000
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    command: npm run dev
    networks:
      - app-network

  postgres:
    image: postgres:15-alpine
    container_name: postgres-dev
    environment:
      POSTGRES_USER: devuser
      POSTGRES_PASSWORD: devpass
      POSTGRES_DB: appdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U devuser"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    container_name: redis-dev
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  adminer:
    image: adminer:latest
    container_name: adminer-dev
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    networks:
      - app-network

  mailhog:
    image: mailhog/mailhog:latest
    container_name: mailhog-dev
    ports:
      - "1025:1025"  # SMTP
      - "8025:8025"  # Web UI
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

---

## AI Tool Configuration

### .copilot-config.json (GitHub Copilot settings)

```json
{
  "copilot": {
    "enabled": true,
    "language": "javascript",
    "model": "gpt-4",
    "suggestions": {
      "enabled": true,
      "codeCompletion": true,
      "documentation": true,
      "tests": true
    },
    "exclude": {
      "patterns": [
        "*.env",
        "*.secrets",
        "src/**/*.test.ts",
        "node_modules/**"
      ]
    },
    "quality": {
      "requireReview": true,
      "minimumCoverageForAcceptance": 80
    }
  }
}
```

### .coderabbit.yaml (CodeRabbit configuration)

```yaml
reviews:
  profile: comprehensive
  request_changes_workflow: author_action_required
  auto_review:
    enabled: true
    auto_incremental_review: true
    auto_review_turned_off: false

codereviews:
  profiles:
    comprehensive:
      enabled: true
      auto_label_model_provider: openai
      auto_label_model_name: gpt-4
      auto_title_model_provider: openai
      auto_title_model_name: gpt-4
      auto_type_model_provider: openai
      auto_type_model_name: gpt-4

  comments:
    artifact_type: markdown
    use_draft_comments: false
    collapse_long_comments: true
    max_comment_length: 3500

  auto_review:
    enabled: true
    auto_incremental_review: true
    auto_review_turned_off: false
    base_branches:
      - main
      - develop

  review_status:
    auto_review_enabled: true
    require_review: false

rules:
  - type: patch_rules
    rules:
      - type: os_or_runtime_related_files
        enabled: true
      - type: documentation_related_files
        enabled: true
      - type: test_files
        enabled: true
```

---

## Code Quality Standards

### .eslintrc.json

```json
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true,
    "jest": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "prettier"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    },
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "plugins": [
    "@typescript-eslint",
    "react",
    "react-hooks",
    "import",
    "security"
  ],
  "rules": {
    "react/react-in-jsx-scope": "off",
    "@typescript-eslint/no-unused-vars": [
      "error",
      {
        "argsIgnorePattern": "^_"
      }
    ],
    "@typescript-eslint/explicit-function-return-types": [
      "error",
      {
        "allowExpressions": true
      }
    ],
    "import/order": [
      "error",
      {
        "groups": [
          "builtin",
          "external",
          "internal",
          "parent",
          "sibling",
          "index"
        ],
        "pathGroups": [
          {
            "pattern": "react",
            "group": "external",
            "position": "before"
          }
        ],
        "pathGroupsExcludedImportTypes": ["react"]
      }
    ],
    "no-console": [
      "warn",
      {
        "allow": ["warn", "error"]
      }
    ],
    "security/detect-object-injection": "warn"
  }
}
```

### .prettierrc.json

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "bracketSpacing": true,
  "arrowParens": "always",
  "endOfLine": "lf",
  "printWidth": 100,
  "useTabs": false,
  "quoteProps": "as-needed",
  "jsxSingleQuote": false,
  "jsxBracketSameLine": false
}
```

### jest.config.js

```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  setupFilesAfterEnv: ['<rootDir>/src/__tests__/setup.ts'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
};
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": "./src",
    "paths": {
      "@/*": ["./*"],
      "@components/*": ["./components/*"],
      "@utils/*": ["./utils/*"],
      "@types/*": ["./types/*"]
    },
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "isolatedModules": true,
    "noEmit": true,
    "allowUnusedLabels": false,
    "allowUnreachableCode": false,
    "exactOptionalPropertyTypes": true,
    "noFallthroughCasesInSwitch": true,
    "noImplicitReturns": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noUncheckedIndexedAccess": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist", "build"]
}
```

---

## Quick Setup Script

### setup-collab-env.sh

```bash
#!/bin/bash

# Collaborative Development Environment Setup
# Run this after cloning: bash setup-collab-env.sh

set -e

echo "🚀 Setting up collaborative development environment..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
npm ci

# 2. Setup pre-commit hooks
echo -e "${BLUE}🪝 Setting up pre-commit hooks...${NC}"
npm run prepare

# 3. Setup database
echo -e "${BLUE}🗄️  Setting up database...${NC}"
docker-compose up -d postgres
sleep 5
npm run db:migrate

# 4. Setup environment
echo -e "${BLUE}⚙️  Setting up environment...${NC}"
if [ ! -f .env.local ]; then
  cp .env.example .env.local
  echo "⚠️  Created .env.local - please update with your values"
fi

# 5. Verify setup
echo -e "${BLUE}✅ Verifying setup...${NC}"
npm run type-check
npm run lint
npm test --passWithNoTests

echo -e "${GREEN}✨ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Update .env.local with your configuration"
echo "2. Run 'npm run dev' to start development"
echo "3. Open http://localhost:3000 in your browser"
echo ""
echo "For GitHub Codespaces:"
echo "  code ."
echo ""
echo "For Live Share pairing:"
echo "  Open VS Code command palette (Ctrl+Shift+P)"
echo "  Type 'Live Share: Start collaboration session'"
```

---

## GitHub Branch Protection Rules (via CLI)

```bash
#!/bin/bash

# Setup branch protection using GitHub CLI
# Run: bash setup-branch-protection.sh

REPO_OWNER="your-org"
REPO_NAME="your-repo"

echo "Setting up branch protection for $REPO_OWNER/$REPO_NAME..."

# Protect main branch
gh repo rules update \
  --repository "$REPO_OWNER/$REPO_NAME" \
  --branch "main" \
  --require-pull-request-reviews \
  --required-review-count 1 \
  --require-code-owner-reviews false \
  --require-status-checks \
  --status-checks "lint-and-test" "build" \
  --dismiss-stale-reviews false \
  --require-branches-to-be-up-to-date true

# Protect develop branch
gh repo rules update \
  --repository "$REPO_OWNER/$REPO_NAME" \
  --branch "develop" \
  --require-pull-request-reviews \
  --required-review-count 1 \
  --require-status-checks \
  --status-checks "lint-and-test" \
  --dismiss-stale-reviews false

echo "✅ Branch protection configured!"
```

---

**Version:** 1.0
**Last Updated:** November 2025
**Ready to Use:** Yes - Copy configurations directly into your project
