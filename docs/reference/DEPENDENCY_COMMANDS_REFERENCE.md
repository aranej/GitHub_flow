# Git Submodules & Alternatives - Command Reference & Troubleshooting

## Quick Command Reference

### Git Submodules

#### Basic Operations

```bash
# Add a new submodule
git submodule add https://github.com/user/repo.git libs/repo-name
git submodule add --depth 1 https://github.com/user/repo.git libs/repo-name  # Shallow clone

# Clone repo with submodules
git clone --recurse-submodules https://github.com/user/repo.git
git clone --recurse-submodules --depth 1 https://github.com/user/repo.git  # Shallow

# Initialize submodules in existing clone
git submodule update --init
git submodule update --init --recursive  # Include nested submodules
git submodule update --init --recursive --depth 1  # Shallow

# Update all submodules to latest
git submodule update --remote
git submodule update --remote --merge  # Merge instead of detach
git submodule update --remote --rebase  # Rebase instead of detach

# Update specific submodule
git submodule update --remote libs/repo-name

# Check status
git submodule status
git submodule foreach git status

# List all submodules
cat .gitmodules
git config --file .gitmodules --get-regexp path

# Configure submodule to track branch
git config -f .gitmodules submodule.libs/repo-name.branch main
git submodule update --remote

# Remove submodule
git submodule deinit -f libs/repo-name
git rm --cached libs/repo-name
git config --remove-section submodule.libs/repo-name
git config --file .gitmodules --remove-section submodule.libs/repo-name
rm -rf libs/repo-name .git/modules/libs/repo-name
git add .gitmodules
git commit -m "Remove submodule libs/repo-name"
```

#### Pushing Changes

```bash
# Modify submodule and push to external repo
cd libs/repo-name
git add .
git commit -m "Update code"
git push origin main
cd ../..

# Update parent repo to reference new commit
git add libs/repo-name
git commit -m "chore: update submodule libs/repo-name"
git push origin main
```

#### Advanced Operations

```bash
# Foreach operations
git submodule foreach git pull origin main
git submodule foreach git status
git submodule foreach --recursive git status  # Include nested

# Shallow fetch submodules
git config --global submodule.fetchJobs 10  # Parallel submodule fetches

# Clean submodule caches
git submodule foreach git clean -fdx
git submodule foreach git reset --hard

# Check submodule commit history
cd libs/repo-name
git log --oneline
git log --oneline -- src/  # History of specific path

# Verify submodule URL
git config --get submodule.libs/repo-name.url

# Change submodule URL
git config --file .gitmodules submodule.libs/repo-name.url https://new-url.git
git submodule sync
git submodule update --init
```

---

### Git Subtree

#### Basic Operations

```bash
# Add a subtree
git subtree add --prefix=libs/repo-name https://github.com/user/repo.git main

# Add subtree with squash (cleaner history)
git subtree add --prefix=libs/repo-name https://github.com/user/repo.git main --squash

# Update a subtree
git subtree pull --prefix=libs/repo-name https://github.com/user/repo.git main

# Update with squash
git subtree pull --prefix=libs/repo-name https://github.com/user/repo.git main --squash

# Push changes back to external repo
git subtree push --prefix=libs/repo-name https://github.com/user/repo.git branch-name

# Extract subtree history
git subtree log --prefix=libs/repo-name

# Check subtree status
git log --oneline -- libs/repo-name

# Verify external repo config
git remote -v | grep repo-name  # If added as remote
```

#### With Remote Configuration

```bash
# Add remote for easier operations
git remote add repo-name https://github.com/user/repo.git

# Pull from named remote
git subtree pull --prefix=libs/repo-name repo-name main

# Push to named remote
git subtree push --prefix=libs/repo-name repo-name branch-name

# Remove remote
git remote remove repo-name
```

#### Advanced Operations

