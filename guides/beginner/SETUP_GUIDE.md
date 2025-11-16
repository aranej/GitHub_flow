# Release Automation Setup Guide for 2025

## Quick Start Options

Choose one based on your project type:

### Option A: Simple NPM Package (semantic-release)
Recommended for: Single package projects

```bash
# 1. Install dependencies
npm install --save-dev semantic-release \
  @semantic-release/commit-analyzer \
  @semantic-release/release-notes-generator \
  @semantic-release/changelog \
  @semantic-release/npm \
  @semantic-release/github \
  @semantic-release/git

# 2. Copy configuration
cp .releaserc.json .releaserc.json.backup
# Edit .releaserc.json with your repository info

# 3. Copy GitHub Action
mkdir -p .github/workflows
cp .github/workflows/release.yml .github/workflows/

# 4. Configure branch protection
# GitHub Settings → Branches → Add rule
# - Branch name pattern: main
# - Require pull request reviews: 1
# - Require status checks to pass
# - Include administrators: No

# 5. Add GitHub token
# GitHub → Settings → Developer settings → Personal access tokens
# Scopes: repo, workflow, write:packages
# Add as: Settings → Secrets → GITHUB_TOKEN

# 6. Test dry run
npx semantic-release --dry-run

# 7. Make a commit
git add .
git commit -m "feat: add amazing new feature"
git push
```

---

### Option B: Monorepo with pnpm (Changesets)
Recommended for: Monorepos with multiple packages

```bash
# 1. Setup pnpm workspace
npm install -g pnpm@8
pnpm init -w

# 2. Create workspace structure
mkdir -p packages/core packages/cli packages/web

# 3. Initialize changesets
pnpm add -D @changesets/cli @changesets/changelog-github
pnpm changeset init

# 4. Configure workspace
cp pnpm-workspace.yaml.example pnpm-workspace.yaml
cp .changeset/config.json .changeset/config.json.backup
# Edit config.json with your repo details

# 5. Copy GitHub Action
mkdir -p .github/workflows
cp .github/workflows/changesets-release.yml .github/workflows/

# 6. Add scripts to package.json (root)
# See monorepo-package.json.example for reference

# 7. First changeset
pnpm changeset

# Follow prompts:
# - Select packages to bump
# - Select version type (major/minor/patch)
# - Write change description

# 8. Commit and push
git add .changeset
git commit -m "chore: add changeset"
git push

# 9. GitHub Action creates release PR
# Review and merge PR
# Action automatically publishes packages
```

---

### Option C: Release Drafter (Manual with Templates)
Recommended for: Teams wanting more control over releases

```bash
# 1. Setup Release Drafter
npm install --save-dev release-drafter/release-drafter

# 2. Copy configurations
mkdir -p .github/workflows .github
cp .github/workflows/release-drafter.yml .github/workflows/
cp .github/release-drafter.yml .github/

# 3. Edit release-drafter.yml
# Customize categories and autolabeling rules

# 4. Merge PR → Draft release is updated

# 5. Publish draft release manually
# OR: Use GitHub CLI
gh release edit <draft-release> --draft=false
```

---

## Configuration Checklist

### GitHub Repository Settings

- [ ] **Branches**
  - [ ] Go to Settings → Branches
  - [ ] Add rule for `main`
  - [ ] Enable "Require pull request reviews before merging"
  - [ ] Enable "Require branches to be up to date"
  - [ ] Enable "Require status checks to pass"
  - [ ] Enable "Restrict who can push to matching branches"

- [ ] **Secrets and Variables**
  - [ ] Settings → Secrets and variables → Actions
  - [ ] Add `NPM_TOKEN` (for npm publishing)
  - [ ] Add `GITHUB_TOKEN` (auto-created, but verify)
  - [ ] Add `PYPI_TOKEN` (if publishing to PyPI)

- [ ] **Actions Permissions**
  - [ ] Settings → Actions → General
  - [ ] "Read and write permissions" enabled
  - [ ] "Allow GitHub Actions to create and approve pull requests" enabled

### Code Quality

- [ ] Add `.eslintrc.json`
- [ ] Add `.prettierrc`
- [ ] Configure `jest.config.js`
- [ ] Add `tsconfig.json`

### Commit Messages

Enforce Conventional Commits:

```bash
# 1. Install husky and commitlint
npm install --save-dev husky @commitlint/cli @commitlint/config-conventional

# 2. Setup husky
npx husky install

# 3. Add commit-msg hook
echo "npx --no -- commitlint --edit \$1" > .husky/commit-msg
chmod +x .husky/commit-msg

# 4. Create commitlint.config.js
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
```

### Pre-commit Hooks

```bash
# 1. Install lint-staged
npm install --save-dev lint-staged

# 2. Add to package.json
cat > .lintstagedrc << 'EOF'
{
  "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{json,md}": ["prettier --write"],
  "*.test.ts": ["jest --bail --findRelatedTests"]
}
EOF

# 3. Add pre-commit hook
echo "npx lint-staged" > .husky/pre-commit
chmod +x .husky/pre-commit
```

---

## Commit Message Examples

### Features
```bash
git commit -m "feat(auth): add two-factor authentication"
git commit -m "feat(api): redesign endpoints"
git commit -m "feat!: remove deprecated API v1"  # MAJOR bump
```

### Bugs
```bash
git commit -m "fix(ui): button alignment on mobile"
git commit -m "fix(core): memory leak in parser"
```

### Breaking Changes
```bash
# Method 1: ! after type
git commit -m "refactor!: change function signature"

# Method 2: Footer
git commit -m "refactor: change function signature

BREAKING CHANGE: function now returns Promise instead of callback"
```

