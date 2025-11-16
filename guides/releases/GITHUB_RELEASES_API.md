# GitHub Releases API Integration Guide

## Overview

GitHub's Releases API allows you to programmatically create, edit, and manage releases. Combined with GitHub Actions, it enables fully automated release workflows.

## API Endpoints

### REST API v3

```
POST   /repos/{owner}/{repo}/releases           Create a release
GET    /repos/{owner}/{repo}/releases           List releases
GET    /repos/{owner}/{repo}/releases/{id}      Get release by ID
GET    /repos/{owner}/{repo}/releases/latest    Get latest release
PATCH  /repos/{owner}/{repo}/releases/{id}      Update release
DELETE /repos/{owner}/{repo}/releases/{id}      Delete release
GET    /repos/{owner}/{repo}/releases/tags/{tag} Get release by tag
POST   /repos/{owner}/{repo}/releases/{id}/assets Upload asset
GET    /repos/{owner}/{repo}/releases/{id}/assets Get release assets
DELETE /repos/{owner}/{repo}/releases/assets/{id} Delete asset
```

### GraphQL API

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
      publishedAt
      url
    }
  }
}
```

---

## Authentication

### Method 1: Personal Access Token (PAT)

```bash
# Create token at GitHub Settings → Developer settings → Personal access tokens
# Scopes needed: repo, workflow, write:packages

export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx

# Usage
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/owner/repo/releases
```

### Method 2: OIDC Token (2025 Recommended)

```yaml
# GitHub Actions
jobs:
  release:
    permissions:
      id-token: write
      contents: write

    steps:
      - name: Get OIDC token
        uses: actions/github-script@v7
        with:
          script: |
            const token = await core.getIDToken('https://token.actions.githubusercontent.com');
            core.setSecret(token);
            return token;
```

### Method 3: GitHub App

```bash
# Create GitHub App at GitHub Settings → Developer settings → GitHub Apps
# Install app to repository
# Authenticate with app credentials

GITHUB_TOKEN=$(curl -X POST \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/app/installations/{installation_id}/access_tokens \
  -d '{"repositories": ["repo"]}' \
  | jq -r '.token')
```

---

## Create Release - Examples

### Using GitHub CLI

```bash
# Basic release
gh release create v1.0.0

# With title and notes
gh release create v1.0.0 \
  --title "Version 1.0.0" \
  --notes "Major release with new features"

# With auto-generated notes
gh release create v1.0.0 \
  --generate-notes \
  --latest

# Pre-release
gh release create v1.0.0-beta.1 \
  --prerelease \
  --generate-notes

# Draft release
gh release create v1.0.0 \
  --draft \
  --notes "WIP - do not publish"

# With assets
gh release create v1.0.0 \
  dist/app.tar.gz \
  dist/app.zip \
  dist/checksums.txt

# Mark as latest
gh release create v1.0.0 \
  --latest
```

### Using REST API

```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/owner/repo/releases \
  -d '{
    "tag_name": "v1.0.0",
    "target_commitish": "main",
    "name": "Release 1.0.0",
    "body": "## Features\n- New API endpoint\n- Performance improvements\n\n## Fixes\n- Critical bug fix",
    "draft": false,
    "prerelease": false,
    "make_latest": "true"
  }'
```

### Using JavaScript (octokit)

```javascript
const { Octokit } = require("@octokit/rest");

const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN
});

async function createRelease(owner, repo, version, notes) {
  const response = await octokit.rest.repos.createRelease({
    owner,
    repo,
    tag_name: `v${version}`,
    name: `Release ${version}`,
    body: notes,
    draft: false,
    prerelease: false,
    make_latest: "true"
  });

  return response.data;
}

// Usage
createRelease(
  'org',
  'repo',
  '1.0.0',
  '## Features\n- Feature 1'
);
```

### Using Python

```python
from github import Github

class ReleaseManager:
    def __init__(self, token):
        self.gh = Github(token)

    def create_release(self, owner, repo, tag, title, notes, draft=False):
        r = self.gh.get_user(owner).get_repo(repo)

        release = r.create_git_release(
            tag=tag,
            name=title,
            message=notes,
            draft=draft,
            prerelease='alpha' in tag or 'beta' in tag
        )

        return {
            'id': release.id,
            'tag': release.tag_name,
            'name': release.title,
            'url': release.html_url
        }

# Usage
manager = ReleaseManager(os.environ['GITHUB_TOKEN'])
release = manager.create_release(
    'org', 'repo', 'v1.0.0',
    'Version 1.0.0',
    '## Features\n- Feature 1'
)
print(f"Created: {release['url']}")
```

---

## Upload Release Assets

### Upload Single File

```bash
gh release upload v1.0.0 ./dist/app.tar.gz

