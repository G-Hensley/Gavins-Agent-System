#!/usr/bin/env bash
# run-eval.sh — Execute evals for Gavin's Agent System
#
# Usage:
#   ./run-eval.sh <target>            Run a specific tier or review challenge
#   ./run-eval.sh all                 Run every eval
#   ./run-eval.sh --list              List all available evals
#   ./run-eval.sh --results           Show summary of past eval runs
#   ./run-eval.sh --help              Show this message
#
# Target examples:
#   tier-1
#   tier-2
#   tier-3
#   tier-4
#   review-challenges/sql-injection
#   review-challenges/xss-vulnerability

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/results"
TIMESTAMP="$(date +%Y%m%dT%H%M%S)"

TIERS=(
  "tier-1-single-agent"
  "tier-2-multi-agent"
  "tier-3-architecture-first"
  "tier-4-full-workflow"
)

REVIEW_CHALLENGES=(
  "review-challenges/sql-injection"
  "review-challenges/overpermissive-iam"
  "review-challenges/xss-vulnerability"
  "review-challenges/dependency-vuln"
  "review-challenges/spec-deviation"
  "review-challenges/code-quality-issues"
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

usage() {
  # Print the header comment block at the top of the file (lines 2-18)
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

list_evals() {
  echo "Available evals:"
  echo ""
  echo "Tiers:"
  for tier in "${TIERS[@]}"; do
    echo "  ${tier}"
  done
  echo ""
  echo "Review challenges:"
  for challenge in "${REVIEW_CHALLENGES[@]}"; do
    echo "  ${challenge}"
  done
  echo ""
  echo "Meta targets:"
  echo "  all"
  exit 0
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

get_git_sha() {
  git -C "${SCRIPT_DIR}" rev-parse --short HEAD 2>/dev/null || echo "unknown"
}

# ---------------------------------------------------------------------------
# Result scaffolding
# ---------------------------------------------------------------------------

# write_result_scaffold <run_dir> <eval_id>
# Creates a result.json template for the given run. Token values and findings
# are left null/empty — to be filled in manually or by a future integration.
write_result_scaffold() {
  local run_dir="$1"
  local eval_id="$2"
  local iso_date
  iso_date="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local git_sha
  git_sha="$(get_git_sha)"

  cat > "${run_dir}/result.json" <<JSON
{
  "eval": "${eval_id}",
  "date": "${iso_date}",
  "git_sha": "${git_sha}",
  "status": "pending",
  "agents_dispatched": [],
  "metrics": {
    "total_tokens": null,
    "duration_seconds": null,
    "review_cycles": null
  },
  "findings": [],
  "notes": ""
}
JSON
}

# ---------------------------------------------------------------------------
# Results summary
# ---------------------------------------------------------------------------

show_results() {
  if [[ ! -d "${RESULTS_DIR}" ]]; then
    echo "No results directory found at ${RESULTS_DIR}"
    exit 0
  fi

  local found=0

  printf "%-50s  %-24s  %-10s  %-8s  %s\n" "EVAL" "DATE" "STATUS" "GIT_SHA" "NOTES"
  printf '%s\n' "$(python3 -c 'print("-" * 110)' 2>/dev/null || printf '%0.s-' $(seq 1 110))"

  while IFS= read -r result_file; do
    found=1
    # Extract fields using python3 for portable JSON parsing
    if command -v python3 &>/dev/null; then
      python3 - "${result_file}" <<'PYEOF'
import json, sys
try:
    with open(sys.argv[1]) as f:
        d = json.load(f)
    eval_id   = d.get("eval", "unknown")[:49]
    date_val  = d.get("date", "")[:23]
    status    = d.get("status", "unknown")[:9]
    git_sha   = d.get("git_sha", "")[:7]
    notes     = (d.get("notes") or "")[:40]
    print(f"{eval_id:<50}  {date_val:<24}  {status:<10}  {git_sha:<8}  {notes}")
except Exception as e:
    print(f"  (could not parse {sys.argv[1]}: {e})")
PYEOF
    else
      # Fallback: print the raw path if python3 unavailable
      echo "  ${result_file}"
    fi
  done < <(find "${RESULTS_DIR}" -name "result.json" | sort)

  if [[ "${found}" -eq 0 ]]; then
    echo "No past eval results found in ${RESULTS_DIR}"
  fi

  exit 0
}

validate_target() {
  local target="$1"
  [[ -z "${target}" ]] && die "No target specified. Run with --help for usage."

  # Normalize tier shorthand (e.g. "tier-1" -> "tier-1-single-agent")
  case "${target}" in
    tier-1) target="tier-1-single-agent" ;;
    tier-2) target="tier-2-multi-agent" ;;
    tier-3) target="tier-3-architecture-first" ;;
    tier-4) target="tier-4-full-workflow" ;;
  esac

  # Check existence
  if [[ "${target}" != "all" ]]; then
    local path="${SCRIPT_DIR}/${target}"
    [[ -d "${path}" ]] || die "Target not found: ${path}"
  fi

  echo "${target}"
}

