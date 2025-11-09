#!/bin/bash

# Release Automation Setup Script
# This script helps set up automated release management for your project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Release Automation Setup ===${NC}\n"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js is not installed. Please install Node.js 18+ first.${NC}"
    exit 1
fi

NODE_VERSION=$(node --version)
echo -e "${GREEN}✓${NC} Node.js ${NODE_VERSION} found"

# Ask user which setup to use
echo -e "\n${BLUE}Choose setup option:${NC}"
echo "1) Simple NPM Package (semantic-release)"
echo "2) Monorepo (pnpm + changesets)"
echo "3) Release Drafter (manual)"
echo "4) Skip setup"

read -p "Enter option (1-4): " OPTION

case $OPTION in
    1)
        setup_semantic_release
        ;;
    2)
        setup_monorepo
        ;;
    3)
        setup_release_drafter
        ;;
    4)
        echo -e "${YELLOW}Setup skipped.${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option.${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}=== Setup Complete ===${NC}"
echo -e "\nNext steps:"
echo "1. Review generated configuration files"
echo "2. Update .releaserc.json or .changeset/config.json with your repository info"
echo "3. Commit and push to enable automated releases"
echo "4. Make a test commit with 'feat:' prefix to trigger first release"

function setup_semantic_release() {
    echo -e "\n${BLUE}Setting up semantic-release...${NC}"

    # Install dependencies
    echo -e "\n${YELLOW}Installing dependencies...${NC}"
    npm install --save-dev \
        semantic-release \
        @semantic-release/commit-analyzer \
        @semantic-release/release-notes-generator \
        @semantic-release/changelog \
        @semantic-release/npm \
        @semantic-release/github \
        @semantic-release/git

    # Create .github/workflows directory
    mkdir -p .github/workflows .github

    # Copy configurations
    echo -e "\n${YELLOW}Creating configuration files...${NC}"

    if [ ! -f ".releaserc.json" ]; then
        cat > .releaserc.json << 'EOF'
{
  "branches": [
    "main",
    { "name": "beta", "prerelease": true },
    { "name": "alpha", "prerelease": true }
  ],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    "@semantic-release/git",
    "@semantic-release/github"
  ]
}
EOF
        echo -e "${GREEN}✓${NC} Created .releaserc.json"
    fi

    if [ ! -f ".github/workflows/release.yml" ]; then
        cat > .github/workflows/release.yml << 'EOF'
name: Automated Release

on:
  push:
    branches: [main, beta, alpha]

permissions:
  contents: write
  packages: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npm run lint --if-present
      - run: npm run test --if-present
      - run: npm run build --if-present

      - name: Release
        run: npx semantic-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
EOF
        echo -e "${GREEN}✓${NC} Created .github/workflows/release.yml"
    fi

    if [ ! -f ".github/release.yml" ]; then
        cat > .github/release.yml << 'EOF'
changelog:
  exclude:
    labels: [ignore, skip-changelog, internal]
    authors: [dependabot]
  categories:
    - title: '🚀 Features'
      labels: [feature, enhancement]
    - title: '🐛 Bug Fixes'
      labels: [fix, bugfix]
    - title: '💥 Breaking Changes'
      labels: [breaking]
    - title: '📚 Documentation'
      labels: [documentation]
EOF
        echo -e "${GREEN}✓${NC} Created .github/release.yml"
    fi

    # Setup git hooks
    setup_git_hooks

    echo -e "\n${GREEN}✓${NC} semantic-release setup complete"
}

function setup_monorepo() {
    echo -e "\n${BLUE}Setting up monorepo with pnpm and changesets...${NC}"

    # Check if pnpm is installed
    if ! command -v pnpm &> /dev/null; then
        echo -e "${YELLOW}Installing pnpm...${NC}"
        npm install -g pnpm
    fi

    PNPM_VERSION=$(pnpm --version)
    echo -e "${GREEN}✓${NC} pnpm ${PNPM_VERSION} found"

    # Create workspace structure
    echo -e "\n${YELLOW}Creating workspace structure...${NC}"
    mkdir -p packages/core packages/cli examples

    # Install dependencies
    echo -e "\n${YELLOW}Installing dependencies...${NC}"
    pnpm add -D \
        @changesets/cli \
        @changesets/changelog-github

    # Initialize changesets
    if [ ! -d ".changeset" ]; then
        pnpm changeset init
    fi

    # Create pnpm-workspace.yaml
    if [ ! -f "pnpm-workspace.yaml" ]; then
        cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'packages/*'
  - 'examples/*'
EOF
        echo -e "${GREEN}✓${NC} Created pnpm-workspace.yaml"
    fi

    # Create .changeset/config.json
    cat > .changeset/config.json << 'EOF'
{
  "$schema": "https://unpkg.com/@changesets/config@2.3.1/schema.json",
  "changelog": ["@changesets/changelog-github", { "repo": "your-org/your-repo" }],
  "commit": false,
  "access": "public",
  "baseBranches": ["main"],
  "updateInternalDependencies": "patch"
}
EOF
    echo -e "${GREEN}✓${NC} Created .changeset/config.json"

    # Create GitHub Action
    mkdir -p .github/workflows

    if [ ! -f ".github/workflows/changesets-release.yml" ]; then
        cat > .github/workflows/changesets-release.yml << 'EOF'
name: Changesets Release

on:
  push:
    branches: [main]

concurrency: ${{ github.workflow }}-${{ github.ref }}

permissions:
  contents: write
  pull-requests: write
  packages: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: 8
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'

      - run: pnpm install --frozen-lockfile
      - run: pnpm lint --if-present
      - run: pnpm test --if-present
      - run: pnpm build --if-present

      - uses: changesets/action@v1
        with:
          publish: pnpm run release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
EOF
        echo -e "${GREEN}✓${NC} Created .github/workflows/changesets-release.yml"
    fi

    setup_git_hooks

    echo -e "\n${GREEN}✓${NC} Monorepo setup complete"
    echo -e "\n${YELLOW}Edit .changeset/config.json and set your repository:${NC}"
    echo '  "repo": "your-org/your-repo"'
}