```bash
# Subtree with full history (no squash)
git subtree add --prefix=libs/repo-name https://github.com/user/repo.git main

# Squash entire history into one commit
git subtree add --prefix=libs/repo-name https://github.com/user/repo.git main --squash

# Split and extract a directory as new repo
git subtree split --prefix=libs/repo-name -b new-branch
git push https://github.com/user/new-repo.git new-branch:main

# View subtree merges
git log --oneline --grep="Merge made by" -- libs/repo-name
```

---

### NPM/Yarn/pnpm Workspaces

#### NPM Workspaces

```bash
# Define workspaces in package.json
{
  "workspaces": ["packages/*", "services/*"]
}

# Install all dependencies
npm install

# Run script across all workspaces
npm run build --workspaces

# Run in specific workspace
npm run test --workspace=packages/ui
npm run build --workspace=@company/ui

# Add dependency to workspace
npm install lodash --workspace=packages/utils

# Add dependency as dev-only
npm install jest -D --workspace=packages/utils

# Add local dependency between workspaces
npm install @company/utils --workspace=packages/components

# Remove dependency
npm uninstall lodash --workspace=packages/utils

# List all workspaces
npm run list --workspaces
npm ls -a --depth=0

# Info about workspace
npm list --workspace=packages/ui
```

#### Yarn Workspaces

```bash
# Define workspaces
{
  "workspaces": ["packages/*"]
}

# Install
yarn install

# Run scripts
yarn workspaces run build
yarn workspace @company/ui run test

# Add dependency
yarn workspace @company/ui add react@18.0.0

# Add dev dependency
yarn workspace @company/ui add -D @types/react

# Remove workspace
yarn workspace @company/old-package remove lodash

# List all workspaces
yarn workspaces list

# Version workspaces
yarn workspaces foreach run version
```

#### pnpm Workspaces (Recommended)

```bash
# Create pnpm-workspace.yaml
packages:
  - 'packages/*'
  - 'services/*'
  - 'apps/*'

# Install all
pnpm install

# Install recursively from any subdirectory
pnpm install --recursive

# Run script in all packages
pnpm run build -r  # -r = --recursive

# Run in specific package/filter
pnpm run build --filter @company/ui
pnpm run build --filter "...services/*"  # Only services
pnpm run build --filter="./packages/ui"

# Add dependency globally
pnpm add lodash -w  # -w = workspace root

# Add to specific package
pnpm add lodash --filter @company/ui
pnpm add -D typescript --filter @company/ui

# Add local package dependency
pnpm add @company/utils --filter @company/ui

# Link packages (if not in workspace)
pnpm link @company/utils --filter @company/ui

# List dependencies
pnpm ls --depth=0  # Top-level only
pnpm ls --depth=2
pnpm ls --filter @company/ui

# Check for issues
pnpm ls --recursive
pnpm audit
pnpm audit --fix

# Publish packages
pnpm publish --filter "...@company/*" --access public

# Version management
pnpm -r exec npm version patch
pnpm recursive update  # Update all

# Workspaces info
pnpm ls -r --depth=0
pnpm recursive list
```

#### Commands with Filters (pnpm Advanced)

```bash
# Filter syntax
--filter <package-name>          # Specific package
--filter "@scope/*"              # All packages in scope
--filter "...@scope/*"           # Dependents too
--filter "./packages/*"          # By path pattern
--filter "<selector>"            # Glob pattern

# Examples
pnpm run build --filter @company/ui
pnpm run test --filter "packages/*"
pnpm run lint --filter "...{packages,services}/*"

# Changed only (for CI)
pnpm run build --filter "...[main]"

# Exclude
pnpm run build --filter="!packages/old-package"
```

---

### Monorepo Tools

#### Turborepo

