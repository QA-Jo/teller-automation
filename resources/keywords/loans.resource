*** Settings ***
Documentation       High-level operational keywords for the Loans module 
...                 utilizing explicit frontend test IDs and native Playwright interactions.
Library             Browser
Resource            common.resource
Resource            ../locators/loans_locators.resource


*** Keywords ***
Navigate To Active Loans Page
    [Documentation]    Clicks the main Loans sidebar section and opens the Active Loans sub-module.
    ...                Paces navigation to stay under the backend request rate limit (bursts of
    ...                ~13 requests return HTTP 429 for ~1 hour).
    Sleep                      12s
    Wait For Elements State    ${LOANS_PARENT_MENU}    visible    timeout=10s
    Click                      ${LOANS_PARENT_MENU}
    Wait For Elements State    ${ACTIVE_LOANS_MENU}    visible    timeout=10s
    Click                      ${ACTIVE_LOANS_MENU}
    Get Url                    contains    /loans/active

Navigate To Pending Applications Page
    [Documentation]    Clicks the main Loans sidebar section and opens the Pending Applications sub-module.
    ...                Paced to stay under the backend request rate limit.
    Sleep                      12s
    Wait For Elements State    ${LOANS_PARENT_MENU}    visible    timeout=30s
    Click                      ${LOANS_PARENT_MENU}
    Wait For Elements State    ${PENDING_APPS_MENU}    visible    timeout=10s
    Click                      ${PENDING_APPS_MENU}
    Get Url                    contains    /loans/pending

Navigate To Pending Disbursements Page
    [Documentation]    Clicks the main Loans sidebar section and opens the Pending Disbursements sub-module.
    ...                Paced to stay under the backend request rate limit.
    Sleep                      12s
    Wait For Elements State    ${LOANS_PARENT_MENU}    visible    timeout=10s
    Click                      ${LOANS_PARENT_MENU}
    Wait For Elements State    ${PENDING_DISB_MENU}    visible    timeout=10s
    Click                      ${PENDING_DISB_MENU}
    Get Url                    contains    /loans/disbursement

Navigate To Rejected Loans Page
    [Documentation]    Clicks the main Loans sidebar section and opens the Rejected Loan Applications sub-module.
    ...                Paced to stay under the backend request rate limit.
    Sleep                      12s
    Wait For Elements State    ${LOANS_PARENT_MENU}    visible    timeout=10s
    Click                      ${LOANS_PARENT_MENU}
    Wait For Elements State    ${REJECTED_APPS_MENU}   visible    timeout=10s
    Click                      ${REJECTED_APPS_MENU}
    Get Url                    contains    /loans/rejected

View Active Loans List
    [Documentation]    Verifies that the Active Loans module page container and table list load successfully.
    Wait For Elements State    ${ACTIVE_LOANS_PAGE}     visible    timeout=10s
    Wait For Elements State    ${ACTIVE_LOANS_TABLE}    visible    timeout=5s

View Pending Applications List
    [Documentation]    Verifies that the Pending Applications page container and table list load successfully.
    Wait For Elements State    ${PENDING_APPS_PAGE}     visible    timeout=10s
    Wait For Elements State    ${PENDING_APPS_TABLE}    visible    timeout=5s

View Pending Disbursements List
    [Documentation]    Verifies that the Pending Disbursements page container and table list load successfully.
    Wait For Elements State    ${PENDING_DISB_PAGE}     visible    timeout=10s
    Wait For Elements State    ${PENDING_DISB_TABLE}    visible    timeout=5s

View Rejected Loans List
    [Documentation]    Verifies that the Rejected Applications page container and table list load successfully.
    Wait For Elements State    ${REJECTED_APPS_PAGE}    visible    timeout=10s
    Wait For Elements State    ${REJECTED_APPS_TABLE}   visible    timeout=5s

Fill New Loan Form
    [Documentation]    Fills in the new loan creation form using native Browser Playwright keywords.
    [Arguments]        &{loan}
    Fill Text          id=customer-id       ${loan.customer_id}
    
    # Playwright uses 'Select Options' instead of 'Select Options By'
    Wait For Elements State    id=loan-product      enabled    timeout=5s
    Select Options     id=loan-product      value    ${loan.product}
    
    Fill Text          id=loan-amount       ${loan.amount}
    Fill Text          id=loan-term         ${loan.term}
    Fill Text          id=loan-purpose      ${loan.purpose}

Submit New Loan Form
    [Documentation]    Submits the new loan creation form.
    Click              id=create-loan-button
    Wait For Elements State    css=.success-message    visible

Verify Loan Is Created
    [Documentation]    Verifies the loan was successfully created.
    [Arguments]        ${customer_id}
    Get Text           css=.success-message    contains    ${customer_id}

Approve Loan
    [Documentation]    Verifies the approval modal opens for a loan row — opens the detail modal
    ...                and closes it without approving, leaving the loan in Pending status.
    [Arguments]        ${loan_id}
    Click                      ${PENDING_APPS_TABLE} >> css=tr:has-text("${loan_id}") >> nth=0 >> ${PENDING_APPS_APPROVE_BTN}
    Wait For Elements State    ${LOAN_APP_MODAL_CUSTOMER_FORM}    visible    timeout=15s
    Click                      ${LOAN_DETAILS_CLOSE_BTN}
    Wait For Elements State    ${LOAN_APP_MODAL_CUSTOMER_FORM}    hidden    timeout=10s

Reject Loan
    [Documentation]    Verifies the rejection modal flow for a loan row — opens detail modal,
    ...                clicks Reject this application, fills remarks, then closes with Back
    ...                leaving the loan in Pending status.
    [Arguments]        ${loan_id}    ${reason}
    Click                      ${PENDING_APPS_TABLE} >> css=tr:has-text("${loan_id}") >> nth=0 >> ${PENDING_APPS_REJECT_BTN}
    Wait For Elements State    ${LOAN_APP_MODAL_CUSTOMER_FORM}    visible    timeout=15s
    Click                      ${LOAN_DETAILS_REJECT_BTN}
    Wait For Elements State    ${LOAN_REJECTION_INPUT}    visible    timeout=10s
    Fill Text                  ${LOAN_REJECTION_INPUT}    ${reason}
    Click                      ${LOAN_REJECTION_BACK_BTN}
    Wait For Elements State    ${LOAN_REJECTION_INPUT}    hidden    timeout=10s
    Click                      css=.ant-modal-close
    Wait For Elements State    ${LOAN_APP_MODAL_CUSTOMER_FORM}    hidden    timeout=10s

Disburse Loan
    [Documentation]    Verifies the Disburse Payment modal opens for a loan row and closes with Back.
    [Arguments]        ${loan_id}
    Click                      ${PENDING_DISB_TABLE} >> css=tr:has-text("${loan_id}") >> nth=0 >> ${PENDING_DISB_DISBURSE_BTN}
    Wait For Elements State    css=.ant-modal-content:has-text("Disburse Payment")    visible    timeout=30s
    Click                      css=.ant-modal-content:has-text("Disburse Payment") >> css=button:has-text("Back")
    Wait For Elements State    css=.ant-modal-content:has-text("Disburse Payment")    hidden    timeout=10s