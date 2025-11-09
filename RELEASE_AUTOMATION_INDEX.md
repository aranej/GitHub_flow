# Release Automation 2025 - Complete Setup Index

## Overview

This directory contains a complete, production-ready automated release management setup for 2025. Choose your setup option and follow the guides.

---

## Documentation Files

### 1. **RELEASE_AUTOMATION_2025.md** (Main Reference)
**Complete guide covering all aspects of automated releases**

- Semantic-release deep dive
- Changelog generation tools (conventional-changelog, auto-changelog, release-it, Changeish AI)
- Release notes automation (GitHub native, Release Drafter, AI agents)
- Version bumping strategies and SemVer rules
- Multi-package releases (monorepos with semantic-release-monorepo and Changesets)
- Release branching strategies (Trunk-based, GitFlow, Release Flow)
- GitHub Releases API usage
- Complete setup examples for different scenarios
- 2025 best practices and security considerations

**Read this first for comprehensive understanding.**

### 2. **GITHUB_RELEASES_API.md** (API Integration)
**Detailed GitHub Releases API reference**

- REST API v3 endpoints
- GraphQL API examples
- Authentication methods (PAT, OIDC, GitHub App)
- Create, update, list releases
- Upload and manage assets
- Generate release notes automatically
- GitHub Actions integration patterns
- Advanced patterns and error handling
- Rate limiting and best practices

**Use this for programmatic release management.**

### 3. **RELEASE_AUTOMATION_REFERENCE.md** (Quick Lookup)
**Quick reference tables and command checklists**

- Commit type to version mapping table
- Tool comparison matrix
- Configuration file reference
- GitHub Actions workflow templates
- Conventional Commits examples
- Troubleshooting decision tree
- Security best practices
- Performance optimization tips
- Monthly maintenance checklist
- Integration examples (Slack, Discord, Jira)
- Common pitfalls and solutions

**Use this for quick lookups and troubleshooting.**

### 4. **SETUP_GUIDE.md** (Implementation Steps)
**Step-by-step setup instructions for each approach**

- Quick start options (A, B, C)
- Configuration checklist
- Commit message enforcement
- Pre-commit hooks setup
- Version bumping decision tree
- Testing releases locally
- Troubleshooting guide
- GitHub API usage examples
- Performance tips
- Next steps

**Follow this to set up your first release automation.**

---

## Configuration Files

### Core Release Automation Configs

#### Option 1: Simple NPM Package (semantic-release)
```
.releaserc.json              Main semantic-release configuration
.github/workflows/release.yml CI/CD workflow for automated releases
.github/release.yml          GitHub's auto-generated notes config
```

**Use when:**
- Single npm package project
- Need fully automated releases
- Want simple setup

**Quick start:**
```bash
npm install --save-dev semantic-release @semantic-release/github @semantic-release/npm
cp .releaserc.json your-project/
cp .github/workflows/release.yml your-project/.github/workflows/
```

---

#### Option 2: Monorepo (pnpm + Changesets)
```
.changeset/config.json                 Changesets configuration
.github/workflows/changesets-release.yml Changesets release workflow
pnpm-workspace.yaml.example             pnpm workspace configuration
monorepo-package.json.example           Root package.json template
```

**Use when:**
- Multiple packages in monorepo
- Want team-friendly release process
- Using pnpm or npm workspaces

**Quick start:**
```bash
pnpm add -D @changesets/cli @changesets/changelog-github
pnpm changeset init
cp .changeset/config.json your-monorepo/
cp .github/workflows/changesets-release.yml your-monorepo/.github/workflows/
```

---

#### Option 3: Manual with Release Drafter
```
.github/workflows/release-drafter.yml  Release Drafter automation
.github/release-drafter.yml            Release Drafter configuration
```

**Use when:**
- Want manual control over releases
- Prefer draft review before publishing
- Team wants to manage version numbers

**Quick start:**
```bash
npm install --save-dev release-drafter/release-drafter
cp .github/workflows/release-drafter.yml your-project/.github/workflows/
cp .github/release-drafter.yml your-project/.github/
```

---

### Example Configuration Files

```
package.json.example                 Single package npm template
monorepo-package.json.example        Monorepo root package.json
pnpm-workspace.yaml.example          pnpm workspace configuration
```

These are templates you can use as reference when setting up your project.

---

## Setup Script

```
scripts/setup-release-automation.sh
```