### No Release
```bash
git commit -m "docs: update README"
git commit -m "chore: update dependencies"
git commit -m "test: add unit tests"
```

---

## Version Bumping Decision Tree

```
START
  ↓
Any BREAKING CHANGE or feat!: ?
  ├─ YES → MAJOR version bump (e.g., 1.0.0 → 2.0.0)
  └─ NO ↓
New feature (feat:)?
  ├─ YES → MINOR version bump (e.g., 1.0.0 → 1.1.0)
  └─ NO ↓
Bug fix (fix:) or perf:?
  ├─ YES → PATCH version bump (e.g., 1.0.0 → 1.0.1)
  └─ NO ↓
Documentation, refactor, test, chore?
  └─ NO RELEASE
```

---

## Testing Releases Locally

### Test semantic-release
```bash
# Dry run (doesn't publish)
npx semantic-release --dry-run

# With debug output
DEBUG=semantic-release:* npx semantic-release --dry-run

# Analyze commits only
npx semantic-release --analyze-commits
```

### Test changesets
```bash
# Version packages
pnpm changeset version

# Preview what would be published
pnpm changeset publish --dry-run

# Revert changesets
git checkout pnpm-lock.yaml
git checkout package*.json
pnpm install
rm -rf .changesets/*
```

### Test release notes
```bash
# Using GitHub CLI
gh release create v1.0.0 --draft --generate-notes

# View generated notes before publishing
gh release view v1.0.0 --json body
```

---

## Troubleshooting

### Release Not Triggering

**Problem:** GitHub Action runs but doesn't create release

**Solutions:**
1. Check commit messages follow Conventional Commits
   ```bash
   git log --oneline | head -5
   # Should show: feat(...), fix(...), etc.
   ```

2. Verify branch protection doesn't block automation
   - Settings → Branches → main → Check "Restrict who can push"
   - Add GitHub Actions bot user

3. Check Action logs
   ```bash
   gh run list --workflow release.yml --limit 5
   gh run view <RUN_ID> --log
   ```

### Version Not Incrementing

**Problem:** Commits present but version stays the same

**Solutions:**
1. Check if commits were analyzed
   ```bash
   DEBUG=semantic-release:* npx semantic-release --dry-run
   ```

2. Verify releaseRules in .releaserc.json match commit types

3. Check if all commits have proper type prefix
   ```bash
   git log --format=%B | grep -E "^(feat|fix|docs|style|refactor|perf|test|chore)"
   ```

### npm Publish Fails

**Problem:** "403 Forbidden" or authentication errors

**Solutions:**
1. Verify npm token
   ```bash
   npm token list  # Personal machine
   ```

2. Check token scopes include publishing

3. Verify package access is public
   ```json
   // package.json
   "publishConfig": {
     "access": "public"
   }
   ```

### Changeset Version Conflicts

**Problem:** Multiple changesets for same package

**Solutions:**
1. Consolidate changesets
   ```bash
   pnpm changeset
   # Select same packages and squash changes
   ```

2. Remove conflicting changesets
   ```bash
   rm .changeset/*.md
   pnpm changeset  # Create single changeset
   ```

---

## GitHub API Usage Examples

### Create Release via CLI
```bash
# Basic
gh release create v1.0.0

# With notes
gh release create v1.0.0 --notes "Major features in this release"

# Auto-generated notes
gh release create v1.0.0 --generate-notes

# With assets
gh release create v1.0.0 dist/app.tar.gz dist/app.zip

# Pre-release
gh release create v1.0.0-rc.1 --prerelease

# Draft
gh release create v1.0.0 --draft

# No latest tag
gh release create v1.0.0 --latest false
```

### Create Release via API
```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/OWNER/REPO/releases \
  -d '{
    "tag_name": "v1.0.0",
    "name": "Release v1.0.0",
    "body": "## Features\n- New API\n## Fixes\n- Bug fix",
    "draft": false,
    "prerelease": false,
    "make_latest": "true"
  }'
```

### Create Release via JavaScript
```javascript
const { Octokit } = require("@octokit/rest");

const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN
});

await octokit.rest.repos.createRelease({
  owner: 'org',
  repo: 'project',
  tag_name: 'v1.0.0',
  name: 'Release v1.0.0',
  body: releaseNotes,
  draft: false,
  prerelease: false
});
```

---

## Performance Tips

1. **Cache dependencies** in GitHub Actions
   ```yaml
   - uses: actions/setup-node@v4
     with:
       node-version: '20'
       cache: 'npm'  # or 'pnpm'
   ```

2. **Use shallow clones** for faster checkout
   ```yaml
   - uses: actions/checkout@v4
     with:
       fetch-depth: 1
   ```

3. **Parallel package builds** in monorepos
   ```bash
   pnpm -r --parallel build
   ```

4. **Skip expensive checks** for docs-only changes
   ```yaml
   - if: ${{ !contains(github.event.head_commit.modified, '.ts') }}
     run: npm test
   ```

---

## Next Steps

1. Choose setup option (A, B, or C)
2. Follow installation steps
3. Make test commit with semantic message
4. Verify GitHub Action runs
5. Review generated release
6. Iterate on configurations
7. Document for team

---

## Additional Resources

- [Conventional Commits](https://www.conventionalcommits.org)
- [semantic-release Docs](https://semantic-release.gitbook.io)
- [Changesets Docs](https://github.com/changesets/changesets)
- [GitHub CLI Docs](https://cli.github.com)
- [GitHub Actions Docs](https://docs.github.com/actions)
