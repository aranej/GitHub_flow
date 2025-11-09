# GitHub Security Scanning Implementation Guide (2025)

A comprehensive guide for implementing and managing GitHub's integrated security scanning tools for 2025.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Detailed Setup](#detailed-setup)
3. [Configuration Examples](#configuration-examples)
4. [Best Practices](#best-practices)
5. [Troubleshooting](#troubleshooting)
6. [Advanced Features](#advanced-features)
7. [Integration Examples](#integration-examples)

---

## Quick Start

### 1. Enable GitHub Advanced Security (GAS)

**For Repository Admins:**

1. Go to Repository > Settings > Security & Analysis
2. Enable:
   - Code Scanning (CodeQL) - Free for public repos
   - Secret Scanning - Free for public repos
   - Dependabot version updates
   - Dependabot security updates

**Cost Note (2025):**
- **Free Tier**: CodeQL, Secret Scanning on public repos
- **GitHub Advanced Security (GAS)**: $45,000/year for enterprise
  - Includes private repo advanced features
  - Suggested for 5+ private repos

### 2. Configure Dependabot

Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
```

### 3. Enable CodeQL

Create `.github/workflows/codeql.yml` - Use the template in this repository

### 4. Configure Secret Scanning

Dashboard > Settings > Code Security & Analysis > Secret Scanning > Enable Push Protection

---

## Detailed Setup

### Phase 1: Initial Assessment (Week 1)

**Activities:**
- Review current security tooling
- Identify critical applications
- Establish baseline metrics
- Define security policies

**Checklist:**
- [ ] Catalog all repositories
- [ ] Identify languages used
- [ ] Document current security tools
- [ ] Set up CODEOWNERS file

### Phase 2: Basic Implementation (Week 2-3)

**Activities:**
- Enable GitHub Advanced Security
- Configure Dependabot
- Set up CodeQL scanning
- Enable secret scanning

**Files to Create:**
- `.github/dependabot.yml`
- `.github/codeql-config.yml`
- `.github/secret_scanning.yml`
- `.github/workflows/codeql-analysis.yml`
- `.github/CODEOWNERS`

### Phase 3: Advanced Configuration (Week 4-6)

**Activities:**
- Create custom CodeQL queries
- Set up security policies
- Configure automated remediation
- Integrate with incident management

**Files to Create:**
- `.github/codeql/custom-queries/`
- `.github/SECURITY.md`
- `.github/workflows/dependency-review.yml`
- `.github/workflows/security-orchestration.yml`

### Phase 4: Hardening & Monitoring (Week 7+)

**Activities:**
- Implement branch protection rules
- Set up security dashboards
- Create incident response procedures
- Conduct security audits

---

## Configuration Examples

### Example 1: NodeJS Project Security Setup

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "03:00"
    reviewers:
      - "security-team"
    labels:
      - "dependencies"
    groups:
      production:
        dependency-types: ["production"]
      dev:
        dependency-types: ["dev"]
```

**Workflow in `.github/workflows/codeql-analysis.yml`:**
- Initialize CodeQL with JavaScript
- Install dependencies via `npm ci`
- Run CodeQL analysis
- Upload SARIF results

**Branch Protection Rule:**
```
- Require CodeQL check to pass
- Require Dependency Review to pass
- Dismiss stale reviews when new commits pushed
- Require branches to be up to date before merging
```

### Example 2: Python/Django Application

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "daily"
      time: "04:00"
    allow:
      - dependency-type: "production"
      - dependency-type: "dev"
    ignore:
      - dependency-name: "django"
        versions: ["<4.0"]

  - package-ecosystem: "pip"
    directory: "/requirements-dev"
    schedule:
      interval: "weekly"
```

**CodeQL Configuration for Python:**
```yaml
# .github/codeql-config.yml
queries:
  - uses: security-and-quality
packs:
  github/codeql-python:
    version: 3.2.0
```

### Example 3: Multi-Language Monorepo

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/frontend"
    schedule:
      interval: "weekly"

  - package-ecosystem: "pip"
    directory: "/backend"
    schedule:
      interval: "weekly"

  - package-ecosystem: "maven"
    directory: "/services/java"
    schedule:
      interval: "weekly"

  - package-ecosystem: "docker"
    directory: "/docker"
    schedule:
      interval: "weekly"
```

### Example 4: Secret Scanning with Custom Patterns

```yaml
# .github/secret_scanning.yml
push-protection:
  enabled: true
  bypass-allowed: true
  bypass:
    reviewers:
      - "security-team"
    expiration: 24

custom-patterns:
  - name: "api-key-pattern"
    pattern: "api_key_[A-Za-z0-9]{32}"
    secret_group: 1
    validity-checks:
      enabled: true

excluded-directories:
  - "tests/**"
  - "docs/**"
  - "fixtures/**"
```

---

## Best Practices

### 1. Code Scanning (CodeQL)

**✅ DO:**
- Run CodeQL on every push to main/develop
- Use security-and-quality query suite
- Pin CodeQL action to specific version
- Upload SARIF results automatically
- Address high/critical alerts before merge

**❌ DON'T:**
- Disable security checks without justification
- Merge PRs with high/critical CodeQL findings
- Use overly broad exclusion patterns
- Change query configuration without review

**Implementation:**
```yaml
# In workflow file
- uses: github/codeql-action/analyze@v3.26.11
  with:
    category: "/language:javascript"
    wait-for-processing: true
```

### 2. Dependency Management

**✅ DO:**
- Review Dependabot PRs daily
- Test security patches before merge
- Group related dependencies
- Track update trends
- Enable security updates immediately

**❌ DON'T:**
- Auto-merge all Dependabot PRs without testing
- Ignore security updates
- Keep dependencies outdated
- Use deprecated packages

**Update Schedule:**
```
Security Updates: Immediate
Major Updates: Weekly
Minor Updates: Monthly
```

### 3. Secret Scanning

**✅ DO:**
- Enable push protection on all repos
- Review bypass requests
- Rotate compromised secrets immediately
- Exclude only legitimate test fixtures
- Enable AI-powered detection (2025)

**❌ DON'T:**
- Commit credentials of any kind
- Bypass push protection without review
- Use real secrets in tests/docs
- Ignore secret scanning alerts

**Protected Secret Types (45+ in 2025):**
- GitHub tokens (ghp_, ghu_, ghs_, gho_)
- AWS access keys
- Google API keys
- Slack webhooks
- Database credentials
- API tokens

### 4. Security Policies & Rules

**Branch Protection Configuration:**

```bash
# Require these checks pass:
- CodeQL scanning
- Dependency review
- All status checks
- Dismiss stale reviews: Yes
- Require up-to-date branches: Yes
```

**CODEOWNERS Setup:**

```
# .github/CODEOWNERS
* @security-team
src/auth/ @security-team @auth-team
src/api/ @security-team @api-team
Dockerfile @security-team @devops-team
dependabot.yml @security-team
.github/workflows/ @security-team
```

### 5. Vulnerability Response SLA

| Severity | SLA | Action |
|----------|-----|--------|
| Critical | 24h | Immediate patch/workaround |
| High | 48-72h | Planned patch |
| Medium | 2 weeks | Next release cycle |
| Low | 30 days | Monitor and plan |

**Response Workflow:**

1. **Detection** → Automated scan (within minutes)
2. **Alert** → Team notification (immediate)
3. **Triage** → Assess impact (within SLA)
4. **Remediation** → Apply fix (within SLA)
5. **Verification** → Confirm fix (same day)
6. **Reporting** → Document incident (within 3 days)

---

## Troubleshooting

### Issue 1: CodeQL Timeout

**Symptom:** CodeQL analysis exceeds 120-minute timeout

**Solutions:**
```yaml
# Increase timeout in workflow
timeout-minutes: 240

# Or increase build-specific timeout
- uses: github/codeql-action/autobuild@v3
  timeout-minutes: 120

# Or reduce database size
path-ignore:
  - "**/node_modules/**"
  - "**/vendor/**"
  - "**/dist/**"
```

### Issue 2: High False Positive Rate

**Symptom:** Too many low-confidence alerts from CodeQL

**Solutions:**
```yaml
# In codeql-config.yml
filters:
  min-precision: "high"  # Instead of "low"

# Or disable specific noisy queries
disable-specific-queries:
  - "js/sql-injection"  # If causing too many FPs
```

### Issue 3: Dependabot Rate Limiting

**Symptom:** Dependabot PRs hitting rate limits

**Solutions:**
```yaml
# Reduce open PR limit
open-pull-requests-limit: 5  # Default is 10

# Group dependencies
groups:
  production:
    dependency-types: ["production"]
  dev:
    dependency-types: ["dev"]

# Less frequent updates
schedule:
  interval: "monthly"  # Instead of weekly
```

### Issue 4: Secret Scanning False Positives

**Symptom:** Legitimate strings flagged as secrets

**Solutions:**
```yaml
# Exclude test directories
excluded-directories:
  - "tests/**"
  - "fixtures/**"

# Increase AI confidence threshold (2025)
ai-detection:
  confidence-threshold: 0.9  # Stricter

# Customize patterns
custom-patterns:
  - pattern: "my_internal_pattern"
    validity-checks:
      enabled: true
```

### Issue 5: GitHub Actions Permissions

**Symptom:** Workflow fails with permission denied

**Solution:**
```yaml
# Set minimal permissions
permissions:
  contents: read
  security-events: write
  pull-requests: write

# Or use environment-specific permissions
jobs:
  scan:
    permissions:
      contents: read
      security-events: write
```

---

## Advanced Features (2025)

### 1. AI-Enhanced Secret Detection

**Capabilities:**
- Generic password detection using ML
- Context-aware analysis
- Significantly reduced false positives
- Extended metadata for findings

**Configuration:**
```yaml
ai-detection:
  generic-passwords: true
  contextual-analysis: true
  confidence-threshold: 0.85
  false-positive-reduction: true
  extended-metadata-checks: true
```

### 2. Custom CodeQL Queries

**Creating Custom Queries:**

```ql
// queries/hardcoded-secrets.ql
import cpp

from StringLiteral str
where str.getValue().matches("%password%") or
      str.getValue().matches("%key%") or
      str.getValue().matches("%token%")
select str, "Potential hardcoded credential"
```

**Publishing Custom Query Pack:**

```yaml
# qlpack.yml
name: myorg/custom-security-queries
version: 1.0.0
description: Organization-specific security queries
requires: codeql/cpp-queries
```

**Using in Workflow:**
```yaml
- uses: github/codeql-action/init@v3
  with:
    packs: ghcr.io/myorg/custom-security-queries:latest
```

### 3. Supply Chain Security

**SBOM Generation:**
```bash
# CycloneDX format (standard)
cyclonedx-bom -o sbom.xml

# Or with npm
cyclonedx-npm -o sbom-npm.xml

# GitHub SBOM API
GET /repos/{owner}/{repo}/dependency-graph/sbom
```

**Dependency Graph Integration:**
```bash
# View dependency tree
curl -H "Authorization: token TOKEN" \
  "https://api.github.com/repos/owner/repo/dependency-graph/snapshots"
```

### 4. AI-Powered Autofixes

**Copilot-Assisted Remediation:**
```yaml
# GitHub Copilot for enterprise customers
# Can auto-generate fixes for CodeQL findings

steps:
  - uses: github/copilot-code-scanning-action@v1
    with:
      sarif-file: "results/javascript.sarif"
      language: javascript
```

### 5. Compliance & Audit

**Automated Compliance Checks:**
```yaml
- name: OWASP Top 10 Coverage
  run: |
    # Verify all OWASP categories covered
    # Generate compliance report

- name: CIS Benchmark Check
  run: |
    # Check Docker CIS compliance
    # Check Kubernetes CIS compliance
```

---

## Integration Examples

### Integration 1: Slack Notifications

```yaml
# .github/workflows/security-alerts.yml
- name: Send Slack Alert
  uses: slackapi/slack-github-action@v1.26.0
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
    payload: |
      {
        "text": "Security Alert",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Critical security issue found in ${{ github.repository }}"
            }
          }
        ]
      }
```

### Integration 2: Jira Ticket Creation

```yaml
- name: Create Jira Ticket
  uses: actions/github-script@v7
  with:
    script: |
      const jira = require('jira-client');
      const client = new jira({
        protocol: 'https',
        host: 'jira.example.com',
        username: process.env.JIRA_USER,
        password: process.env.JIRA_PASSWORD,
        apiVersion: '2'
      });

      client.addNewIssue({
        fields: {
          project: {key: 'SEC'},
          summary: 'Critical vulnerability found',
          issuetype: {name: 'Bug'},
          priority: {name: 'Critical'}
        }
      });
```

### Integration 3: Snyk Integration (Additional SCA)

```yaml
- name: Run Snyk Security Scan
  uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    args: --severity-threshold=high
```

### Integration 4: PagerDuty Escalation

```yaml
- name: Create PagerDuty Incident
  if: github.event_name == 'workflow_dispatch'
  uses: actions/github-script@v7
  with:
    script: |
      const fetch = require('node-fetch');
      await fetch('https://api.pagerduty.com/incidents', {
        method: 'POST',
        headers: {
          'Authorization': `Token token=${process.env.PD_TOKEN}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          incident: {
            type: 'incident',
            title: 'Critical Security Finding',
            urgency: 'high',
            body: {
              type: 'incident_body',
              details: 'Security scan found critical issue'
            }
          }
        })
      });
```

---

## Metrics & Reporting

### Key Metrics to Track

1. **Velocity Metrics:**
   - Mean Time to Remediation (MTTR)
   - Alert closure rate
   - Fix success rate

2. **Coverage Metrics:**
   - CodeQL coverage (% of codebase)
   - Dependency coverage (# tracked)
   - Secret scanning effectiveness

3. **Risk Metrics:**
   - Open high/critical alerts
   - SLA compliance rate
   - Vulnerability trend

4. **Process Metrics:**
   - False positive ratio
   - Average time to triage
   - Automation success rate

### Dashboard Example

```markdown
## Security Dashboard (Weekly Report)

### Vulnerabilities
- Critical: 0 (↓)
- High: 2 (→)
- Medium: 8 (↑2)
- Low: 15 (↓3)

### Coverage
- Code Scanning: 87%
- Dependency Review: 100%
- Secret Scanning: 100%

### Performance
- MTTR (High): 36 hours (↓6h)
- SLA Compliance: 95% (↑2%)
- False Positive Rate: 3.2% (↓0.5%)

### Trend
- Issues trending: Down
- Coverage trending: Up
- MTTR trending: Improving
```

---

## Appendix

### A. Environment Variables

```bash
# CodeQL Configuration
CODEQL_THREADS=4
CODEQL_MEMORY=2048
CODEQL_QUERY_EVAL_TIMEOUT=1800

# GitHub API
GITHUB_TOKEN
GITHUB_REPOSITORY

# External Services
SLACK_WEBHOOK_URL
JIRA_TOKEN
SNYK_TOKEN
```

### B. File Structure

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
└── IMPLEMENTATION_GUIDE.md

SECURITY.md
CODE_OF_CONDUCT.md
```

### C. Useful Resources

- [GitHub Advanced Security Docs](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security)
- [CodeQL Documentation](https://codeql.github.com)
- [Dependabot Docs](https://docs.github.com/en/code-security/dependabot)
- [OWASP Top 10](https://owasp.org/Top10/)
- [CWE Top 25](https://cwe.mitre.org/top25/)

---

**Document Version:** 2.0
**Last Updated:** November 2025
**Maintained By:** Security Team
**Review Cycle:** Quarterly