```bash
# Install
npm install -D turbo

# Create turbo.json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    }
  }
}

# Build with Turborepo
turbo run build

# Build with caching
turbo run build --cache-dir=/tmp/turbo-cache

# Build specific apps
turbo run build --filter=web
turbo run build --filter="web..." --include-dependencies

# View task graph
turbo run build --graph

# Clean cache
turbo prune
rm -rf node_modules .turbo

# Remote caching setup
turbo login
turbo link

# Dry run
turbo run build --dry

# Parallel vs. sequential
turbo run build --concurrency=4
```

#### Nx

```bash
# Install
npm install -D nx

# Initialize
npx nx@latest init

# List projects
nx list

# Build
nx build my-app
nx build --all
nx build --projects="app-1,app-2"

# Test
nx test my-lib
nx test --all
nx affected:test  # Only affected by changes

# Lint
nx lint my-app
nx lint --all

# Generate
nx generate @nx/react:app my-new-app
nx generate @nx/angular:library shared-utils

# See dependency graph
nx graph
nx dep-graph

# Affected commands
nx affected:build
nx affected:test
nx affected:lint

# Workspace analysis
nx report
nx show:projects

# Configure caching
# nx.json
{
  "targetDefaults": {
    "build": {
      "cache": true,
      "outputs": ["{projectRoot}/dist"]
    }
  }
}

# Remote caching
nx connect-to-nx-cloud  # For NxCloud
```

---

## Troubleshooting

### Git Submodule Issues

#### Problem: "Submodule path is a git directory"

```bash
# Issue: Submodule folder exists with .git directory

# Solution 1: Remove and re-add
git submodule deinit -f libs/repo-name
git rm -f --cached libs/repo-name
rm -rf libs/repo-name .git/modules/libs/repo-name
git submodule add https://github.com/user/repo.git libs/repo-name

# Solution 2: Force sync
git submodule sync --recursive
git submodule update --init --recursive --force
```

#### Problem: Empty Submodule Folder After Clone

```bash
# Issue: Cloned without --recurse-submodules flag

# Solution:
git submodule update --init --recursive
# Or update setup instructions to use:
git clone --recurse-submodules https://github.com/user/repo.git
```

#### Problem: "No submodule mapping found"

```bash
# Issue: .gitmodules syntax error or missing config

# Check .gitmodules
cat .gitmodules

# Verify syntax
git config --file .gitmodules --list

# Fix syntax errors manually, then:
git submodule sync
git submodule update --init --recursive
```

#### Problem: "Submodule reference is not a commit"

```bash
# Issue: Submodule points to branch, not commit

# Solution: Point to specific commit
cd libs/repo-name
git checkout <commit-hash>
cd ../..
git add libs/repo-name
git commit -m "Pin submodule to specific commit"

# Or configure to track branch
git config -f .gitmodules submodule.libs/repo-name.branch main
git submodule update --remote
```

#### Problem: "Failed to recurse into submodule path"

```bash
# Issue: Network error, disk space, or permission issue

# Check status
git submodule status
git submodule foreach git status

# Try update with retry
git submodule update --init --recursive || git submodule update --init --recursive

# Clear cache
rm -rf .git/modules/
git submodule update --init --recursive

# Check disk space
df -h
```

#### Problem: Merge Conflicts in Submodule

```bash
# Issue: .gitmodules merge conflict

# View conflict
cat .gitmodules

# Resolve manually
# Edit .gitmodules, remove conflict markers
git add .gitmodules
git commit -m "resolve: merge conflict in .gitmodules"

# Or take theirs/ours
git checkout --theirs .gitmodules
git add .gitmodules
```

---

### Git Subtree Issues

#### Problem: "fatal: Not a valid object name"

```bash
# Issue: Remote URL or branch doesn't exist

# Solution:
# 1. Verify remote exists and is accessible
git ls-remote https://github.com/user/repo.git

# 2. Check branch exists
git ls-remote --heads https://github.com/user/repo.git

# 3. Retry with correct URL and branch
git subtree pull --prefix=libs/repo-name https://github.com/user/repo.git main
```

