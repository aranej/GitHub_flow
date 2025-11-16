# CODEOWNERS Practical Templates & Patterns

This document contains ready-to-use templates for different organizational structures and use cases.

---

## Template 1: Small Startup (5-15 Engineers)

**Use Case**: Early-stage company with generalist teams

```
# .github/CODEOWNERS
# Small team - focus on critical path ownership

*                              @org/engineering
/security/                     @org/security-lead
/infrastructure/               @org/devops-lead
/docs/                         @org/tech-leads
```

**Rationale:**
- Everyone owns code generally
- Specific owners for critical areas
- Low maintenance overhead
- Good for knowledge sharing

---

## Template 2: Growth-Stage Startup (15-40 Engineers)

**Use Case**: Multiple teams forming, specialized areas emerging

```
# .github/CODEOWNERS
# Growth stage - balanced specialization

*                              @org/engineering-leads

# Backend
/api/                          @org/backend-team
/services/                     @org/backend-team
/database/                     @org/data-platform

# Frontend
/frontend/                     @org/frontend-team
/web-components/              @org/frontend-team

# Infrastructure
/infrastructure/              @org/devops-team
/.github/                     @org/devops-team
/deployment/                  @org/devops-team

# Security & Quality
/security/                    @org/security-team
/tests/                       @org/qa-team
/docs/                        @org/tech-writers
```

**Rationale:**
- Clear domain ownership
- Multiple teams with specialties
- Scalable to medium size
- Maintainable CODEOWNERS file

---

## Template 3: Enterprise Organization (40+ Engineers)

**Use Case**: Multiple teams, complex ownership requirements, governance needs

```
# .github/CODEOWNERS
# Enterprise structure with escalation

*                              @org/engineering-leads

# ============================================
# PLATFORM / INFRASTRUCTURE TEAMS
# ============================================

# Security - Critical path, requires multiple reviews
/security/                    @org/security-team @security-lead
/authentication/              @org/security-team @identity-lead
/encryption/                  @org/security-team

# Infrastructure - DevOps ownership
/infrastructure/              @org/devops-team @devops-lead
/kubernetes/                  @org/devops-team
/terraform/                   @org/devops-team
/.github/workflows/           @org/devops-team
/deployment/                  @org/devops-team @devops-lead

# Data Platform
/database/                    @org/data-platform @dba-lead
/migrations/                  @org/data-platform
/analytics/                   @org/data-analytics-team

# Performance & Monitoring
/monitoring/                  @org/devops-team @org/performance-team
/observability/               @org/devops-team

# ============================================
# PRODUCT / FEATURE TEAMS
# ============================================

# API Layer (Core)
/api/                         @org/api-team @api-lead
/api/auth/                    @org/security-team @org/api-team
/api/v1/                      @org/api-team
/api/v2/                      @org/api-team
/api/v3/                      @org/api-team

# Core Services
/services/user/               @org/identity-team
/services/account/            @org/identity-team
/services/payments/           @org/payments-team @payments-lead
/services/notifications/      @org/backend-team
/services/search/             @org/search-team

# Frontend - Web
/frontend/                    @org/frontend-team
/frontend/components/         @org/frontend-team
/frontend/pages/              @org/frontend-team
/frontend/a11y/               @org/accessibility-team @org/frontend-team
/frontend/performance/        @org/performance-team

# Mobile
/mobile/                      @org/mobile-team
/mobile/ios/                  @org/mobile-ios-team
/mobile/android/              @org/mobile-android-team

# Business Logic / Domain Services
/domains/                     @org/product-team
/workflows/                   @org/product-team

# ============================================
# SHARED & SUPPORT
# ============================================

# Testing & Quality
/tests/                       @org/qa-team
/tests/integration/           @org/qa-team @org/api-team
/tests/e2e/                   @org/qa-team
/tests/performance/           @org/performance-team
/cypress/                     @org/qa-team

# Libraries & Tools
/lib/                         @org/engineering-leads
/tools/                       @org/platform-engineering
/scripts/                     @org/devops-team
/automation/                  @org/devops-team

# Documentation
/docs/                        @org/tech-writers @org/engineering-leads
/docs/api/                    @org/api-team @org/tech-writers
/docs/architecture/           @org/engineering-leads
/docs/security/               @org/security-team

# Configuration
/config/                      @org/engineering-leads
/.env*                        @org/devops-team
/.editorconfig                @org/engineering-leads
/tsconfig.json                @org/frontend-team
/.eslintrc                    @org/frontend-team

# Governance
LICENSE                       @org/legal
SECURITY.md                   @org/security-team
PRIVACY.md                    @org/legal
COMPLIANCE/                   @org/compliance
```