**Interactive script that guides you through setup:**

```bash
chmod +x scripts/setup-release-automation.sh
./scripts/setup-release-automation.sh
```

**Features:**
- Checks Node.js installation
- Offers setup options (1-3)
- Installs dependencies
- Creates configuration files
- Sets up git hooks
- Provides next steps

---

## Quick Navigation

### I want to...

#### Setup automated releases
1. Read: SETUP_GUIDE.md (quick start)
2. Run: `./scripts/setup-release-automation.sh`
3. Follow: Configuration checklist

#### Understand the approach better
1. Read: RELEASE_AUTOMATION_2025.md (sections 1-7)
2. Review: RELEASE_AUTOMATION_REFERENCE.md (comparison table)
3. Choose: Option A, B, or C

#### Create releases programmatically
1. Read: GITHUB_RELEASES_API.md
2. Use: API examples (JavaScript, Python, bash)
3. Integrate: With custom workflows

#### Fix a release issue
1. Reference: RELEASE_AUTOMATION_REFERENCE.md (troubleshooting)
2. Check: SETUP_GUIDE.md (troubleshooting section)
3. Debug: Using GitHub CLI or Actions logs

#### Understand best practices
1. Read: RELEASE_AUTOMATION_2025.md (2025 best practices)
2. Review: RELEASE_AUTOMATION_REFERENCE.md (security, performance)
3. Study: Example configurations

---

## File Structure Overview

```
GitHub_flow/
├── RELEASE_AUTOMATION_2025.md          ← Main guide (START HERE)
├── RELEASE_AUTOMATION_REFERENCE.md     ← Quick reference
├── RELEASE_AUTOMATION_INDEX.md         ← This file
├── GITHUB_RELEASES_API.md              ← API reference
├── SETUP_GUIDE.md                      ← Implementation steps
│
├── .releaserc.json                     ← semantic-release config
├── .github/
│   ├── workflows/
│   │   ├── release.yml                 ← Automated release (semantic-release)
│   │   ├── release-drafter.yml        ← Release Drafter workflow
│   │   └── changesets-release.yml     ← Monorepo release (Changesets)
│   ├── release.yml                     ← GitHub auto-notes config
│   └── release-drafter.yml             ← Release Drafter config
│
├── .changeset/
│   └── config.json                     ← Changesets config
│
├── scripts/
│   └── setup-release-automation.sh     ← Interactive setup
│
└── *.example files
    ├── package.json.example            ← Single package template
    ├── monorepo-package.json.example   ← Monorepo template
    └── pnpm-workspace.yaml.example     ← pnpm workspace template
```

---

## Getting Started (5 Minutes)

### Step 1: Choose Your Option
```
Single Package → Use Option A (semantic-release)
Monorepo       → Use Option B (Changesets + pnpm)
Manual Control → Use Option C (Release Drafter)
```

### Step 2: Run Setup Script
```bash
chmod +x scripts/setup-release-automation.sh
./scripts/setup-release-automation.sh
```

### Step 3: Configure
Edit the generated configuration files:
- Update repository URL
- Set proper branch names
- Configure your preferences

### Step 4: Test
```bash
# Test without publishing
npm run release:dry
# OR
npx semantic-release --dry-run
# OR
pnpm changeset
```

### Step 5: Deploy
```bash
git add .
git commit -m "chore: setup release automation"
git push
```

---

## Supported Tools & Services

### Package Registries
- npm (Node.js packages)
- PyPI (Python packages)
- NuGet (.NET packages)
- RubyGems (Ruby packages)
- Maven (Java packages)
- Cargo (Rust packages)

### CI/CD Platforms
- GitHub Actions (included)
- GitLab CI
- CircleCI
- Jenkins
- Travis CI
- Azure DevOps

### Messaging & Integration
- GitHub native notifications
- Slack (webhooks)
- Discord
- Microsoft Teams
- Custom webhooks

### Version Control
- GitHub (primary)
- GitLab
- Bitbucket
- Azure Repos

---

## 2025 Highlights

### Security
✅ **OIDC Token Support** - No long-lived secrets needed
✅ **Provenance Attestation** - Automatic package signing
✅ **Token-Free Publishing** - Trusted CI/CD integration

### Automation
✅ **AI-Powered Notes** - Generate human-like release notes
✅ **Smart Versioning** - Automatic semver bumping
✅ **Multi-Registry** - Publish to multiple registries atomically

