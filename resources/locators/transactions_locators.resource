*** Variables ***
# ============================================================
# Transactions Module Locators
# data-testid: transactions.*
# ============================================================

# Navigation - Sidebar
${TRANSACTIONS_MENU}                css=[data-testid="nav-sidebar-transactions"]

# Transactions List Page
${TXN_LIST_PAGE}                    css=[data-testid="page-transactions-list"]

# Transactions List Page - Total Balance
${TOTAL_BALANCE_CARD}               css=section:has-text("Total Balance:")

# Transactions List Page - Search
${TXN_SEARCH_FIELD}                 css=input[placeholder="Search transactions..."]
${TXN_SEARCH_BUTTON}                css=#btnSearch:has-text("Search")

# Transaction Table
${TXN_TABLE}                        css=[data-testid="table-transactions"]
${TXN_TABLE_ROWS}                   css=[data-testid="table-transactions"] tbody tr

# Transaction Action Buttons (per row)
${TXN_VIEW_BTN}                     css=[data-testid="btn-transactions-view"]
${TXN_DOWNLOAD_BTN}                 css=[data-testid="btn-transactions-download"]

# New Transaction Button
${NEW_TXN_BTN}                      css=[data-testid="btn-transactions-new"]

# Transaction Type Filter (column header filter icon)
${TXN_TYPE_FILTER}                  css=th:has-text("Transaction Type") .ant-table-filter-trigger
${TXN_FILTER_EXTERNAL}              css=[data-menu-id$="-fund_transfer_external"]
${TXN_FILTER_INTERNAL}              css=[data-menu-id$="-fund_transfer_internal"]
${TXN_FILTER_WITHDRAWAL}            css=[data-menu-id$="-cash_withdrawal"]
${TXN_FILTER_DEPOSIT}               css=[data-menu-id$="-cash_deposit"]
${TXN_FILTER_INTEREST_CREDITING}    css=[data-menu-id$="-interest_credit"]
${TXN_FILTER_LOAN_DISBURSEMENT}     css=[data-menu-id$="-loan_disbursement"]
${TXN_FILTER_LOAN_PAYMENT}          css=[data-menu-id$="-loan_payment"]

# Date & Time Filter (column header filter icon)
${TXN_DATE_TIME_FILTER}             css=th:has-text("Date & Time") .ant-table-filter-trigger
${TXN_DATE_START_INPUT}             css=input[placeholder="Start date"]
${TXN_DATE_END_INPUT}               css=input[placeholder="End date"]
${TXN_DATE_FILTER_SEARCH_BTN}       css=.ant-table-filter-dropdown button:has-text("Search")
${TXN_DATE_FILTER_RESET_BTN}        css=.ant-table-filter-dropdown button:has-text("Reset")

# Status Filter (column header filter icon)
${TXN_STATUS_FILTER}                css=th:has-text("Status") .ant-table-filter-trigger
${TXN_STATUS_PENDING}               css=[data-menu-id$="-pending"]
${TXN_STATUS_SUCCESS}               css=[data-menu-id$="-success"]
${TXN_STATUS_FAILED}                css=[data-menu-id$="-failed"]

# Filter Action Buttons
${TXN_FILTER_APPLY_BTN}             css=button.ant-btn-primary.ant-btn-sm:has-text("OK")
${TXN_FILTER_RESET_BTN}             css=.ant-table-filter-dropdown-btns .ant-btn-link

# Transaction Detail Modal
${TXN_DETAIL_MODAL}                 css=.ant-modal-content
${TXN_DETAIL_BACK_BTN}              css=.ant-modal-content button:has-text("Back")
${TXN_DETAIL_DOWNLOAD_CSV_BTN}      css=.ant-modal-content button:has-text("Download CSV")

# No Data
${TXN_NO_DATA_MESSAGE}              css=.ant-empty-description


# ============================================================
# Create Transaction — New Transaction Page
# data-testid: transactions.new
# ============================================================

${NEW_TXN_PAGE}                         css=[data-testid="page-transactions-new"]
${NEW_TXN_STEPS}                        css=[data-testid="steps-transactions-new"]


# ============================================================
# Create Transaction — Validation / Error States
# ============================================================

# Empty search results in the New Transaction modal
${CREATE_TXN_NO_RESULTS_MSG}        css=.ant-modal-content .ant-empty-description

# Inline form validation error messages (ant-design form error)
${CREATE_TXN_FORM_ERROR}            css=.ant-modal-content .ant-form-item-explain-error


# ============================================================
# Create Transaction — New Transaction Modal (t4.2, t4.3)
# ============================================================

# Modal Container
${CREATE_TXN_MODAL}                     css=.ant-modal-content

# Step 1 — Customer Information (Account Search)
${CREATE_TXN_SEARCH_INPUT}              css=input[type="search"][placeholder*="Account number"]
${CREATE_TXN_SEARCH_BTN}                css=.ant-modal-content #btnSearch
${CREATE_TXN_SEARCH_RESULT_ITEM}        css=.ant-modal-content [role="button"]

# Step 2 — Transaction Type Selection Buttons
${CREATE_TXN_DEPOSIT_BTN}               css=button.btn-primary:has-text("Deposit")
${CREATE_TXN_WITHDRAWAL_BTN}            css=button.btn-outline:has-text("Withdraw")

# Step 2 — Transaction Form Fields (shared by Deposit and Withdrawal)
${CREATE_TXN_TYPE_SELECT}               css=.ant-select-selector
${CREATE_TXN_AMOUNT_INPUT}              css=.ant-input-number-input
${CREATE_TXN_NOTES_INPUT}               css=textarea[placeholder="Add any relevant notes"]
${CREATE_TXN_CANCEL_BTN}                css=button:has-text("Cancel")
${CREATE_TXN_PROCESS_DEPOSIT_BTN}       css=button:has-text("Process Deposit")
${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    css=button:has-text("Process Withdrawal")

# Step 3 — Confirmation / Receipt
${CREATE_TXN_PRINT_RECEIPT_BTN}         css=button:has-text("Print Receipt")
${CREATE_TXN_NEW_TXN_BTN_CONFIRM}       css=button.btn-primary:has-text("New Transaction")
