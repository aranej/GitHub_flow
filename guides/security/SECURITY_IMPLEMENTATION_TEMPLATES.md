# GitHub Enterprise Security - Implementation Templates & Policies

## Ready-to-Use Configuration Templates

---

## 1. Organization Security Policy Template

### File: `.github/SECURITY_POLICY.md`

```markdown
# Security Policy

## Reporting Security Vulnerabilities

If you discover a security vulnerability, please email security@company.com
instead of using the public issue tracker. Include:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any proposed solutions

## Security Requirements for All Contributors

### Authentication
- MFA (Multi-Factor Authentication) is required
- SSH keys must have strong passphrases
- Personal access tokens expire after 30 days of inactivity

### Code Review
- All code changes require pull requests
- Minimum 2 approvals required for main branch
- Code owners must review sensitive paths
- All commits must be signed

### Secrets & Credentials
- Never commit secrets, API keys, or credentials
- Use GitHub Secrets for CI/CD environments
- Enable push protection to prevent accidental commits
- Rotate credentials after any suspected compromise

### Branch Protection
- Force push disabled
- Branch deletion disabled
- All status checks must pass
- Linear history required

## Compliance & Audit

- All repository activity is logged and audited
- Audit logs retained for 180+ days minimum
- Regular security assessments performed
- Quarterly access reviews conducted

## Security Questions?

Contact: security@company.com
Slack: #security-team
```

---

## 2. Ruleset Configuration - Terraform

### File: `terraform/github_rulesets.tf`

```hcl
# Terraform configuration for GitHub Enterprise Rulesets
# Requires: GitHub provider v6.0+
# Usage: terraform apply -target=github_repository_ruleset

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = var.github_organization
  token = var.github_token
}

# Variables
variable "github_organization" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}

# Production Branch Ruleset
resource "github_repository_ruleset" "production_protection" {
  for_each = toset(var.production_repositories)

  repository   = each.key
  name         = "Production Protection"
  target       = "branch"
  enforcement  = "active"

  conditions {
    ref_name {
      exclude = []
      include = ["refs/heads/main"]
    }
  }

  rules {
    require_pull_request {
      required_approving_review_count = 3
      require_code_owner_review       = true
      dismiss_stale_reviews_on_push   = true
      require_last_push_approval      = false
    }

    require_status_checks {
      strict_required_status_checks_policy = true
      required_status_checks = [
        "build",
        "test",
        "security-scan",
        "dependency-check"
      ]
    }

    require_signed_commits = true
    require_linear_history = true
    restrict_deletions     = true
  }

  bypass_actors {
    actor_id    = github_team.release_team.id
    actor_type  = "Team"
    bypass_mode = "always"
  }

  bypass_actors {
    actor_id    = github_team.devops.id
    actor_type  = "Team"
    bypass_mode = "always"
  }
}

# Release Branch Ruleset
resource "github_repository_ruleset" "release_protection" {
  for_each = toset(var.release_repositories)

  repository   = each.key
  name         = "Release Protection"
  target       = "branch"
  enforcement  = "active"

  conditions {
    ref_name {
      exclude = []
      include = ["refs/heads/release-*"]
    }
  }

  rules {
    require_pull_request {
      required_approving_review_count = 2
      require_code_owner_review       = true
      dismiss_stale_reviews_on_push   = true
    }

    require_status_checks {
      strict_required_status_checks_policy = true
      required_status_checks = [
        "build",
        "test",
        "release-validation"
      ]
    }

    require_signed_commits = true
    require_linear_history = true
    restrict_deletions     = true
  }

  bypass_actors {
    actor_id    = github_team.release_team.id
    actor_type  = "Team"
    bypass_mode = "always"
  }
}

# Development Branch Ruleset
resource "github_repository_ruleset" "develop_protection" {
  for_each = toset(var.development_repositories)

  repository   = each.key
  name         = "Development Protection"
  target       = "branch"
  enforcement  = "active"

  conditions {
    ref_name {
      exclude = []
      include = ["refs/heads/develop"]
    }
  }

  rules {
    require_pull_request {
      required_approving_review_count = 1
      dismiss_stale_reviews_on_push   = true
    }

    require_status_checks {
      strict_required_status_checks_policy = false
      required_status_checks = [
        "build",
        "test"
      ]
    }
  }
}

# Reference GitHub Teams
data "github_team" "release_team" {
  slug = "release-team"
}

data "github_team" "devops" {
  slug = "devops"
}

# Outputs
output "production_ruleset_id" {
  value = {
    for repo, ruleset in github_repository_ruleset.production_protection :
    repo => ruleset.id
  }
}
```