### Developer Experience
✅ **Changesets for Teams** - Better than semantic-release-monorepo
✅ **Feature Flags** - Release without branching
✅ **Zero-Config** - Setup in minutes

### Reliability
✅ **Automated Testing** - Run full suite before release
✅ **Rollback Support** - Easy version rollback
✅ **Audit Trail** - Complete release history

---

## Common Workflows

### Daily Development
```bash
# 1. Feature branch
git checkout -b feature/new-feature

# 2. Commit with conventional messages
git commit -m "feat: add new feature"

# 3. Push and create PR
git push -u origin feature/new-feature
# Create PR on GitHub

# 4. Merge (automation takes over)
# → GitHub Action runs tests
# → semantic-release analyzes commits
# → Version bumped automatically
# → Package published
# → Release notes generated
# → GitHub release created
```

### Monorepo Workflow
```bash
# 1. Feature development
git checkout -b feature/core-update

# 2. Commit changes
git commit -m "feat(core): add new utility"

# 3. Create changeset
pnpm changeset

# 4. Merge PR
# → Changesets action creates release PR
# → Review and merge release PR
# → All packages published

# 5. Continue on main
git checkout main
git pull
```

### Manual Release
```bash
# 1. Prepare release
git checkout main
git pull

# 2. Review draft release
gh release view <draft-release>

# 3. Publish when ready
gh release edit <draft-release> --draft=false
```

---

## Maintenance Tasks

### Weekly
- Monitor GitHub Actions for failures
- Review release notes for accuracy
- Check dependency updates

### Monthly
- Rotate authentication tokens
- Update GitHub Actions versions
- Review and archive old releases
- Analyze release metrics

### Quarterly
- Security audit of CI/CD
- Review and update branch protection rules
- Performance optimization
- Team training on release process

---

## Support & Resources

### Official Documentation
- [semantic-release](https://semantic-release.gitbook.io/)
- [Changesets](https://github.com/changesets/changesets)
- [GitHub Actions](https://docs.github.com/actions)
- [Conventional Commits](https://www.conventionalcommits.org/)

### Community
- GitHub Discussions
- Stack Overflow (#release-management, #github-actions)
- Reddit (r/devops, r/github)

### Tools
- GitHub CLI: `gh release --help`
- semantic-release: `npx semantic-release --help`
- Changesets: `pnpm changeset --help`

---

## Next Steps

1. **Choose setup option** (A, B, or C)
2. **Read relevant documentation** (SETUP_GUIDE.md)
3. **Run setup script** or configure manually
4. **Test locally** with --dry-run flag
5. **Deploy to repository** with git push
6. **Make test commit** with feat: prefix
7. **Review generated release**
8. **Document for team** with link to SETUP_GUIDE.md

---

## Document Version

- **Updated:** 2025-11-09
- **Release Automation Era:** 2025
- **Status:** Production Ready
- **Last Reviewed:** 2025-11-09

## Changes from Previous Versions

### 2025 Updates
- Added OIDC token authentication
- Included AI-powered release notes
- Changesets as preferred monorepo tool
- Trunk-based development as standard
- Enhanced security practices
- Performance optimization tips

---

## Checklist Before Production

- [ ] Read RELEASE_AUTOMATION_2025.md
- [ ] Choose setup option (A, B, or C)
- [ ] Review configuration files
- [ ] Run setup script
- [ ] Update repository URLs
- [ ] Test with --dry-run
- [ ] Test with --skip-ci commit
- [ ] Commit automation files
- [ ] Push to main
- [ ] Make feat: test commit
- [ ] Verify release created
- [ ] Review release notes
- [ ] Update team documentation
- [ ] Train team on workflow

---

## Questions?

Refer to the appropriate documentation file:

| Question | Document |
|----------|----------|
| How do I set this up? | SETUP_GUIDE.md |
| What's the full guide? | RELEASE_AUTOMATION_2025.md |
| How do I use the API? | GITHUB_RELEASES_API.md |
| How do I troubleshoot? | RELEASE_AUTOMATION_REFERENCE.md |
| Which option should I choose? | RELEASE_AUTOMATION_2025.md (section 8) |
| What's the commit format? | RELEASE_AUTOMATION_REFERENCE.md (Commit Examples) |
| How do I version? | RELEASE_AUTOMATION_REFERENCE.md (Version Bumping) |

---

**Ready to automate? Start with SETUP_GUIDE.md →**
