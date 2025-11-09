# GitHub Security Configuration Checklist (2025)

Complete implementation checklist for GitHub-integrated security scanning tools.

## Prerequisites

- [ ] GitHub repository created
- [ ] GitHub Advanced Security enabled (or available)
- [ ] Repository admin access
- [ ] Team members identified for security roles
- [ ] External service accounts ready (Slack, Jira, etc.)

---

## Phase 1: Repository Configuration

### Repository Settings

- [ ] Enable GitHub Advanced Security
  - Path: Settings > Code Security & Analysis
  - Features to enable:
    - [ ] Code Scanning (CodeQL)
    - [ ] Secret Scanning
    - [ ] Dependabot version updates
    - [ ] Dependabot security updates

- [ ] Configure Branch Protection Rules
  - [ ] Require CodeQL check to pass
  - [ ] Require dependency review
  - [ ] Require all status checks to pass
  - [ ] Dismiss stale pull request approvals
  - [ ] Require branches to be up to date before merging
  - [ ] Restrict who can force push: security-team only
  - [ ] Restrict who can dismiss reviews: security-team only

- [ ] Enable Signed Commits (Optional but Recommended)
  - [ ] Require signed commits: Yes

### Access Control

- [ ] Create security team
- [ ] Create code owners file (`.github/CODEOWNERS`)
- [ ] Assign team members to appropriate groups:
  - [ ] Security team (review all security changes)
  - [ ] DevOps team (review infrastructure changes)
  - [ ] Code owners (review specific modules)

---

## Phase 2: Core Configuration Files

### 2.1 Dependabot Configuration

- [ ] Create `.github/dependabot.yml`
  - [ ] npm configuration
  - [ ] pip/poetry configuration
  - [ ] Maven/Gradle configuration
  - [ ] Docker configuration
  - [ ] GitHub Actions configuration
  - [ ] Set appropriate schedule (daily/weekly)
  - [ ] Configure grouping strategy
  - [ ] Set pull request limits
  - [ ] Add labels and assignees
  - [ ] Configure commit messages

**Validation:**
- [ ] File syntax is valid YAML
- [ ] All package ecosystems configured
- [ ] Schedules are staggered
- [ ] Test Dependabot by creating a dependency update

### 2.2 CodeQL Configuration

- [ ] Create `.github/codeql-config.yml`
  - [ ] Select query suite (security-and-quality recommended)
  - [ ] Configure path ignores
  - [ ] Set database options
  - [ ] Configure language-specific settings
  - [ ] Enable AI-powered analysis
  - [ ] Set result filters

**Validation:**
- [ ] Syntax is valid YAML
- [ ] Paths excluded are appropriate
- [ ] Language settings match project languages

### 2.3 Secret Scanning Configuration

- [ ] Create `.github/secret_scanning.yml`
  - [ ] Enable push protection
  - [ ] Configure bypass workflow
  - [ ] Define excluded directories
  - [ ] Define excluded files
  - [ ] Add custom patterns
  - [ ] Configure provider-specific settings
  - [ ] Enable AI detection
  - [ ] Set up notifications

**Validation:**
- [ ] Push protection enabled and working
- [ ] Test exclusions don't hide real secrets
- [ ] Custom patterns are tested
- [ ] Bypass notifications working

### 2.4 CODEOWNERS

- [ ] Create `.github/CODEOWNERS`
  - [ ] Default owners specified
  - [ ] Security paths require security-team
  - [ ] Infrastructure paths require devops-team
  - [ ] All modules have owners

**Validation:**
- [ ] File syntax correct
- [ ] All teams exist
- [ ] Test by checking PR requirements

---

## Phase 3: Workflows

### 3.1 CodeQL Analysis Workflow

- [ ] Create `.github/workflows/codeql-analysis.yml`
  - [ ] Triggers configured:
    - [ ] Push to main/develop
    - [ ] Pull request events
    - [ ] Nightly schedule
    - [ ] Manual trigger
  - [ ] Multi-language matrix
  - [ ] Minimal permissions set
  - [ ] Actions pinned to specific SHA
  - [ ] Build steps for each language
  - [ ] SARIF upload enabled
  - [ ] Result processing configured

