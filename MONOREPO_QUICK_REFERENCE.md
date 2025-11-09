# Monorepo Development Quick Reference
## 2025 Practical Commands and Workflows

---

## NX QUICK COMMANDS

### Project Management
```bash
# List all projects
nx list

# Show project details
nx show project @mymonorepo/web

# View project structure
nx graph

# View affected projects
nx graph --affected

# Show dependencies
nx dep-graph
```

### Development
```bash
# Start development server for specific app
nx serve @mymonorepo/web

# Serve with file watching
nx serve @mymonorepo/web --watch

# Run multiple apps in parallel
nx run-many -t serve

# Rebuild on file change
nx watch -- nx run-many -t build
```

### Building and Compilation
```bash
# Build single project
nx build @mymonorepo/web

# Build all affected projects (from commit)
nx affected -t build

# Build with source maps
nx build @mymonorepo/web --sourceMap

# Build without cache
nx build @mymonorepo/web --skip-nx-cache

# Build with stats
nx build @mymonorepo/web --stats-json
```

### Testing
```bash
# Test affected projects
nx affected -t test

# Run tests for specific project
nx test @mymonorepo/web

# Test with coverage
nx test @mymonorepo/web --coverage

# Run tests in watch mode
nx test @mymonorepo/web --watch

# Run specific test file
nx test @mymonorepo/web --testFile=src/button.spec.ts
```

### Linting
```bash
# Lint affected projects
nx affected -t lint

# Lint specific project
nx lint @mymonorepo/web

# Fix lint errors
nx lint @mymonorepo/web --fix

# Check lint cache
nx lint @mymonorepo/web --verbose
```

### Code Generation
```bash
# Generate React library
nx generate @nx/react:library --name=my-components --directory=libs

# Generate NestJS service
nx generate @nx/nest:library --name=my-service --directory=libs

# Generate component in library
nx generate @nx/react:component button --project=@mymonorepo/shared-ui

# List available generators
nx list @nx/react

# Show generator options
nx generate @nx/react:component --help
```

### Debugging
```bash
# Run with verbose logging
nx build @mymonorepo/web --verbose

# Show affected analysis
nx affected:apps
nx affected:libs

# Check cache status
nx show project @mymonorepo/web --config-only

# Display execution plan without running
nx run-many -t build --dry-run
```

---

## TURBOREPO QUICK COMMANDS

### Building and Running
```bash
# Build all packages
turbo build

# Build only changed packages
turbo build --filter="[HEAD^]"

# Build specific package and dependencies
turbo build --filter="@mymonorepo/web..."

# Build with caching disabled
turbo build --no-cache

# Build with output only
turbo build --output-logs=only-with-errors
```

### Running Tasks
```bash
# Run multiple tasks
turbo run build test lint

# Run task for changed packages
turbo run build --filter="[HEAD^]"

# Run task in parallel with concurrency limit
turbo run build --concurrency=4

# Run with dry run
turbo run build --dry
```

### Cache Management
```bash
# Analyze cache hits
turbo build --verbosity=full

# Clear all caches
turbo prune --out-dir=dist

# Enable remote caching
turbo login

# Link to Vercel
turbo link
```

---

## GIT OPERATIONS FOR MONOREPOS

### Sparse Checkout
```bash
# Clone with sparse checkout
git clone --sparse --filter=blob:none <repo-url>

# Initialize sparse checkout (cone mode - fastest)
git sparse-checkout init --cone

# Add directories
git sparse-checkout set apps/web libs/shared-ui

# Add more directories incrementally
git sparse-checkout add apps/admin

# View current configuration
git sparse-checkout list

# Disable sparse checkout
git sparse-checkout disable

# Full repo checkout
git checkout --sparse
```

### Partial Clone (Blob Filtering)
```bash
# Clone without downloading file contents
git clone --filter=blob:none <repo-url>

# Clone with sparse and blob filtering (fastest)
git clone --sparse --filter=blob:none <repo-url>

# Configure fetch to use blob filtering
git config --global remote.origin.filterBlobLimit 256k

# Manually download blobs when needed
git fetch-pack --all --stdin-commits
```

