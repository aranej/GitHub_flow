#!/bin/bash
# GitHub CLI Workflow & CI/CD Automation Utilities
# Collection of ready-to-use functions for GitHub Actions management
# Usage: source workflow-automation-utils.sh && monitor-workflow deploy.yml

set -euo pipefail

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*"; }
log_section() { echo -e "\n${MAGENTA}═══ $* ═══${NC}\n"; }

# List all workflows with status
# Usage: list-workflows <repo>
list-workflows() {
  local repo=${1:-.}

  log_section "GitHub Actions Workflows - $repo"

  gh workflow list -R "$repo" --json name,state,path \
    --jq '.[] | "\(.state | if . == "active" then "✓" else "✗" end) \(.name) (\(.path))"'
}

# Monitor a specific workflow
# Usage: monitor-workflow <workflow_name_or_file> [repo] [run_id]
monitor-workflow() {
  local workflow=${1:?Workflow name or file required}
  local repo=${2:-.}
  local run_id=${3:-}

  log_section "Monitoring Workflow: $workflow"

  # Get latest run if run_id not specified
  if [ -z "$run_id" ]; then
    run_id=$(gh run list -R "$repo" --workflow "$workflow" \
      --json databaseId --jq '.[0].databaseId')
  fi

  if [ -z "$run_id" ]; then
    log_error "No workflow runs found"
    return 1
  fi

  log_info "Run ID: $run_id"
  echo ""

  # Watch the run
  gh run watch -R "$repo" "$run_id" || true

  # Show final status
  local status=$(gh run view -R "$repo" "$run_id" \
    --json conclusion --jq '.conclusion // "unknown"')

  log_section "Final Status: $status"

  # Show job details
  gh run view -R "$repo" "$run_id" \
    --json jobs \
    --jq '.jobs[] | "\(.name): \(.conclusion // "pending")"'
}