**Validation:**
- [ ] Workflow syntax valid
- [ ] Triggers working
- [ ] Actions pinned correctly
- [ ] Analysis completes successfully
- [ ] Results visible in Security tab

### 3.2 Dependency Review Workflow

- [ ] Create `.github/workflows/dependency-review.yml`
  - [ ] Triggers on dependency changes
  - [ ] Dependency review action enabled
  - [ ] SBOM generation enabled
  - [ ] Vulnerability assessment included
  - [ ] License checking included
  - [ ] Summary comments enabled

**Validation:**
- [ ] Workflow runs on PR with dependency changes
- [ ] Comments appear on PRs
- [ ] Artifacts are generated
- [ ] High vulnerabilities block PR

### 3.3 Security Orchestration Workflow

- [ ] Create `.github/workflows/security-orchestration.yml`
  - [ ] All scanning steps configured
  - [ ] Container scanning (if Docker used)
  - [ ] IaC scanning (if infrastructure used)
  - [ ] Vulnerability triage configured
  - [ ] Compliance checks included
  - [ ] Reporting enabled
  - [ ] Slack notifications configured

**Validation:**
- [ ] Workflow runs on schedule
- [ ] All security tools integrated
- [ ] Reports generated
- [ ] Notifications sent

---

## Phase 4: Documentation & Policies

### 4.1 Security Policy

- [ ] Create `SECURITY.md`
  - [ ] Vulnerability reporting procedure
  - [ ] Supported versions
  - [ ] Security features documented
  - [ ] Alert severity levels defined
  - [ ] Remediation SLAs specified
  - [ ] Contact information provided

**Validation:**
- [ ] Document links are working
- [ ] Procedures are clear
- [ ] SLAs are achievable

### 4.2 Implementation Guide

- [ ] Create `.github/IMPLEMENTATION_GUIDE.md`
  - [ ] Setup instructions
  - [ ] Configuration examples
  - [ ] Best practices
  - [ ] Troubleshooting guide
  - [ ] Integration examples

**Validation:**
- [ ] All commands tested
- [ ] Examples work for your languages
- [ ] Documentation is current

### 4.3 Contributing Guidelines

- [ ] Create `CONTRIBUTING.md`
  - [ ] Security requirements listed
  - [ ] Testing requirements
  - [ ] Code review process
  - [ ] Dependency update policy
  - [ ] Security disclosure info

**Validation:**
- [ ] Guidelines link from README
- [ ] Process is clear

---

## Phase 5: Testing & Validation

### 5.1 CodeQL Testing

- [ ] Create test with known vulnerability
- [ ] Verify CodeQL detects it
- [ ] Verify alert created in Security tab
- [ ] Test custom queries (if created)
- [ ] Test exclusion patterns

**Test Cases:**
- [ ] SQL injection (if applicable)
- [ ] Hardcoded credentials
- [ ] Insecure deserialization
- [ ] Path traversal

### 5.2 Secret Scanning Testing

- [ ] Create test with fake secret
- [ ] Verify push protection blocks it
- [ ] Test bypass workflow
- [ ] Test excluded directory doesn't trigger alert
- [ ] Verify custom patterns work

**Test Cases:**
- [ ] GitHub token format
- [ ] AWS key format
- [ ] Custom pattern
- [ ] Fake credential in test file

### 5.3 Dependabot Testing

- [ ] Update a test dependency
- [ ] Verify Dependabot creates PR
- [ ] Verify labels are applied
- [ ] Verify reviewers assigned
- [ ] Test grouping strategy

### 5.4 Workflow Testing

- [ ] Run workflows manually
- [ ] Verify all steps execute
- [ ] Check for timeouts
- [ ] Verify permissions sufficient
- [ ] Test error handling
- [ ] Check notifications sent

---

## Phase 6: Team Training & Documentation

- [ ] Schedule security team training
  - [ ] CodeQL alert review
  - [ ] Vulnerability triage process
  - [ ] Remediation procedures
  - [ ] Incident response

- [ ] Schedule developer training
  - [ ] Secrets handling
  - [ ] Dependency updates
  - [ ] Code review expectations
  - [ ] Security best practices

