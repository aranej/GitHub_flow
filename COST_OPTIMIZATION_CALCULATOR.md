# GitHub Actions Cost Optimization & ROI Calculator 2025

## Cost Analysis Framework

### Current GitHub Pricing (2025)

#### GitHub-Hosted Runners

**Included Minutes by Plan:**
- Free: 2,000 minutes/month (public repos unlimited)
- Pro: 3,000 minutes/month
- Team: 3,000 minutes/month
- Enterprise Cloud: 50,000 minutes/month

**Overage Rates:**
- Linux (ubuntu-latest): $0.008/minute
- Windows (windows-latest): $0.016/minute
- macOS (macos-latest): $0.016/minute

**Storage:**
- Free: 500 MB
- Pro: 1 GB
- Team: 2 GB
- Enterprise: 50 GB
- Storage overage: $0.008/GB/day

---

## Scenario 1: Startup (Small Team)

### Current State (No Optimization)

```
Team Size: 5 engineers
Repositories: 10
Workflow runs/day: 50
Average job duration: 10 minutes
Jobs per run: 3 (serial)
Matrix size: None

Monthly Usage:
  - Total minutes: 50 runs × 3 jobs × 10 min = 1,500 minutes
  - Status: Under limit (Free tier: 2,000 minutes)
  - Monthly cost: $0

Issues:
  - Slow feedback loop (30 min per deployment)
  - Sequential job execution
  - No caching strategy
  - Manual deployment steps
```

### Optimized State

**Implementation:**
1. Implement dependency caching (5 min setup)
2. Parallelize jobs (10 min setup)
3. Add reusable workflows (30 min setup)

```
Optimizations Applied:
  - Dependency caching: -30% job duration (7 min → 5 min)
  - Job parallelization: -70% workflow time (30 min → 9 min)
  - Selective testing: -25% total jobs (remove redundant tests)

New Metrics:
  - Jobs per run: 3 (parallel instead of serial)
  - Job duration: 5 minutes
  - Total minutes per run: 5 minutes (not 30)
  - Monthly usage: 50 runs × 5 min = 250 minutes
  - Monthly cost: $0 (still under Free tier)
  - Deployment time: 9 minutes (was 30 minutes) = 67% faster

Additional Benefits:
  - 3 minutes average feedback time
  - Better developer experience
  - Code quality: Maintainable automation
  - Team velocity: +20% due to faster feedback

ROI:
  - Setup cost: 0 hours (Free tier, no cost)
  - Productivity gain: 3 hours/week × 5 engineers = 15 hours/week
  - Monthly savings: ~60 hours
  - Annual value: ~$120,000 (15 hours × $200/hr rate)
```

---

## Scenario 2: Growing Company (Mid-Size Team)

### Current State (No Optimization)

```
Team Size: 30 engineers
Repositories: 50
Workflow runs/day: 500
Average job duration: 15 minutes
Jobs per run: 5 (mixed serial/parallel)
Matrix testing: 4 Node versions × 3 OS = 12 jobs
Daily costs: ~$15-20
Monthly costs: ~$450-600

Breakdown:
  - Test runs: 300 × 15 min = 4,500 min
  - Build runs: 100 × 20 min = 2,000 min
  - Deploy runs: 50 × 10 min = 500 min
  - Total: 7,000 minutes/month
  - Overage: 7,000 - 3,000 = 4,000 minutes
  - Cost: 4,000 × $0.008 = $32/day = ~$960/month

Issues:
  - High monthly costs
  - Slow CI feedback (20-30 minutes)
  - Resource contention
  - Expensive Windows/macOS testing
  - Duplicate caching across jobs
```

### Optimization Phase 1: Quick Wins (1 week)

**Cost: 10 hours setup | Time to ROI: 3 weeks**