### Performance Optimization
```bash
# Enable file system monitor
git config core.fsmonitor true
git config core.untrackedCache true

# Run garbage collection
git gc --aggressive

# Repack objects
git repack -Ad

# Check repository health
git fsck --full

# Get stats
git count-objects -v
```

### History Analysis
```bash
# Show affected files between commits
git diff main..feature-branch --name-only

# Show file changes with stats
git diff main..feature-branch --stat

# See which commits affected a path
git log --oneline -- apps/web

# Find commits with large file changes
git log --name-status --pretty=format:"%H %s" main..feature-branch

# Show commit graph
git log --oneline --graph --all
```

---

## GITHUB ACTIONS WORKFLOWS

### Checking Workflow Status
```bash
# View workflow runs
gh workflow list

# View run details
gh run view <run-id>

# View run logs
gh run view <run-id> --log

# List recent runs
gh run list --limit 10

# Check specific workflow
gh run list --workflow=selective-ci.yml
```

### Debugging Workflows
```bash
# Re-run failed workflow
gh run rerun <run-id>

# Re-run specific job
gh run rerun <run-id> --job <job-id>

# View workflow file
gh workflow view selective-ci.yml --json

# Check workflow triggers
gh api repos/owner/repo/actions/workflows | jq '.workflows[] | {name, on}'
```

### Local Workflow Testing
```bash
# Install act for local testing
brew install act

# Run workflow locally
act -j build

# Run specific job
act -l  # List jobs
act --job <job-name>

# Debug with verbose output
act --verbose
```

---

## CODE OWNERSHIP (CODEOWNERS)

### Managing CODEOWNERS
```bash
# Validate CODEOWNERS file
pnpm codeowners:validate

# Sync CODEOWNERS from package.json
pnpm codeowners:sync

# Check which owners are responsible for a file
git check-ignore -v apps/web/src/index.ts

# Simulate CODEOWNERS matching
cat .github/CODEOWNERS | grep "apps/web"
```

### CODEOWNERS Patterns
```
# Format: <path> <owner1> <owner2> @team

# Single team for path
/apps/web/ @web-team

# Multiple owners
/libs/shared-ui/ @design-team @frontend-lead

# Specific subpath override (more specific rules override general)
/libs/shared-ui/
/libs/shared-ui/buttons/ @button-specialist

# Using GitHub teams
/apps/api/ @organization/backend-team

# Using email addresses
/apps/mobile/ user@example.com
```

---

## COMMON DEVELOPMENT WORKFLOWS

### Feature Development
```bash
# 1. Create feature branch
git checkout -b feat/user-profile

# 2. Configure sparse checkout for affected areas
git sparse-checkout set apps/web libs/shared-ui libs/shared-types

# 3. Install dependencies
pnpm install

# 4. Start development
pnpm nx serve @mymonorepo/web

# 5. Make changes, commit with semantic messages
git add .
git commit -m "feat(web): add user profile page"

# 6. Run tests locally
pnpm nx affected -t test

# 7. Push and create PR
git push origin feat/user-profile
gh pr create --title "feat: user profile page" --body "..."
```

### Testing Workflow
```bash
# Run tests for affected projects
pnpm nx affected -t test

# Run tests with coverage
pnpm nx affected -t test --coverage

# Run specific test file
pnpm nx test @mymonorepo/web --testFile=profile.spec.ts

# Watch mode for development
pnpm nx test @mymonorepo/web --watch

# Generate coverage report
pnpm nx affected -t test --coverage
open coverage/index.html
```

### Building and Deployment
```bash
# Build affected projects
pnpm nx affected -t build

# Build specific app
pnpm nx build @mymonorepo/web

# View build artifacts
ls dist/apps/web

# Check build size
du -sh dist/apps/web

# Analyze bundle
nx build @mymonorepo/web --stats-json
webpack-bundle-analyzer dist/apps/web/stats.json
```