---

## 3. GitHub Actions: Security Scanning Workflow

### File: `.github/workflows/security.yml`

```yaml
name: Security Scanning & Code Quality

on:
  push:
    branches:
      - main
      - develop
      - 'release-*'
  pull_request:
    branches:
      - main
      - develop
      - 'release-*'
  schedule:
    - cron: '0 2 * * 0'  # Weekly security scan

permissions:
  contents: read
  security-events: write
  pull-requests: write
  checks: write

jobs:
  # Code Scanning with CodeQL
  code-scan:
    name: CodeQL Analysis
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        language: ['javascript', 'python']
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v2
        with:
          languages: ${{ matrix.language }}
          queries: security-and-quality

      - name: Autobuild
        uses: github/codeql-action/autobuild@v2

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v2
        with:
          category: /language:${{ matrix.language }}
          upload: true

  # Dependency Scanning
  dependency-check:
    name: Dependency Vulnerability Check
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run Dependabot check
        run: npm audit --audit-level=moderate
        continue-on-error: true

      - name: Comment PR with audit results
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const auditOutput = execSync('npm audit --json',
              { encoding: 'utf-8', stdio: 'pipe' });
            const audit = JSON.parse(auditOutput);

            let comment = '## npm Audit Report\n\n';
            comment += `- **Vulnerabilities:** ${audit.metadata.vulnerabilities.total}\n`;
            comment += `- **Moderate:** ${audit.metadata.vulnerabilities.moderate}\n`;
            comment += `- **High:** ${audit.metadata.vulnerabilities.high}\n`;
            comment += `- **Critical:** ${audit.metadata.vulnerabilities.critical}\n`;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });

  # Secret Scanning
  secret-scan:
    name: Secret Detection
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: TruffleHog Secret Scanning
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD
          extra_args: --debug --only-verified

  # SAST: SonarQube (Optional)
  sonarqube:
    name: SonarQube Analysis
    runs-on: ubuntu-latest
    if: vars.SONAR_ENABLED == 'true'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: SonarQube Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

  # Linting & Code Style
  lint:
    name: Lint & Code Style
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

      - name: Check formatting with Prettier
        run: npm run format:check

  # Security Summary
  security-summary:
    name: Security Summary
    needs: [code-scan, dependency-check, secret-scan, lint]
    runs-on: ubuntu-latest
    if: always()
    steps:
      - name: Check security status
        run: |
          echo "## Security Scan Summary"
          echo "- CodeQL: ${{ needs.code-scan.result }}"
          echo "- Dependencies: ${{ needs.dependency-check.result }}"
          echo "- Secrets: ${{ needs.secret-scan.result }}"
          echo "- Lint: ${{ needs.lint.result }}"

      - name: Fail if security checks failed
        if: |
          needs.code-scan.result == 'failure' ||
          needs.secret-scan.result == 'failure'
        run: exit 1
```

---

## 4. Bypass Request Approval Process

### File: `.github/BYPASS_APPROVAL_POLICY.md`

