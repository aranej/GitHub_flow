# Enterprise-Grade GitHub Security Configuration 2025

## Executive Summary

This guide provides comprehensive recommendations for implementing advanced branch protection, repository security, and compliance controls in GitHub 2025. These configurations are designed to meet enterprise security requirements including SOC 2, HIPAA, and industry-standard compliance frameworks.

---

## Table of Contents

1. [Advanced Branch Protection Rules](#advanced-branch-protection-rules)
2. [GitHub Rulesets (Recommended Approach)](#github-rulesets-recommended-approach)
3. [Push Protection & Secret Scanning](#push-protection--secret-scanning)
4. [Deployment Protection & Required Deployments](#deployment-protection--required-deployments)
5. [Bypass Permissions & Access Control](#bypass-permissions--access-control)
6. [Audit Logging & Compliance](#audit-logging--compliance)
7. [Enterprise-Grade Configuration](#enterprise-grade-configuration)
8. [Compliance Requirements](#compliance-requirements)

---

## 1. Advanced Branch Protection Rules

### Overview
Branch protection rules enforce certain workflows for branches and are available in public and private repositories at all GitHub tiers. **Note:** GitHub recommends using Rulesets (see Section 2) for new implementations due to superior scalability and policy layering.

### Core Protection Features

#### 1.1 Require Pull Request Reviews
```
Minimum 2-3 code reviews required per pull request
- For enterprise: Require 3 approvals for production branches
- Dismiss stale pull request approvals when new commits are pushed
- Require review from code owners (CODEOWNERS file)
- Require approval from specific teams (NEW in November 2025)
```

**Implementation Best Practice:**
- Require reviews on sensitive code paths (production, security, deployment)
- Use team-based approval requirements for critical branches
- Enable stale review dismissal to prevent outdated approvals

#### 1.2 Require Status Checks
```
Required checks before merge:
- All GitHub Actions CI/CD pipelines must pass
- Code quality scans (CodeQL, SonarQube)
- Security scanning (SAST/DAST)
- Dependency vulnerability checks (Dependabot)
- Build verification checks
- Custom status checks from third-party tools
```

**Enterprise Configuration:**
```
Status Check Names (examples):
- "build"
- "test"
- "lint"
- "security-scan"
- "dependency-check"
- "deployment-preview"
```

#### 1.3 Require Branches to be Up to Date
- Ensure branch is up to date with base branch before merge
- Prevents merge skew and integration issues
- **Critical for:** Production, release, and main branches

#### 1.4 Require Signed Commits
```
Enforce GPG/SSH signing for all commits:
- Git commit signing with GPG keys
- SSH commit signing
- Web commit signing via GitHub
```

**Enterprise Requirement:** Mandatory for regulated environments (HIPAA, SOC 2, PCI DSS)

#### 1.5 Require Linear History
- Prevent merge commits to maintain clear commit history
- Enforce rebase-and-merge or squash-and-merge strategies
- **Recommended for:** All protected branches

#### 1.6 Lock Branch (Read-Only)
```
When enabled:
- No one can push to the branch except those with bypass permissions
- Useful for release branches during specific windows
- Prevents accidental modifications to tagged releases
```

#### 1.7 Restrict Who Can Push
```
Limit direct push access to:
- Repository administrators
- Specific teams (e.g., "release-team", "devops")
- Named GitHub Apps
- Service accounts with elevated permissions
```

---

## 2. GitHub Rulesets (Recommended Approach)

### Why Rulesets Over Traditional Branch Protection Rules?

| Aspect | Branch Protection | Rulesets |
|--------|-------------------|----------|
| **Scalability** | Single branch/pattern | Apply across repos/orgs/enterprise |
| **Policy Layering** | Limited | Multiple rulesets can apply simultaneously |
| **Audit Trail** | Basic | Enhanced with creation/modification tracking |
| **Visibility** | Admin only | Anyone can view active rules |
| **Bypass Management** | Limited | Granular role/team-based bypass control |
| **Enforcement Scope** | Repository-level | Repository, Organization, Enterprise |
| **Maturity** | Established | Generally Available (GA) as of November 2025 |

### Available Rules in Rulesets

#### Core Rules
1. **Require pull request reviews**
   - Minimum number of approvals
   - Dismiss stale approvals
   - Require review from code owners
   - **NEW:** Require review from specific teams on specific files

2. **Require status checks**
   - Enforce passing status checks
   - Enforce branches to be up to date
   - Separate configuration for merge vs. PR requirements (Requested feature)

3. **Require signed commits**
   - Enforce GPG/SSH signatures

4. **Require linear history**
   - No merge commits allowed

5. **Restrict creations**
   - Prevent branch creation matching the pattern

6. **Restrict updates**
   - Prevent commits/updates to matching branches

7. **Restrict deletions**
   - Prevent branch deletion

### Ruleset Application & Targeting

#### By Ref Name
```
Patterns for targeting branches:
- main          (exact match)
- main*         (wildcard)
- release-*     (prefix matching)
- v[0-9]*       (regex patterns)
```

#### By File Change
```
Target specific rules to files/directories:
- src/security/**
- src/auth/**
- .github/workflows/
- terraform/
```

#### Conditions for Enforcement
```
When to apply rules:
- Branch creation
- Push events
- Pull request merges
- Specific environments
```

### Ruleset Example: Enterprise Production Branch

```yaml
Name: "Enterprise Production Protection"
Enforcement: Active
Target Branches:
  - Pattern: "main"
  - Pattern: "release-*"

Rules:
  1. Require Pull Request Reviews:
     - Min approvals: 3
     - Dismiss stale approvals: true
     - Require CODEOWNERS approval: true
     - Required team approval: security-team (on src/security/ changes)

  2. Require Status Checks:
     - build: true
     - test: true
     - security-scan (CodeQL): true
     - dependency-check (Dependabot): true
     - integration-tests: true
     - deployment-preview: true
     - require-branches-up-to-date: true

  3. Require Signed Commits: true

  4. Require Linear History: true

Bypass Permissions (Allow these actors):
  - admin: can-bypass (with audit logging)
  - team: release-team (audited)
  - team: site-reliability-engineering
  - github-app: automated-releases (with restrictions)

Enforcement on Admins: true (Do not allow admins to bypass)
```

### Team-Based Review Requirements (NEW - November 2025)

```yaml
Feature: "Required review by specific teams on specific files"

Use Case: Enforce stricter policies for critical code paths

Example Configuration:
  Rule: Require specific team approval on file changes
  Team: "security-team"
  Files:
    - "src/security/**"
    - "src/auth/**"
    - "infrastructure/secrets/**"
  Required Approvals: 2
  Default Approvals: 1 (for other files)
```

**Benefits:**
- Granular control over code ownership
- Separate approval paths for sensitive vs. standard code
- Scales across organization without duplicating rules
- More precise than CODEOWNERS alone

### Enterprise Rulesets (Public Preview)

```
Features in preview (Oct 2025):
- Enterprise custom repository properties
- Enterprise repository policies
- Enterprise rulesets
- Enterprise teams in bypass lists
```

---

## 3. Push Protection & Secret Scanning

### Overview

Push protection is a secret scanning feature designed to prevent sensitive information from being pushed to your repository in the first place.

### Recent Updates (2025)

#### March 2025: New Product Structure
```
GitHub Advanced Security now available as two standalone products:
1. GitHub Secret Protection
   - Secret scanning
   - AI-detected passwords
   - Push protection for secrets

2. GitHub Code Security
   - Code scanning (CodeQL)
   - Supply chain security
```

#### August 2025: Configurable Patterns (GA)
```
Feature: "Configurable push protection patterns"
Status: Generally Available
Capability: Security teams can choose which secret patterns
            are included in push protection
```

#### February 2025: REST API Management
```
Feature: Manage bypass requests via REST API
Capability: Integrate push protection bypass reviews
           with existing workflows
Use Case: Automated triage and approval workflows
```

#### July 2025: GitHub Apps Integration
```
Feature: GitHub Apps can review bypass requests
Capability: Apps can now approve/reject secret scanning
           push protection bypass and alert dismissal requests
Use Case: Automated compliance workflows
```

### Configuration

#### Enable Push Protection

```
Repository Settings > Code Security > Push protection
- Enable for all secret patterns OR
- Select specific patterns to protect:
  * AWS credentials
  * Azure credentials
  * Google API keys
  * Custom patterns (enterprise)
  * AI-detected passwords (new)
```

#### Custom Secret Patterns

```
For Enterprise: Define organization-specific patterns
- Internal API keys
- Custom token formats
- Proprietary credential formats
- Database connection strings
- Internal certificate formats
```

#### Bypass Management

```
REST API Endpoints:
- POST /repos/{owner}/{repo}/secret-scanning/alerts/{number}/bypass-requests
- GET /repos/{owner}/{repo}/secret-scanning/bypass-requests
- PATCH /repos/{owner}/{repo}/secret-scanning/bypass-requests/{id}

Reviewers can:
- Approve push protection bypass requests
- Require justification from developers
- Audit all bypass decisions
```

### Integration with CI/CD

```yaml
# GitHub Actions workflow for secret scanning
name: Secret Scanning
on: [push, pull_request]

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run secret scanning
        uses: github/secret-scanning@v1
        with:
          patterns-file: '.github/secret-patterns.json'
          on-found: fail  # Block push if secrets found
```

---

## 4. Deployment Protection & Required Deployments

### 4.1 Required Deployments (Branch Protection)

```
Purpose: Require successful deployment to specific environments
         before pull request can be merged

Environments requiring successful deployment before merge:
- staging
- integration
- canary
- production (optional - depends on deployment strategy)
```

#### Configuration Steps

```
1. Create deployment environments in repository settings
2. Add branch protection rule
3. Enable "Require deployments to succeed before merging"
4. Select required environments:
   - staging (required)
   - integration (required)
   - canary (optional, for high-risk changes)
```

#### Environment Configuration

```yaml
Environments:

staging:
  - Description: "Pre-release testing environment"
  - Deployment branches: "refs/heads/main"
  - Protection rules: Enabled
  - Required reviewers: [devops-team]
  - Deployment URL: https://staging.company.com

integration:
  - Description: "Integration testing environment"
  - Required reviewers: [qa-team]
  - Deployment URL: https://integration.company.com

production:
  - Description: "Production environment"
  - Required reviewers: [release-team, security-team]
  - Deployment URL: https://api.company.com
  - Require up-to-date branches: true
  - Require conversation resolution: true
```

### 4.2 Custom Deployment Protection Rules

```
Purpose: Custom policies for deployment approval/rejection

Status: Public Preview (powered by GitHub Apps)

Capabilities:
- External approval systems integration
- Custom environment validation
- Compliance checks before deployment
- Cost/resource validation
- Security scanning integration
```

#### Custom Rule Implementation

```
Available for:
- GitHub Enterprise Cloud (GHEC)
- Public repositories (all plans)

Implementation:
- GitHub App receives deployment event
- Validates deployment against custom policies
- Approves or rejects with explanation
- Audit trail in GitHub Events API
```

#### Example Custom Rules

```yaml
rule-set: "enterprise-deployment-controls"

rules:
  1. budget-check:
     action: validate
     criteria: deployment_cost <= budget_allocation
     on-failure: reject

  2. security-approval:
     action: require-approval
     approvers: [security-team]
     timeout: 24h

  3. compliance-validation:
     action: scan
     checks: [hipaa-compliance, pci-dss, sox-controls]
     on-failure: reject

  4. infrastructure-validation:
     action: validate
     criteria: infrastructure_ready && no_active_incidents
```

### 4.3 Merge Queue with Status Checks

```
Purpose: Ensure all PRs pass status checks on latest branch version

Configuration:
1. Enable merge queue
2. Configure merge_group trigger for GitHub Actions
3. Ensure all status checks run on merge_group event
4. Set max entries and merge strategies
```

#### Critical Configuration

```yaml
name: CI Workflow
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  merge_group:  # MUST include this for merge queue
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: npm test
      - name: Security scan
        run: npm run security-scan
```

**Known Issue (July 2025):**
- Duplicate workflow runs due to merge_group AND push to gh-readonly-queue/**
- Workaround: Use concurrency groups to cancel redundant runs

---

## 5. Bypass Permissions & Access Control

### 5.1 Bypass Permission Models

#### Traditional Model (Legacy)
```
By default:
- Repository admins can bypass branch protections
- Custom roles with "bypass branch protections" permission can bypass

Enterprise Configuration:
- Enable "Do not allow bypassing the above settings"
- Forces ALL users (including admins) to follow protections
- Highly recommended for regulated environments
```

#### Role-Based Bypass

```
Repository Roles:
- Maintain role: Can perform administrative tasks
- Admin role: Can manage settings and bypass protections

Custom Role (Enterprise):
- Can create roles with granular permissions
- Assign "Bypass branch protections" selectively
- Audit all bypass actions
```

### 5.2 Ruleset-Based Bypass Control

```
Granular bypass configuration per ruleset:

Allowed to bypass:
- Users: [admin1, admin2]
- Teams: [release-team, devops]
- Organization: [github-app-release-bot]
- Apps: [trusted-automation-app]

Bypass requirements:
- Enforce bypass restrictions even on admins
- Require justification for bypass
- Audit bypass events
- Email notification of bypass usage
```

#### Example Bypass Configuration

```yaml
Ruleset: "production-protection"

Bypass permissions:
  allowed-actors:
    - type: user
      name: alice
      reason: "Release manager"

    - type: team
      name: site-reliability-engineers
      reason: "Emergency rollback authorization"

    - type: github-app
      name: "automated-releases"
      reason: "Scheduled release automation"

  audit-requirements:
    - log-all-bypasses: true
    - require-justification: true
    - notify-security-team: true
    - max-bypasses-per-day: 5
    - bypass-expiration: 24h

  enforcement-on-admins: true
```

### 5.3 Workflow for Dismissing Stale Approvals

```
Configuration: "Dismiss stale pull request approvals
                when new commits are pushed"

Behavior:
- When new commits pushed to PR: previous approvals marked stale
- PR cannot merge until re-approved
- Ensures approvals reflect latest code changes

Critical for: Security-sensitive repositories
```

---

## 6. Audit Logging & Compliance

### 6.1 Enterprise Audit Log

#### Log Retention Policies

```
GitHub Enterprise Cloud:
- Standard events: 180 days
- Git events: 7 days
- Exported/streamed: Indefinite

GitHub Enterprise Server:
- Default: Indefinite
- Configurable: Set custom retention period
```

#### Audit Log Contents

Each log entry includes:
```
- Timestamp (UTC)
- Actor (user, GitHub App, integration)
- Action performed
- Organization/Repository context
- IP address
- User agent
- Result (success/failure)
- Additional context (branch names, PR numbers, etc.)
```

### 6.2 Audit Log Streaming (NEW)

```
Feature: Stream audit and Git events to external systems
Status: Generally available since January 2022
Adoption: 800+ enterprises using audit log streaming

Supported Endpoints:
1. AWS S3
2. Azure Blob Storage
3. Google Cloud Storage
4. Datadog
5. Splunk
6. Sumo Logic
```

#### Streaming Configuration Example

```yaml
Streaming Destination: AWS S3

Configuration:
  bucket: "company-github-audit-logs"
  region: "us-east-1"
  prefix: "enterprise/audit/"
  encryption: "AES256"

Event Types Streamed:
  - organization-events (all admin actions)
  - pull-request-events (PR creation, reviews, merges)
  - push-events (commits, branches)
  - deployment-events (releases, environment changes)
  - security-events (secret scanning, code scanning alerts)

Frequency: Real-time (seconds to minutes)
```

### 6.3 Audit Log Queries & Analysis

```
REST API for audit log queries:
GET /enterprises/{enterprise}/audit-log

Parameters:
- action: specific action type
- created: date range
- actor: user or app
- include: git-events, secret-scanning, etc.

Example API Call:
GET /enterprises/acme-corp/audit-log?
  action=repo.settings_update&
  created=2025-01-01..2025-01-31

Response: JSON array of audit events
```

---

## 7. Enterprise-Grade Configuration

### 7.1 Multi-Layer Security Architecture

```
Layer 1: Code Protection
├── Branch protection rules (legacy)
└── Repository rulesets (recommended)

Layer 2: Deployment Security
├── Required deployment environments
├── Custom deployment protection rules
└── Merge queue with status checks

Layer 3: Secret Protection
├── Push protection (blocking)
├── Secret scanning (reactive)
└── Custom pattern detection

Layer 4: Audit & Compliance
├── Comprehensive audit logging
├── Audit log streaming
├── Compliance report generation
└── SIEM integration

Layer 5: Access Control
├── Role-based bypass permissions
├── Team-based approvals
├── GitHub App restrictions
└── Fine-grained personal access tokens
```

### 7.2 Comprehensive Production Branch Configuration

```yaml
Branch Pattern: main

Repository Rulesets:
  - ruleset-id: "production-protection"
    enforcement: "active"

    rules:
      # Code Review Requirements
      - require-pull-request:
          min-approvals: 3
          require-codeowners: true
          dismiss-stale-reviews: true

      # Team-Based Reviews (NEW)
      - require-team-review:
          team: security-team
          min-approvals: 1
          files:
            - "src/security/**"
            - "src/auth/**"
            - "infrastructure/**"

      # Status Checks
      - require-status-checks:
          strict: true  # require up-to-date with base
          checks:
            - "build"
            - "test"
            - "lint"
            - "security-scan"
            - "dependency-check"
            - "integration-tests"

      # Commit Integrity
      - require-signed-commits: true
      - require-linear-history: true

      # Deployment Requirements
      - require-deployments:
          environments:
            - "staging"
            - "integration"

Bypass Permissions:
  allowed-actors:
    - type: user
      name: release-manager-1
      audit: true
    - type: team
      name: site-reliability-engineers
      audit: true
      justification-required: true

  admin-enforcement: true

Audit & Monitoring:
  - log-all-bypasses: true
  - notification-channel: security-slack
  - daily-summary: true
```

### 7.3 Release Branch Configuration

```yaml
Branch Pattern: release-*

Repository Rulesets:
  - ruleset-id: "release-protection"
    enforcement: "active"

    rules:
      - require-pull-request:
          min-approvals: 2
          require-codeowners: true

      - require-status-checks:
          strict: true
          checks:
            - "release-validation"
            - "version-bump-check"
            - "changelog-verification"

      - require-signed-commits: true

Bypass Permissions:
  allowed-actors:
    - type: team
      name: release-team

Notifications:
  - release-created: notify-all-teams
  - bypass-used: notify-security-team
```

### 7.4 Development Branch Configuration

```yaml
Branch Pattern: develop

Repository Rulesets:
  - ruleset-id: "develop-protection"
    enforcement: "active"

    rules:
      - require-pull-request:
          min-approvals: 1
          dismiss-stale-reviews: true

      - require-status-checks:
          strict: false  # can merge without latest main
          checks:
            - "build"
            - "test"
            - "lint"

Bypass Permissions: more permissive than main
```

---

## 8. Compliance Requirements

### 8.1 SOC 2 Type II Compliance

#### Required GitHub Controls

```
SOC 2 Trust Service Criteria - Security (CC):
├── CC6.1: Logical Access Control
│   ├── MFA for all users (mandatory)
│   ├── Role-based access control
│   └── Regular access reviews
│
├── CC6.2: Authentication
│   ├── Strong password policies
│   ├── SSH key management
│   └── Personal access token rotation
│
├── CC7.1: System Monitoring
│   ├── Audit log collection
│   ├── Audit log retention (180+ days)
│   └── Real-time alerting on security events
│
└── CC9.1: Logical and Physical Access
    ├── Segregation of duties
    ├── No single person can bypass protections
    └── Principle of least privilege

SOC 2 Trust Service Criteria - Availability (A):
├── Source code backup
├── Disaster recovery plan
├── Incident response procedures
└── Change management controls (branch protection)

SOC 2 Trust Service Criteria - Processing Integrity (PI):
├── Code review requirements
├── Automated testing
├── Security scanning (SAST)
└── Dependency vulnerability scanning

SOC 2 Trust Service Criteria - Confidentiality (C):
├── Secret scanning with push protection
├── Encrypted data transmission (HTTPS/SSH)
├── Audit logging with encryption
└── Limited access to sensitive code paths

SOC 2 Trust Service Criteria - Privacy (P):
├── Data handling policies
├── PII identification and protection
└── GDPR compliance for data subjects
```

#### GitHub Configuration for SOC 2

```yaml
Organization Level:
  authentication:
    - mfa-required: true
    - sso-saml-enabled: true
    - ip-allow-list: ["10.0.0.0/8", "203.0.113.0/24"]

  access-control:
    - role-based-access: true
    - minimum-permission-principle: true
    - quarterly-access-reviews: true

  audit-logging:
    - audit-log-streaming: enabled
    - stream-destination: "aws-s3"
    - retention-days: 365
    - notification-on-access: true

Repository Level:
  branch-protection:
    - ruleset-enforcement: "active"
    - min-approvals: 2
    - require-codeowners: true

  secret-protection:
    - push-protection: enabled
    - secret-scanning: enabled
    - custom-patterns: enabled

  code-security:
    - code-scanning: enabled
    - dependabot: enabled
    - dependency-updates: automated
```

### 8.2 HIPAA Compliance

```
HIPAA Security Rule (45 CFR Part 164 Subpart C):

Administrative Safeguards (45 CFR § 164.308):
├── Workforce Security
│   ├── Authorization/supervision procedures
│   ├── Access management (GitHub roles)
│   └── Security awareness training
│
├── Information Access Management
│   ├── Access controls based on role
│   ├── Default access to minimum necessary
│   └── Audit controls
│
├── Security Awareness and Training
│   └── Training on GitHub security best practices
│
└── Security Management Process
    ├── Risk analysis and assessment
    ├── Incident response plan
    └── Sanction policy for violations

Technical Safeguards (45 CFR § 164.312):
├── Access Controls
│   ├── MFA required
│   ├── Encrypted authentication
│   └── Audit controls for account activity
│
├── Audit Controls (GitHub Audit Logs)
│   ├── Comprehensive logging
│   ├── Non-repudiation (tie actions to users)
│   └── Log retention: 6+ years
│
├── Integrity Controls
│   ├── Code review (branch protection)
│   ├── Signed commits
│   └── Change control procedures
│
└── Transmission Security
    ├── HTTPS for all connections
    ├── SSH key authentication
    └── VPN for administrative access

Physical Safeguards (45 CFR § 164.310):
├── GitHub uses data centers with physical security
├── Audit facilities access
└── GitHub SOC 2 report demonstrates compliance

Organizational Safeguards (45 CFR § 164.314):
├── Business Associate Agreements (BAA)
├── Subcontractor management
└── Documentation of security procedures
```

#### HIPAA Configuration

```yaml
Protected Health Information (PHI) Protection:

Code Repository:
  - branch-protection:
      min-approvals: 2
      require-signed-commits: true
      require-security-review: true

  - secret-protection:
      push-protection: enabled
      patterns: [phi-ssn, phi-medical-record, phi-dob]

  - data-classification:
      tags: [hipaa-regulated, phi-handling]

Access Control:
  - mfa-required: true
  - access-review-frequency: quarterly
  - terminated-user-removal: immediate

Audit Logging:
  - streaming-enabled: true
  - stream-destination: secure-siem
  - retention-days: 2190  # 6 years
  - tamper-proof: true

Encryption:
  - data-in-transit: TLS 1.2+
  - authentication: SSH or HTTPS
  - audit-logs: encrypted-at-rest
```

### 8.3 PCI DSS Compliance (for payment processing)

```
PCI DSS v4.0 Key Requirements for GitHub:

Requirement 1: Install and maintain network security
├── GitHub: Behind AWS firewall
├── Recommendation: Use GitHub Enterprise Server in secure VPC
└── Network segmentation for development

Requirement 2: Apply secure defaults
├── MFA enforced
├── Default deny access policy
└── All default credentials changed

Requirement 3: Protect stored cardholder data
├── Do not commit payment card data to repositories
├── Use GitHub secret scanning to detect card data
└── Push protection blocks common payment patterns

Requirement 6: Develop and maintain secure code
├── Code scanning (CodeQL) for vulnerabilities
├── Dependency scanning (Dependabot)
├── Branch protection with status checks
├── Signed commits for audit trail

Requirement 7: Restrict access by business need
├── Role-based access control
├── Branch protection by team
├── Audit logging of all access
└── Quarterly access reviews

Requirement 10: Log and monitor access to cardholder data
├── Comprehensive audit logging
├── 12-month log retention
├── Log file integrity checks
└── Regular log reviews
```

### 8.4 ISO 27001 Alignment

```
ISO 27001:2022 Controls Alignment:

A.5.1 Policies for information security
├── GitHub security policy documentation
├── Branch protection policies as code
└── Compliance baseline in rulesets

A.6.1 Information security roles and responsibilities
├── Define roles and permissions in GitHub
├── Document bypass approval workflows
└── Security team membership

A.7.1 Human resource security
├── MFA for all employees
├── Secure onboarding process
├── Secure offboarding (access removal)

A.8.1 Information classification
├── Classify repositories and branches
├── Team-based review for sensitive code
└── Different protection levels

A.8.2 Asset management
├── Inventory of critical repositories
├── Change tracking via audit logs
└── Backup and recovery procedures

A.9.1 Access control
├── Role-based access control
├── Principle of least privilege
├── Regular access reviews

A.9.2 User access management
├── User provisioning via SSO/SAML
├── Access termination procedures
└── Privileged account management

A.12.4 Event logging
├── Comprehensive audit logging
├── Audit log streaming to secure storage
├── Log retention (1+ years)

A.12.6 Capacity management
├── GitHub Actions runner limits
├── API rate limit management
└── Storage quota monitoring

A.14.1 Information security incident management
├── Incident response procedures
├── Audit logs for investigation
└── Regular incident drills
```

---

## 9. Implementation Checklist

### Phase 1: Foundation (Week 1-2)

```
[ ] Enable organization-wide MFA enforcement
[ ] Configure SSO/SAML for GitHub Enterprise
[ ] Enable audit log streaming to S3/SIEM
[ ] Create GitHub teams matching organization structure
[ ] Review and document bypass approval process
[ ] Set up GitHub organization webhooks for monitoring
```

### Phase 2: Repository Protection (Week 3-4)

```
[ ] Create organization-level rulesets for:
    [ ] Main/production branches (3 approvals)
    [ ] Release branches (2 approvals)
    [ ] Development branches (1 approval)
[ ] Configure ruleset team-based reviews
[ ] Enable push protection with custom patterns
[ ] Set up required deployment environments
[ ] Configure merge queue with merge_group trigger
```

### Phase 3: Security Scanning (Week 5-6)

```
[ ] Enable code scanning (CodeQL)
[ ] Enable secret scanning with push protection
[ ] Enable Dependabot for dependency updates
[ ] Configure custom secret patterns
[ ] Set up push protection bypass workflow
[ ] Create GitHub Actions for security scanning
```

### Phase 4: Compliance & Audit (Week 7-8)

```
[ ] Configure audit log streaming with encryption
[ ] Set up SIEM integration (Splunk/Datadog)
[ ] Create audit log analysis queries
[ ] Document all security policies in GitHub
[ ] Set up automatic compliance reports
[ ] Schedule monthly compliance audits
[ ] Create incident response procedures
```

### Phase 5: Validation & Testing (Week 9-10)

```
[ ] Test branch protection on main branch
[ ] Verify all status checks pass before merge
[ ] Test push protection with sample secrets
[ ] Verify deployment environment enforcement
[ ] Test bypass permission workflow
[ ] Validate audit log captures all events
[ ] Perform security incident simulation
[ ] Generate SOC 2 compliance report
```

---

## 10. Monitoring & Maintenance

### 10.1 Regular Reviews

```
Weekly:
- Review audit logs for suspicious activity
- Check failed status checks in CI/CD
- Monitor GitHub Actions usage

Monthly:
- Access review (who has what permissions)
- Dependency vulnerability assessment
- Merge queue performance analysis
- Bypass usage review

Quarterly:
- Complete access review and revocation
- Update security policies
- Test disaster recovery procedures
- Compliance audit

Annually:
- Security architecture review
- Penetration testing
- Policy refresh and training
- External audit (SOC 2)
```

### 10.2 Key Metrics

```
Monitoring Metrics:
- Bypass usage rate (should be low)
- Failed status checks (track trends)
- Average review time per PR
- Security findings by type
- Deployment success rate
- Audit log ingestion rate
```

### 10.3 Automation

```yaml
# GitHub Actions: Daily Security Report
name: Daily Security Report
schedule:
  - cron: '0 8 * * 1-5'  # 8 AM weekdays

jobs:
  security-report:
    runs-on: ubuntu-latest
    steps:
      - name: Check failed status checks
        uses: github/script@v7

      - name: Review new vulnerabilities
        uses: github/script@v7

      - name: Audit log analysis
        uses: github/script@v7

      - name: Send Slack notification
        uses: slackapi/slack-github-action@v1
```

---

## 11. Quick Reference: Configuration Examples

### Repository Ruleset JSON

```json
{
  "name": "Enterprise Production Protection",
  "description": "Multi-layer protection for production branch",
  "enforcement": "active",
  "target": {
    "branch_name_pattern": {
      "operator": "starts_with",
      "pattern": "main"
    }
  },
  "rules": {
    "require_pull_request": {
      "required_approving_review_count": 3,
      "require_code_owner_review": true,
      "dismiss_stale_reviews_on_push": true,
      "require_last_push_approval": false
    },
    "require_status_checks": {
      "strict": true,
      "required_status_checks": [
        "build",
        "test",
        "security-scan",
        "dependency-check"
      ]
    },
    "require_signed_commits": true,
    "require_linear_history": true,
    "restrict_deletions": true,
    "restrict_creations": false
  },
  "bypass_actors": [
    {
      "actor_type": "Team",
      "actor_id": "release-team",
      "bypass_mode": "always"
    },
    {
      "actor_type": "OrganizationAdmin",
      "bypass_mode": "always_allow_bypass_by_admins"
    }
  ]
}
```

### GitHub Actions Workflow with All Security Features

```yaml
name: CI/CD Pipeline with Security

on:
  push:
    branches: [main, develop, 'release-*']
  pull_request:
    branches: [main, develop, 'release-*']
  merge_group:
    branches: [main]

permissions:
  contents: read
  security-events: write
  deployments: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Run tests
        run: npm test -- --coverage

      - name: Linting
        run: npm run lint

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v2
        with:
          languages: ['javascript']

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v2

      - name: Secret scanning
        uses: github/secret-scanning-action@v1

      - name: Dependency check (Dependabot)
        uses: github/dependency-check@v1

  deploy:
    needs: [build, security]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://api.company.com

    steps:
      - uses: actions/checkout@v4

      - name: Deploy to staging
        run: ./deploy.sh staging

      - name: Deploy to production
        run: ./deploy.sh production

      - name: Notify on completion
        if: always()
        uses: slackapi/slack-github-action@v1
```

---

## 12. References & Additional Resources

### Official GitHub Documentation
- [GitHub Rulesets Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [Push Protection](https://docs.github.com/en/code-security/secret-scanning/introduction/about-push-protection)
- [Audit Log for Enterprise](https://docs.github.com/en/enterprise-cloud@latest/admin/concepts/security-and-compliance/audit-log-for-an-enterprise)
- [Security Hardening for Enterprise](https://docs.github.com/en/enterprise-cloud@latest/admin/configuring-settings/hardening-security-for-your-enterprise)

### Compliance Frameworks
- [SOC 2 Type II Compliance Guide](https://delve.co/blog/github-your-soc-2-compliance-configuration-checklist)
- [ISO 27001:2022 Standard](https://www.iso.org/standard/27001)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [PCI DSS v4.0 Requirements](https://www.pcisecuritystandards.org/)
- [HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html)

### GitHub Blog & Updates
- [GitHub Changelog - Latest Updates](https://github.blog/changelog/)
- [GitHub Security Blog](https://github.blog/enterprise-software/secure-software-development/)
- [GitHub Well-Architected Framework](https://wellarchitected.github.com/)

---

## Appendix: Glossary

```
Term                          Definition
----                          ----------
Branch Protection Rule        Legacy feature for protecting branches
Ruleset                       Modern, scalable replacement for branch protection
Push Protection               Secret scanning feature blocking secret commits
Secret Scanning               Automated detection of exposed credentials
CODEOWNERS                    File to designate code ownership for review
Status Checks                 Automated tests/scans that must pass
Merge Queue                   Serializes PRs for guaranteed passing status
Bypass Permission             Ability to override branch protection rules
Audit Log                     Complete record of all organizational actions
Audit Log Streaming           Real-time forwarding of logs to external system
Deployment Protection Rule    Custom approval workflow for deployments
GitHub App                    External application with GitHub integration
SAML/SSO                      Enterprise authentication integration
MFA                           Multi-Factor Authentication
SOC 2                         Security, Availability, Processing Integrity, Confidentiality, Privacy audit
HIPAA                         Health Insurance Portability and Accountability Act
PCI DSS                       Payment Card Industry Data Security Standard
SIEM                          Security Information & Event Management system
```

---

**Document Version:** 2.0 (November 2025)
**Last Updated:** 2025-11-09
**Status:** Enterprise Grade
**Compliance Level:** SOC 2, HIPAA, PCI DSS, ISO 27001