### Code Review Checklist
```
Before submitting PR:
- ☐ Code follows monorepo patterns (.cursor/rules)
- ☐ All tests pass (pnpm nx affected -t test)
- ☐ Linting passes (pnpm nx affected -t lint --fix)
- ☐ Types check out (pnpm nx affected -t type-check)
- ☐ CODEOWNERS auto-requested
- ☐ PR description references issue
- ☐ Commit messages are semantic
- ☐ No circular dependencies introduced
- ☐ New public APIs are documented
- ☐ CHANGELOG updated if necessary
```

---

## PERFORMANCE TROUBLESHOOTING

### Slow Git Operations
```bash
# Check if fsmonitor is enabled
git config core.fsmonitor

# Enable performance optimizations
git config core.fsmonitor true
git config core.untrackedCache true
git config feature.manyFiles true
git config index.version 4

# Rebuild index
rm .git/index
git reset

# Garbage collection
git gc --aggressive

# Check repository size
du -sh .git
git count-objects -v
```

### Slow Builds
```bash
# Check cache status
nx show project @mymonorepo/web --config-only

# Clear cache
rm -rf .nx/cache
rm -rf .turbo

# Run with verbose logging
pnpm nx build @mymonorepo/web --verbose

# Profile build
nx build @mymonorepo/web --stats-json
node -e "console.log(require('./stats.json'))"

# Check project dependencies
nx dep-graph --filter=@mymonorepo/web
```

### Slow CI/CD
```bash
# Check which jobs are running
gh run list --workflow=selective-ci.yml

# View step execution time
gh run view <run-id> --json jobs

# Analyze workflow performance
gh api repos/owner/repo/actions/runs | jq '.workflow_runs[] | {id, name, run_number, created_at}'

# Check if path filters are working
git diff origin/main --name-only | head -20
```

---

## DEPENDENCY MANAGEMENT

### Checking Dependencies
```bash
# List all dependencies
pnpm list

# List dependencies for specific project
pnpm list --filter=@mymonorepo/web

# Check for outdated packages
pnpm outdated

# Check for security vulnerabilities
pnpm audit

# Check for duplicate dependencies
pnpm dedupe --check

# Show dependency graph
pnpm list --depth=0
```

### Updating Dependencies
```bash
# Update all packages
pnpm update

# Update specific package
pnpm update react@18

# Update all to latest
pnpm update --latest

# Interactive update
pnpm update --interactive --latest

# Remove duplicate dependencies
pnpm dedupe
```

### Dependency Validation
```bash
# Check for circular dependencies
nx dep-graph --focus=@mymonorepo/web

# Validate dependency boundaries
nx run-many -t dep-check

# Check for unused dependencies
pnpm dlx depcheck

# Analyze bundle imports
nx build @mymonorepo/web --stats-json
```

---

## DEBUG AND LOGGING

### Enabling Debug Output
```bash
# Nx verbose logging
NX_LOG_LEVEL=verbose pnpm nx build @mymonorepo/web

# Turborepo verbose logging
turbo build --verbosity=full

# Git debug
GIT_TRACE=1 git status
GIT_TRACE_PERFORMANCE=1 git status

# Node.js debug
NODE_DEBUG=* pnpm build
```

### Analyzing Performance
```bash
# Time Nx command
time pnpm nx build @mymonorepo/web

# Profile with Node
node --prof pnpm build
node --prof-process isolate-*.log > profile.txt

# Check Turborepo caching
turbo build --verbosity=full | grep -i cache
```

---

## MONOREPO MAINTENANCE

### Regular Maintenance Tasks
```bash
# Weekly: Clean cache
pnpm nx run-many -t clean

# Weekly: Run security audit
pnpm audit

# Monthly: Update dependencies
pnpm update

# Monthly: Check for deprecated packages
npm deprecation-check

# Quarterly: Deep repository cleanup
git gc --aggressive
git prune --expire=now
```