**Rationale:**
- Organized by platform and product teams
- Clear escalation paths
- Governance separation (legal, compliance)
- Handles large teams with minimal conflicts

---

## Template 4: API-First Architecture

**Use Case**: Microservices, API-gateway, version-controlled APIs

```
# .github/CODEOWNERS
# API-First Microservices Architecture

*                              @org/engineering

# ============================================
# API GATEWAY & CORE
# ============================================

/api/gateway/                 @org/api-platform-team
/api/middleware/              @org/api-platform-team
/api/routing/                 @org/api-platform-team

# ============================================
# API VERSIONS (Explicit Control)
# ============================================

/api/v1/                      @org/api-team @org/backend-team-v1
/api/v1/auth/                 @org/security-team @org/api-team
/api/v1/users/                @org/identity-team
/api/v1/payments/             @org/payments-team @payments-lead

/api/v2/                      @org/api-team @org/backend-team-v2
/api/v2/auth/                 @org/security-team @org/api-team
/api/v2/users/                @org/identity-team
/api/v2/products/             @org/product-team

/api/v3/                      @org/api-team @org/backend-team-v3
/api/v3/**/*.go               @org/api-team @org/golang-team

# ============================================
# MICROSERVICES
# ============================================

/services/auth-service/       @org/security-team @org/identity-team
/services/user-service/       @org/identity-team
/services/payment-service/    @org/payments-team @payments-lead
/services/notification-service/ @org/backend-team
/services/analytics-service/  @org/data-analytics-team
/services/search-service/     @org/search-team

# ============================================
# SHARED
# ============================================

/shared/dto/                  @org/api-team
/shared/errors/               @org/api-team
/shared/middleware/           @org/api-team
/shared/auth/                 @org/security-team

# ============================================
# TESTING
# ============================================

/tests/api/                   @org/api-team @org/qa-team
/tests/integration/           @org/qa-team @org/backend-team
```

**Rationale:**
- Clear API version ownership
- Service-based organization
- Shared code governance
- Scalable for large APIs

---

## Template 5: Full-Stack Web Application

**Use Case**: React/Vue frontend + Node/Python backend

```
# .github/CODEOWNERS
# Full-Stack Web Application

*                              @org/engineering

# ============================================
# FRONTEND - REACT/VUE
# ============================================

/src/components/              @org/frontend-team
/src/pages/                   @org/frontend-team
/src/hooks/                   @org/frontend-team
/src/utils/                   @org/frontend-team
/src/styles/                  @org/frontend-team @org/design-team
/src/a11y/                    @org/accessibility-team
/src/i18n/                    @org/localization-team
/src/auth/                    @org/security-team

# ============================================
# STATE MANAGEMENT
# ============================================

/src/store/                   @org/frontend-team @org/state-management-lead
/src/redux/                   @org/frontend-team
/src/context/                 @org/frontend-team

# ============================================
# BACKEND - NODE/PYTHON
# ============================================

/server/                      @org/backend-team
/server/routes/               @org/backend-team
/server/controllers/          @org/backend-team
/server/models/               @org/backend-team
/server/middleware/           @org/backend-team @org/security-team
/server/auth/                 @org/security-team

# ============================================
# DATABASE
# ============================================

/server/migrations/           @org/data-platform
/server/seeds/                @org/backend-team @org/data-platform
/db/                          @org/data-platform

# ============================================
# TESTING
# ============================================

/tests/unit/                  @org/qa-team @org/frontend-team
/tests/integration/           @org/qa-team @org/backend-team
/tests/e2e/                   @org/qa-team
/cypress/                     @org/qa-team

# ============================================
# CONFIG & BUILD
# ============================================

package.json                  @org/engineering-leads
tsconfig.json                 @org/frontend-team
.eslintrc                     @org/frontend-team
webpack.config.js             @org/frontend-team
/config/                      @org/engineering-leads
Dockerfile                    @org/devops-team
docker-compose.yml            @org/devops-team

# ============================================
# DOCS
# ============================================

/docs/                        @org/tech-writers
/docs/frontend/               @org/frontend-team
/docs/backend/                @org/backend-team
README.md                     @org/engineering-leads
```

**Rationale:**
- Separates frontend and backend concerns
- Clear testing ownership
- Configuration management
- Scalable for growth

---

## Template 6: Open Source Project

**Use Case**: Community-driven project, multiple maintainers

```
# CODEOWNERS
# Open Source Project

* @maintainer1 @maintainer2

# Core functionality - requires both maintainers
/src/core/ @maintainer1 @maintainer2

# Documentation
/docs/ @maintainer1 @docs-team

# Testing
/tests/ @test-maintainer

# CI/CD
/.github/workflows/ @maintainer2

# Accessibility
/src/a11y/ @accessibility-lead
```

