# GitHub Enterprise Security Guide 2025 - Complete Reference

## Overview

This collection provides comprehensive, production-ready security configurations for GitHub Enterprise in 2025, covering advanced branch protection, rulesets, push protection, compliance, and enterprise-grade architectures.

**Current Date:** November 9, 2025
**Framework Status:** Production Ready
**Compliance Level:** SOC 2, HIPAA, PCI DSS, ISO 27001

---

## Document Library

### 1. **ENTERPRISE_SECURITY_GUIDE_2025.md** (Primary Reference)
**Purpose:** Comprehensive security framework and best practices
**Size:** ~8,000 lines | **Topics:** 12 major sections

**Contents:**
- Advanced branch protection rules (6 features)
- GitHub Rulesets (the modern approach)
- Team-based review requirements (NEW Nov 2025)
- Push protection & secret scanning
- Required deployments & custom rules
- Bypass permissions & access control
- Audit logging & compliance
- Enterprise-grade configurations
- SOC 2 Type II compliance mapping
- HIPAA, PCI DSS, ISO 27001 alignment
- Implementation checklist (10 weeks)
- Monitoring & maintenance procedures
- Quick reference and glossary

**Best For:** Understanding the full security landscape, compliance mapping, strategic planning

**Key Features:**
- November 2025 updates included
- Enterprise security configurations
- Real-world implementation examples
- Compliance checklist for multiple frameworks

---

### 2. **SECURITY_IMPLEMENTATION_TEMPLATES.md** (Practical Tools)
**Purpose:** Copy-paste ready implementations
**Size:** ~2,500 lines | **Topics:** 8 ready-to-use templates

**Contents:**
1. **Organization Security Policy** (.github/SECURITY_POLICY.md)
   - MFA requirements
   - Code review standards
   - Secret handling procedures
   - Branch protection overview

2. **Terraform Ruleset Configuration** (terraform/github_rulesets.tf)
   - Production ruleset (main branch)
   - Release ruleset (release-* branches)
   - Development ruleset
   - Fully functional HCL code

3. **Security Scanning Workflow** (.github/workflows/security.yml)
   - CodeQL analysis
   - Dependency scanning
   - Secret detection
   - SAST with SonarQube
   - Parallel execution strategy

4. **Bypass Approval Policy** (.github/BYPASS_APPROVAL_POLICY.md)
   - Authorized teams
   - Approval scenarios
   - Request procedure
   - Audit & monitoring
   - Violation handling

5. **Audit Log Analysis Script** (scripts/analyze_audit_logs.py)
   - Python 3 implementation
   - Audit log fetching
   - Suspicious activity detection
   - Compliance report generation
   - REST API integration

6. **Incident Response Plan** (.github/INCIDENT_RESPONSE.md)
   - Quick response checklist
   - 3 incident scenarios with procedures
   - Compliance notification requirements
   - Post-incident review process

7. **CODEOWNERS Template** (CODEOWNERS)
   - Security team assignments
   - DevOps file patterns
   - Database schema protection
   - Documentation ownership

8. **Monthly Security Review Checklist** (docs/MONTHLY_SECURITY_REVIEW.md)
   - Week-by-week review schedule
   - SQL queries for audit analysis
   - Metrics tracking
   - Report generation template

**Best For:** Quick implementation, team setup, policy documentation

**Usage:**
```bash
# Copy templates directly to repository
cp CODEOWNERS /path/to/repo/
cp SECURITY_POLICY.md /path/to/repo/.github/
cp security.yml /path/to/repo/.github/workflows/
# ... etc
```

---

### 3. **SECURITY_ARCHITECTURE_PATTERNS.md** (Advanced Design)
**Purpose:** Enterprise security architecture patterns
**Size:** ~2,000 lines | **Topics:** 6 architectural patterns

**Contents:**
1. **Multi-Tier Protection Architecture**
   - 5-layer security model
   - Layer interactions
   - Decision tree diagrams
   - Data flow visualization

2. **Risk-Based Branch Protection**
   - Risk scoring algorithm
   - Risk-to-requirements mapping
   - Python implementation
   - Configuration examples by risk level

3. **Zero-Trust Access Control**
   - Zero-trust principles
   - 5-factor verification (WHO, WHAT, WHERE, WHEN, HOW)
   - Python access controller implementation
   - Real-world policies