```
Implementations:
1. Dependency caching (npm, pip, maven)
2. Parallelize independent jobs
3. Reduce matrix combinations (only test on Linux)
4. Shallow clone (fetch-depth: 1)

Results:
  - Job duration: 15 min → 8 min (-47%)
  - Workflow time: 25 min → 10 min (-60%)
  - Monthly minutes: 7,000 → 4,000 (-43%)
  - Monthly cost: $960 → $320 (-67%)
  - Monthly savings: $640

Timeline to ROI:
  - Setup cost: 10 hours × $200/hr = $2,000
  - Monthly savings: $640
  - Break-even: 3.1 months
```

### Optimization Phase 2: Advanced (2 weeks)

**Additional Cost: 20 hours | Cumulative savings: $1,280/month**

```
Implementations:
1. Reusable workflows (reduce duplication)
2. Composite actions (centralize step logic)
3. Docker layer caching
4. Conditional job execution
5. Concurrency groups (cancel stale runs)

Results:
  - Job duration: 8 min → 6 min (-25%)
  - Stale run cancellation: -10% of runs
  - Docker builds: 5 min → 30 sec (-90%)
  - Monthly minutes: 4,000 → 2,200 (-45%)
  - Monthly cost: $320 → $96 (-70%)
  - Monthly savings: $224 (Phase 1) + $224 (Phase 2) = $448 total saved from Phase 1

Total monthly savings: $864 from baseline
```

### Optimization Phase 3: Infrastructure (1 month)

**Cost: $1,000 setup + $100/month | Break-even: 2.6 months**

```
Implementation: Self-hosted runners on AWS EC2
- 3 × t3.medium instances (24/7)
- Cost: $60/month ($0.0832/hour × 730 hours)
- Setup: Terraform, autoscaling, monitoring

Savings vs GitHub-hosted:
  - Remaining GitHub minutes: 500/month (small tasks)
  - GitHub cost: $4/month (under Pro limit)
  - EC2 cost: $60/month
  - Net cost: $64/month vs $96 = $32 savings

Better approach: Scheduled scaling
  - Peak (8 AM-6 PM weekdays): 3 runners = $45/month
  - Standard (6 PM-10 PM): 1 runner = $15/month
  - Off-peak (10 PM-8 AM): Scale to 0 = $0
  - Average: ~$30/month

With scaling:
  - Operational cost: $30/month
  - GitHub cost: $4/month
  - Total: $34/month vs $96 = $62/month savings

Combined monthly savings (all phases):
  - Phase 1 & 2: $864
  - Phase 3: $62
  - **Total: $926/month ($11,112/year)**

Total ROI investment: 30 hours × $200/hr = $6,000
Break-even: 6.5 months
Annual value: $11,112
2-year ROI: $16,224
```

---

## Scenario 3: Enterprise

### Current State (No Optimization)

```
Team Size: 200 engineers
Repositories: 500
Workflow runs/day: 5,000
Average job duration: 12 minutes
Jobs per run: 8 jobs (matrix: 4 OS × 2 langs)
Monthly cost: ~$12,000-15,000

Detailed Breakdown:
  - Unit tests: 2,000 runs × 2 langs × 4 OS × 3 min = 48,000 min
  - Integration tests: 1,000 runs × 4 min = 4,000 min
  - Build jobs: 1,000 runs × 10 min = 10,000 min
  - Deploy: 500 runs × 15 min = 7,500 min
  - Windows builds: 500 runs × 20 min = 10,000 min
  - Total: 79,500 minutes/month

  - Included (Enterprise): 50,000 minutes
  - Overage: 29,500 minutes
  - Cost: (29,500 × $0.008 Linux) + (5,000 × $0.016 Windows) = $312 + $80 = ~$392/day
  - Monthly: ~$11,760
```

### Enterprise Optimization Strategy

**Phase 1: Caching & Parallelization (4 weeks, $8,000 cost)**