- [ ] Create runbooks
  - [ ] Alert response runbook
  - [ ] Incident response runbook
  - [ ] Escalation procedures
  - [ ] Emergency procedures

- [ ] Documentation
  - [ ] SLA documentation
  - [ ] Process documentation
  - [ ] Tool documentation
  - [ ] Training materials

---

## Phase 7: Ongoing Maintenance

### Weekly Tasks

- [ ] Review CodeQL alerts (Security tab)
- [ ] Review Dependabot PRs
- [ ] Check for new secret alerts
- [ ] Verify workflows ran successfully

### Monthly Tasks

- [ ] Review and close resolved alerts
- [ ] Update dependency exclusions if needed
- [ ] Review custom patterns for effectiveness
- [ ] Generate security metrics
- [ ] Team sync meeting

### Quarterly Tasks

- [ ] Full security posture assessment
- [ ] Update security policies
- [ ] Review and update runbooks
- [ ] Team training refresher
- [ ] Tool version updates

### Annually

- [ ] Security audit
- [ ] Penetration testing (if applicable)
- [ ] Policy review and updates
- [ ] Tool evaluation and renewal
- [ ] Team review

---

## Advanced Configuration (Optional)

### Custom CodeQL Queries

- [ ] Create custom query pack
  - [ ] Define qlpack.yml
  - [ ] Create custom queries
  - [ ] Publish to GHCR
  - [ ] Reference in workflow

### External Integrations

- [ ] Slack integration
  - [ ] Configure webhook
  - [ ] Set up notifications
  - [ ] Test alerts

- [ ] Jira integration
  - [ ] Configure credentials
  - [ ] Auto-create tickets
  - [ ] Test integration

- [ ] Additional SCA tools
  - [ ] Snyk integration
  - [ ] Whitesource integration
  - [ ] Grype integration

### Compliance & Audit

- [ ] Enable audit logging
- [ ] Set up compliance reporting
- [ ] Configure compliance dashboards
- [ ] Document audit trail

---

## Success Criteria

### Phase 1 Complete When:
- [ ] All GitHub Advanced Security features enabled
- [ ] Branch protection rules configured
- [ ] Team structure defined

### Phase 2 Complete When:
- [ ] All configuration files created
- [ ] Files validated and tested
- [ ] No syntax errors

### Phase 3 Complete When:
- [ ] All workflows created
- [ ] Workflows run successfully
- [ ] Results appear in dashboards

### Phase 4 Complete When:
- [ ] SECURITY.md created and published
- [ ] Documentation complete
- [ ] Team has access to docs

### Phase 5 Complete When:
- [ ] All tests pass
- [ ] Coverage validated
- [ ] Workflows stable

### Overall Success When:
- [ ] Zero critical/high findings in main branch
- [ ] SLA compliance > 95%
- [ ] Team trained on processes
- [ ] Metrics tracking implemented

---

## Quick Reference

### File Locations
```
.github/
├── workflows/
│   ├── codeql-analysis.yml
│   ├── dependency-review.yml
│   └── security-orchestration.yml
├── CODEOWNERS
├── codeql-config.yml
├── secret_scanning.yml
├── dependabot.yml
├── IMPLEMENTATION_GUIDE.md
└── SECURITY_CONFIG_CHECKLIST.md

Root:
├── SECURITY.md
├── CONTRIBUTING.md
└── CODE_OF_CONDUCT.md
```

### Key URLs
- Security tab: `https://github.com/owner/repo/security`
- Code scanning: `https://github.com/owner/repo/security/code-scanning`
- Secret scanning: `https://github.com/owner/repo/settings/security_analysis`
- Dependabot: `https://github.com/owner/repo/security/dependabot`
- Workflows: `https://github.com/owner/repo/actions`

### Common Commands
```bash
# Validate YAML syntax
yamllint .github/dependabot.yml

# Test CodeQL locally
codeql database create --language=javascript --source-root=. mydb
codeql database analyze mydb --format=sarif-latest --output=results.sarif

# Run Dependabot locally
docker run dependabot/dependabot-core
```

---

**Document Version:** 2.0
**Last Updated:** November 2025
**Review Cycle:** Quarterly
**Maintained By:** Security Team