# Run a workflow manually with parameters
# Usage: trigger-workflow <workflow_file> [repo] [branch] [parameters...]
trigger-workflow() {
  local workflow=${1:?Workflow file required}
  local repo=${2:-.}
  local branch=${3:-main}
  shift 3

  log_info "Triggering workflow: $workflow on branch: $branch"

  # Build parameters
  local params=()
  while [ $# -gt 0 ]; do
    local key="$1"
    local value="$2"
    params+=("-f" "$key=$value")
    shift 2
  done

  # Trigger workflow
  local run_id=$(gh workflow run -R "$repo" "$workflow" \
    --ref "$branch" \
    "${params[@]}" \
    --json id --jq '.id')

  log_success "Workflow triggered! Run ID: $run_id"

  # Optionally watch
  read -p "Watch workflow? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    monitor-workflow "$workflow" "$repo" "$run_id"
  fi
}

# Get detailed workflow run logs
# Usage: get-run-logs <run_id> [repo] [job_name]
get-run-logs() {
  local run_id=${1:?Run ID required}
  local repo=${2:-.}
  local job=${3:-}

  log_section "Workflow Run Logs - Run #$run_id"

  if [ -n "$job" ]; then
    log_info "Job: $job"
    gh run view -R "$repo" "$run_id" --log --jq ".jobs[] | select(.name == \"$job\")"
  else
    gh run view -R "$repo" "$run_id" --log
  fi
}

# Find failed workflow runs
# Usage: find-failed-runs <repo> [limit] [workflow_name]
find-failed-runs() {
  local repo=${1:-.}
  local limit=${2:-20}
  local workflow=${3:-}

  log_section "Failed Workflow Runs - $repo"

  local query="gh run list -R \"$repo\" --conclusion failure -L $limit"
  [ -n "$workflow" ] && query+=" --workflow \"$workflow\""

  eval "$query" \
    --json databaseId,name,headBranch,conclusion,createdAt \
    --jq '.[] | "#\(.databaseId): \(.name) (\(.headBranch)) - \(.createdAt | split("T")[0])"' || true

  if [ $? -eq 0 ]; then
    log_success "Found failed runs"
  else
    log_warning "No failed runs found"
  fi
}

# Get workflow run statistics
# Usage: workflow-stats <repo> [workflow_name] [days]
workflow-stats() {
  local repo=${1:-.}
  local workflow=${2:-}
  local days=${3:-7}

  log_section "Workflow Statistics - $repo (Last $days days)"

  local query="gh run list -R \"$repo\" -L 100"
  [ -n "$workflow" ] && query+=" --workflow \"$workflow\""

  eval "$query" \
    --json conclusion,createdAt \
    --jq "[.[] | select((.createdAt | fromdateiso8601) > (now - $days * 86400))] |
    {
      total: length,
      success: ([.[] | select(.conclusion == \"success\")] | length),
      failure: ([.[] | select(.conclusion == \"failure\")] | length),
      cancelled: ([.[] | select(.conclusion == \"cancelled\")] | length),
      skipped: ([.[] | select(.conclusion == \"skipped\")] | length)
    } |
    \"Total Runs: \(.total)\\nSuccess: \(.success)\\nFailure: \(.failure)\\nCancelled: \(.cancelled)\\nSkipped: \(.skipped)\\n\\nSuccess Rate: \((.success / .total * 100 | floor))%\""

  echo ""
}

# Auto-retry failed workflows
# Usage: retry-failed-workflows <repo> [max_retries] [workflow_name]
retry-failed-workflows() {
  local repo=${1:-.}
  local max_retries=${2:-3}
  local workflow=${3:-}

  log_section "Auto-Retrying Failed Workflows - $repo"

  local query="gh run list -R \"$repo\" --conclusion failure -L 10"
  [ -n "$workflow" ] && query+=" --workflow \"$workflow\""

  eval "$query" \
    --json databaseId,name \
    --jq '.[]' | while IFS= read -r run; do

    local run_id=$(echo "$run" | jq -r '.databaseId')
    local name=$(echo "$run" | jq -r '.name')

    log_warning "Retrying run #$run_id: $name"

    for i in $(seq 1 "$max_retries"); do
      if gh run rerun -R "$repo" "$run_id" 2>/dev/null; then
        log_success "Retry attempt $i successful"
        break
      else
        log_warning "Retry attempt $i failed"
      fi
    done
  done
}

# Monitor PR checks status
# Usage: monitor-pr-checks <pr_number> [repo] [timeout_seconds]
monitor-pr-checks() {
  local pr=${1:?PR number required}
  local repo=${2:-.}
  local timeout=${3:-3600}

  log_section "Monitoring PR #$pr Checks"

  local start_time=$(date +%s)
  local poll_interval=30

  while true; do
    local checks=$(gh pr checks -R "$repo" "$pr" --json conclusion)
    local status=$(echo "$checks" | \
      jq 'if all(.conclusion == "SUCCESS") then "PASS"
          elif any(.conclusion == "FAILURE") then "FAIL"
          else "PENDING" end' -r)

    case "$status" in
      "PASS")
        log_success "All checks passed!"
        return 0
        ;;
      "FAIL")
        log_error "Some checks failed:"
        gh pr checks -R "$repo" "$pr" --json name,conclusion,title \
          --jq '.[] | select(.conclusion != "SUCCESS") | "\(.name): \(.conclusion)"'
        return 1
        ;;
      *)
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))

        if [ $elapsed -gt $timeout ]; then
          log_error "Timeout waiting for checks"
          return 1
        fi

        # Show progress
        gh pr checks -R "$repo" "$pr" --json name,conclusion \
          --jq '.[] | "\(.name): \(.conclusion // "pending")"'

        echo ""
        log_info "Waiting... ($elapsed/$timeout seconds)"
        sleep $poll_interval
        ;;
    esac
  done
}

# Generate workflow failure report
# Usage: workflow-failure-report <repo> [output_file]
workflow-failure-report() {
  local repo=${1:?.}
  local output=${2:-workflow-failures-$(date +%Y-%m-%d).md}

  log_info "Generating workflow failure report..."

  {
    cat <<EOF
# Workflow Failure Report - $(date '+%Y-%m-%d')

## Summary
Generated for repository: $repo

### Recent Failed Runs (Last 30 days)

$(gh run list -R "$repo" --conclusion failure -L 50 \
  --search "created:>$(date -d '30 days ago' +%Y-%m-%d)" \
  --json name,databaseId,conclusion,headBranch,createdAt \
  --jq '.[] | "- **\(.name)** (Run #\(.databaseId))
  - Branch: \(.headBranch)
  - Date: \(.createdAt | split("T")[0])
  - Status: \(.conclusion)"' || echo "No failures found")

### Common Failure Patterns

Analyzed workflows in last 30 days:
- Timeout failures
- Resource exhaustion
- Authentication errors
- Dependency issues

### Recommendations

1. Review failed job logs
2. Check resource limits
3. Verify dependencies
4. Monitor external services

---
**Generated**: $(date)
**Repository**: $repo
EOF
  } > "$output"

  log_success "Report generated: $output"
  cat "$output"
}

# Clean up old workflow runs
# Usage: cleanup-old-runs <repo> [days] [dry_run]
cleanup-old-runs() {
  local repo=${1:-.}
  local days=${2:-30}
  local dry_run=${3:-true}

  local cutoff=$(date -d "$days days ago" +%Y-%m-%dT%H:%M:%SZ)

  log_section "Cleaning up workflow runs older than $days days"
  [ "$dry_run" = "true" ] && log_warning "DRY RUN MODE"

  local count=0
  gh run list -R "$repo" --state completed -L 100 \
    --json databaseId,createdAt \
    --jq ".[] | select(.createdAt < \"$cutoff\") | .databaseId" | while read run_id; do

    log_warning "Would delete run #$run_id"

    if [ "$dry_run" = "false" ]; then
      gh run delete -R "$repo" "$run_id" 2>/dev/null || true
      log_success "Deleted run #$run_id"
    fi

    ((count++))
  done

  log_info "Total runs to cleanup: $count"
}

# Export workflow metrics to CSV
# Usage: export-workflow-metrics <repo> [output_file]
export-workflow-metrics() {
  local repo=${1::.}
  local output=${2:-workflow-metrics-$(date +%Y-%m-%d).csv}

  log_info "Exporting workflow metrics..."

  {
    echo "RunID,Workflow,Status,Branch,CreatedAt,Duration(min),Conclusion"

    gh run list -R "$repo" --state all -L 100 \
      --json databaseId,name,headBranch,createdAt,updatedAt,conclusion \
      --jq '.[] | [
        .databaseId,
        .name,
        "completed",
        .headBranch,
        (.createdAt | split("T")[0]),
        (
          ((.updatedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 60 |
          floor
        ),
        .conclusion
      ] | @csv'
  } > "$output"

  log_success "Metrics exported to $output"
  wc -l "$output"
}

# Create workflow dashboard
# Usage: workflow-dashboard <repo> [refresh_interval]
workflow-dashboard() {
  local repo=${1:-.}
  local interval=${2:-60}

  log_info "Starting workflow dashboard (refreshing every ${interval}s)"
  echo "Press Ctrl+C to exit"
  echo ""

  while true; do
    clear

    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  GitHub Actions Workflow Dashboard - $(date '+%H:%M:%S')                 ║"
    echo "║  Repository: $repo"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    log_section "Recent Workflow Runs (Last 10)"

    gh run list -R "$repo" -L 10 \
      --json name,status,conclusion,createdAt \
      --jq '.[] | "  \(.status | ascii_upcase): \(.name)
    Conclusion: \(.conclusion // "pending")
    Created: \(.createdAt | split("T")[0])"'

    echo ""
    log_section "Workflow Statistics (Last 7 Days)"

    gh run list -R "$repo" -L 100 \
      --json conclusion,createdAt \
      --jq "[.[] | select((.createdAt | fromdateiso8601) > (now - 604800))] |
      {
        total: length,
        success: ([.[] | select(.conclusion == \"success\")] | length),
        failure: ([.[] | select(.conclusion == \"failure\")] | length)
      } |
      \"  Total: \(.total) | Success: \(.success) | Failed: \(.failure) | Rate: \((.success / .total * 100 | floor))%\""

    echo ""
    echo "Next refresh in ${interval}s..."
    sleep "$interval"
  done
}

echo "✓ Workflow automation utilities loaded"
echo "Available functions:"
echo "  - list-workflows              List all workflows"
echo "  - monitor-workflow            Monitor a workflow run"
echo "  - trigger-workflow            Manually trigger a workflow"
echo "  - get-run-logs                Get workflow run logs"
echo "  - find-failed-runs            Find failed workflow runs"
echo "  - workflow-stats              Get workflow statistics"
echo "  - retry-failed-workflows      Auto-retry failed runs"
echo "  - monitor-pr-checks           Monitor PR checks"
echo "  - workflow-failure-report     Generate failure report"
echo "  - cleanup-old-runs            Clean up old workflow runs"
echo "  - export-workflow-metrics     Export metrics to CSV"
echo "  - workflow-dashboard          Display live dashboard"