```markdown
# Branch Protection Bypass Approval Policy

## Purpose
This policy defines when and how to bypass branch protection rules in production environments.

## Authorized Teams
- Release Team (release-team)
- Site Reliability Engineers (devops)
- Security Team (security-team)

## Bypass Scenarios & Requirements

### 1. Emergency Hotfix
**Scenario:** Critical security or stability issue requiring immediate production deployment

**Requirements:**
- Issue severity: Critical (P1) or High (P2)
- Root cause documented
- Fix reviewed by security team
- Minimal scope changes
- Rollback plan documented

**Approval Process:**
1. Security team approval (REQUIRED)
2. On-call engineer approval
3. Post-incident review within 24 hours

**Audit Trail:**
- Bypass request logged with timestamp
- Justification documented in GitHub issue
- Change tracked in SIEM

### 2. Release Deployment
**Scenario:** Scheduled release deployment to production

**Requirements:**
- Release candidate tested in staging/integration
- All PR approvals obtained
- Release notes completed
- Deployment plan documented
- Rollback plan documented

**Approval Process:**
1. Release team lead approval
2. Optional: DevOps review for deployment safety
3. Deployment conducted during change window

### 3. Configuration Update
**Scenario:** Non-code change (infrastructure, configuration)

**Requirements:**
- Change request documentation
- Impact analysis completed
- Testing evidence provided
- Rollback plan documented

**Approval Process:**
1. DevOps approval
2. Owner of affected system approval
3. Infrastructure review (optional)

## Bypass Request Procedure

### Step 1: Create Bypass Request Issue
Create GitHub issue with template:

```
## Bypass Request

### Type
[ ] Emergency Hotfix
[ ] Release Deployment
[ ] Configuration Update
[ ] Other: ___________

### Justification
[Detailed reason for bypass]

### Scope of Changes
[What exactly is changing?]

### Risk Assessment
- Blast radius: [Low/Medium/High]
- Affected users: [Estimated number]
- Rollback difficulty: [Easy/Medium/Hard]

### Approvals Required
- [ ] Security Review: ___________
- [ ] Owner Approval: ___________
- [ ] DevOps Approval: ___________

### Rollback Plan
[Detailed rollback procedure]
```

### Step 2: Security Review
- Security team reviews justification
- Validates scope and impact
- Approves or denies in GitHub issue

### Step 3: Owner Approval
- System owner reviews change
- Confirms rollback plan
- Approves deployment window

### Step 4: Deployment & Audit
- Bypass permission used with justification
- Deployment tracked in logs
- Post-deployment verification completed

### Step 5: Post-Mortem
- Review change results
- Document lessons learned
- Update procedures if needed

## Approval Metrics

**Target Response Time:** 15 minutes
**Average Bypass Rate:** < 2 per month per repository
**Bypass Denial Rate:** < 10% (indicates appropriate policy)

## Escalation Path

1. Request made in GitHub issue
2. Initial review by approver (15 min)
3. Security team review if needed (30 min)
4. Executive approval if required (1-4 hours)
5. Deployment window coordinator final sign-off

## Audit & Monitoring

All bypass requests are:
- Logged in GitHub audit trail
- Streamed to SIEM system
- Reviewed in monthly security reports
- Included in annual compliance audits

## Violations & Consequences

**Unauthorized Bypass:**
- Immediate access revocation
- Security incident investigation
- Compliance report filed
- Training required before reinstatement

**Bypass Used Outside Approved Scenarios:**
- Formal security review
- Manager notification
- Optional disciplinary action
- Policy training required

## Policy Review

This policy is reviewed:
- Quarterly by Security Team
- Annually by Management
- After any security incident
- Upon request of compliance auditors

---

**Last Updated:** 2025-11-09
**Next Review:** 2026-02-09
**Owner:** Security Team
```

---

## 5. Audit Log Analysis Script

### File: `scripts/analyze_audit_logs.py`