4. **Compliance-Driven Architecture**
   - Compliance requirement mapping
   - Control matrix (SOC 2, HIPAA, PCI DSS)
   - Evidence collection strategies
   - Audit trail integration

5. **High-Velocity Development Security**
   - Fast vs. slow security comparison
   - Parallel check architecture
   - Risk-based review routing
   - Python review router implementation

6. **Incident Response Automation**
   - Automated response scenarios
   - GitHub Actions automation workflows
   - Incident triage process
   - Remediation workflows

**Best For:** Architecture design, high-scale deployments, DevSecOps teams

---

## Quick Navigation by Topic

### By Use Case

#### "I need to secure production branch NOW"
→ See **ENTERPRISE_SECURITY_GUIDE_2025.md** Section 2 (Rulesets)
→ Copy **SECURITY_IMPLEMENTATION_TEMPLATES.md** - Terraform config

#### "I need compliance ready (SOC 2)"
→ See **ENTERPRISE_SECURITY_GUIDE_2025.md** Section 8.1
→ Use **SECURITY_IMPLEMENTATION_TEMPLATES.md** - Monthly review checklist

#### "I need to block secrets from being pushed"
→ See **ENTERPRISE_SECURITY_GUIDE_2025.md** Section 3
→ Update **.github/SECURITY_POLICY.md** from templates

#### "I need to set up team-based review requirements"
→ See **ENTERPRISE_SECURITY_GUIDE_2025.md** Section 2 (Rulesets)
→ Terraform templates in **SECURITY_IMPLEMENTATION_TEMPLATES.md**

#### "I need incident response automation"
→ See **SECURITY_ARCHITECTURE_PATTERNS.md** Section 6
→ Implement GitHub Actions from **SECURITY_IMPLEMENTATION_TEMPLATES.md**

#### "I need to design enterprise-scale security"
→ See **SECURITY_ARCHITECTURE_PATTERNS.md** - All patterns
→ Reference **ENTERPRISE_SECURITY_GUIDE_2025.md** Section 7

### By Feature

| Feature | Primary Doc | Secondary Resources |
|---------|-------------|-------------------|
| Branch Protection Rules | ENTERPRISE_SECURITY_GUIDE_2025.md §1 | SECURITY_ARCHITECTURE_PATTERNS.md §2 |
| GitHub Rulesets | ENTERPRISE_SECURITY_GUIDE_2025.md §2 | SECURITY_IMPLEMENTATION_TEMPLATES.md - Terraform |
| Push Protection | ENTERPRISE_SECURITY_GUIDE_2025.md §3 | SECURITY_IMPLEMENTATION_TEMPLATES.md - Workflows |
| Deployments | ENTERPRISE_SECURITY_GUIDE_2025.md §4 | SECURITY_ARCHITECTURE_PATTERNS.md §4 |
| Bypass Control | ENTERPRISE_SECURITY_GUIDE_2025.md §5 | SECURITY_IMPLEMENTATION_TEMPLATES.md - Policy |
| Audit Logging | ENTERPRISE_SECURITY_GUIDE_2025.md §6 | SECURITY_IMPLEMENTATION_TEMPLATES.md - Script |
| Compliance | ENTERPRISE_SECURITY_GUIDE_2025.md §8 | SECURITY_ARCHITECTURE_PATTERNS.md §4 |
| Incidents | SECURITY_IMPLEMENTATION_TEMPLATES.md - Plan | SECURITY_ARCHITECTURE_PATTERNS.md §6 |

### By Compliance Framework

| Framework | Primary Location | Key Sections |
|-----------|-----------------|--------------|
| **SOC 2 Type II** | ENTERPRISE_SECURITY_GUIDE_2025.md §8.1 | CC6-CC9 controls, MFA, audit logging |
| **HIPAA** | ENTERPRISE_SECURITY_GUIDE_2025.md §8.2 | Administrative, technical, physical safeguards |
| **PCI DSS v4.0** | ENTERPRISE_SECURITY_GUIDE_2025.md §8.3 | Requirements 1-10 mapping |
| **ISO 27001:2022** | ENTERPRISE_SECURITY_GUIDE_2025.md §8.4 | A.5-A.14 controls alignment |

---

## Implementation Timeline

