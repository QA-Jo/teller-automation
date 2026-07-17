#!/bin/bash
# ============================================================
# run_all.sh — Module-ordered test runner with rate-limit protection
#
# Execution order (safest → most rate-limited):
#   reports → customers → accounts → transactions → products → loans → auth
#
# Auth suites run one-by-one with a configurable gap between them
# during regression runs to avoid hitting the 10-attempt/15-min IP block.
#
# See run_config.yaml for full execution strategy reference.
#
# Usage:
#   bash run_all.sh                                              # smoke, all banks
#   bash run_all.sh --tag smoke                                  # smoke, all banks
#   bash run_all.sh --tag regression                             # regression, all banks
#   bash run_all.sh --bank rural-bank-san-antonio                # one bank, smoke
#   bash run_all.sh --bank rural-bank-san-antonio --tag smoke    # one bank, smoke
#   bash run_all.sh --module reports                             # one module, smoke
#   bash run_all.sh --module auth --tag smoke                    # auth smoke, all banks
#   bash run_all.sh --module auth --tag regression               # auth regression (with 60s gaps)
#   bash run_all.sh --tag smoke --exclude reset-password         # smoke, skip reset-password
#   bash run_all.sh --help
# ============================================================

set -euo pipefail

# Auto-activate .venv if robot is not already from the venv
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/.venv/bin/activate" && "$(which robot)" != "${SCRIPT_DIR}/.venv/bin/robot" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/.venv/bin/activate"
fi

# ============================================================
# Configuration
# ============================================================

ALL_BANKS=(
  "rural-bank-san-antonio"
  "banco-abucay"
  "rural-bank-hermosa"
  "alegre"
)

# Non-auth modules in safe execution order
NON_AUTH_MODULES=(
  "reports:tests/6_reports"
  "customers:tests/2_customers"
  "accounts:tests/3_accounts"
  "transactions:tests/4_transactions"
  "products:tests/5_products"
  "loans:tests/7_loans"
)

# Auth suites in execution order (login first, reset-password last)
AUTH_SUITES=(
  "tests/1_auth/t1.2_login.robot"
  "tests/1_auth/t1.3_forgot_password.robot"
  "tests/1_auth/t1.4_change_password.robot"
  "tests/1_auth/t1.1_reset_password.robot"
)

# Sleep between auth suites during regression (seconds)
# Regression includes negative tests that count toward the 10/15-min rate limit.
AUTH_REGRESSION_SLEEP=60

# ============================================================
# Helpers
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASSED]${NC} $*"; }
fail() { echo -e "  ${RED}[FAILED]${NC} $*"; GLOBAL_FAIL=1; }
skip() { echo -e "  ${YELLOW}[SKIP]${NC}   $*"; }
info() { echo -e "  ${CYAN}[INFO]${NC}   $*"; }
header() { echo -e "\n${BOLD}$*${NC}"; }

usage() {
  echo ""
  echo "Usage: bash run_all.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --bank <id>         Run for a specific bank only"
  echo "                      IDs: rural-bank-san-antonio | banco-abucay | rural-bank-hermosa | alegre"
  echo "  --module <name>     Run a specific module only"
  echo "                      Names: reports | customers | accounts | transactions | products | loans | auth"
  echo "  --tag <tag>         Include only tests with this tag  (default: smoke)"
  echo "  --exclude <tag>     Exclude tests with this tag"
  echo "  --help              Show this help message"
  echo ""
  echo "Examples:"
  echo "  bash run_all.sh                                              # smoke, all banks"
  echo "  bash run_all.sh --tag regression                             # regression, all banks"
  echo "  bash run_all.sh --bank rural-bank-san-antonio --tag smoke    # one bank, smoke"
  echo "  bash run_all.sh --module auth --tag regression               # auth regression (60s gaps)"
  echo "  bash run_all.sh --tag smoke --exclude reset-password         # smoke, skip reset-password"
  echo "  bash run_all.sh --module reports --tag smoke                 # reports module only"
  echo ""
  exit 0
}

# ============================================================
# Argument parsing
# ============================================================

TAG="smoke"
BANK_FILTER=""
MODULE_FILTER=""
EXCLUDE_TAG=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --tag)     TAG="$2";           shift 2 ;;
    --bank)    BANK_FILTER="$2";   shift 2 ;;
    --module)  MODULE_FILTER="$2"; shift 2 ;;
    --exclude) EXCLUDE_TAG="$2";   shift 2 ;;
    --help|-h) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# ============================================================
# Build robot command arguments
# ============================================================

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
GLOBAL_FAIL=0

build_robot_args() {
  local var_file="$1"
  local output_dir="$2"
  local args="-V ${var_file} -d ${output_dir}"

  [[ -n "$TAG" ]]         && args+=" --include ${TAG}"
  [[ -n "$EXCLUDE_TAG" ]] && args+=" --exclude ${EXCLUDE_TAG}"

  echo "$args"
}

