# 2026-07 Regression — Pre-deployment to SBX

Published results: https://qa-jo.github.io/teller-automation/
(run: `2026-07_regression-pre-deployment-to-sbx`)

## In scope — executed, all passing (21 TCs)
| Module | Test cases | Result |
|--------|-----------|--------|
| Customers | t2.1–t2.6 | ✅ Pass |
| Accounts | t3.1–t3.2 | ✅ Pass |
| Transactions | t4.1–t4.3 | ✅ Pass |
| Products | t5.1–t5.3 | ✅ Pass |
| Reports | t6.1 | ✅ Pass |
| Loans | t7.1–t7.6 | ✅ Pass |

## Out of scope — excluded this run
Excluded — **no recent changes to these areas on the current deployment.**
Regression testing for them was done last **June 2026** (see the `2026-06-02_regression-post-deployment` results).

| Module | Test cases | Notes |
|--------|-----------|-------|
| 1_auth | t1.1–t1.4 | Excluded — no recent changes; last regressed June 2026 (`2026-06-02_regression-post-deployment`). |
| 8_interest | t8.1 | Excluded — no recent changes; additionally pending dedicated interest-test accounts to be provisioned. |

---

# Teller SBX + SIT July 2026 Smoke Testing

Published results: https://qa-jo.github.io/teller-automation/
(run: `Teller_SBX_and_SIT_July2026_Smoke_Testing`, one sub-folder per bank)

Per-bank smoke run across SBX/SIT environments. Auth (t1.2–t1.4) is included;
`t1.1` reset-password (one-time temp passwords) and `t8.1` interest (accounts
not provisioned) are excluded for all banks.

## Limited-module banks (SNR-SBX, Guagua-SBX) smoke scope

Some SBX tenants expose **only Customers, Accounts, Transactions and Reports** —
there are **no Products or Loans modules**, and the tenant has no cash
deposit/withdrawal, external-transfer, or loan/interest transaction data.
Running the full suite yields ~140 not-applicable failures, so these banks are
run through the scoped wrapper **`run_limited_smoke.sh <bank>`**
(`run_snr_sbx_smoke.sh` is a thin wrapper for SNR-SBX). Confirmed limited-module
banks so far: **SNR-SBX**, **Guagua-SBX**, **Hermosa-SBX**.

**In scope (run + reported):**
| Module | Test cases |
|--------|-----------|
| Auth | t1.2, t1.3, t1.4 |
| Customers | t2.1, t2.2, t2.3 |
| Accounts | t3.1, t3.2 |
| Transactions | t4.1 (view/list) |
| Reports | t6.1 |

**Out of scope — whole TC files not run:** t2.4/t2.5/t2.6 (product & loan
availment), t4.2/t4.3 (cash withdrawal/deposit), t5.* (products), t7.* (loans),
t1.1 (reset-password), t8.1 (interest).

**Out of scope — status-change sub-tests, excluded at RUN time** (never executed).
These are mutating and share the account other tests verify as Active, so running
them corrupts test data. They carry a `status-change` tag; the wrapper passes
`--exclude-tag status-change` to `run_july_regression.sh`.
| Sub-tests | Reason |
|-----------|--------|
| t2.1.13, t2.1.14, t2.2.10–t2.2.13 | Change customer/account status (excluded on request; mutating) |

**Out of scope — read-only sub-tests filtered from the report** (feature/data not
present in these tenants; safe to run, then removed via `rebot`):
| Sub-tests | Reason |
|-----------|--------|
| t2.3.10–14, t3.2.9–13, t4.1.9–13 | Filter by Cash Withdrawal/Deposit, Savings Interest, Loan Disbursement/Payment — those transaction types don't exist in the tenant |
| t4.1.5 | Search by ID targets an External Transfer — no external-transfer data (no partner account code set up) |
| t2.1.12 | Profile detail verification checks the Eligible Products tab, which requires the Products module |

**Per-bank data notes** (each tenant needs its own valid customer/account data):
- **SNR-SBX** — `VALID_CUSTOMER` = Louisa May (Active customer with an Active account).
- **Guagua-SBX** — `VALID_CUSTOMER`/account = **Jocelyn Javier Amban** (`7711031228974342`,
  Active). The originally-configured Josephine Santos only has a **Closed** account
  (terminal status, cannot be reactivated), which failed the Active-account checks
  (t2.2.3/.4), so the dataset was switched to Jocelyn. `VALID_ACCOUNT_NUMBER` (the
  module-level account search, t3.1.3) points at Myka Feliciano Quiambao's Active
  account. Result: **54/54**.
- **Hermosa-SBX** — `VALID_CUSTOMER`/account = **Lena Moretti** (Active). Only
  `VALID_ACCOUNT_NUMBER`/`EXPECTED_*` (t3.1.3) needed fixing — pointed at Lena's own
  Active account `7710744278473292` (was Warren Test Hermosa's Deceased account).
  Result: **54/54**.

Run + publish (per bank):
```
bash run_limited_smoke.sh SNR-SBX        # or: bash run_snr_sbx_smoke.sh
bash run_limited_smoke.sh Guagua-SBX
bash publish_reports.sh --timestamp Teller_SBX_and_SIT_July2026_Smoke_Testing \
  --title "Teller SBX and SIT July 2026 Smoke Testing"
```