**Rationale:**
- Dual ownership for critical code
- Community contributions welcomed
- Clear area ownership
- Low maintenance overhead

---

## Template 7: Healthcare/Finance (Compliance-Heavy)

**Use Case**: Regulated industry, audit trails, segregation of duties

```
# .github/CODEOWNERS
# Compliance-Heavy Organization

*                              @org/engineering-leads

# ============================================
# COMPLIANCE & LEGAL
# ============================================

LICENSE                       @org/legal @org/compliance
SECURITY.md                   @org/security
PRIVACY.md                    @org/legal
COMPLIANCE/                   @org/compliance @org/legal
AUDIT_LOG/                    @org/compliance

# ============================================
# SECURITY & AUTHENTICATION
# ============================================

/security/                    @org/security @org/compliance
/auth/                        @org/security @org/identity-team
/encryption/                  @org/security
/secrets/                     @org/devops @org/security

# ============================================
# DATA HANDLING - SEGREGATION OF DUTIES
# ============================================

/data/pii/                    @org/security @org/compliance @data-protection-officer
/data/phi/                    @org/security @org/compliance @hipaa-lead
/data/pci/                    @org/security @org/compliance @pci-lead
/backup/                      @org/devops @org/compliance
/archive/                     @org/devops @org/compliance

# ============================================
# AUDIT & LOGGING
# ============================================

/audit/                       @org/compliance @org/security
/logging/                     @org/devops @org/compliance
/monitoring/                  @org/devops @org/security

# ============================================
# INFRASTRUCTURE - SECURE BASELINE
# ============================================

/infrastructure/              @org/devops @org/security
/.github/workflows/           @org/devops @org/security
/deployment/                  @org/devops-lead @org/security

# ============================================
# CODE & APPLICATION
# ============================================

/src/                         @org/backend-team
/api/                         @org/api-team
/frontend/                    @org/frontend-team

# ============================================
# TESTING - SECURITY & REGRESSION
# ============================================

/tests/security/              @org/security @org/qa-team
/tests/compliance/            @org/compliance @org/qa-team
/tests/integration/           @org/qa-team

# ============================================
# DOCUMENTATION
# ============================================

/docs/security/               @org/security @org/compliance
/docs/compliance/             @org/compliance @org/legal
/docs/                        @org/tech-writers
```

**Rationale:**
- Explicit security ownership
- Compliance segregation of duties
- Audit trail focus
- Legal/Privacy separation

---

## Template 8: Machine Learning / Data Science

**Use Case**: ML models, data pipelines, experimentation

```
# .github/CODEOWNERS
# ML & Data Science Organization

*                              @org/engineering

# ============================================
# MODELS & ML
# ============================================

/models/                      @org/ml-team @org/ml-lead
/models/nlp/                  @org/nlp-team
/models/vision/               @org/computer-vision-team
/models/recommenders/         @org/recommendations-team

# ============================================
# DATA PIPELINES
# ============================================

/pipelines/                   @org/data-engineering-team
/pipelines/ingestion/         @org/data-engineering-team
/pipelines/transform/         @org/data-engineering-team
/pipelines/feature-store/     @org/ml-platform-team

# ============================================
# FEATURE ENGINEERING
# ============================================

/features/                    @org/ml-platform-team @org/ml-team
/features/notebooks/          @org/data-scientists

# ============================================
# EXPERIMENTATION
# ============================================

/experiments/                 @org/ml-team
/notebooks/                   @org/data-scientists
/notebooks/research/          @org/research-team

# ============================================
# INFRASTRUCTURE
# ============================================

/infrastructure/ml/           @org/ml-infra-team
/gpu-cluster/                 @org/ml-infra-team
/distributed-training/        @org/ml-infra-team

# ============================================
# MODEL SERVING
# ============================================

/serving/                     @org/ml-platform-team
/api/predictions/             @org/ml-platform-team
/model-registry/              @org/ml-platform-team

# ============================================
# TESTING & VALIDATION
# ============================================

/tests/model-validation/      @org/ml-team @org/qa-team
/tests/data-quality/          @org/data-engineering-team
/tests/fairness/              @org/ml-ethics-team
```

**Rationale:**
- ML-specific organization
- Experimentation clarity
- Model and data separation
- Infrastructure for ML workloads

---

## Rotation Schedule Template