```python
#!/usr/bin/env python3
"""
GitHub Enterprise Audit Log Analysis Tool

Purpose: Analyze GitHub audit logs for security and compliance issues
Usage: python3 analyze_audit_logs.py --days 30 --output report.json
"""

import json
import argparse
from datetime import datetime, timedelta
from typing import List, Dict, Any
import requests
from collections import defaultdict

class GitHubAuditAnalyzer:
    def __init__(self, token: str, organization: str):
        self.token = token
        self.organization = organization
        self.base_url = f"https://api.github.com/enterprises/{organization}"
        self.headers = {
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github.v3+json"
        }

    def get_audit_logs(self, days: int = 30) -> List[Dict[str, Any]]:
        """Fetch audit logs for specified number of days"""
        cutoff_date = (datetime.now() - timedelta(days=days)).isoformat()
        url = f"{self.base_url}/audit-log"

        logs = []
        page = 1

        while True:
            params = {
                "created": f">{cutoff_date}",
                "per_page": 100,
                "page": page
            }

            response = requests.get(url, headers=self.headers, params=params)
            response.raise_for_status()

            data = response.json()
            logs.extend(data)

            if len(data) < 100:
                break
            page += 1

        return logs

    def analyze_access_patterns(self, logs: List[Dict]) -> Dict[str, Any]:
        """Analyze user access patterns"""
        access_by_user = defaultdict(int)
        access_by_action = defaultdict(int)
        failed_actions = []

        for log in logs:
            if log.get("action"):
                access_by_action[log["action"]] += 1
                access_by_user[log.get("actor", "unknown")] += 1

                if not log.get("action_success", True):
                    failed_actions.append({
                        "actor": log.get("actor"),
                        "action": log.get("action"),
                        "timestamp": log.get("created_at"),
                        "reason": log.get("result")
                    })

        return {
            "access_by_user": dict(access_by_user),
            "access_by_action": dict(access_by_action),
            "failed_actions": failed_actions
        }

    def detect_suspicious_activity(self, logs: List[Dict]) -> List[Dict[str, Any]]:
        """Detect potentially suspicious activity"""
        suspicious = []

        # Multiple failed login attempts
        failed_logins = defaultdict(int)
        for log in logs:
            if log.get("action") == "user.login" and not log.get("action_success"):
                failed_logins[log.get("actor")] += 1

        for user, count in failed_logins.items():
            if count >= 5:  # 5+ failed attempts
                suspicious.append({
                    "type": "MULTIPLE_FAILED_LOGINS",
                    "user": user,
                    "count": count,
                    "severity": "HIGH"
                })

        # Repository permission changes
        for log in logs:
            if "permission" in log.get("action", "").lower():
                suspicious.append({
                    "type": "PERMISSION_CHANGE",
                    "user": log.get("actor"),
                    "action": log.get("action"),
                    "repository": log.get("repo"),
                    "timestamp": log.get("created_at"),
                    "severity": "MEDIUM"
                })

        # Push to protected branch
        for log in logs:
            if log.get("action") == "push" and log.get("ref").startswith("refs/heads/main"):
                if log.get("bypass_reason"):
                    suspicious.append({
                        "type": "BYPASS_USED",
                        "user": log.get("actor"),
                        "branch": "main",
                        "reason": log.get("bypass_reason"),
                        "timestamp": log.get("created_at"),
                        "severity": "MEDIUM"
                    })

        return suspicious

    def generate_compliance_report(self, logs: List[Dict]) -> Dict[str, Any]:
        """Generate compliance-focused report"""
        return {
            "period": "last_30_days",
            "total_events": len(logs),
            "audit_completeness": self._check_audit_completeness(logs),
            "retention_status": self._check_retention(logs),
            "critical_events": self._find_critical_events(logs),
            "compliance_violations": self._check_violations(logs)
        }

    def _check_audit_completeness(self, logs: List[Dict]) -> Dict[str, Any]:
        """Verify audit log completeness"""
        has_user_actions = any("user" in log.get("action", "") for log in logs)
        has_repo_actions = any("repo" in log.get("action", "") for log in logs)
        has_org_actions = any("org" in log.get("action", "") for log in logs)

        return {
            "has_user_actions": has_user_actions,
            "has_repo_actions": has_repo_actions,
            "has_org_actions": has_org_actions,
            "completeness_percentage": (
                int(has_user_actions) + int(has_repo_actions) + int(has_org_actions)
            ) / 3 * 100
        }

    def _check_retention(self, logs: List[Dict]) -> Dict[str, Any]:
        """Check audit log retention"""
        if not logs:
            return {"status": "INCOMPLETE", "message": "No logs found"}

        oldest_log = min(log.get("created_at", "") for log in logs)
        days_retained = (datetime.now() - datetime.fromisoformat(
            oldest_log.replace("Z", "+00:00")
        )).days

        return {
            "oldest_log_date": oldest_log,
            "days_retained": days_retained,
            "minimum_required": 180,
            "compliance_status": "PASS" if days_retained >= 180 else "FAIL"
        }

    def _find_critical_events(self, logs: List[Dict]) -> List[Dict]:
        """Find critical security events"""
        critical_actions = [
            "org.add_member",
            "org.remove_member",
            "repo.access_granted",
            "repo.access_revoked",
            "org.security_policy_update",
            "team.add_to_repository",
            "team.remove_from_repository"
        ]

        return [log for log in logs if log.get("action") in critical_actions]

    def _check_violations(self, logs: List[Dict]) -> List[Dict]:
        """Check for compliance violations"""
        violations = []

        # Check for unsigned commits
        for log in logs:
            if log.get("action") == "git.push":
                if not log.get("signature"):
                    violations.append({
                        "type": "UNSIGNED_COMMIT",
                        "user": log.get("actor"),
                        "repository": log.get("repo"),
                        "timestamp": log.get("created_at")
                    })

        return violations

    def export_report(self, report: Dict[str, Any], output_file: str):
        """Export report to JSON file"""
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2, default=str)
        print(f"Report exported to {output_file}")


def main():
    parser = argparse.ArgumentParser(
        description="Analyze GitHub Enterprise audit logs"
    )
    parser.add_argument(
        "--token",
        required=True,
        help="GitHub API token with audit log access"
    )
    parser.add_argument(
        "--organization",
        required=True,
        help="Organization to analyze"
    )
    parser.add_argument(
        "--days",
        type=int,
        default=30,
        help="Number of days to analyze (default: 30)"
    )
    parser.add_argument(
        "--output",
        default="audit_report.json",
        help="Output file for report (default: audit_report.json)"
    )

    args = parser.parse_args()

    analyzer = GitHubAuditAnalyzer(args.token, args.organization)

    print(f"Fetching audit logs for {args.organization} (last {args.days} days)...")
    logs = analyzer.get_audit_logs(args.days)
    print(f"Retrieved {len(logs)} audit events")

    print("Analyzing access patterns...")
    access_analysis = analyzer.analyze_access_patterns(logs)

    print("Detecting suspicious activity...")
    suspicious_activity = analyzer.detect_suspicious_activity(logs)

    print("Generating compliance report...")
    compliance_report = analyzer.generate_compliance_report(logs)

    report = {
        "timestamp": datetime.now().isoformat(),
        "organization": args.organization,
        "period_days": args.days,
        "total_events": len(logs),
        "access_analysis": access_analysis,
        "suspicious_activity": suspicious_activity,
        "compliance_report": compliance_report
    }

    analyzer.export_report(report, args.output)

    # Print summary
    print("\n" + "="*60)
    print("AUDIT LOG ANALYSIS SUMMARY")
    print("="*60)
    print(f"Total Events: {len(logs)}")
    print(f"Suspicious Activities: {len(suspicious_activity)}")
    print(f"Compliance Status: {compliance_report['audit_completeness']['completeness_percentage']:.1f}%")
    print(f"Critical Events: {len(compliance_report['critical_events'])}")
    print("="*60)


if __name__ == "__main__":
    main()
```

