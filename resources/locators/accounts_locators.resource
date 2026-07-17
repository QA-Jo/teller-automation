*** Variables ***
# ============================================================
# Accounts Module Locators
# data-testid: accounts.*
# ============================================================

# Navigation - Sidebar
${ACCOUNTS_MENU}                    css=[data-testid="nav-sidebar-accounts"]

# Accounts List Page
${ACCOUNTS_LIST_PAGE}               css=[data-testid="page-accounts-list"]

# Accounts List Page - Search
${ACCOUNTS_SEARCH_FIELD}            css=[data-testid="search-accounts"] input
${ACCOUNTS_SEARCH_BUTTON}           css=[data-testid="search-accounts"] button

# Accounts List Table
${ACCOUNTS_TABLE}                   css=[data-testid="table-accounts"]
${ACCOUNTS_TABLE_ROWS}              css=[data-testid="table-accounts"] tbody tr

# Account Actions (per row)
${VIEW_ACCOUNT_TRANSACTIONS_LINK}   css=[data-testid="btn-accounts-view-transactions"]

# Pagination (shared across Accounts list and Transaction History)
${PAGINATION_NEXT}                  css=button.ant-pagination-item-link:has(svg[data-icon="right"])
${PAGINATION_PREV}                  css=button.ant-pagination-item-link:has(svg[data-icon="left"])

# Account Status Filter (column header filter icon)
${ACCOUNT_STATUS_FILTER}            css=th:has-text("Account Status") span.ant-table-filter-trigger

# Account Status Filter Options — AntD dropdown menu items
${FILTER_OPTION_ACTIVE}             css=[data-menu-id$="-active"]
${FILTER_OPTION_INACTIVE}           css=[data-menu-id$="-inactive"]
${FILTER_OPTION_DORMANT}            css=[data-menu-id$="-dormant"]
${FILTER_OPTION_FROZEN}             css=[data-menu-id$="-frozen"]
${FILTER_OPTION_CLOSED}             css=[data-menu-id$="-closed"]
${FILTER_OPTION_DECEASED}           css=[data-menu-id$="-deceased"]
${FILTER_OPTION_BLOCKED}            css=[data-menu-id$="-blocked"]

# Filter Action Buttons (shared across all filters)
${FILTER_APPLY_BTN}                 css=button.ant-btn-primary.ant-btn-sm:has-text("OK")
${FILTER_RESET_BTN}                 css=.ant-table-filter-dropdown-btns .ant-btn-link

# No Data
${NO_DATA_MESSAGE}                  css=.ant-empty-description

# ============================================================
# ACCOUNTS — TRANSACTION HISTORY PAGE
# data-testid: accounts.transactions
# ============================================================

# Page
${ACCOUNTS_TXN_PAGE}                css=[data-testid="page-accounts-transactions"]

# Search
${ACCT_TXN_SEARCH_FIELD}            css=input[placeholder="Search transactions..."]
${ACCT_TXN_SEARCH_BUTTON}           css=#btnSearch:has-text("Search")

# Transaction Table
${ACCT_TXN_TABLE}                   css=.ant-table-body table
${ACCT_TXN_TABLE_ROWS}              css=.ant-table-body table tbody tr

# Transaction Action Buttons (per row)
${VIEW_TXN_BTN}                     css=button:has([data-icon="eye"])
${DOWNLOAD_TXN_BTN}                 css=button:has([data-icon="download"])

# Transaction Type Filter
${TXN_TYPE_FILTER}                  css=th:has-text("Transaction Type") span.ant-table-filter-trigger
${TXN_TYPE_SEND_MONEY}              css=[data-menu-id$="-fund_transfer_external"]
${TXN_TYPE_RECEIVE_MONEY}           css=[data-menu-id$="-cash_in_external"]
${TXN_TYPE_FUND_TRANSFER}           css=[data-menu-id$="-fund_transfer_internal"]
${TXN_TYPE_CASH_WITHDRAWAL}         css=[data-menu-id$="-cash_withdrawal"]
${TXN_TYPE_CASH_DEPOSIT}            css=[data-menu-id$="-cash_deposit"]
${TXN_TYPE_SAVINGS_INTEREST}        css=[data-menu-id$="-interest_credit"]
${TXN_TYPE_LOAN_DISBURSEMENT}       css=[data-menu-id$="-loan_disbursement"]
${TXN_TYPE_LOAN_PAYMENT}            css=[data-menu-id$="-loan_payment"]

# Transaction Status Filter
${TXN_STATUS_FILTER}                css=th:has-text("Status") span.ant-table-filter-trigger
${TXN_STATUS_PENDING}               css=[data-menu-id$="-pending"]
${TXN_STATUS_SUCCESS}               css=[data-menu-id$="-success"]
${TXN_STATUS_FAILED}                css=[data-menu-id$="-failed"]

# Date & Time Filter
${DATE_TIME_FILTER}                 css=th:has-text("Date & Time") span.ant-table-filter-trigger
${DATE_START_INPUT}                 css=input[placeholder="Start date"]
${DATE_END_INPUT}                   css=input[placeholder="End date"]
${DATE_FILTER_SEARCH_BTN}           css=.ant-table-filter-dropdown button:has-text("Search")
${DATE_FILTER_RESET_BTN}            css=.ant-table-filter-dropdown button:has-text("Reset")

# Transaction Detail Modal
${ACCT_TXN_DETAIL_MODAL}            css=.ant-modal-content
${ACCT_TXN_DETAIL_BACK_BTN}         css=.ant-modal-content button:has-text("Back")

# Breadcrumb Navigation
${ACCOUNTS_BREADCRUMB_LINK}         css=a[href$="/dashboard/accounts"]