#### Problem: Subtree Push Fails

```bash
# Issue: Don't have push access to external repository

# Solution:
# 1. Verify SSH keys/credentials
ssh -T git@github.com

# 2. Check push permissions
# Contact repository owner to grant access

# 3. Alternative: Create PR instead
git subtree push --prefix=libs/repo-name https://github.com/user/repo.git feature-branch
# Then create PR in external repository
```

#### Problem: Large Repository Size After Subtree

```bash
# Issue: Subtree includes full history

# Solution: Use --squash flag
git subtree pull --prefix=libs/repo-name https://github.com/user/repo.git main --squash

# If already added, can't retroactively squash
# Only solution: Remove and re-add with squash
git rm --cached libs/repo-name
rm -rf libs/repo-name
git subtree add --prefix=libs/repo-name https://github.com/user/repo.git main --squash
```

---

### Workspace Issues (npm/yarn/pnpm)

#### Problem: "missing peer dependency"

```bash
# Issue: Peer dependency not installed

# For npm:
npm install <peer-dependency>

# For pnpm:
# pnpm enforces peer dependencies strictly
# Either install at workspace root:
pnpm add <peer-dependency> -w

# Or at specific workspace:
pnpm add <peer-dependency> --filter @company/package

# Check all peer dependency issues
pnpm audit
```

#### Problem: "Conflicting dependency versions"

```bash
# Issue: Different packages requiring different versions

# Diagnose:
npm ls <dependency>  # npm
yarn why <dependency>  # Yarn
pnpm ls <dependency>  # pnpm

# Solutions:
# 1. Install compatible version
npm install react@18.0.0 -w  # At workspace root

# 2. Update specific package
npm install react@18.0.0 --workspace=packages/ui

# 3. Use pnpm for strictest resolution
# (Forces compatibility)
pnpm install

# 4. Override dependency (use resolutions/overrides)
{
  "resolutions": {
    "react": "18.0.0"  // npm
  },
  "overrides": {
    "react": "18.0.0"  // pnpm
  }
}
```

#### Problem: "Cannot find module" after workspace changes

```bash
# Issue: Dependencies not updated

# Solution:
# npm
npm install
npm ls  # Verify

# yarn
yarn install
yarn why <package>

# pnpm
pnpm install
pnpm ls --recursive

# Clear and reinstall
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

#### Problem: Circular Dependencies

```bash
# Issue: Package A depends on Package B, which depends on Package A

# Detect with pnpm
pnpm ls --recursive

# Detect with npm
npm ls --all

# Solution:
# 1. Extract common code to third package
# 2. Use dependency injection
# 3. Use barrel exports strategically
# 4. Refactor package structure

# Example fix:
# Before: A → B → A (circular)
# After:
#   A → Common → B
#   B → Common (no cycle)
```

---

### Monorepo Tool Issues

#### Turborepo: Cache Invalidation Issues

```bash
# Problem: Cache not updating when files change

# Solutions:
# 1. Clear cache
turbo prune --scope=my-app
rm -rf node_modules .turbo

# 2. Rebuild from scratch
turbo run build --force

# 3. Verify turbo.json cache config
# turbo.json should have:
{
  "pipeline": {
    "build": {
      "outputs": ["dist/**"],
      "cache": true
    }
  }
}

# 4. Check file watching
turbo run build --trace=true
```

#### Nx: Generation Issues

```bash
# Problem: nx generate fails

# Solution 1: Verify plugin installed
nx list

# Solution 2: Use correct syntax
nx generate @nx/react:app my-app
# NOT: nx generate app my-app

# Solution 3: Workspace configuration
# Check nx.json/workspace.json syntax
nx show:projects

# Solution 4: Clear cache
rm -rf .nx
nx reset
```

#### Workspace: Dependency Resolution Issues

```bash
# Problem: Can't resolve local packages