---

## 6. Security Incident Response Plan

### File: `.github/INCIDENT_RESPONSE.md`

```markdown
# Security Incident Response Plan

## Quick Response Checklist

**Upon discovering potential security incident:**

```
IMMEDIATE ACTIONS (0-15 minutes):
[ ] Declare security incident in #security-team Slack channel
[ ] Identify: what, when, who, where, impact
[ ] Notify incident commander
[ ] Preserve evidence (don't delete)
[ ] Check GitHub audit logs for related activity
[ ] Review affected repositories for unauthorized changes

CONTAINMENT (15-60 minutes):
[ ] Rotate exposed credentials/secrets
[ ] Lock affected user accounts if necessary
[ ] Revert unauthorized commits
[ ] Disable GitHub Apps with potential exposure
[ ] Notify affected users if data exposed

INVESTIGATION (1-24 hours):
[ ] Timeline of events from audit logs
[ ] Root cause analysis
[ ] Extent of compromise
[ ] Data exposure assessment
[ ] Compliance notification requirements

RECOVERY (24-72 hours):
[ ] Patch vulnerabilities
[ ] Update credentials
[ ] Restore from backups if necessary
[ ] Verify integrity of codebase
[ ] Reauthorize users/apps

DOCUMENTATION (72+ hours):
[ ] Incident report
[ ] Timeline
[ ] Root cause
[ ] Remediation steps
[ ] Process improvements
```

## Common Incident Scenarios

### Scenario 1: Credential Exposed in Commit

**Detection:**
- Push protection blocks push with exposed secret
- Secret scanning alert triggered
- Developer reports accidental commit

**Response:**
1. **Immediately:**
   - Rotate exposed credential
   - Check credential usage in past 24 hours
   - Force password/token reset if applicable

2. **Investigation:**
   - Search commit history for exposure window
   - Check if credential was used from unauthorized location
   - Review GitHub audit logs for unusual activity

3. **Remediation:**
   - Remove secret from repository history
   - Rewrite commit history if necessary
   - Force push protection bypass justification

4. **Documentation:**
   - Update secret rotation procedures
   - Add credential to custom push protection patterns

### Scenario 2: Unauthorized Repository Access

**Detection:**
- Audit log shows permission grant to unknown user
- Suspicious push from unauthorized account
- Access review identifies unexpected permissions

**Response:**
1. **Immediately:**
   - Revoke repository access
   - Reset user credentials
   - Review recent commits/pushes

2. **Investigation:**
   - How did they gain access?
   - What changes did they make?
   - Were they logged in elsewhere?
   - Check for account compromise

3. **Remediation:**
   - Force password reset
   - Invalidate all sessions
   - Revert unauthorized changes
   - Enable enhanced monitoring on account

4. **Documentation:**
   - Compliance notification if required
   - Access control improvements
   - Audit log retention extension

### Scenario 3: Malicious Code Merged to Main

**Detection:**
- Code review process failed
- Malicious code reached production
- User reports unexpected behavior
- Security scanning detects malicious patterns

**Response:**
1. **Immediate Containment:**
   - Revert merge commit
   - Notify affected users
   - Check production systems

2. **Investigation:**
   - How did malicious code pass reviews?
   - Where did it come from?
   - What damage was caused?
   - Check other contributions from author

3. **Remediation:**
   - Disable compromised user account
   - Security review of approval process
   - Increase review requirements
   - Enhanced code scanning

4. **Post-Incident:**
   - User training on code review
   - Process improvement discussion
   - Potential account recovery plan

## Compliance Notifications

### When to Notify Stakeholders

```
Incident Type                  Notify          Timeframe
─────────────────────────────────────────────────────
Data breach (PII/PHI)          Legal/Compliance  Immediately
Unauthorized access            Security team     30 min
Secret exposure                Affected users    1 hour
Malicious code in production   All stakeholders  Immediately
Infrastructure compromise      DevOps + Security  Immediately
Audit log tampering            Compliance team    Immediately
```

### Notification Template

```
Subject: SECURITY INCIDENT NOTIFICATION

Incident ID: [YYYY-MM-DD-HHmm-XXXXX]
Severity: [Critical/High/Medium/Low]

SUMMARY:
[Brief description of incident]

IMPACT:
- Systems affected: [list]
- Data exposed: [describe]
- Users impacted: [estimated count]

ACTIONS TAKEN:
- [Action 1]
- [Action 2]
- [Action 3]

NEXT STEPS:
[Timeline for follow-up actions]

For questions, contact: [security-team@company.com](mailto:security-team@company.com)
```

## Post-Incident Review

### After Each Incident:

1. **Root Cause Analysis**
   - Five whys analysis
   - Contributing factors
   - System failures

2. **Timeline Reconstruction**
   - Event sequence
   - Detection delays
   - Response effectiveness

3. **Improvement Opportunities**
   - Process changes
   - Policy updates
   - Tooling gaps

4. **Documentation**
   - Public summary (redacted)
   - Internal detailed report
   - Compliance requirements

---

**Last Updated:** 2025-11-09
**Owner:** Security Team
**Review Frequency:** Quarterly
```

---

## 7. CODEOWNERS Template

### File: `CODEOWNERS`

```
# GitHub CODEOWNERS file for automatic review assignment
# Each line is a file pattern followed by GitHub usernames
# Last matching rule wins

# Default owners for all files
* @security-team

# Authentication & Security
src/security/** @security-team @architects
src/auth/** @security-team @developers
src/crypto/** @security-team

# Infrastructure & DevOps
infrastructure/** @devops @architects
.github/workflows/** @devops
terraform/** @devops @security-team

# Database schemas
src/database/migrations/** @architects @devops
src/database/schemas/** @architects

# API definitions
api/v1/** @developers @api-team
api/v2/** @developers @api-team

# Documentation
*.md @documentation-team
docs/** @documentation-team @developers

# Configuration
.github/SECURITY_POLICY.md @security-team
.github/BYPASS_APPROVAL_POLICY.md @security-team
.github/INCIDENT_RESPONSE.md @security-team

# Deployment
Dockerfile @devops
docker-compose.yml @devops
deployment/** @devops

# Dependencies
package.json @developers
package-lock.json @developers
requirements.txt @developers
```

---

## 8. Monthly Security Review Checklist

### File: `docs/MONTHLY_SECURITY_REVIEW.md`

```markdown
# Monthly Security Review Checklist

## Week 1: Access Review

### User Access
- [ ] Review all organization members
- [ ] Verify MFA is enabled for all users
- [ ] Audit inactive users (no activity > 30 days)
- [ ] Remove unnecessary repository access

### Team Membership
- [ ] Verify team membership accuracy
- [ ] Remove departed employees
- [ ] Add new team members with correct permissions
- [ ] Review team permission levels

### Application Permissions
- [ ] Audit GitHub Apps with org access
- [ ] Review GitHub App permissions
- [ ] Remove unused GitHub Apps
- [ ] Check for suspicious app activity

### Actions
```
SELECT actor, COUNT(*) as action_count
FROM audit_log
WHERE created_at >= NOW() - INTERVAL 30 days
  AND action LIKE 'user.%'
  OR action LIKE 'team.%'
  OR action LIKE 'app.%'
GROUP BY actor
ORDER BY action_count DESC;
```

## Week 2: Code Review & Merge Analysis

### Pull Request Analysis
- [ ] Average review time: target < 24 hours
- [ ] Number of reviews required: maintain standards
- [ ] Stale approvals dismissed: yes/no
- [ ] Failed CI/CD checks: investigate any patterns

### Merge Analysis
- [ ] Commits to main branch: [number] in past month
- [ ] Bypasses used: [number] with justifications
- [ ] Bypass audit: all bypasses justified? Yes/No
- [ ] Failed deployments: [count] - investigate issues

### Code Quality
- [ ] Security issues found: [count]
- [ ] Critical issues: [count] - all fixed?
- [ ] CodeQL findings: [count] unresolved
- [ ] Dependabot alerts: [count] - up to date?

## Week 3: Audit Log Review

### Log Analysis
- [ ] Total audit events: [count]
- [ ] Suspicious activities detected: [count]
- [ ] Investigation results: [findings]
- [ ] Alerts triggered: [count]

### Specific Events to Check
```
# Failed login attempts (> 5 for single user = suspicious)
SELECT actor, COUNT(*) as failed_attempts
FROM audit_log
WHERE action = 'user.login'
  AND action_success = false
  AND created_at >= NOW() - INTERVAL 30 days
GROUP BY actor
HAVING failed_attempts > 5;

# Unusual permission changes
SELECT *
FROM audit_log
WHERE action LIKE 'repo.access_%'
  OR action LIKE 'org.add_member%'
  OR action LIKE 'team.%'
  AND created_at >= NOW() - INTERVAL 30 days;

# Branch protection bypasses
SELECT actor, COUNT(*) as bypass_count
FROM audit_log
WHERE action = 'push'
  AND bypass_reason IS NOT NULL
  AND created_at >= NOW() - INTERVAL 30 days
GROUP BY actor;
```

### Compliance Checks
- [ ] Audit logs retained: 180+ days? Yes/No
- [ ] Audit log stream healthy: Yes/No
- [ ] No gaps in audit trail: Yes/No
- [ ] Integrity of logs verified: Yes/No

## Week 4: Security Updates & Remediation

### Vulnerabilities
- [ ] Critical vulnerabilities: [count] - all patched?
- [ ] High vulnerabilities: [count] - ETA to patch?
- [ ] Dependabot PRs reviewed: [count]
- [ ] Security patches applied: Yes/No

### Secret Scanning
- [ ] Alerts dismissed: [count] - verify legitimacy
- [ ] Secrets rotated: [count]
- [ ] Push protection blocks: [count]
- [ ] Custom patterns: working correctly?

### Compliance
- [ ] SOC 2 controls effective: Yes/No
- [ ] No unauthorized changes: Yes/No
- [ ] Change management followed: Yes/No
- [ ] Documentation up to date: Yes/No

## Report Generation

Generate monthly report with:

```
MONTHLY SECURITY REPORT
Date: [Month/Year]

EXECUTIVE SUMMARY
- All systems healthy: [Yes/No]
- Incidents reported: [count]
- Actions taken: [summary]

KEY METRICS
- MFA coverage: [percentage]
- PR review time (avg): [hours]
- CI/CD pass rate: [percentage]
- Vulnerability coverage: [percentage]

FINDINGS
- Critical issues: [list]
- High issues: [list]
- Medium issues: [list]

RECOMMENDATIONS
1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]

SIGN-OFF
- Reviewed by: [Name]
- Date: [Date]
- Next review: [Date]
```

## Next Steps
- [ ] Email report to stakeholders
- [ ] Schedule follow-up on critical items
- [ ] Update runbooks if needed
- [ ] Schedule next month's review
```

---

## Usage & Integration

All templates in this guide are:

1. **Copy-paste ready**: Can be used directly in repositories
2. **Customizable**: Update organization/team names and requirements
3. **Testable**: Include example configurations
4. **Auditable**: All templates include logging and monitoring

### Quick Integration Steps:

```bash
# Copy CODEOWNERS to repository
cp CODEOWNERS /path/to/repo/CODEOWNERS

# Copy security policy
cp SECURITY_POLICY.md /path/to/repo/.github/SECURITY_POLICY.md

# Copy incident response plan
cp INCIDENT_RESPONSE.md /path/to/repo/.github/INCIDENT_RESPONSE.md

# Deploy workflows
cp security.yml /path/to/repo/.github/workflows/security.yml

# Apply Terraform configuration
cd terraform/
terraform plan
terraform apply
```

---

**Document Version:** 1.0 (November 2025)
**Last Updated:** 2025-11-09
**Template Status:** Production Ready