### Week 1-2: Foundation
```
✓ Review ENTERPRISE_SECURITY_GUIDE_2025.md §9 Phase 1
✓ Enable MFA organization-wide
✓ Configure audit log streaming (use SECURITY_IMPLEMENTATION_TEMPLATES.md)
✓ Create GitHub teams
```

### Week 3-4: Repository Protection
```
✓ Review §2 (Rulesets) in ENTERPRISE_SECURITY_GUIDE_2025.md
✓ Apply Terraform configurations from SECURITY_IMPLEMENTATION_TEMPLATES.md
✓ Configure team-based reviews
✓ Test on non-production repository
```

### Week 5-6: Security Scanning
```
✓ Deploy security workflows from SECURITY_IMPLEMENTATION_TEMPLATES.md
✓ Enable CodeQL, secret scanning, Dependabot
✓ Configure push protection patterns
✓ Set up bypass approval workflow
```

### Week 7-8: Compliance & Audit
```
✓ Configure audit log streaming destination
✓ Set up SIEM integration
✓ Deploy audit analysis script from SECURITY_IMPLEMENTATION_TEMPLATES.md
✓ Generate compliance reports per framework
```

### Week 9-10: Validation
```
✓ Test all security controls
✓ Run security incident simulations
✓ Validate compliance mapping (§8 in ENTERPRISE_SECURITY_GUIDE_2025.md)
✓ Document procedures
```

---

## November 2025 Feature Updates

### Major Features Released

**August 2025:**
- Push protection pattern configuration (GA)
- Configurable which secret patterns are protected

**July 2025:**
- GitHub Apps can review secret scanning bypass requests
- Automated bypass management

**November 2025:**
- **NEW:** Team-based review requirements on specific files
- Require approvals from specific teams for sensitive code paths
- Enterprise rulesets (public preview)
- Enterprise custom repository properties

### What This Means

```
BEFORE (November 2024):
- Same review requirements for all files
- Cannot require security-team for sensitive code
- Limited scalability

AFTER (November 2025):
- Different requirements per code path
- security-team required for src/security/**
- architects required for infrastructure/**
- Scales across organization/enterprise
```

**See:** ENTERPRISE_SECURITY_GUIDE_2025.md §2 "Team-Based Review Requirements (NEW)"

---

## Enterprise Deployment Patterns

### Pattern 1: Centralized Security (Enterprise Rulesets)
**Best for:** Large organizations with consistent policy
```
1 Enterprise Ruleset
    ├── Applied to: 50+ repositories
    ├── Organization-level control
    └── Consistent enforcement
```
**See:** SECURITY_ARCHITECTURE_PATTERNS.md §3 (Zero-Trust) and §4 (Compliance)

### Pattern 2: Risk-Based Tiering
**Best for:** Mixed sensitivity repositories
```
Critical Repos      (Risk Score 80+)  → 3 approvals, all checks
Important Repos     (Risk Score 60+)  → 2 approvals, key checks
Standard Repos      (Risk Score 40+)  → 1 approval, build check
Development Repos   (Risk Score <40)  → minimal requirements
```
**See:** SECURITY_ARCHITECTURE_PATTERNS.md §2

### Pattern 3: Rapid Development + Security
**Best for:** High-velocity teams
```
Parallel CI/CD Jobs (< 15 min total)
    ├── Lint & type check (1 min)
    ├── Unit tests (3 min)
    ├── Integration tests (5 min) [parallel]
    ├── Security scan (5 min) [parallel]
    └── Dependency check (2 min) [parallel]
```
**See:** SECURITY_ARCHITECTURE_PATTERNS.md §5

---

## Quick Command Reference

### Apply Terraform Configuration
```bash
cd terraform/
terraform plan -var="github_organization=YOUR_ORG" \
               -var="github_token=$GITHUB_TOKEN"
terraform apply
```

### Run Audit Log Analysis
```bash
python3 scripts/analyze_audit_logs.py \
  --token $GITHUB_TOKEN \
  --organization your-org \
  --days 30 \
  --output audit_report.json
```

### Deploy Security Workflows
```bash
cp SECURITY_IMPLEMENTATION_TEMPLATES.md .github/workflows/security.yml
git add .github/workflows/security.yml
git commit -m "Add enterprise security scanning workflow"
git push
```

