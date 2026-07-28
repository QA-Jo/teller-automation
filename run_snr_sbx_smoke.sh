#!/bin/bash
# ============================================================
# run_snr_sbx_smoke.sh — Scoped smoke for SNR-SBX.
#
# SNR-SBX is a limited-module bank (Customers/Accounts/Transactions/
# Reports only). This is a thin wrapper around run_limited_smoke.sh;
# see that script and REGRESSION_SCOPE.md for the full scope rationale.
#
# Usage:
#   bash run_snr_sbx_smoke.sh [RUN_NAME]
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${SCRIPT_DIR}/run_limited_smoke.sh" SNR-SBX "$@"
