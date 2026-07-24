#!/bin/bash
# ============================================================
# run_snr_sbx_smoke.sh — Scoped smoke run for SNR-SBX
#
# SNR-SBX (Rural Bank of San Narciso, SBX) exposes only the
# Customers, Accounts, Transactions and Reports modules for the QA
# teller account. It has NO Products or Loans modules, and the
# tenant has no cash deposit/withdrawal, external-transfer, or
# loan/interest transaction data. Running the full smoke suite
# therefore produces ~140 not-applicable failures.
#
# This wrapper runs ONLY the in-scope TC files and then filters out
# the individual sub-tests that target features SNR-SBX doesn't have,
# so the published report reflects the true SNR-SBX scope.
#
# In scope (TC files run):
#   Auth         t1.2 (login), t1.3 (forgot pw), t1.4 (change pw)
#   Customers    t2.1 (list), t2.2 (accounts), t2.3 (acct txns)
#   Accounts     t3.1 (list), t3.2 (acct txns)
#   Transactions t4.1 (list/view)
#   Reports      t6.1
#
# Out of scope (whole TC files NOT run):
#   t1.1 reset-password, t2.4/t2.5/t2.6 product & loan availment,
#   t4.2/t4.3 cash withdrawal/deposit, t5.* products, t7.* loans,
#   t8.1 interest.
#
# Out of scope (individual sub-tests filtered from the report):
#   status change (mutating)      t2.1.13, t2.1.14, t2.2.10-13
#   filter by cash/interest/loan  t2.3.10-14, t3.2.9-13, t4.1.9-13
#     transaction types
#   external-transfer txn search  t4.1.5
#   eligible-products profile tab t2.1.12
#
# See REGRESSION_SCOPE.md -> "SNR-SBX (limited-module) smoke scope".
#
# Usage:
#   bash run_snr_sbx_smoke.sh                 # into the default umbrella run
#   bash run_snr_sbx_smoke.sh <RUN_NAME>      # into a custom run folder
#
# After it finishes, publish with:
#   bash publish_reports.sh --timestamp <RUN_NAME> --title "Teller SBX and SIT July 2026 Smoke Testing"
# ============================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_NAME="${1:-Teller_SBX_and_SIT_July2026_Smoke_Testing}"

# In-scope TC files
IN_SCOPE_TCS=(t1.2 t1.3 t1.4 t2.1 t2.2 t2.3 t3.1 t3.2 t4.1 t6.1)

echo "SNR-SBX scoped smoke -> results/${RUN_NAME}/SNR-SBX/"
# status-change tests are excluded at RUN time (not just filtered from the report):
# they are mutating and share the account other tests verify as Active, so executing
# them corrupts state. --exclude-tag keeps them from running at all.
bash "${SCRIPT_DIR}/run_july_regression.sh" --bank SNR-SBX --run "${RUN_NAME}" \
  --tag smoke --nest-bank --sleep 15 --exclude-tag status-change "${IN_SCOPE_TCS[@]}"

echo ""
echo "Filtering out-of-scope sub-tests from the SNR-SBX report..."
python3 - "${SCRIPT_DIR}" "${RUN_NAME}" <<'PY'
import sys, os, tempfile, shutil, subprocess, xml.etree.ElementTree as ET
script_dir, run = sys.argv[1], sys.argv[2]
ROOT = os.path.join(script_dir, 'results', run, 'SNR-SBX')
# Read-only sub-tests to drop from the report, keyed by TC file, matched on the exact
# "tX.Y.N " prefix. NOTE: status-change tests are NOT listed here — they are excluded
# at run time via --exclude-tag status-change above (they must never execute).
EXCLUDE = {
    't2.1': ['t2.1.12 '],                                                 # eligible-products tab (needs Products module)
    't2.3': ['t2.3.10 ', 't2.3.11 ', 't2.3.12 ', 't2.3.13 ', 't2.3.14 '], # cash/interest/loan type filters
    't3.2': ['t3.2.9 ', 't3.2.10 ', 't3.2.11 ', 't3.2.12 ', 't3.2.13 '],  # cash/interest/loan type filters
    't4.1': ['t4.1.5 ', 't4.1.9 ', 't4.1.10 ', 't4.1.11 ', 't4.1.12 ', 't4.1.13 '],  # external search + type filters
}
for tc, prefixes in EXCLUDE.items():
    x = os.path.join(ROOT, tc, 'output.xml')
    if not os.path.exists(x):
        print(f'  {tc}: no output.xml, skipped'); continue
    keep = [t.get('name') for t in ET.parse(x).getroot().iter('test')
            if not any(t.get('name').startswith(p) for p in prefixes)]
    tmp = tempfile.mkdtemp()
    args = ['rebot', '--outputdir', tmp, '--output', 'output.xml', '--log', 'log.html',
            '--report', 'report.html', '--nostatusrc', '--name', tc.upper()]
    for n in keep:
        args += ['--test', n]
    args.append(x)
    subprocess.run(args, capture_output=True, text=True)
    for fn in ('output.xml', 'log.html', 'report.html'):
        s = os.path.join(tmp, fn)
        if os.path.exists(s):
            shutil.move(s, os.path.join(ROOT, tc, fn))
    print(f'  {tc}: kept {len(keep)} in-scope test(s)')
PY

echo ""
echo "Done. Publish with:"
echo "  bash publish_reports.sh --timestamp ${RUN_NAME} --title \"Teller SBX and SIT July 2026 Smoke Testing\""
