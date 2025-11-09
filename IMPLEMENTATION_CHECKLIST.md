# Release Automation Implementation Checklist

## Pre-Implementation

- [ ] **Review Documentation**
  - [ ] Read RELEASE_AUTOMATION_2025.md (sections 1-3)
  - [ ] Read SETUP_GUIDE.md (quick start)
  - [ ] Understand tool comparison in RELEASE_AUTOMATION_REFERENCE.md

- [ ] **Choose Implementation**
  - [ ] Decide: Single package OR Monorepo OR Manual?
  - [ ] Option A: semantic-release for single package
  - [ ] Option B: Changesets + pnpm for monorepo
  - [ ] Option C: Release Drafter for manual
  - [ ] Document choice with team

- [ ] **Check Prerequisites**
  - [ ] Node.js v18+ installed
  - [ ] npm v9+ OR pnpm v8+ installed
  - [ ] Git repository initialized
  - [ ] GitHub repository created and accessible
  - [ ] Admin access to repository settings

## Installation & Setup

### Option A: semantic-release Setup

- [ ] **Install Dependencies**
  ```bash
  npm install --save-dev semantic-release \
    @semantic-release/commit-analyzer \
    @semantic-release/release-notes-generator \
    @semantic-release/changelog \
    @semantic-release/npm \
    @semantic-release/github \
    @semantic-release/git
  ```

- [ ] **Create Configuration**
  - [ ] Copy `.releaserc.json` to project root
  - [ ] Update `repositoryUrl` if needed
  - [ ] Verify branch names (main, beta, alpha)

- [ ] **Setup GitHub Actions**
  - [ ] Create `.github/workflows/` directory
  - [ ] Copy `release.yml` workflow
  - [ ] Copy `.github/release.yml` for auto-notes

- [ ] **Test Locally**
  ```bash
  npx semantic-release --dry-run
  ```

### Option B: Changesets + pnpm Setup

- [ ] **Install pnpm**
  ```bash
  npm install -g pnpm@8
  ```

- [ ] **Create Workspace Structure**
  - [ ] Create `packages/` directory
  - [ ] Create package subdirectories

- [ ] **Install Changesets**
  ```bash
  pnpm add -D @changesets/cli @changesets/changelog-github
  pnpm changeset init
  ```

- [ ] **Create Configuration**
  - [ ] Copy `pnpm-workspace.yaml.example` → `pnpm-workspace.yaml`
  - [ ] Copy `.changeset/config.json`
  - [ ] Update `repo` field in config.json

### Option C: Release Drafter Setup

- [ ] **Install Release Drafter**
  ```bash
  npm install --save-dev release-drafter/release-drafter
  ```

- [ ] **Create Configuration**
  - [ ] Copy `.github/workflows/release-drafter.yml`
  - [ ] Copy `.github/release-drafter.yml`

## GitHub Configuration

- [ ] **Configure Secrets**
  - [ ] Settings → Secrets → Add NPM_TOKEN
  - [ ] Add PYPI_TOKEN (if needed)
  - [ ] Verify GITHUB_TOKEN is available

- [ ] **Configure Branch Protection**
  - [ ] Settings → Branches → Add rule for `main`
  - [ ] Require pull request reviews: ✓
  - [ ] Require status checks: ✓
  - [ ] Restrict pushers: Add github-actions[bot]

- [ ] **Actions Permissions**
  - [ ] Settings → Actions → General
  - [ ] Read and write permissions: ✓
  - [ ] Allow PR approvals: ✓

## Commit Setup

- [ ] **Install Git Hooks**
  ```bash
  npm install --save-dev husky @commitlint/cli @commitlint/config-conventional
  npx husky install
  ```

- [ ] **Create commitlint Configuration**
  - [ ] Create `commitlint.config.js`

- [ ] **Create Hooks**
  - [ ] Create `.husky/commit-msg`
  - [ ] Create `.husky/pre-commit` (optional)

## Testing

- [ ] **Test Dry Run**
  - [ ] Run `npx semantic-release --dry-run` or `pnpm changeset`
  - [ ] Verify version detection
  - [ ] Verify commit analysis

- [ ] **Test Commit Validation**
  - [ ] Good: `git commit -m "feat: test"`
  - [ ] Bad: `git commit -m "test"` (should fail)

- [ ] **Test First Real Release**
  - [ ] Make feat commit
  - [ ] Push to main
  - [ ] Verify GitHub Action runs
  - [ ] Verify release created
  - [ ] Verify package published

## Documentation

- [ ] **Create Internal Docs**
  - [ ] Create RELEASE_PROCESS.md
  - [ ] Document commit format
  - [ ] Link to guides

- [ ] **Update README.md**
  - [ ] Add release info
  - [ ] Link to guides

- [ ] **Update package.json**
  - [ ] Verify repository URL
  - [ ] Verify license

## Team Communication

- [ ] **Announce Release Automation**
  - [ ] Schedule team meeting
  - [ ] Explain benefits
  - [ ] Walk through examples

- [ ] **Provide Resources**
  - [ ] Share SETUP_GUIDE.md
  - [ ] Share RELEASE_AUTOMATION_REFERENCE.md
  - [ ] Create quick reference card

## Post-Launch

- [ ] **Monitor First Release**
  - [ ] Watch Action logs
  - [ ] Verify package published
  - [ ] Review release notes

- [ ] **Get Team Feedback**
  - [ ] Ask for feedback
  - [ ] Adjust if needed
  - [ ] Document lessons

- [ ] **Setup Notifications**
  - [ ] Configure Slack (optional)
  - [ ] Configure email (optional)

## Final Sign Off

- [ ] All configuration files in place
- [ ] All tests passing
- [ ] Team trained
- [ ] Documentation complete
- [ ] First release successful
- [ ] Ready for production