```yaml
# .github/config/rotation-schedule.yml
# Quarterly rotation schedule for code reviewers

rotation_q1_2025:
  api_team:
    primary: alice
    secondary: bob
    backup: charlie

  frontend_team:
    primary: david
    secondary: eve
    backup: frank

  backend_team:
    primary: grace
    secondary: henry
    backup: iris

  devops_team:
    primary: jack
    secondary: karen
    backup: leo

rotation_q2_2025:
  api_team:
    primary: bob
    secondary: charlie
    backup: alice

  frontend_team:
    primary: eve
    secondary: frank
    backup: david

  # ... continue rotation
```

---

## Escalation Trigger Template

```yaml
# .github/config/escalation-rules.yml
# Defines when and how to escalate code reviews

escalation_rules:
  time_based:
    - trigger_after: 24h
      level: 2
      notify: "@team-lead"

    - trigger_after: 48h
      level: 3
      notify: "@engineering-director"

  approval_based:
    - pattern: "/security/*"
      skip_to_level: 2
      required_approvals: 2

    - pattern: "/api/*"
      skip_to_level: 2
      required_approvers: "@api-lead,@architecture-committee"

  change_based:
    - paths_changed: ["/database/", "/infrastructure/"]
      escalate_to: "@devops-lead"

    - files_changed: ">=10"
      escalate_to: "@tech-lead"

    - additions_lines: ">500"
      escalate_to: "@architecture-committee"
```

---

## GitHub Actions Integration Template

```yaml
# .github/workflows/codeowners-validation.yml

name: Validate CODEOWNERS File

on: [pull_request, push]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Check CODEOWNERS Exists
        run: |
          if [ ! -f ".github/CODEOWNERS" ]; then
            echo "ERROR: .github/CODEOWNERS file not found"
            exit 1
          fi

      - name: Validate CODEOWNERS Syntax
        run: |
          python scripts/validate_codeowners.py

      - name: Check for Overlaps
        run: |
          python scripts/check_codeowners_overlap.py

      - name: Validate User/Team Exist
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const codeowners = fs.readFileSync('.github/CODEOWNERS', 'utf8');

            // Extract all team/user references
            const refs = codeowners.match(/@[\w\-/]+/g) || [];

            for (const ref of refs) {
              if (ref.includes('/')) {
                // Team format: @org/team
                try {
                  await github.rest.teams.getByName({
                    org: ref.split('/')[1],
                    team_slug: ref.split('/')[2]
                  });
                } catch (e) {
                  console.error(`Invalid team: ${ref}`);
                }
              } else {
                // User format: @user
                try {
                  await github.rest.users.getByUsername({
                    username: ref.substring(1)
                  });
                } catch (e) {
                  console.warn(`User ${ref} may not exist`);
                }
              }
            }
```

---

## Monitoring & Metrics Template

```sql
-- Query: Review SLA Compliance
SELECT
  owner,
  COUNT(*) as total_reviews,
  AVG(EXTRACT(HOUR FROM (approved_at - created_at))) as avg_hours_to_approval,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY EXTRACT(HOUR FROM (approved_at - created_at))) as p95_hours,
  COUNT(CASE WHEN EXTRACT(HOUR FROM (approved_at - created_at)) <= 24 THEN 1 END) as met_24h_sla
FROM pull_requests
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY owner
ORDER BY avg_hours_to_approval;

-- Query: Code Owner Coverage
SELECT
  CASE
    WHEN owner = '*' THEN 'Uncovered'
    ELSE owner
  END as owner,
  COUNT(*) as file_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM codeowners), 2) as percentage_coverage
FROM codeowners
GROUP BY owner
ORDER BY file_count DESC;

-- Query: Escalation Frequency by Team
SELECT
  team,
  COUNT(*) as escalation_count,
  AVG(escalation_level) as avg_escalation_level,
  MAX(EXTRACT(HOUR FROM escalation_time)) as max_escalation_delay_hours
FROM escalations
WHERE escalation_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY team
ORDER BY escalation_count DESC;
```

---

## Best Practices Summary

1. **Start Simple**: Begin with minimal CODEOWNERS, expand as needed
2. **Use Teams**: Always prefer `@org/team` over `@username`
3. **Document Patterns**: Keep a legend at the top of CODEOWNERS
4. **Regular Updates**: Schedule quarterly reviews (Feb, May, Aug, Nov)
5. **Clear Escalation**: Define explicit escalation triggers and SLAs
6. **Automate Validation**: Use CI to validate CODEOWNERS syntax
7. **Monitor Metrics**: Track review times, escalation frequency
8. **Communicate Changes**: Announce CODEOWNERS updates to teams
9. **Handle Special Cases**: Create exceptions for critical paths
10. **Version Control**: Keep CODEOWNERS reviewed like any other file

---

**Version**: 1.0
**Updated**: 2025-11-09
