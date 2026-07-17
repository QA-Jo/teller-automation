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