function setup_release_drafter() {
    echo -e "\n${BLUE}Setting up Release Drafter...${NC}"

    # Install dependencies
    echo -e "\n${YELLOW}Installing dependencies...${NC}"
    npm install --save-dev release-drafter/release-drafter

    # Create GitHub Action
    mkdir -p .github/workflows .github

    if [ ! -f ".github/workflows/release-drafter.yml" ]; then
        cat > .github/workflows/release-drafter.yml << 'EOF'
name: Release Drafter

on:
  pull_request:
    types: [opened, synchronize, reopened, labeled]
  push:
    branches: [main]

permissions:
  contents: read
  pull-requests: write

jobs:
  update_release_draft:
    runs-on: ubuntu-latest
    steps:
      - uses: release-drafter/release-drafter@v5
        with:
          config-name: release-drafter.yml
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOF
        echo -e "${GREEN}✓${NC} Created .github/workflows/release-drafter.yml"
    fi

    if [ ! -f ".github/release-drafter.yml" ]; then
        cat > .github/release-drafter.yml << 'EOF'
name-template: 'v$RESOLVED_VERSION'
tag-template: 'v$RESOLVED_VERSION'

categories:
  - title: '🚀 Features'
    labels: [feature, enhancement]
  - title: '🐛 Bug Fixes'
    labels: [bugfix, fix]
  - title: '💥 Breaking Changes'
    labels: [breaking]
  - title: '📚 Documentation'
    labels: [documentation]

version-resolver:
  major:
    labels: [breaking]
  minor:
    labels: [feature, enhancement]
  patch:
    labels: [fix, bugfix]
  default: patch

exclude-labels: [skip-changelog, skip-release, internal]
exclude-contributors: [dependabot, dependabot[bot]]
EOF
        echo -e "${GREEN}✓${NC} Created .github/release-drafter.yml"
    fi

    setup_git_hooks

    echo -e "\n${GREEN}✓${NC} Release Drafter setup complete"
}

function setup_git_hooks() {
    echo -e "\n${YELLOW}Setting up git hooks...${NC}"

    # Install husky
    npm install --save-dev husky @commitlint/cli @commitlint/config-conventional

    # Initialize husky
    if [ ! -d ".husky" ]; then
        npx husky install
    fi

    # Add commit-msg hook
    if [ ! -f ".husky/commit-msg" ]; then
        echo '#!/bin/sh' > .husky/commit-msg
        echo 'npx --no -- commitlint --edit "$1"' >> .husky/commit-msg
        chmod +x .husky/commit-msg
        echo -e "${GREEN}✓${NC} Created commit-msg hook"
    fi

    # Create commitlint config
    if [ ! -f "commitlint.config.js" ]; then
        cat > commitlint.config.js << 'EOF'
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'chore', 'ci', 'revert']
    ],
    'subject-case': [2, 'never', ['upper-case']],
    'subject-full-stop': [2, 'never', '.']
  }
};
EOF
        echo -e "${GREEN}✓${NC} Created commitlint.config.js"
    fi
}

# Run main function based on option
case $OPTION in
    1)
        setup_semantic_release
        ;;
    2)
        setup_monorepo
        ;;
    3)
        setup_release_drafter
        ;;
esac

echo -e "\n${GREEN}=== Configuration files ready ===${NC}"
echo -e "\n${YELLOW}Recommended next steps:${NC}"
echo "1. Review generated configuration files"
echo "2. Update repository URLs and settings"
echo "3. Commit changes: git add . && git commit -m 'chore: setup release automation'"
echo "4. Push to remote: git push"
echo "5. Make a test commit: git commit -m 'feat: test release automation'"
