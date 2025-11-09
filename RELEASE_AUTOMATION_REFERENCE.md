# Release Automation Reference Guide

## Quick Lookup Tables

### Commit Type to Version Mapping

| Commit Type | Pattern | Version Impact | Example |
|------------|---------|-----------------|---------|
| Feature | `feat:` | MINOR bump | `feat(auth): add OAuth2` |
| Bug Fix | `fix:` | PATCH bump | `fix(ui): button styling` |
| Performance | `perf:` | PATCH bump | `perf(api): optimize queries` |
| Breaking Change | `feat!:` or `BREAKING CHANGE:` | MAJOR bump | `feat!: redesign API` |
| Documentation | `docs:` | NO release | `docs: update README` |
| Style | `style:` | NO release | `style: format code` |
| Refactor | `refactor:` | NO release | `refactor: simplify logic` |
| Test | `test:` | NO release | `test: add unit tests` |
| Chore | `chore:` | NO release | `chore: update deps` |
| CI | `ci:` | NO release | `ci: update workflow` |

### Version Bumping Examples

```
Current: 1.5.3
├─ feat(api): new endpoint        → 1.6.0 (MINOR)
├─ fix(db): query bug             → 1.5.4 (PATCH)
├─ feat!: redesign API            → 2.0.0 (MAJOR)
├─ chore: update dependencies     → 1.5.3 (NO CHANGE)
└─ docs: fix typo                 → 1.5.3 (NO CHANGE)
```

### Prerelease Versions

```
1.0.0-alpha.1       (early development)
1.0.0-beta.1        (feature complete, testing)
1.0.0-rc.1          (release candidate)
1.0.0               (stable release)
```

---

## Tool Comparison Matrix

| Feature | semantic-release | Changesets | Release-it | Release Drafter |
|---------|-----------------|-----------|-----------|-----------------|
| **Single Package** | ✅ Excellent | ⚠️ OK | ✅ Excellent | ⚠️ Manual |
| **Monorepo** | ⚠️ With plugin | ✅ Excellent | ⚠️ Limited | ⚠️ Manual |
| **Automation** | ✅ Fully auto | ✅ Fully auto | ✅ Fully auto | ⚠️ Semi-manual |
| **Changelog** | ✅ Built-in | ✅ Built-in | ✅ Built-in | ❌ No |
| **Version Bump** | ✅ Auto | ✅ Auto | ✅ Auto | ❌ Manual |
| **Publish** | ✅ Auto | ✅ Auto | ✅ Auto | ❌ Manual |
| **Team Friendly** | ⚠️ DevOps | ✅ All devs | ✅ All devs | ✅ All teams |
| **Learning Curve** | ⚠️ Medium | ✅ Easy | ✅ Easy | ✅ Easy |

---

## Configuration Files Reference

### .releaserc.json (semantic-release)

```json
{
  // Branch configuration
  "branches": [
    "main",
    { "name": "beta", "prerelease": true }
  ],

  // Plugin pipeline
  "plugins": [
    // 1. Analyze commits and determine version
    "@semantic-release/commit-analyzer",

    // 2. Generate release notes
    "@semantic-release/release-notes-generator",

    // 3. Update CHANGELOG.md
    ["@semantic-release/changelog", { "changelogFile": "CHANGELOG.md" }],

    // 4. Update package.json and publish
    ["@semantic-release/npm", { "npmPublish": true }],

    // 5. Commit changes
    ["@semantic-release/git", { "assets": ["package.json", "CHANGELOG.md"] }],

    // 6. Create GitHub release
    "@semantic-release/github"
  ],

  // Commit analysis rules
  "analyzeCommits": {
    "preset": "angular",
    "releaseRules": [
      { "breaking": true, "release": "major" },
      { "type": "feat", "release": "minor" },
      { "type": "fix", "release": "patch" }
    ]
  }
}
```

### .changeset/config.json (Changesets)

```json
{
  // How to generate changelog
  "changelog": [
    "@changesets/changelog-github",
    { "repo": "org/repo" }
  ],

  // Auto-commit changes
  "commit": false,

  // Make packages public on npm
  "access": "public",

  // Branches to release from
  "baseBranches": ["main"],

  // How to bump interdependent packages
  "updateInternalDependencies": "patch",

  // Packages to ignore
  "ignore": ["@org/internal"]
}
```

### .github/release-drafter.yml

```yaml
# Release tag format
name-template: 'v$RESOLVED_VERSION'
tag-template: 'v$RESOLVED_VERSION'

# PR categories
categories:
  - title: '🚀 Features'
    labels: [feature, enhancement]
  - title: '🐛 Bug Fixes'
    labels: [fix, bugfix]

# Version resolution
version-resolver:
  major:
    labels: [breaking]
  minor:
    labels: [feature, enhancement]
  patch:
    labels: [fix]
  default: patch

# Exclude from changelog
exclude-labels: [skip-changelog, internal]
exclude-contributors: [dependabot]
```