# Solution 1: Check package.json dependencies
{
  "dependencies": {
    "@company/utils": "workspace:*"  // pnpm
    "@company/utils": "*"             // npm/yarn
  }
}

# Solution 2: Verify package.json names
# Each package needs unique name field

# Solution 3: Install explicitly
pnpm add @company/utils --filter @company/app

# Solution 4: Check symlinks
ls -la node_modules/@company/utils
npm ls @company/utils  # Verify resolution
```

---

## Performance Optimization

### Submodule Performance

```bash
# Use shallow clones
git clone --recurse-submodules --depth 1 https://github.com/user/repo.git

# Configure shallow for submodules
git config --global submodule.shallow true

# Parallel fetch
git config --global submodule.fetchJobs 10

# .gitmodules optimization
[submodule "libs/repo"]
    path = libs/repo
    url = https://github.com/user/repo.git
    shallow = true
    branch = main
```

### Monorepo Build Performance

```bash
# Turborepo: Enable remote caching
turbo login
turbo link

# Nx: Enable distributed task execution
nx.json:
{
  "nxCloud": {
    "accessToken": "token",
    "computeTarget": true
  }
}

# pnpm: Parallel installation
pnpm install --shamefully-hoist  # Faster, less strict
pnpm install -w --reporter=silent  # Quiet mode

# Node: Increase memory
NODE_OPTIONS=--max-old-space-size=4096 npm run build
```

---

## Migration Commands

### Submodule to Subtree

```bash
#!/bin/bash
# migrate-submodule-to-subtree.sh

SUBMODULE_NAME=$1
SUBMODULE_PATH=$(git config --file .gitmodules --get submodule.${SUBMODULE_NAME}.path)
SUBMODULE_URL=$(git config --file .gitmodules --get submodule.${SUBMODULE_NAME}.url)

if [ -z "$SUBMODULE_PATH" ] || [ -z "$SUBMODULE_URL" ]; then
    echo "Submodule not found: $SUBMODULE_NAME"
    exit 1
fi

echo "Migrating $SUBMODULE_NAME from submodule to subtree..."
echo "  Path: $SUBMODULE_PATH"
echo "  URL: $SUBMODULE_URL"

# Remove submodule
git submodule deinit -f "${SUBMODULE_PATH}"
git rm -f --cached "${SUBMODULE_PATH}"
git config --remove-section submodule.${SUBMODULE_NAME}
git config --file .gitmodules --remove-section submodule.${SUBMODULE_NAME}
rm -rf "${SUBMODULE_PATH}" ".git/modules/${SUBMODULE_PATH}"

git add .gitmodules
git commit -m "chore: prepare migration of ${SUBMODULE_NAME} to subtree"

# Add as subtree
git subtree add --prefix="${SUBMODULE_PATH}" "${SUBMODULE_URL}" main

echo "Migration complete!"
echo "Verify with: git log --oneline | head"
```

### Multi-Repo to Monorepo

```bash
#!/bin/bash
# migrate-to-monorepo.sh

# Initialize monorepo
mkdir monorepo
cd monorepo
git init
pnpm init

cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'packages/*'
  - 'services/*'
  - 'apps/*'
EOF

git add .
git commit -m "chore: initialize monorepo"

# Consolidate repositories
for repo in service-a service-b service-c; do
    echo "Consolidating $repo..."

    git clone https://github.com/company/${repo}.git /tmp/${repo}
    cd /tmp/${repo}

    # Preserve history with directory move
    git filter-branch --tree-filter \
        "mkdir -p services/${repo}; git mv -k . services/${repo} || true" \
        -- --all

    cd /path/to/monorepo

    git remote add ${repo} /tmp/${repo}
    git fetch ${repo}
    git merge --allow-unrelated-histories ${repo}/main

    rm -rf /tmp/${repo}
    git remote remove ${repo}
done

echo "Monorepo consolidation complete!"
pnpm install
pnpm run build
```