```
Implementations:
1. Advanced caching (node_modules, pip venv, .gradle, Maven repo)
2. Full job parallelization (reduce serial dependencies)
3. Matrix optimization (test only critical combinations)
4. Docker layer caching
5. Artifact caching across jobs

Results:
  - Test duration: 3 min → 1.5 min (-50%)
  - Build duration: 10 min → 6 min (-40%)
  - Deploy duration: 15 min → 8 min (-45%)
  - Job count reduction: -30% (smart matrix)

  New totals:
  - Unit tests: 48,000 × 50% = 24,000 min
  - Integration: 4,000 × 50% = 2,000 min
  - Builds: 10,000 × 40% = 6,000 min
  - Deploy: 7,500 × 45% = 4,125 min
  - Windows: 10,000 × 40% = 6,000 min
  - Total: 42,125 minutes/month

  - Overage: 42,125 - 50,000 = 0 (within Enterprise limit!)
  - Monthly cost: ~$2,000 (just base plan, no overage)
  - Savings: $11,760 - $2,000 = $9,760/month

  ROI: $8,000 setup / $9,760 savings = 0.8 months to break-even
```

**Phase 2: Self-Hosted Runners (2 months, $15,000 setup)**

```
Architecture:
- 20 self-hosted runners on EKS Auto Mode
- Auto-scaling: 5-20 runners based on queue
- Spot instances for 80% savings
- Cost: ~$200/month average

Migrations:
- Move 70% of workloads to self-hosted
- Keep Enterprise plan for critical/security workflows

Remaining GitHub usage:
  - Security scans: 2,000 min
  - Compliance: 1,000 min
  - Critical deploys: 1,000 min
  - Total: 4,000 min/month

Expected costs:
  - Self-hosted runners: $200/month
  - GitHub minutes (4,000 under limit): $2,000/month
  - Total: $2,200/month vs original $11,760
  - Savings: $9,560/month

ROI: $15,000 setup / $9,560 monthly savings = 1.6 months break-even
```

**Phase 3: Advanced Optimizations (Ongoing)**

```
Ongoing Improvements:
1. Secrets automation & rotation: -10% wasted runs
2. Advanced parallelization patterns: -15% job time
3. Cost monitoring & alerts: Continuous optimization
4. Team training & best practices: -20% inefficient workflows

Expected additional savings:
- Reduced stale runs: $500/month
- Better parallelization: $800/month
- Improved efficiency: $400/month
- Total: $1,700/month additional

**Final State:**
- Monthly savings: $9,560 + $1,700 = $11,260
- Annual savings: $135,120
- 3-year savings: $405,360
- Capital investment: $8,000 + $15,000 = $23,000
- 3-year ROI: 1,761% return
```

---

## Cost Calculator Functions

### Function 1: Calculate Monthly GitHub Actions Cost

```python
def calculate_github_actions_cost(
    plan='free',
    monthly_minutes=0,
    monthly_storage_gb=0,
    job_distribution={'linux': 0.7, 'windows': 0.2, 'macos': 0.1}
):
    """
    Calculate monthly GitHub Actions cost

    Args:
        plan: 'free', 'pro', 'team', 'enterprise'
        monthly_minutes: total minutes used
        monthly_storage_gb: storage used in GB
        job_distribution: proportion of jobs by type

    Returns:
        dict with cost breakdown
    """

    plans = {
        'free': {'minutes': 2000, 'storage': 0.5, 'cost': 0},
        'pro': {'minutes': 3000, 'storage': 1, 'cost': 4},
        'team': {'minutes': 3000, 'storage': 2, 'cost': 12},
        'enterprise': {'minutes': 50000, 'storage': 50, 'cost': 0}  # Custom
    }

    selected_plan = plans.get(plan, plans['free'])

    # Calculate minute overages by type
    overage_minutes = max(0, monthly_minutes - selected_plan['minutes'])

    linux_overage = overage_minutes * job_distribution['linux']
    windows_overage = overage_minutes * job_distribution['windows']
    macos_overage = overage_minutes * job_distribution['macos']

    # Minute costs
    minute_cost = (
        linux_overage * 0.008 +
        windows_overage * 0.016 +
        macos_overage * 0.016
    )

    # Storage overage
    storage_overage = max(0, monthly_storage_gb - selected_plan['storage'])
    storage_cost = storage_overage * 0.008 * 30  # Daily rate × 30 days

    total_cost = selected_plan['cost'] + minute_cost + storage_cost

    return {
        'base_cost': selected_plan['cost'],
        'minute_cost': minute_cost,
        'storage_cost': storage_cost,
        'total_monthly': total_cost,
        'annual': total_cost * 12,
        'breakdown': {
            'included_minutes': selected_plan['minutes'],
            'overage_minutes': overage_minutes,
            'storage_gb': monthly_storage_gb,
            'linux_minutes': int(linux_overage),
            'windows_minutes': int(windows_overage),
            'macos_minutes': int(macos_overage)
        }
    }
```