### pnpm-workspace.yaml

```yaml
packages:
  # Include all directories under packages/
  - 'packages/*'
  # Include examples (optional)
  - 'examples/*'

# Use single lockfile
shared-workspace-lockfile: true

# Install peer dependencies
auto-install-peers: true
```

---

## GitHub Actions Workflow Templates

### Template 1: Simple NPM Package

```yaml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      packages: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npm run test --if-present
      - run: npm run build --if-present

      - name: Release
        run: npx semantic-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### Template 2: Monorepo with Changesets

```yaml
name: Release

on:
  push:
    branches: [main]

concurrency: ${{ github.workflow }}-${{ github.ref }}

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      packages: write

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
      - run: pnpm test --if-present
      - run: pnpm build --if-present

      - uses: changesets/action@v1
        with:
          publish: pnpm run release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### Template 3: Multi-Architecture Docker Release

```yaml
name: Docker Release

on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - uses: docker/setup-qemu-action@v3
      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}

      - uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

---

## Conventional Commits Examples

### Good Commit Messages

```bash
# Basic feature
git commit -m "feat(auth): add two-factor authentication"

# Feature with scope details
git commit -m "feat(api): add pagination to list endpoint

- Added limit parameter
- Added offset parameter
- Updated documentation"

# Breaking change (method 1: ! notation)
git commit -m "feat!: redesign user model structure"

# Breaking change (method 2: footer)
git commit -m "refactor: reorganize internal structure

BREAKING CHANGE: Config file format changed from JSON to YAML"

# Bug fix with reference
git commit -m "fix(cli): resolve path resolution issue

Closes #1234"

# Multiple line body
git commit -m "feat(performance): optimize database queries

Implement query caching layer
- Add Redis integration
- Cache queries for 5 minutes
- Add cache invalidation

Closes #456"
```

### Bad Commit Messages (to avoid)

```bash
# ❌ No type prefix
"Update code"
"Fixed stuff"
"Changes"

# ❌ Capitalized subject
"FEAT: Added new feature"
"FIX: Fixed bug"

# ❌ Ending period
"feat: add new feature."
"fix: fixed something."

# ❌ Too vague
"feat: changes"
"fix: improvements"

# ❌ Multiline without breaks
git commit -m "feat: add feature
this is a description that should be in the body"
```

---

## Troubleshooting Decision Tree

```
Release not triggering?
├─ Check commit messages
│  ├─ Must start with feat:, fix:, etc.
│  ├─ Review: git log --oneline | head -5
│  └─ Fix: Rebase with proper messages
├─ Check branch name
│  ├─ Must be in branches: [main, beta, alpha]
│  └─ Fix: Update .releaserc.json
├─ Check GitHub Action status
│  ├─ Review logs: gh run list --workflow release.yml
│  └─ Check permissions in Settings → Actions
└─ Run locally
   └─ npx semantic-release --dry-run

Version bumping incorrectly?
├─ Review commit analysis rules
│  ├─ Check .releaserc.json releaseRules
│  └─ Verify type->release mapping
├─ Check for BREAKING CHANGE footer
│  └─ Add explicitly if needed
└─ Debug analyzer
   └─ DEBUG=semantic-release:* npm run release -- --dry-run

Publish failing?
├─ Check npm token
│  ├─ Verify NPM_TOKEN secret exists
│  ├─ Verify scopes: api, publish
│  └─ Check expiration date
├─ Check package settings
│  ├─ Verify package is public
│  ├─ Check publishConfig.access
│  └─ Verify no .npmignore issues
└─ Check 2FA
   └─ May need to disable or use automation token