make_results_dir() {
  local target_slug="${1//\//-}"
  local run_dir="${RESULTS_DIR}/${TIMESTAMP}-${target_slug}"
  mkdir -p "${run_dir}"
  echo "${run_dir}"
}

# ---------------------------------------------------------------------------
# Execution stubs
# ---------------------------------------------------------------------------

run_tier() {
  local tier="$1"
  local run_dir="$2"
  local tier_path="${SCRIPT_DIR}/${tier}"

  echo "[run-eval] Target: ${tier}"
  echo "[run-eval] Results: ${run_dir}"
  echo "[run-eval] Eval directory: ${tier_path}"
  echo ""

  # TODO: iterate over prompts in tier directory and execute each against the agent system
  echo "[run-eval] PLACEHOLDER — would run all prompts under ${tier_path}/"
  echo "[run-eval] Results would be written to ${run_dir}/"

  write_result_scaffold "${run_dir}" "${tier}"
  echo "[run-eval] Wrote result scaffold to ${run_dir}/result.json"
}

run_review_challenge() {
  local challenge="$1"
  local run_dir="$2"
  local challenge_path="${SCRIPT_DIR}/${challenge}"

  echo "[run-eval] Target: ${challenge}"
  echo "[run-eval] Results: ${run_dir}"
  echo "[run-eval] Challenge directory: ${challenge_path}"
  echo ""

  # TODO: load prompt.md, send artifact + prompt to the target reviewer agent, score output against rubric.md
  echo "[run-eval] PLACEHOLDER — would dispatch reviewer agent for ${challenge_path}/"
  echo "[run-eval] Results would be written to ${run_dir}/"

  write_result_scaffold "${run_dir}" "${challenge}"
  echo "[run-eval] Wrote result scaffold to ${run_dir}/result.json"
}

run_all() {
  local run_dir
  run_dir="$(make_results_dir all)"

  echo "[run-eval] Running all evals"
  echo "[run-eval] Results root: ${run_dir}"
  echo ""

  for tier in "${TIERS[@]}"; do
    echo "--- ${tier} ---"
    run_tier "${tier}" "${run_dir}/${tier}"
    echo ""
  done

  for challenge in "${REVIEW_CHALLENGES[@]}"; do
    local slug="${challenge//\//-}"
    echo "--- ${challenge} ---"
    run_review_challenge "${challenge}" "${run_dir}/${slug}"
    echo ""
  done

  echo "[run-eval] All evals complete. Results in ${run_dir}/"
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

main() {
  local arg="${1:-}"

  case "${arg}" in
    --help|-h)    usage ;;
    --list|-l)    list_evals ;;
    --results|-r) show_results ;;
    all)       run_all ;;
    "")        die "No target specified. Run with --help for usage." ;;
    *)
      local target
      target="$(validate_target "${arg}")"
      local run_dir
      run_dir="$(make_results_dir "${target}")"

      # Route to the right runner
      if [[ "${target}" == review-challenges/* ]]; then
        run_review_challenge "${target}" "${run_dir}"
      else
        run_tier "${target}" "${run_dir}"
      fi
      ;;
  esac
}

main "$@"