### Function 2: Calculate Optimization ROI

```python
def calculate_optimization_roi(
    current_monthly_cost,
    setup_hours=10,
    hourly_rate=200,
    optimization_savings_percent=0.5  # 50% savings
):
    """
    Calculate ROI for GitHub Actions optimization

    Args:
        current_monthly_cost: current monthly spend in dollars
        setup_hours: hours needed for setup
        hourly_rate: rate per hour
        optimization_savings_percent: % of cost savings (0.0-1.0)

    Returns:
        dict with ROI metrics
    """

    setup_cost = setup_hours * hourly_rate
    monthly_savings = current_monthly_cost * optimization_savings_percent
    new_monthly_cost = current_monthly_cost - monthly_savings

    months_to_breakeven = setup_cost / monthly_savings if monthly_savings > 0 else float('inf')

    return {
        'setup_cost': setup_cost,
        'monthly_savings': monthly_savings,
        'new_monthly_cost': new_monthly_cost,
        'months_to_breakeven': months_to_breakeven,
        'annual_savings': monthly_savings * 12,
        '3_year_savings': monthly_savings * 12 * 3,
        'roi_percent': (monthly_savings * 12 * 3 - setup_cost) / setup_cost * 100
    }
```

### Function 3: Compare GitHub-Hosted vs Self-Hosted

```python
def compare_github_vs_self_hosted(
    monthly_minutes,
    plan='pro',
    monthly_runs=500,
    job_distribution={'linux': 0.7, 'windows': 0.2, 'macos': 0.1}
):
    """
    Compare costs between GitHub-hosted and self-hosted runners

    Args:
        monthly_minutes: total minutes of CI/CD
        plan: GitHub plan level
        monthly_runs: number of workflow runs
        job_distribution: proportion by OS

    Returns:
        dict comparing both options
    """

    # GitHub-hosted cost
    github_cost_details = calculate_github_actions_cost(
        plan=plan,
        monthly_minutes=monthly_minutes,
        job_distribution=job_distribution
    )
    github_monthly = github_cost_details['total_monthly']

    # Self-hosted cost calculation
    # Assuming t3.medium EC2 instances with autoscaling

    # Estimate runners needed
    # Average job = 10 minutes, assuming 5 parallel jobs per runner
    concurrent_jobs = (monthly_runs * 3) / (60 * 24)  # Roughly
    runners_needed = max(1, int(concurrent_jobs / 5))

    # Cost per runner (t3.medium with autoscaling)
    # On-demand: $0.0832/hour
    # Spot: $0.0416/hour
    # With autoscaling, 70% downtime = avg $30/runner/month

    runner_cost = runners_needed * 30
    setup_cost = runners_needed * 500  # Setup per runner

    # Additional costs
    networking = 50  # Data transfer, logging
    monitoring = 50  # CloudWatch, etc

    self_hosted_monthly = runner_cost + networking + monitoring
    self_hosted_annual = self_hosted_monthly * 12 + setup_cost

    # Keep GitHub for critical jobs
    github_backup_monthly = 100  # Small safety net

    total_self_hosted_monthly = self_hosted_monthly + github_backup_monthly

    return {
        'github_hosted': {
            'monthly': github_monthly,
            'annual': github_monthly * 12
        },
        'self_hosted': {
            'runners_needed': runners_needed,
            'monthly': total_self_hosted_monthly,
            'annual': total_self_hosted_monthly * 12,
            'setup_cost': setup_cost
        },
        'comparison': {
            'monthly_savings': max(0, github_monthly - total_self_hosted_monthly),
            'annual_savings': max(0, (github_monthly - total_self_hosted_monthly) * 12),
            'break_even_months': setup_cost / max(1, github_monthly - total_self_hosted_monthly),
            'recommendation': 'self_hosted' if github_monthly > total_self_hosted_monthly else 'github_hosted'
        }
    }
```