# Or via API
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/octet-stream" \
  https://uploads.github.com/repos/owner/repo/releases/{release_id}/assets?name=app.tar.gz \
  --data-binary @./dist/app.tar.gz
```

### Upload Multiple Files

```bash
gh release upload v1.0.0 \
  dist/app-linux.tar.gz \
  dist/app-macos.tar.gz \
  dist/app-windows.zip \
  dist/checksums.txt

# With overwrite
gh release upload v1.0.0 \
  dist/app.tar.gz \
  --clobber
```

### Upload in Workflow

```yaml
- name: Upload assets
  uses: softprops/action-gh-release@v1
  if: startsWith(github.ref, 'refs/tags/')
  with:
    files: |
      dist/app*.tar.gz
      dist/checksums.txt
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Generate Release Notes Automatically

### GitHub's Auto-Generated Notes

GitHub can automatically generate release notes based on pull requests and commits.

```bash
# Use --generate-notes flag
gh release create v1.0.0 --generate-notes

# Configure behavior
# Create .github/release.yml
```

### Configure Auto-Generated Notes

```yaml
# .github/release.yml
changelog:
  exclude:
    labels:
      - ignore
      - skip-changelog
      - internal
    authors:
      - dependabot
      - renovate

  categories:
    - title: Breaking Changes
      labels:
        - breaking
        - type:breaking

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
        - docs

    - title: Dependencies
      labels:
        - dependencies
        - type:dependencies
```

### Generate Notes Programmatically

```javascript
const { Octokit } = require("@octokit/rest");

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });

async function generateReleaseNotes(owner, repo, version) {
  const response = await octokit.rest.repos.generateReleaseNotes({
    owner,
    repo,
    tag_name: `v${version}`,
    previous_tag_name: '', // Auto-detect
    target_commitish: 'main'
  });

  return response.data.body;
}

// Usage
const notes = await generateReleaseNotes('org', 'repo', '1.0.0');
console.log(notes);
```

---

## Update Release

### Update Existing Release

```bash
# Edit draft release
gh release edit v1.0.0 --draft=false

# Update notes
gh release edit v1.0.0 \
  --notes "Updated release notes"

# Mark as latest
gh release edit v1.0.0 --latest

# Edit title
gh release edit v1.0.0 --title "New Title"
```

### Update via API

```bash
curl -X PATCH \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/owner/repo/releases/{release_id} \
  -d '{
    "body": "Updated notes",
    "draft": false,
    "prerelease": false,
    "make_latest": "true"
  }'
```

---

## List and Query Releases

### List Recent Releases

```bash
# Latest 10 releases
gh release list --limit 10

# All releases
gh release list --limit 999

# Filter by type
gh release list --exclude-drafts --exclude-pre-releases
```

### Query via API

```bash
# Get latest release
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/owner/repo/releases/latest

# List releases with pagination
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/owner/repo/releases?per_page=30
```

### Query via JavaScript

```javascript
async function listReleases(owner, repo, limit = 10) {
  const releases = await octokit.paginate(
    octokit.rest.repos.listReleases,
    {
      owner,
      repo,
      per_page: limit
    }
  );

  return releases.map(r => ({
    tag: r.tag_name,
    name: r.name,
    date: r.published_at,
    isDraft: r.draft,
    isPrerelease: r.prerelease,
    assets: r.assets.length
  }));
}
```

---

## GitHub Actions Integration