### Enable Push Protection
```
Settings > Code Security > Push Protection
├── Enable for all patterns
├── OR: Select specific patterns
└── Configure custom patterns (enterprise)
```

---

## Troubleshooting Guide

### "Pull request won't merge despite all checks passing"
1. Check branch protection rules (ENTERPRISE_SECURITY_GUIDE_2025.md §1)
2. Verify all status checks are configured in ruleset
3. Check merge queue status
4. Review bypass permissions

### "Too many failed CI/CD runs"
1. Review parallel job configuration (SECURITY_ARCHITECTURE_PATTERNS.md §5)
2. Check status check timeout settings
3. Verify runner capacity
4. Consider job caching optimization

### "Developers frustrated with security requirements"
1. Review risk-based approach (SECURITY_ARCHITECTURE_PATTERNS.md §2)
2. Implement tiered protection per branch
3. Communicate policy rationale
4. Gather feedback from teams

### "Audit logs not being streamed"
1. Verify streaming destination configuration
2. Check credentials/permissions for destination
3. Validate audit log API is accessible
4. Review SIEM ingestion rules

### "Push protection blocking legitimate secrets"
1. Review custom secret patterns
2. Adjust patterns to reduce false positives
3. Implement whitelist process
4. See bypass request workflow in templates

---

## Support & Resources

### Internal Resources
- **Security Team:** security@company.com
- **Slack Channel:** #security-team
- **Runbook:** See .github/INCIDENT_RESPONSE.md
- **Policy Updates:** Monthly review (templates)

### External Resources
- **GitHub Official Docs:** https://docs.github.com/
- **GitHub Changelog:** https://github.blog/changelog/
- **GitHub Security Blog:** https://github.blog/enterprise-software/secure-software-development/
- **Well-Architected Framework:** https://wellarchitected.github.com/

### Related Frameworks
- SOC 2 Trust Services Criteria: https://us.aicpa.org/interestareas/informationsystems/pages/soc-2-assurance-services.aspx
- HIPAA Security Rule: https://www.hhs.gov/hipaa/
- PCI DSS: https://www.pcisecuritystandards.org/
- ISO 27001: https://www.iso.org/standard/27001

---

## Document Maintenance

### How Documents Are Updated
- **Changelog:** Tracked via git commits
- **Version:** Indicated at document header
- **Status:** Production Ready / Public Preview / Beta
- **Review Cycle:** Quarterly + as-needed for GitHub updates

### Contributing Feedback
1. Report issues via: security-feedback@company.com
2. Suggest improvements: security-team Slack channel
3. Report inaccuracies: security-audit@company.com

### Next Review Date: February 9, 2026
*Or sooner if GitHub releases major security features*

---

## Document Map

```
Repository Root/
├── README_SECURITY_GUIDES.md (this file)
├── ENTERPRISE_SECURITY_GUIDE_2025.md
│   └── 12 sections covering all security aspects
├── SECURITY_IMPLEMENTATION_TEMPLATES.md
│   └── 8 ready-to-use templates
├── SECURITY_ARCHITECTURE_PATTERNS.md
│   └── 6 enterprise architecture patterns
│
├── .github/
│   ├── SECURITY_POLICY.md
│   ├── BYPASS_APPROVAL_POLICY.md
│   ├── INCIDENT_RESPONSE.md
│   └── workflows/
│       └── security.yml
│
├── terraform/
│   └── github_rulesets.tf
│
├── scripts/
│   └── analyze_audit_logs.py
│
├── docs/
│   └── MONTHLY_SECURITY_REVIEW.md
│
└── CODEOWNERS
```

---

## Quick Start (5 Minutes)

1. **Read:** ENTERPRISE_SECURITY_GUIDE_2025.md §2 (5 min)
2. **Copy:** Terraform config from templates
3. **Deploy:** Apply terraform in test repo
4. **Verify:** Test branch protection
5. **Iterate:** Adjust for your organization

---

**Overall Document Collection:**
- **Total Pages:** ~12,000+ lines
- **Templates:** 8 production-ready implementations
- **Code Examples:** 20+ functional examples
- **Compliance Coverage:** 4 major frameworks
- **Architecture Patterns:** 6 enterprise patterns
- **Last Updated:** November 9, 2025
- **Status:** Enterprise Production Ready

---

For questions or contributions, contact the Security Team.