---

## Real-World Examples

### Example 1: SaaS Startup ($500/month spend)

```
Current: $500/month (Pro plan with overages)

Quick Optimization (1 week):
- Dependency caching
- Parallelize jobs
- Reduce matrix

Result: 60% cost reduction
- New cost: $200/month
- Monthly savings: $300
- Annual savings: $3,600
- ROI: 10 hours × $200 = $2,000 → Break-even: 6.7 months
```

### Example 2: Mid-Market Company ($5,000/month spend)

```
Current: $5,000/month (Team plan with heavy overages)

Phased Optimization (8 weeks):
1. Phase 1 (Week 1-2): Caching & parallelization
   - Time: 20 hours
   - Savings: $2,500/month (-50%)

2. Phase 2 (Week 3-8): Self-hosted runners
   - Time: 40 hours
   - Setup: $5,000
   - Savings: $3,500/month (-70% from original)

Total investment: 60 hours + $5,000
Total savings: $3,500/month = $42,000/year
Break-even: 1.4 months
2-year value: $89,000
```

### Example 3: Enterprise ($15,000/month spend)

```
Current: $15,000/month (Enterprise plan + major overages)

Comprehensive Optimization (12 weeks):
1. Quick wins: $5,000/month savings
2. Self-hosted runners: $7,000/month savings
3. Advanced patterns: $2,000/month savings

Total: $14,000/month savings (93% reduction)

Investment: 100 hours consulting + $50,000 infrastructure
Annual savings: $168,000
Break-even: 3.6 months
3-year value: $504,000
```

---

## Decision Matrix

| Factor | GitHub-Hosted | Self-Hosted |
|--------|-----------------|-------------|
| Setup Time | 0 hours | 10-20 hours |
| Maintenance | None | 5 hours/month |
| Cost (low usage <1k min) | $0-50/month | $500+/month |
| Cost (high usage >10k min) | $1,000+/month | $200-400/month |
| Scalability | Managed | Manual |
| Security | Good | Excellent |
| Customization | Limited | Full |
| Support | GitHub | Self/Community |

**When to use GitHub-Hosted:**
- Usage under 500 minutes/month
- Security-critical, audit-required workflows
- macOS-only builds
- Minimal DevOps resources

**When to use Self-Hosted:**
- Usage over 5,000 minutes/month
- Custom build environments needed
- Resource cost matters
- Team has DevOps expertise

**Hybrid Approach (Recommended for Enterprise):**
- GitHub: Security, compliance, critical paths
- Self-Hosted: General CI/CD, heavy builds
- Cost ratio: ~70% self-hosted, ~30% GitHub-hosted

---

## Monitoring & Continuous Optimization

### Key Metrics to Track

```
Weekly Report:
- Total minutes used
- Cost per job (trending)
- Cache hit rate (target: >75%)
- Average job duration (trending downward)
- Workflow success rate
- Failed job frequency

Monthly Report:
- Total cost vs budget
- Cost per engineer
- Cost per commit
- ROI of optimizations
- Recommendations for next phase
```

### Cost Alerts

```yaml
name: Cost Alert
on:
  schedule:
    - cron: '0 9 * * *'  # Daily at 9 AM

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - name: Check estimated daily cost
        run: |
          DAILY_COST=$(curl -s "https://api.github.com/repos/${{ github.repository }}/actions/billing/usage" \
            -H "Authorization: token ${{ secrets.GH_TOKEN }}" \
            | jq '.billing.total_paid_minutes * 0.008 / 30')

          if (( $(echo "$DAILY_COST > 50" | bc -l) )); then
            echo "⚠️ High cost alert: $DAILY_COST/day"
          fi
```

---
