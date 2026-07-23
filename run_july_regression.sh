#!/bin/bash
# ============================================================
# run_july_regression.sh — Run regression per TEST CASE FILE
#
# Produces one report per TC (t2.1, t6.1, t7.1, ...) so the
# published index shows them individually under the banner:
#
#     July Regression testing
#       t2.1  report ->
#       t6.1  report ->
#       ...
#
# Output layout:
#   results/July-Regression/<tc>/report.html
#
# Usage:
#   bash run_july_regression.sh                         # all TCs, rural-bank-san-antonio
#   bash run_july_regression.sh --bank <bank-id>        # different bank
#   bash run_july_regression.sh --exclude 7_loans       # skip a module dir (repeatable)
#   bash run_july_regression.sh t6.1 t7.1               # only these TC(s)
#
# After it finishes, publish with the banner title:
#   bash publish_reports.sh --timestamp July-Regression --title "July Regression testing"
# ============================================================

set -uo pipefail

# Auto-activate .venv if robot is not already from the venv
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/.venv/bin/activate" && "$(which robot)" != "${SCRIPT_DIR}/.venv/bin/robot" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/.venv/bin/activate"
fi

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

BANK_ID="rural-bank-san-antonio"
RUN_NAME="2026-07_regression-pre-deployment-to-sbx"
EXCLUDES=()
ONLY_TCS=()
# Tags to include. These suites tag tests by type (smoke/type1), not "regression",
# so default to the same set the manual commands use. Override with --tag (repeatable).
INCLUDE_TAGS=("smoke" "type1")
TAG_OVERRIDE=()
# When true, nest output under a per-bank sub-folder: results/<run>/<bank>/<tc>/
# Lets several banks share one run folder (multi-bank smoke). Off by default so
# the single-bank regression layout (results/<run>/<tc>/) is unchanged.
NEST_BANK=false
# Seconds to pause between TC-file executions (rate-limit protection for
# throttled envs like ITG/SIT). 0 = no gap. Matches the pacing used for the
# San Antonio ITG runs. Intra-suite pacing already lives in the resource files.
SLEEP_BETWEEN=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --bank)      BANK_ID="$2"; shift 2 ;;
    --run)       RUN_NAME="$2"; shift 2 ;;
    --exclude)   EXCLUDES+=("$2"); shift 2 ;;
    --tag)       TAG_OVERRIDE+=("$2"); shift 2 ;;
    --nest-bank) NEST_BANK=true; shift ;;
    --sleep)     SLEEP_BETWEEN="$2"; shift 2 ;;
    t[0-9]*)     ONLY_TCS+=("$1"); shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Apply tag override if provided
[[ ${#TAG_OVERRIDE[@]} -gt 0 ]] && INCLUDE_TAGS=("${TAG_OVERRIDE[@]}")

# Build --include flags
INCLUDE_FLAGS=()
for t in "${INCLUDE_TAGS[@]}"; do INCLUDE_FLAGS+=(--include "$t"); done

VAR_FILE="${SCRIPT_DIR}/resources/variables/${BANK_ID}.yaml"
[[ -f "$VAR_FILE" ]] || { echo -e "${RED}Variable file not found: ${VAR_FILE}${NC}"; exit 1; }

OUT_ROOT="${SCRIPT_DIR}/results/${RUN_NAME}"

echo ""
echo "============================================================"
echo "  July Regression testing — per-TC run"
echo "  Bank   : ${BANK_ID}"
echo "  Output : results/${RUN_NAME}/<tc>/"
echo "  Tags   : ${INCLUDE_TAGS[*]}"
[[ ${#EXCLUDES[@]} -gt 0 ]] && echo "  Skip   : ${EXCLUDES[*]}"
[[ ${#ONLY_TCS[@]} -gt 0 ]] && echo "  Only   : ${ONLY_TCS[*]}"
echo "============================================================"

PASS_TCS=(); FAIL_TCS=(); SKIP_TCS=()

# Discover all test files, sorted
while IFS= read -r file; do
  base="$(basename "$file")"
  tc="$(echo "$base" | grep -oE '^t[0-9]+\.[0-9]+')"
  [[ -z "$tc" ]] && continue

  # --only filter
  if [[ ${#ONLY_TCS[@]} -gt 0 ]]; then
    match=0
    for want in "${ONLY_TCS[@]}"; do [[ "$tc" == "$want" ]] && match=1; done
    [[ $match -eq 0 ]] && continue
  fi

  # --exclude filter (matches any path substring, e.g. a module dir)
  skip=0
  for ex in "${EXCLUDES[@]+"${EXCLUDES[@]}"}"; do
    [[ "$file" == *"$ex"* ]] && skip=1
  done
  if [[ $skip -eq 1 ]]; then
    echo -e "  ${CYAN}[skip]${NC}   ${tc} (excluded)"
    SKIP_TCS+=("$tc"); continue
  fi

  # Pacing gap between executions (skipped before the first run)
  if [[ "$SLEEP_BETWEEN" -gt 0 && "${RAN_ONCE:-false}" == true ]]; then
    echo -e "  ${CYAN}[pace]${NC}   sleeping ${SLEEP_BETWEEN}s before next TC (rate-limit protection)..."
    sleep "$SLEEP_BETWEEN"
  fi
  RAN_ONCE=true

  # Output dir — optionally nested under the bank for multi-bank runs
  if [[ "$NEST_BANK" == true ]]; then
    TC_OUT="${OUT_ROOT}/${BANK_ID}/${tc}"
  else
    TC_OUT="${OUT_ROOT}/${tc}"
  fi

  echo ""
  echo -e "  ${BOLD}[run]${NC}    ${tc}  (${base})"
  if robot -V "$VAR_FILE" "${INCLUDE_FLAGS[@]}" --exclude skip -d "${TC_OUT}" "$file"; then
    PASS_TCS+=("$tc")
  else
    code=$?
    # robot exit 252 = no tests matched the tag; treat as skipped, not failed
    if [[ $code -eq 252 ]]; then
      echo -e "  ${CYAN}[skip]${NC}   ${tc} (no tests matching tags: ${INCLUDE_TAGS[*]})"
      rm -rf "${TC_OUT}"
      SKIP_TCS+=("$tc")
    else
      FAIL_TCS+=("$tc")
    fi
  fi
done < <(find "${SCRIPT_DIR}/tests" -name 't*.robot' | sort)

echo ""
echo "============================================================"
echo -e "  ${GREEN}Passed${NC}  : ${PASS_TCS[*]:-none}"
echo -e "  ${RED}Failed${NC}  : ${FAIL_TCS[*]:-none}"
echo -e "  ${CYAN}Skipped${NC} : ${SKIP_TCS[*]:-none}"
echo "============================================================"
echo "  Publish with:"
echo "    bash publish_reports.sh --timestamp ${RUN_NAME} --title \"July Regression testing\""
echo "============================================================"
echo ""

[[ ${#FAIL_TCS[@]} -eq 0 ]]