### Create Release on Tag Push

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  create-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate notes
        id: notes
        run: |
          TAG=${{ github.ref_name }}
          PREV_TAG=$(git describe --tags --abbrev=0 $TAG^ 2>/dev/null || echo '')
          if [ -z "$PREV_TAG" ]; then
            NOTES=$(git log $TAG --oneline | sed 's/^/- /')
          else
            NOTES=$(git log $PREV_TAG..$TAG --oneline | sed 's/^/- /')
          fi
          echo "body<<EOF" >> $GITHUB_OUTPUT
          echo "$NOTES" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - uses: actions/create-release@v1
        with:
          tag_name: ${{ github.ref_name }}
          release_name: Release ${{ github.ref_name }}
          body: ${{ steps.notes.outputs.body }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Release with Build Artifacts

```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist/

  release:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: dist

      - uses: softprops/action-gh-release@v1
        with:
          files: |
            dist/**
          generate_release_notes: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Multi-Platform Release

```yaml
name: Release Multi-Platform

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v3
        with:
          name: dist-${{ matrix.os }}
          path: dist/

  release:
    needs: build
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/download-artifact@v3

      - uses: softprops/action-gh-release@v1
        with:
          files: |
            dist-*/**
          generate_release_notes: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Advanced Patterns

### Release with Draft Approval

```yaml
name: Create Release Draft

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  draft-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate notes
        id: notes
        run: |
          # Generate changelog
          NOTES=$(git log v$(git describe --tags --abbrev=0 $(git rev-list --tags --skip=1 -n1))..HEAD --oneline | sed 's/^/- /')
          echo "body<<EOF" >> $GITHUB_OUTPUT
          echo "$NOTES" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - uses: actions/create-release@v1
        with:
          tag_name: ${{ github.ref_name }}
          release_name: Draft ${{ github.ref_name }}
          body: ${{ steps.notes.outputs.body }}
          draft: true  # Create as draft
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Notify in Slack
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "Release draft created for ${{ github.ref_name }}. Review and publish when ready."
            }
```

### Automatic Version Detection

```javascript
// scripts/detect-version.js
const fs = require('fs');
const path = require('path');

function getNextVersion() {
  // Read latest tag
  const { execSync } = require('child_process');
  const latestTag = execSync('git describe --tags --abbrev=0', {
    encoding: 'utf-8'
  }).trim();

  // Analyze commits since tag
  const commits = execSync(`git log ${latestTag}..HEAD --format=%B`, {
    encoding: 'utf-8'
  });

  const hasBreaking = /BREAKING CHANGE/i.test(commits);
  const hasFeature = /^feat/im.test(commits);
  const hasFix = /^fix/im.test(commits);

  const [major, minor, patch] = latestTag.replace('v', '').split('.');

  if (hasBreaking) {
    return `v${parseInt(major) + 1}.0.0`;
  } else if (hasFeature) {
    return `v${major}.${parseInt(minor) + 1}.0`;
  } else if (hasFix) {
    return `v${major}.${minor}.${parseInt(patch) + 1}`;
  }

  return latestTag;
}

const version = getNextVersion();
console.log(version);
```

---

## Rate Limiting

GitHub API has rate limits:

| Endpoint | Limit |
|----------|-------|
| Authenticated | 5,000 requests/hour |
| Unauthenticated | 60 requests/hour |
| GraphQL | 5,000 points/hour |

### Handle Rate Limits

```javascript
async function createReleaseWithRetry(config, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await octokit.rest.repos.createRelease(config);
    } catch (error) {
      if (error.status === 403 && error.message.includes('API rate limit')) {
        const resetTime = parseInt(error.response.headers['x-ratelimit-reset']) * 1000;
        const waitTime = resetTime - Date.now();
        console.log(`Rate limited. Waiting ${waitTime}ms...`);
        await new Promise(r => setTimeout(r, waitTime));
        continue;
      }
      throw error;
    }
  }
}
```

---

## Error Handling

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Invalid token | Check GITHUB_TOKEN, verify scopes |
| 403 Forbidden | Insufficient permissions | Check token permissions, branch protection |
| 404 Not Found | Tag/release not found | Verify tag exists, check tag name |
| 422 Validation Failed | Invalid input | Check required fields, format |
| 429 Too Many Requests | Rate limited | Wait and retry, use exponential backoff |

### Error Handler

```javascript
async function safeCreateRelease(config) {
  try {
    return await octokit.rest.repos.createRelease(config);
  } catch (error) {
    if (error.status === 401) {
      throw new Error('Invalid GitHub token');
    } else if (error.status === 403) {
      throw new Error('Insufficient permissions for release');
    } else if (error.status === 404) {
      throw new Error(`Tag ${config.tag_name} not found`);
    } else if (error.status === 422) {
      throw new Error(`Invalid release data: ${error.message}`);
    } else {
      throw error;
    }
  }
}
```

---

## Best Practices

1. **Always use HTTPS** when calling GitHub API
2. **Validate token scopes** before deploying workflows
3. **Use OIDC tokens** instead of personal tokens in CI/CD
4. **Implement retry logic** for network failures
5. **Generate release notes** automatically from commits
6. **Test releases locally** before automating
7. **Keep release notes concise** and user-focused
8. **Sign releases** with GPG keys for security
9. **Monitor rate limits** in high-volume releases
10. **Document release process** for team consistency

---

## Useful Resources

- [GitHub REST API Docs](https://docs.github.com/rest/releases)
- [GitHub GraphQL API](https://docs.github.com/graphql)
- [octokit.js Documentation](https://octokit.github.io/rest.js/)
- [PyGithub Documentation](https://pygithub.readthedocs.io/)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