# ============================================================
# Runner functions
# ============================================================

run_non_auth_module() {
  local module_name="$1"
  local module_path="$2"
  local var_file="$3"
  local output_dir="results/${TIMESTAMP}/${BANK_ID}/${module_name}"

  header "    ┌─ MODULE: ${module_name}"
  local args
  args=$(build_robot_args "$var_file" "$output_dir")

  # shellcheck disable=SC2086
  if robot $args "$module_path"; then
    pass "${module_name}"
  else
    fail "${module_name} (check ${output_dir}/log.html)"
  fi
}

run_auth_module() {
  local var_file="$1"

  # Determine sleep between suites
  local sleep_secs=0
  if [[ "$TAG" == "regression" ]]; then
    sleep_secs=$AUTH_REGRESSION_SLEEP
    info "Auth regression mode — ${sleep_secs}s gap between suites (rate-limit protection)"
  else
    info "Auth smoke mode — no inter-suite sleep needed"
  fi

  local first=true
  for suite in "${AUTH_SUITES[@]}"; do
    local suite_name
    suite_name=$(basename "$suite" .robot)

    # Skip reset-password if excluded
    if [[ -n "$EXCLUDE_TAG" && "$suite" == *"t1.1"* && "$EXCLUDE_TAG" == *"reset-password"* ]]; then
      skip "${suite_name} (excluded by --exclude ${EXCLUDE_TAG})"
      continue
    fi

    # Sleep between suites (not before the first one)
    if [[ "$first" == false && "$sleep_secs" -gt 0 ]]; then
      echo ""
      info "Sleeping ${sleep_secs}s before next auth suite to respect rate limit..."
      sleep "$sleep_secs"
    fi
    first=false

    local output_dir="results/${TIMESTAMP}/${BANK_ID}/auth/${suite_name}"
    local args
    args=$(build_robot_args "$var_file" "$output_dir")

    header "    ┌─ SUITE: ${suite_name}"
    # shellcheck disable=SC2086
    if robot $args "$suite"; then
      pass "${suite_name}"
    else
      fail "${suite_name} (check ${output_dir}/log.html)"
    fi
  done
}

# ============================================================
# Determine which banks to run
# ============================================================

if [[ -n "$BANK_FILTER" ]]; then
  BANKS=("$BANK_FILTER")
else
  BANKS=("${ALL_BANKS[@]}")
fi

# ============================================================
# Main execution loop
# ============================================================

echo ""
echo "============================================================"
echo "  Teller Automation — ${TIMESTAMP}"
echo "  Tag     : ${TAG}"
echo "  Exclude : ${EXCLUDE_TAG:-none}"
echo "  Bank    : ${BANK_FILTER:-all}"
echo "  Module  : ${MODULE_FILTER:-all}"
echo "============================================================"

for BANK_ID in "${BANKS[@]}"; do
  VAR_FILE="resources/variables/${BANK_ID}.yaml"

  if [[ ! -f "$VAR_FILE" ]]; then
    echo ""
    fail "Variable file not found: ${VAR_FILE} — skipping bank ${BANK_ID}"
    continue
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  BANK: ${BANK_ID}  |  $(date '+%H:%M:%S')"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # --- Non-auth modules (no rate-limit risk) ---
  if [[ -z "$MODULE_FILTER" || "$MODULE_FILTER" != "auth" ]]; then
    for entry in "${NON_AUTH_MODULES[@]}"; do
      mod_name="${entry%%:*}"
      mod_path="${entry##*:}"

      # Filter by --module if specified
      if [[ -n "$MODULE_FILTER" && "$MODULE_FILTER" != "$mod_name" ]]; then
        continue
      fi

      run_non_auth_module "$mod_name" "$mod_path" "$VAR_FILE"
    done
  fi

  # --- Auth module (rate-limited — always runs last) ---
  if [[ -z "$MODULE_FILTER" || "$MODULE_FILTER" == "auth" ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  MODULE: auth  [rate-limited — running suites sequentially]"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    run_auth_module "$VAR_FILE"
  fi

done

# ============================================================
# Summary
# ============================================================

echo ""
echo "============================================================"
if [[ "$GLOBAL_FAIL" -eq 0 ]]; then
  echo -e "  ${GREEN}${BOLD}ALL RUNS PASSED${NC}"
else
  echo -e "  ${RED}${BOLD}SOME RUNS FAILED — check results/${TIMESTAMP}/*/log.html${NC}"
fi
echo "  Results saved: results/${TIMESTAMP}/"
echo "============================================================"
echo ""

exit "$GLOBAL_FAIL"