### Monitoring Repository Health
```bash
# Check repository size
du -sh .git
git count-objects -v

# Analyze commit history
git log --oneline --all | wc -l

# Check for large files
git rev-list --all --objects | \
  sed -n $(git rev-list --objects --all | \
  cut -f1 -d' ' | \
  git cat-file --batch-check | \
  grep blob | \
  sort -k3 -n -r | \
  head -20 | \
  cut -d' ' -f1 | \
  while read hash; do \
    echo -n "-e s/$hash/$hash/p "; \
  done) | \
  cut -d' ' -f2- | \
  sort -u | \
  tail -20
```

---

## USEFUL ALIASES

### Add to .gitconfig or .bash_aliases
```bash
# Nx aliases
alias nx-build='pnpm nx build'
alias nx-test='pnpm nx affected -t test'
alias nx-lint='pnpm nx affected -t lint'
alias nx-graph='pnpm nx graph'
alias nx-affected='pnpm nx affected --base=main --head=HEAD'

# Git aliases
alias git-sparse-clone='git clone --sparse --filter=blob:none'
alias git-optimize='git config core.fsmonitor true && git config feature.manyFiles true'
alias git-status-fast='git -c core.fsmonitor=true status'

# Monorepo aliases
alias mono-setup='pnpm install && pnpm build'
alias mono-test='pnpm nx affected -t test'
alias mono-lint='pnpm nx affected -t lint --fix'
alias mono-dev='pnpm run dev'
```

---

## TROUBLESHOOTING COMMON ISSUES

### Issue: "Cannot find module" errors
```bash
# Solution 1: Check path aliases in tsconfig.base.json
cat tsconfig.base.json | grep -A 20 '"paths"'

# Solution 2: Rebuild project
pnpm nx build @mymonorepo/web --skip-nx-cache

# Solution 3: Clear node_modules and reinstall
rm -rf node_modules
pnpm install
```

### Issue: Tests failing unexpectedly
```bash
# Solution: Clear Jest cache
pnpm jest --clearCache

# Run with verbose output
pnpm nx test @mymonorepo/web --verbose

# Run single test file
pnpm nx test @mymonorepo/web --testFile=specific.spec.ts
```

### Issue: Git operations slow
```bash
# Solution: Apply performance optimizations
git config core.fsmonitor true
git config core.untrackedCache true
git config feature.manyFiles true

# Clear cache
rm -rf .git/index.lock
git reset
```

### Issue: PR doesn't trigger CI/CD
```bash
# Solution: Check path filters
.github/workflows/selective-ci.yml

# Check file changes
git diff origin/main --name-only

# Force push to re-trigger
git commit --allow-empty -m "trigger: ci"
git push
```

---

## RESOURCES

### Internal Docs
- `ARCHITECTURE.md` - System design and patterns
- `PATTERNS.md` - Code patterns and examples
- `.cursor/rules` - AI coding guidelines

### Commands Reference
- `pnpm help` - Package manager help
- `nx help` - Nx CLI help
- `turbo help` - Turborepo CLI help
- `git help` - Git documentation

### Quick Help
```bash
# List all available scripts
cat package.json | grep -A 30 '"scripts"'

# Show Nx project details
nx show project @mymonorepo/web

# List all generators
nx list
```

---

## GIT BRANCH PROTECTION RULES (GitHub)

Recommended branch protection rules for `main`:
```
- Require pull request reviews before merging
  - Required number of reviewers: 2 (or 1 if small team)
  - Require review from code owners: ✓
- Require status checks to pass before merging
  - Required checks:
    - lint
    - test
    - build
- Require branches to be up to date before merging: ✓
- Require code owner reviews: ✓
- Restrict who can push to matching branches: admin/maintainers only
```

---

This quick reference should help teams navigate monorepo development efficiently in 2025.