Changeset conflicts?
├─ Consolidate changesets
│  ├─ rm .changeset/*.md
│  └─ pnpm changeset (single)
├─ Check for pending changes
│  ├─ git status
│  └─ Commit changes first
└─ Verify branch
   └─ Must be on main
```

---

## Security Best Practices

### Token Management

| Token | Type | Scope | Rotation |
|-------|------|-------|----------|
| NPM_TOKEN | Personal | publish:all | 30 days |
| GITHUB_TOKEN | Automatic | repo, workflow | Per job |
| PYPI_TOKEN | Personal | upload | 90 days |

### Using OIDC (2025 Recommended)

```yaml
# No NPM_TOKEN needed with OIDC
jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      id-token: write  # Required for OIDC

    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          registry-url: 'https://registry.npmjs.org'

      # npm automatically uses OIDC token
      - run: npm publish
```

### Protecting Secrets

```yaml
# Store in GitHub Secrets
Settings → Secrets and variables → Actions → New repository secret
- NPM_TOKEN
- PYPI_TOKEN
- REGISTRY_TOKEN

# Reference in workflows
env:
  NPM_TOKEN: ${{ secrets.NPM_TOKEN }}

# Never log secrets
- run: npm install  # Don't echo
```

### Signed Commits

```bash
# Enable GPG signing
git config --global user.signingkey <KEY_ID>
git config --global commit.gpgsign true

# Or sign individual commits
git commit -S -m "feat: add feature"

# Verify signature
git log --show-signature
```

---

## Performance Optimization

### Reduce Workflow Time

```yaml
# 1. Cache dependencies
- uses: actions/setup-node@v4
  with:
    cache: 'npm'  # Caches node_modules

# 2. Shallow clone
- uses: actions/checkout@v4
  with:
    fetch-depth: 1  # Only get latest commit

# 3. Conditional jobs
- if: contains(github.event.head_commit.modified, '.ts')
  run: npm test

# 4. Parallel tasks
pnpm -r --parallel build

# 5. Matrix testing
strategy:
  matrix:
    node-version: [18, 20, 22]
```

### Monorepo Optimization

```bash
# Selective package operations
pnpm -r --filter "@org/core" build

# Changed packages only
pnpm changed

# Dependency graph
pnpm why @org/utils

# Parallel with limit
pnpm -r --parallel --concurrency 4 test
```

---

## Monthly Maintenance Checklist

- [ ] Review and rotate NPM/PyPI tokens
- [ ] Update dependencies: `npm update` or `pnpm update`
- [ ] Check GitHub Actions for deprecated versions
- [ ] Review and archive old releases
- [ ] Analyze release frequency and metrics
- [ ] Update branch protection rules if needed
- [ ] Review security advisories
- [ ] Test dry-run release locally: `semantic-release --dry-run`

---

## Useful Commands

### Local Testing

```bash
# Dry run (don't publish)
npx semantic-release --dry-run

# Analyze commits only
npx semantic-release --analyze-commits

# With debug output
DEBUG=semantic-release:* npx semantic-release --dry-run

# Check current version
jq .version package.json
```

### GitHub Operations

```bash
# List releases
gh release list --limit 10

# Create release with notes
gh release create v1.0.0 --generate-notes

# Edit release
gh release edit v1.0.0 --notes "Updated notes"

# Delete release
gh release delete v1.0.0

# View release
gh release view v1.0.0 --json body
```

### Monorepo Operations

```bash
# List packages
pnpm list --depth -1

# Show changed packages
pnpm changed

# Show dependency tree
pnpm ls @org/core

# Update all
pnpm update -r

# Run script in workspace
pnpm -r run build
```

---

## Integration Examples

### Slack Notification

```yaml
- name: Notify Slack
  if: success()
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "Release v${{ steps.release.outputs.version }} published! 🚀"
      }
```

### Discord Notification

```yaml
- name: Discord notification
  if: success()
  uses: sarisia/actions-status-discord@v1
  with:
    webhook_url: ${{ secrets.DISCORD_WEBHOOK }}
    description: "Released v${{ steps.release.outputs.version }}"
```

### Create Jira Issue

```yaml
- name: Create Jira ticket
  uses: atlassian/gajira-create@v3
  with:
    project: PROJ
    issuetype: Release
    summary: "Release v${{ steps.release.outputs.version }}"
```

---

## Common Pitfalls to Avoid

1. **Not enforcing Conventional Commits**
   - Setup commitlint hooks
   - Require PR titles to follow format

2. **Publishing to multiple registries without coordination**
   - Use same version across all registries
   - Sequence publish operations

3. **Loose branch protection rules**
   - Require at least 1 approval
   - Require status checks to pass
   - Dismiss stale reviews

4. **Long-lived feature branches**
   - Keep branches short-lived (<3 days)
   - Use feature flags for incomplete work

5. **Forgetting to update CHANGELOG**
   - Automate with semantic-release or changesets
   - Review changelog in PR before release

6. **Insufficient test coverage for releases**
   - Run full test suite before release
   - Include integration tests

7. **Not managing prerelease versions**
   - Use beta/alpha branches for testing
   - Test prereleases before stable release

---

## Additional Resources

### Documentation
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [semantic-release docs](https://semantic-release.gitbook.io/)
- [Changesets](https://github.com/changesets/changesets/)

### Tools
- [commitlint](https://commitlint.js.org/)
- [husky](https://typicode.github.io/husky/)
- [lint-staged](https://github.com/okonet/lint-staged)
- [Release Drafter](https://github.com/release-drafter/release-drafter)

### CI/CD
- [GitHub Actions](https://docs.github.com/actions/)
- [GitHub CLI](https://cli.github.com/)
- [Nx Release](https://nx.dev/docs/guides/nx-release/)
