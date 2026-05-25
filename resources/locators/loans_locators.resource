*** Variables ***
# ============================================================================
# 🧭 SIDEBAR NAVIGATION CONTROLS
# ============================================================================
${LOANS_PARENT_MENU}                  css=[data-testid="nav-sidebar-loans"]
# Sub-menu items are AntD <li> elements with no data-testid — match on data-menu-id route suffix.
${ACTIVE_LOANS_MENU}                  css=[data-menu-id$="/loans/active"]
${PENDING_APPS_MENU}                  css=[data-menu-id$="/loans/pending"]
${PENDING_DISB_MENU}                  css=[data-menu-id$="/loans/disbursement"]
${REJECTED_APPS_MENU}                 css=[data-menu-id$="/loans/rejected"]

# ============================================================================
# 🟢 ACTIVE LOANS VIEW
# ============================================================================
${ACTIVE_LOANS_PAGE}                  css=[data-testid="page-loans-active"]
${ACTIVE_LOANS_SEARCH}                css=[data-testid="search-loans-active"]
${ACTIVE_LOANS_SEARCH_INPUT}          css=[data-testid="search-loans-active"] input
${ACTIVE_LOANS_SEARCH_BTN}            css=[data-testid="search-loans-active"] button
${ACTIVE_LOANS_TABLE}                 css=[data-testid="table-loans-active"]
# Cleared >> nth=0 for dynamic keyword parsing safety
${ACTIVE_LOANS_VIEW_SCHEDULE_BTN}     css=[data-testid="btn-loans-active-view-schedule"]
${ACTIVE_LOANS_PAY_NOW_BTN}           css=[data-testid="btn-loans-active-pay-now"]

# ============================================================================
# 🟡 PENDING APPLICATIONS VIEW
# ============================================================================
${PENDING_APPS_PAGE}                  css=[data-testid="page-loans-pending"]
${PENDING_APPS_SEARCH}                css=[data-testid="search-loans-pending"]
${PENDING_APPS_SEARCH_INPUT}          css=[data-testid="search-loans-pending"] input
${PENDING_APPS_SEARCH_BTN}            css=[data-testid="search-loans-pending"] button
${PENDING_APPS_TABLE}                 css=[data-testid="table-loans-pending"]
# Cleared >> nth=0 for dynamic keyword parsing safety
${PENDING_APPS_APPROVE_BTN}           css=[data-testid="btn-loans-pending-approve"]
${PENDING_APPS_REJECT_BTN}            css=[data-testid="btn-loans-pending-reject"]

# ============================================================================
# 🔵 PENDING DISBURSEMENTS VIEW
# ============================================================================
${PENDING_DISB_PAGE}                  css=[data-testid="page-loans-disbursements"]
${PENDING_DISB_SEARCH}                css=[data-testid="search-loans-disbursements"]
${PENDING_DISB_SEARCH_INPUT}          css=[data-testid="search-loans-disbursements"] input
${PENDING_DISB_SEARCH_BTN}            css=[data-testid="search-loans-disbursements"] button
${PENDING_DISB_TABLE}                 css=[data-testid="table-loans-disbursements"]
# Cleared >> nth=0 for dynamic keyword parsing safety
${PENDING_DISB_VIEW_DETAILS_BTN}      css=[data-testid="btn-loans-disbursements-view-details"]
${PENDING_DISB_DISBURSE_BTN}          css=[data-testid="btn-loans-disbursements-disburse"]

# ============================================================================
# 🔴 REJECTED APPLICATIONS VIEW
# ============================================================================
${REJECTED_APPS_PAGE}                 css=[data-testid="page-loans-rejected"]
${REJECTED_APPS_SEARCH}               css=[data-testid="search-loans-rejected"]
${REJECTED_APPS_SEARCH_INPUT}         css=[data-testid="search-loans-rejected"] input
${REJECTED_APPS_SEARCH_BTN}           css=[data-testid="search-loans-rejected"] button
${REJECTED_APPS_TABLE}                css=[data-testid="table-loans-rejected"]

# ============================================================================
# 📅 ACTIVE LOAN SCHEDULE PAGE
# ============================================================================
${LOAN_SCHEDULE_PAGE}                 css=[data-testid="page-loans-schedule"]
${LOAN_SCHEDULE_TABLE}                css=[data-testid="table-loans-schedule"]
${LOAN_SCHEDULE_VIEW_TXN_BTN}         css=[data-testid="btn-loans-schedule-view-transaction"]
${LOAN_SCHEDULE_STATUS_CARD}          css=[data-testid="card-loans-schedule-payment-status"]
${LOAN_SCHEDULE_DETAILS_CARD}         css=[data-testid="card-loans-schedule-loan-details"]
${LOAN_SCHEDULE_PAY_NOW_BTN}          css=[data-testid="btn-loans-schedule-pay-now"]

# ============================================================================
# 📦 TRANSACTION DETAILS MODAL
# ============================================================================
${TXN_DETAILS_MODAL}                  css=[data-testid="modal-transaction-details"]
${TXN_DETAILS_BACK_BTN}               css=[data-testid="btn-transaction-details-back"]
${TXN_DETAILS_FILE_LIST}              css=[data-testid="file-list-transaction-details"]

# ============================================================================
# ⚖️ APPLICATION DECISION MODAL
# ============================================================================
${APP_DECISION_MODAL}                 css=[data-testid="modal-loan-application-decision"]
${APP_DECISION_CLOSE_BTN}             css=[data-testid="btn-loan-decision-close"]

# ============================================================================
# 🔍 LOAN DETAILS MODAL
# ============================================================================
${LOAN_DETAILS_MODAL}                 css=[data-testid="modal-loan-details"]
${LOAN_DETAILS_APPROVE_BTN}           css=[data-testid="btn-loan-details-approve"]
${LOAN_DETAILS_REJECT_BTN}            css=[data-testid="btn-loan-details-reject"]
${LOAN_DETAILS_CLOSE_BTN}             css=[data-testid="btn-loan-details-close"]

# ============================================================================
# 📋 LOAN APPLICATION DETAIL MODAL (opens via Pending Applications row Approve/Reject)
# No testid on the modal itself — anchor on the "Customer Form" label inside the body.
# ============================================================================
${LOAN_APP_DETAIL_MODAL}              css=.ant-modal-content:has-text("Customer Form")
${LOAN_APP_MODAL_CUSTOMER_FORM}       css=.ant-modal-content p:text-is("Customer Form")
${LOAN_APP_MODAL_CUSTOMER_DETAILS}    css=.ant-modal-content p:text-is("Customer Details")

# ============================================================================
# 💳 PAYMENT MODALS
# ============================================================================
${LOAN_PAYMENT_MODAL}                 css=[data-testid="modal-loan-payment"]
${LOAN_PAYMENT_CONFIRM_MODAL}         css=[data-testid="modal-loan-payment-confirmation"]

# ============================================================================
# 📝 REJECTION REMARKS MODAL
# ============================================================================
${LOAN_REJECTION_REMARKS_MODAL}       css=[data-testid="modal-loan-rejection-remarks"]
${LOAN_REJECTION_INPUT}               css=[data-testid="input-loan-rejection-remarks"]
${LOAN_REJECTION_SUBMIT_BTN}          css=[data-testid="modal-loan-rejection-remarks-btn-ok"]
${LOAN_REJECTION_BACK_BTN}            css=[data-testid="modal-loan-rejection-remarks-btn-cancel"]