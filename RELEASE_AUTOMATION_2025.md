# Automated Release Management for 2025: Complete Setup Guide

## Table of Contents
1. [Semantic-Release Deep Dive](#semantic-release-deep-dive)
2. [Changelog Generation](#changelog-generation)
3. [Release Notes Automation](#release-notes-automation)
4. [Version Bumping Strategies](#version-bumping-strategies)
5. [Multi-Package Releases](#multi-package-releases)
6. [Release Branching Strategies](#release-branching-strategies)
7. [GitHub Releases API Usage](#github-releases-api-usage)
8. [Complete Setup Examples](#complete-setup-examples)

---

## Semantic-Release Deep Dive

### Overview
**Semantic-release** is a fully automated versioning and package publishing tool that analyzes commit messages to determine the next version number following Semantic Versioning (SemVer) principles.

### How It Works
1. **Analyzes commit history** using Conventional Commits specification
2. **Determines version bump** (MAJOR, MINOR, PATCH)
3. **Generates changelog** from commits
4. **Creates GitHub releases** with release notes
5. **Publishes packages** to npm, PyPI, or other registries

### Core Features (2025)
- **Automatic versioning**: No manual version management
- **Conventional Commits support**: Parses standardized commit messages
- **Multi-plugin ecosystem**: GitHub, GitLab, npm, Docker, Slack integrations
- **Monorepo support**: `semantic-release-monorepo` plugin
- **CI/CD integration**: Works seamlessly with GitHub Actions, GitLab CI, CircleCI

### Default Configuration
Uses **Angular Commit Message Conventions**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Commit Types and Version Impact
```
feat(auth):        → MINOR version (feature)
fix(ui):           → PATCH version (bugfix)
BREAKING CHANGE:   → MAJOR version (breaking)
perf(api):         → PATCH version (with [skip ci] to avoid release)
docs(README):      → No release
refactor(core):    → No release (without BREAKING)
test(unit):        → No release
chore(deps):       → No release
```

### Installation & Configuration

```bash
npm install --save-dev semantic-release
npm install --save-dev @semantic-release/github @semantic-release/npm @semantic-release/changelog @semantic-release/git @semantic-release/commit-analyzer @semantic-release/release-notes-generator
```

### Minimal .releaserc.json Configuration
```json
{
  "branches": [
    "main",
    {
      "name": "beta",
      "prerelease": true
    },
    {
      "name": "alpha",
      "prerelease": true
    }
  ],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    "@semantic-release/github",
    "@semantic-release/git"
  ],
  "repositoryUrl": "https://github.com/user/repo.git"
}
```

### 2025 Best Practices
- **NPM Trusted Publishing**: Use OIDC tokens instead of long-lived npm tokens (no `NPM_TOKEN` needed)
- **Provenance Attestations**: Automatic generation of package provenance for security
- **Multi-branch releases**: Support for main, beta, alpha release channels
- **Conditional plugins**: Load plugins only when needed

---

## Changelog Generation

### Tools Landscape (2025)

#### 1. **conventional-changelog-cli** (Recommended)
Parses Conventional Commits and generates CHANGELOG.md
```bash
npm install --save-dev conventional-changelog-cli
npx conventional-changelog -p angular -i CHANGELOG.md -s
```

#### 2. **auto-changelog**
Git-based changelog from tags and commits
```bash
npm install --save-dev auto-changelog
npx auto-changelog --template keepachangelog
```

#### 3. **release-it**
Changelog generation + versioning + publishing
```bash
npm install --save-dev release-it @release-it/conventional-changelog
npx release-it --dry-run
```

#### 4. **Changeish** (AI-Powered 2025)
Uses LLM to generate natural language changelogs
```bash
bash changeish.sh --since v1.0.0 --until HEAD --model gpt-4
```

### Changelog Format Options

#### Keep a Changelog (Recommended)
```markdown
## [1.2.0] - 2025-11-09

### Added
- New feature X
- New feature Y

### Fixed
- Bug fix A
- Bug fix B

### Changed
- Breaking change C

### Deprecated
- Old API D

## [1.1.0] - 2025-10-15
...
```

#### Conventional Format
```markdown
### 1.2.0 (2025-11-09)

#### Features
* **auth:** add OAuth2 support ([abc1234](https://github.com/org/repo/commit/abc1234))
* **api:** deprecate v1 endpoint ([def5678](https://github.com/org/repo/commit/def5678))

#### Bug Fixes
* **ui:** fix button alignment ([ghi9012](https://github.com/org/repo/commit/ghi9012))

#### BREAKING CHANGES

* **api:** v1 endpoint removed in 2.0.0
```

### Configuration Example
```javascript
// changelog.config.js
module.exports = {
  disableEmoji: false,
  format: 'utf-8',
  list: ['feat', 'fix', 'perf', 'docs', 'breaking'],
  maxMessageLength: 64,
  types: [
    { types: ['feat', 'feature'], label: '🚀 Features' },
    { types: ['fix', 'bugfix'], label: '🐛 Bugfixes' },
    { types: ['improvements', 'enhancement'], label: '⚡ Improvements' },
    { types: ['perf'], label: '🎯 Performance' },
    { types: ['breaking'], label: '💥 Breaking Changes' },
  ],
};
```

---

## Release Notes Automation

### GitHub's Native Approach (2025)

#### Automatically Generated Release Notes
Configure in `.github/release.yml`:
```yaml
changelog:
  exclude:
    labels:
      - ignore
      - documentation
    authors:
      - dependabot
  categories:
    - title: Breaking Changes
      labels:
        - breaking
    - title: Features
      labels:
        - feature
        - enhancement
    - title: Bug Fixes
      labels:
        - bugfix
        - fix
    - title: Documentation
      labels:
        - documentation
    - title: Dependencies
      labels:
        - dependencies
```

#### Usage in GitHub CLI
```bash
# Create release with auto-generated notes
gh release create v1.0.0 --generate-notes

# Create from draft
gh release create v1.0.0 --draft --generate-notes

# Add pre-release flag
gh release create v1.0.0-beta.1 --prerelease --generate-notes
```

### AI-Powered Release Notes (2025)

#### Using Release-Drafter Action
```yaml
# .github/workflows/release-drafter.yml
name: Release Drafter

on:
  pull_request:
    types: [opened, synchronize, reopened]
  push:
    branches:
      - main

jobs:
  update_release_draft:
    runs-on: ubuntu-latest
    steps:
      - uses: release-drafter/release-drafter@v5
        with:
          config-name: release-drafter.yml
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Release Drafter Config (`.github/release-drafter.yml`)
```yaml
name-template: 'v$RESOLVED_VERSION'
tag-template: 'v$RESOLVED_VERSION'
categories:
  - title: '🚀 Features'
    labels:
      - 'feature'
      - 'enhancement'
  - title: '🐛 Bug Fixes'
    labels:
      - 'fix'
      - 'bugfix'
  - title: '💥 Breaking Changes'
    labels:
      - 'breaking'
  - title: '📚 Documentation'
    labels:
      - 'documentation'
  - title: '🔧 Maintenance'
    labels:
      - 'chore'
      - 'dependencies'

version-resolver:
  major:
    labels:
      - 'breaking'
  minor:
    labels:
      - 'feature'
      - 'enhancement'
  patch:
    labels:
      - 'fix'
      - 'bugfix'
  default: patch

exclude-labels:
  - 'skip-changelog'
  - 'internal'

exclude-contributors:
  - 'dependabot'
  - 'dependabot[bot]'
```

### Advanced: AI Release Notes Agent (2025)
```python
# release_notes_agent.py
import json
from github import Github
from anthropic import Anthropic

class ReleaseNotesAgent:
    def __init__(self, github_token, anthropic_token):
        self.gh = Github(github_token)
        self.client = Anthropic()

    def generate_release_notes(self, owner, repo, version):
        repo = self.gh.get_user(owner).get_repo(repo)

        # Get PRs since last release
        prs = repo.get_pulls(state='closed', sort='updated')

        pr_data = [{
            'number': pr.number,
            'title': pr.title,
            'labels': [l.name for l in pr.labels],
            'body': pr.body[:500]
        } for pr in prs[:10]]

        # Use Claude to generate polished release notes
        prompt = f"""
        Generate professional release notes for version {version} based on these pull requests:
        {json.dumps(pr_data, indent=2)}

        Structure as:
        ## Features
        ## Bug Fixes
        ## Breaking Changes
        ## Thanks to Contributors
        """

        response = self.client.messages.create(
            model="claude-opus",
            max_tokens=1024,
            messages=[{"role": "user", "content": prompt}]
        )

        return response.content[0].text
```

---

## Version Bumping Strategies

### Semantic Versioning (SemVer) Rules

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]

Examples:
1.0.0-alpha      (pre-release)
1.0.0-alpha.1    (pre-release with identifier)
1.0.0-rc.1       (release candidate)
2.0.0            (stable release)
2.0.0+build.123  (build metadata)
```

### Decision Matrix

| Scenario | Bump | Example |
|----------|------|---------|
| New backward-compatible features | MINOR | 1.0.0 → 1.1.0 |
| Backward-compatible bug fixes | PATCH | 1.1.0 → 1.1.1 |
| Breaking changes | MAJOR | 1.9.0 → 2.0.0 |
| Deprecation notices | MINOR | 1.0.0 → 1.1.0 |
| Dependency major bump | MAJOR only if API changes | 1.0.0 → 1.1.0 or 2.0.0 |
| Internal refactoring (no API change) | No bump | - |

### Automated Version Bumping with semantic-release

```javascript
// .releaserc.js
module.exports = {
  branches: [
    {
      name: 'main',
      channel: 'latest'
    },
    {
      name: 'next',
      channel: 'next',
      prerelease: 'rc'
    },
    {
      name: 'next-major',
      channel: 'next-major',
      prerelease: 'alpha'
    }
  ],

  analyzeCommits: {
    preset: 'angular',
    releaseRules: [
      { breaking: true, release: 'major' },
      { type: 'feat', release: 'minor' },
      { type: 'fix', release: 'patch' },
      { type: 'perf', release: 'patch' },
      { type: 'refactor', release: false },
      { type: 'style', release: false },
      { type: 'docs', release: false },
      { type: 'test', release: false },
      { type: 'chore', release: false },
      { scope: 'no-release', release: false }
    ]
  },

  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    ['@semantic-release/npm', { tarballDir: 'dist' }],
    '@semantic-release/github',
    '@semantic-release/git'
  ]
};
```

### Manual Version Control with Commit Messages

```bash
# Standard bump (automatic detection)
git commit -m "feat: add new feature"

# Explicit major bump
git commit -m "feat!: redesign API"
# OR
git commit -m "fix: critical bug

BREAKING CHANGE: API endpoint removed"

# Explicit minor bump
git commit -m "feat(auth): add OAuth support"

# Explicit patch bump
git commit -m "fix(ui): button styling"

# No release
git commit -m "chore: update dependencies"
```

---

## Multi-Package Releases

### Monorepo Setup with semantic-release-monorepo

#### Installation
```bash
npm install --save-dev semantic-release semantic-release-monorepo
npm install --save-dev @semantic-release/changelog @semantic-release/git @semantic-release/github @semantic-release/npm
```

#### Root .releaserc.json
```json
{
  "branches": [
    "main",
    { "name": "beta", "prerelease": true }
  ],
  "plugins": [
    "semantic-release-monorepo",
    "@semantic-release/github"
  ]
}
```

#### Per-Package .releaserc.json
```json
{
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    [
      "@semantic-release/git",
      {
        "assets": [
          "package.json",
          "CHANGELOG.md"
        ]
      }
    ]
  ]
}
```

### Alternative: Changesets (Recommended for 2025)

Changesets is more modern and works better with pnpm workspaces.

#### Installation
```bash
npm install --save-dev @changesets/cli @changesets/changelog-github
pnpm install --save-dev @changesets/cli @changesets/changelog-github
```

#### Setup
```bash
pnpm changeset init
```

#### Workflow (.changeset/config.json)
```json
{
  "changelog": [
    "@changesets/changelog-github",
    { "repo": "org/repo" }
  ],
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "public",
  "baseBranches": ["main"],
  "updateInternalDependencies": "patch",
  "ignore": ["@org/internal-tools"]
}
```

#### Developer Workflow
```bash
# 1. Create changeset
pnpm changeset

# 2. Review and commit
git add .changeset
git commit -m "chore: add changeset"

# 3. Merge to main
git push

# 4. GitHub Action automatically creates PR and version bump
```

#### GitHub Action (.github/workflows/release.yml)
```yaml
name: Release

on:
  push:
    branches:
      - main

concurrency: ${{ github.workflow }}-${{ github.ref }}

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: pnpm/action-setup@v2
        with:
          version: 8

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'

      - run: pnpm install --frozen-lockfile

      - name: Create Release Pull Request or Publish
        uses: changesets/action@v1
        with:
          publish: pnpm run release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### Monorepo Directory Structure
```
project/
├── packages/
│   ├── core/
│   │   ├── package.json
│   │   ├── CHANGELOG.md
│   │   └── .releaserc.json (if using semantic-release-monorepo)
│   ├── cli/
│   │   ├── package.json
│   │   ├── CHANGELOG.md
│   │   └── .releaserc.json
│   └── web/
│       ├── package.json
│       ├── CHANGELOG.md
│       └── .releaserc.json
├── .releaserc.json (root config)
├── .changeset/
│   ├── config.json
│   └── releases/
├── pnpm-workspace.yaml
└── .github/workflows/
    └── release.yml
```

---

## Release Branching Strategies

### 1. Trunk-Based Development (Recommended 2025)

**Best for:** CI/CD-focused teams, frequent releases

```
main (always deployable)
├── feature/auth-v2 (short-lived, 1-3 days)
├── feature/api-redesign (short-lived, 1-3 days)
└── feature/ui-overhaul (short-lived, 1-3 days)

Release: Tag from main → auto-release
Hotfix: Create fix branch, PR to main, tag
```

#### Workflow
```bash
# 1. Feature development
git checkout -b feature/new-feature main
# ... commit with conventional messages ...
git push origin feature/new-feature

# 2. Create PR
# ... GitHub requires approval ...

# 3. Merge to main
git merge --squash feature/new-feature
git push origin main
# → CI/CD triggers semantic-release

# 4. Hotfix
git checkout -b hotfix/critical-bug main
git push origin hotfix/critical-bug
# ... merge, tag triggers release ...
```

### 2. GitHub Flow (Simple)

```
main (production-ready)
├── feature/user-auth
├── bugfix/login-issue
└── docs/readme-update

Release: Tag from main
Hotfix: Direct to main with PR
```

### 3. Release Flow (Hybrid - Recommended)

**Best for:** Need stability + fast shipping

```
main (development)
├── feature/add-api-v2 (merged frequently)
└── feature/ui-redesign
    ↓ (merge to main)

release/1.0.0 (created when ready)
├── hotfix/critical-bug (cherry-picked to release and main)
├── hotfix/perf-issue (cherry-picked to release and main)
└── (tags create releases)

main continues: 1.1.0 development
release/1.0.0 gets: 1.0.1, 1.0.2 patches
```

#### Implementation
```bash
# Development
git checkout -b feature/new-api main
# ... development ...
git push && create PR

# When ready to release
git checkout main && git pull
git checkout -b release/1.0.0

# Stabilization on release branch only
git checkout release/1.0.0
git cherry-pick <hotfix-commits-from-main>

# Tag triggers release
git tag v1.0.0
git push origin release/1.0.0 --tags

# Continue development on main
git checkout main
git merge release/1.0.0  # Bring back any picks
```

### 4. Git Flow (Complex, for enterprise)

```
main (production)
├── hotfix/security-patch
└── (production tags only)

develop (staging)
├── release/1.0.0 (pre-release)
│   └── (hotfixes merged back)
├── feature/new-feature
├── feature/enhancement
└── bugfix/ui-issue

Workflow:
feature → develop → release → main → hotfix → develop+main
```

### Branch Protection Configuration
```yaml
# GitHub branch protection rules
branches:
  - name: main
    protection:
      dismiss_stale_reviews: true
      require_code_review: 1
      require_status_checks_to_pass: true
      required_checks:
        - test
        - lint
        - build
      restrict_who_can_push:
        users: [automation-user]
      allow_deletion: false
      allow_force_pushes: false

  - name: release/*
    protection:
      require_code_review: 1
      restrict_who_can_push: [release-manager-team]
      allow_deletion: false
```

---

## GitHub Releases API Usage

### GitHub REST API v3 - Releases Endpoint

#### Authentication (2025 Recommended: OIDC)
```bash
# Old way (deprecated)
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx

# 2025 way: OIDC Token
export GITHUB_TOKEN=$(jq -r '.token' $ACTIONS_ID_TOKEN_REQUEST_TOKEN_ENV)
```

#### Create Release
```bash
gh release create v1.0.0 \
  --title "Version 1.0.0" \
  --notes "Major release with new features" \
  --draft false \
  --prerelease false
```

#### Create Release with Auto-Generated Notes
```bash
gh release create v1.0.0 \
  --generate-notes \
  --latest
```

#### Create Release with Files
```bash
gh release create v1.0.0 \
  --title "Version 1.0.0" \
  --generate-notes \
  dist/app-1.0.0.tar.gz \
  dist/app-1.0.0.zip \
  dist/checksums.txt
```

#### Programmatic API (JavaScript)
```javascript
// Using @octokit/rest
const { Octokit } = require("@octokit/rest");

const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN
});

async function createRelease(owner, repo, tag, notes) {
  const response = await octokit.rest.repos.createRelease({
    owner,
    repo,
    tag_name: tag,
    name: `Release ${tag}`,
    body: notes,
    draft: false,
    prerelease: tag.includes('alpha') || tag.includes('beta'),
    make_latest: 'true'
  });

  return response.data;
}

// Upload asset
async function uploadAsset(owner, repo, releaseId, filePath) {
  const fs = require('fs');
  const path = require('path');

  const response = await octokit.rest.repos.uploadReleaseAsset({
    owner,
    repo,
    release_id: releaseId,
    name: path.basename(filePath),
    data: fs.readFileSync(filePath)
  });

  return response.data;
}
```

#### Programmatic API (Python)
```python
from github import Github, GithubException

class ReleaseManager:
    def __init__(self, token):
        self.gh = Github(token)

    def create_release(self, owner, repo, tag, title, notes, assets=None):
        """Create GitHub release with optional assets"""
        r = self.gh.get_user(owner).get_repo(repo)

        release = r.create_git_release(
            tag=tag,
            name=title,
            message=notes,
            draft=False,
            prerelease='alpha' in tag or 'beta' in tag
        )

        # Upload assets
        if assets:
            for asset_path in assets:
                release.upload_asset(asset_path)

        return release

    def update_release(self, owner, repo, release_id, notes):
        """Update existing release notes"""
        r = self.gh.get_user(owner).get_repo(repo)
        release = r.get_release(release_id)
        release.edit(body=notes)
        return release

    def list_releases(self, owner, repo, limit=10):
        """List recent releases"""
        r = self.gh.get_user(owner).get_repo(repo)
        return list(r.get_releases()[:limit])
```

#### GraphQL API
```graphql
mutation CreateRelease($input: CreateReleaseInput!) {
  createRelease(input: $input) {
    release {
      id
      name
      tagName
      description
      isDraft
      isPrerelease
      createdAt
      publishedAt
      url
    }
  }
}

# Variables:
{
  "input": {
    "repositoryId": "R_kgDOB...",
    "tagName": "v1.0.0",
    "name": "Release 1.0.0",
    "body": "## Features\n- New API endpoints",
    "draft": false,
    "prerelease": false
  }
}
```

### GitHub Actions Integration

#### Automatic Release on Tag
```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate Release Notes
        id: notes
        run: |
          TAG=${{ github.ref_name }}
          PREV_TAG=$(git describe --tags --abbrev=0 $TAG^)
          NOTES=$(git log $PREV_TAG..$TAG --oneline | \
            sed 's/^/- /')
          echo "changelog<<EOF" >> $GITHUB_OUTPUT
          echo "$NOTES" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create Release
        uses: actions/create-release@v1
        with:
          tag_name: ${{ github.ref_name }}
          release_name: Release ${{ github.ref_name }}
          body: ${{ steps.notes.outputs.changelog }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Release with Build Artifacts
```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-and-release:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Build
        run: |
          npm ci
          npm run build
          npm run package

      - name: Generate Checksums
        run: |
          cd dist
          sha256sum * > checksums.txt
          cat checksums.txt

      - name: Create Release with Assets
        uses: softprops/action-gh-release@v1
        with:
          files: |
            dist/app-*.tar.gz
            dist/checksums.txt
          generate_release_notes: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Complete Setup Examples

### Example 1: Simple NPM Package

**Project Structure:**
```
project/
├── src/
├── package.json
├── .releaserc.json
├── CHANGELOG.md
└── .github/workflows/
    └── release.yml
```

**package.json:**
```json
{
  "name": "@org/package",
  "version": "0.0.0-semantically-released",
  "description": "My awesome package",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "test": "jest",
    "lint": "eslint src"
  },
  "devDependencies": {
    "semantic-release": "^23.0.0",
    "@semantic-release/commit-analyzer": "^11.0.0",
    "@semantic-release/release-notes-generator": "^12.0.0",
    "@semantic-release/changelog": "^6.0.0",
    "@semantic-release/npm": "^11.0.0",
    "@semantic-release/github": "^9.0.0",
    "@semantic-release/git": "^10.0.0"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/org/package"
  }
}
```

**.releaserc.json:**
```json
{
  "branches": [
    "main",
    { "name": "beta", "prerelease": true },
    { "name": "alpha", "prerelease": true }
  ],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    [
      "@semantic-release/changelog",
      {
        "changelogFile": "CHANGELOG.md"
      }
    ],
    "@semantic-release/npm",
    [
      "@semantic-release/git",
      {
        "assets": ["package.json", "CHANGELOG.md"],
        "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
      }
    ],
    "@semantic-release/github"
  ]
}
```

**.github/workflows/release.yml:**
```yaml
name: Release

on:
  push:
    branches:
      - main
      - beta
      - alpha

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      packages: write
      id-token: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          registry-url: 'https://registry.npmjs.org'

      - run: npm ci

      - run: npm run lint
      - run: npm run test
      - run: npm run build

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Release
        run: npx semantic-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

---

### Example 2: Monorepo with pnpm and Changesets

**pnpm-workspace.yaml:**
```yaml
packages:
  - 'packages/*'
```

**.changeset/config.json:**
```json
{
  "$schema": "https://unpkg.com/@changesets/config@2.3.1/schema.json",
  "changelog": [
    "@changesets/changelog-github",
    { "repo": "org/monorepo" }
  ],
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "public",
  "baseBranches": ["main", "beta"],
  "updateInternalDependencies": "patch",
  "ignore": ["@org/internal-tools"]
}
```

**.github/workflows/release.yml:**
```yaml
name: Release

on:
  push:
    branches:
      - main
      - beta

concurrency: ${{ github.workflow }}-${{ github.ref }}

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      id-token: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: pnpm/action-setup@v2
        with:
          version: 8

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
          registry-url: 'https://registry.npmjs.org'

      - run: pnpm install --frozen-lockfile

      - run: pnpm lint
      - run: pnpm test
      - run: pnpm build

      - name: Create Release Pull Request or Publish
        uses: changesets/action@v1
        with:
          title: 'chore: release packages'
          publish: pnpm run release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

**package.json (root):**
```json
{
  "private": true,
  "scripts": {
    "build": "pnpm -r build",
    "test": "pnpm -r test",
    "lint": "pnpm -r lint",
    "release": "pnpm -r publish --access public"
  },
  "devDependencies": {
    "@changesets/cli": "^2.26.0",
    "@changesets/changelog-github": "^0.5.0"
  }
}
```

---

### Example 3: Docker Multi-Architecture Release

**.github/workflows/docker-release.yml:**
```yaml
name: Docker Release

on:
  push:
    tags:
      - 'v*'

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
            type=ref,event=tag
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=raw,value=latest,enable={{is_default_branch}}

      - uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

---

### Example 4: Full Release Pipeline with Quality Checks

**.github/workflows/release.yml:**
```yaml
name: Release Pipeline

on:
  push:
    branches:
      - main
      - beta

jobs:
  # Quality checks
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - run: npm ci
      - run: npm run lint
      - run: npm run test -- --coverage

      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  # Build artifacts
  build:
    needs: quality
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - run: npm ci
      - run: npm run build

      - uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist/

  # Release
  release:
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    permissions:
      contents: write
      packages: write
      id-token: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      - uses: actions/download-artifact@v3
        with:
          name: dist
          path: dist/

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          registry-url: 'https://registry.npmjs.org'

      - run: npm ci

      - name: Release
        run: npx semantic-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

---

## Key Takeaways for 2025

### Version Control
- **Trunk-based development** is the standard for high-performing teams
- **Release Flow** balances control with velocity
- Feature flags enable continuous deployment to main

### Automation
- **semantic-release** + **GitHub Actions** = fully automated releases
- **Changesets** is better for monorepos than semantic-release-monorepo
- **OIDC tokens** replace long-lived credentials (more secure)

### Changelog & Release Notes
- GitHub's built-in auto-generation is sufficient for most projects
- **Release Drafter** for manual review workflows
- AI-powered notes (like Claude) for professional polish

### Version Bumping
- Conventional Commits standardize version decisions
- Automation removes human error
- BREAKING CHANGE and feat:/fix: prefixes do 90% of the work

### Security (2025)
- Use OIDC for GitHub Actions → npm/PyPI
- No long-lived tokens in secrets
- Automatic provenance attestations
- Signed commits/releases recommended

### Multi-Package
- **Changesets** + **pnpm** is the modern approach
- Handles inter-package dependencies correctly
- Better DX than semantic-release-monorepo

---

## Quick Reference: Complete Command Examples

```bash
# Initialize semantic-release
npm install --save-dev semantic-release @semantic-release/github

# Initialize changesets
pnpm add --save-dev @changesets/cli
pnpm changeset init

# Create changeset
pnpm changeset

# Test release locally
npx semantic-release --dry-run

# Manual release
npx semantic-release --no-ci

# Create GitHub release
gh release create v1.0.0 --generate-notes

# List releases
gh release list --limit 10
```

---

## Resources

- [semantic-release Documentation](https://semantic-release.gitbook.io)
- [Conventional Commits](https://www.conventionalcommits.org)
- [Semantic Versioning](https://semver.org)
- [Changesets](https://github.com/changesets/changesets)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [GitHub Releases API](https://docs.github.com/rest/releases)
- [GitHub Release Drafter](https://github.com/release-drafter/release-drafter)
- [release-it](https://github.com/release-it/release-it)
