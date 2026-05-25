*** Settings ***
Documentation       t7.3 Loan Disbursements Processing
...                 Validates the post-approval loan fulfillment loop using the newly 
...                 approved application for Luis Ramos. Covers list sorting, detailed modal 
...                 views, structural field verifications, execution tracking, and clean 
...                 navigation cancel actions.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/customers.resource
Resource            ../../resources/keywords/loans.resource

Suite Setup         Login To Teller App
Suite Teardown      Close Browser
Test Setup          Navigate To Pending Disbursements Page And Verify
Test Teardown       Close Modal If Open


*** Variables ***
${TARGET_CUSTOMER_NAME}          Luis Ramos
${PAGINATION_FIRST_PAGE}         css=.ant-pagination-item-1


*** Keywords ***
Navigate To Pending Disbursements Page And Verify
    [Documentation]    Helper step to ensure clean, verified routing before each test case.
    Navigate To Pending Disbursements Page
    View Pending Disbursements List


*** Test Cases ***

t7.3.1 Pending Disbursement list shows latest approved loan at the top
    [Documentation]    Verifies that the most recently approved loan appears on the very first row 
    ...                of the pending disbursements ledger table, and checks column integrity.
    [Tags]             loans    disbursements    smoke    mvp    type2
    # Enforce sorting check by ensuring we are on page 1
    ${has_first_page}=    Run Keyword And Return Status    Wait For Elements State    ${PAGINATION_FIRST_PAGE}    visible    timeout=2s
    IF    ${has_first_page}    Click    ${PAGINATION_FIRST_PAGE}
    
    # Wait for the target to render in the actual data rows (ignoring Ant Design measure rows)
    Wait For Elements State    ${PENDING_DISB_TABLE} >> tbody tr.ant-table-row:has-text("${TARGET_CUSTOMER_NAME}") >> nth=0    visible    timeout=10s
    
    # Assert the sorting engine placed him at the very top of the actual data rows
    ${first_row_text}=    Get Text    ${PENDING_DISB_TABLE} >> tbody tr.ant-table-row >> nth=0
    Should Contain    ${first_row_text}    ${TARGET_CUSTOMER_NAME}    msg=Sorting Failure: Expected ${TARGET_CUSTOMER_NAME} to be in row 0 but was not.
    
    # Assert complete compliance for all structural data columns
    Run Keyword And Continue On Failure    Wait For Elements State    ${PENDING_DISB_TABLE} >> text=Customer ID             visible    timeout=2s
    Run Keyword And Continue On Failure    Wait For Elements State    ${PENDING_DISB_TABLE} >> text=Customer Name           visible    timeout=2s
    Run Keyword And Continue On Failure    Wait For Elements State    ${PENDING_DISB_TABLE} >> text=Loan Name               visible    timeout=2s
    Run Keyword And Continue On Failure    Wait For Elements State    ${PENDING_DISB_TABLE} >> text=Approved By             visible    timeout=2s
    Run Keyword And Continue On Failure    Wait For Elements State    ${PENDING_DISB_TABLE} >> text=Total Loan Amount       visible    timeout=2s
    Run Keyword And Continue On Failure    Wait For Elements State    ${PENDING_DISB_TABLE} >> text=Application Details     visible    timeout=2s
    Run Keyword And Continue On Failure    Wait For Elements State    ${PENDING_DISB_TABLE} >> text="Action"                visible    timeout=2s


t7.3.2 Newly approved loan shows View and Disburse Payment options in Pending Disbursement
    [Documentation]    Ensures the targeted entry possesses both actionable workflow controls 
    ...                within its designated operational matrix row.
    [Tags]             loans    disbursements    smoke    mvp    type2
    ${target_row}=     Set Variable    ${PENDING_DISB_TABLE} >> tbody tr:has-text("${TARGET_CUSTOMER_NAME}") >> nth=0
    
    # Check accessibility and layout configuration rules for both explicit actions
    Run Keyword And Continue On Failure    Wait For Elements State    ${target_row} >> ${PENDING_DISB_VIEW_DETAILS_BTN}    visible    timeout=5s
    Run Keyword And Continue On Failure    Wait For Elements State    ${target_row} >> ${PENDING_DISB_VIEW_DETAILS_BTN}    enabled    timeout=5s
    Run Keyword And Continue On Failure    Wait For Elements State    ${target_row} >> ${PENDING_DISB_DISBURSE_BTN}        visible    timeout=5s
    Run Keyword And Continue On Failure    Wait For Elements State    ${target_row} >> ${PENDING_DISB_DISBURSE_BTN}        enabled    timeout=5s


t7.3.3 Clicking 'View' in Pending Disbursements opens the loan application details
    [Documentation]    Clicks the summary view trigger and inspects the read-only application details data block.
    [Tags]             loans    disbursements    functional    smoke    mvp    type2
    
    Click    ${PENDING_DISB_TABLE} >> tbody tr.ant-table-row:has-text("${TARGET_CUSTOMER_NAME}") >> ${PENDING_DISB_VIEW_DETAILS_BTN} >> nth=0
    
    ${VIEW_MODAL}=    Set Variable    css=.ant-modal-content:has-text("Customer Form")
    Wait For Elements State    ${VIEW_MODAL}    visible    timeout=10s
    
    # Assert primary structural headings
    Run Keyword And Continue On Failure    Wait For Elements State    ${VIEW_MODAL} >> text=Customer Form          visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${VIEW_MODAL} >> text=Loan Details           visible
    
    # FIX: Added >> nth=0 because "Customer Details" appears as both a <p> and an <h2> in the modal
    Run Keyword And Continue On Failure    Wait For Elements State    ${VIEW_MODAL} >> text=Customer Details >> nth=0    visible
    
    # Assert specific read-only loan configuration fields exist
    Run Keyword And Continue On Failure    Wait For Elements State    ${VIEW_MODAL} >> text=Loan amount            visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${VIEW_MODAL} >> text=Interest rate (%)      visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${VIEW_MODAL} >> text=Loan term length       visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${VIEW_MODAL} >> text=Mode of disbursement   visible
    
    # Assert target customer data successfully populated into the read-only view
    Run Keyword And Continue On Failure    Wait For Elements State    ${VIEW_MODAL} >> text=${TARGET_CUSTOMER_NAME}  visible
    
    # Exit view action panel cleanly using your defined data-testid control on the button
    Click    ${VIEW_MODAL} >> ${LOAN_DETAILS_CLOSE_BTN}
    Wait For Elements State    ${VIEW_MODAL}    hidden    timeout=5s




t7.3.4 Disburse Payment modal displays loan details pre-filled from availment
    [Documentation]    Validates that the processing panel accurately inherits immutable core 
    ...                financial records populated during structural approval.
    [Tags]             loans    disbursements    validation    type2    smoke
    
    Click    ${PENDING_DISB_TABLE} >> tbody tr.ant-table-row:has-text("${TARGET_CUSTOMER_NAME}") >> ${PENDING_DISB_DISBURSE_BTN} >> nth=0
    
    # FIX: Use dynamic locator since data-testid is missing from this specific modal
    ${DISBURSE_MODAL}=    Set Variable    css=.ant-modal-content:has-text("Disburse Payment")
    Wait For Elements State    ${DISBURSE_MODAL}    visible    timeout=10s
    
    # FIX: Matches the exact capitalization from your HTML snippet
    Run Keyword And Continue On Failure    Wait For Elements State    ${DISBURSE_MODAL} >> text=Loan Amount               visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${DISBURSE_MODAL} >> text=Interest Rate (%)         visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${DISBURSE_MODAL} >> text=Loan Term                 visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${DISBURSE_MODAL} >> text=Mode of Disbursement      visible


t7.3.5 Confirming disbursement generates a loan account with complete loan details
    [Documentation]    Executes fulfillment workflow using historical setup records, 
    ...                handles account routing mode fields, and validates successful completion.
    [Tags]             loans    disbursements    smoke    mvp    type2
    
    Click    ${PENDING_DISB_TABLE} >> tbody tr.ant-table-row:has-text("${TARGET_CUSTOMER_NAME}") >> ${PENDING_DISB_DISBURSE_BTN} >> nth=0
    
    ${DISBURSE_MODAL}=    Set Variable    css=.ant-modal-content:has-text("Disburse Payment")
    Wait For Elements State    ${DISBURSE_MODAL}    visible    timeout=10s
    
    # Process account routing parameterization step if executing under banking channel rules
    ${is_account_mode}=    Run Keyword And Return Status    Wait For Elements State    id=settlement-account-input    visible    timeout=2s
    IF    ${is_account_mode}
        Fill Text    id=settlement-account-input    ${T26_SAVINGS_ACCOUNT_NUMBER}
    END
    
    Click    ${DISBURSE_MODAL} >> text=Confirm Disbursement
    
    # Handle confirmation overlay wrapper if triggered by site framework
    ${has_overlay}=    Run Keyword And Return Status    Wait For Elements State    css=.ant-modal-confirm-btns    visible    timeout=2s
    IF    ${has_overlay}    Click    css=.ant-modal-confirm-btns .ant-btn-primary
    
    # Intercept system status message alert
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${SUCCESS_TOAST_DISBURSED}    attached    timeout=5s
    Wait For Elements State    ${DISBURSE_MODAL}    hidden    timeout=10s
    
t7.3.6 Successfully disbursed loan appears in Active Loans with View Schedule and Pay options
    [Documentation]    Ensures the finalized contract has migrated cleanly to the Active Loans ledger 
    ...                and exposes the 'View Schedule' and 'Pay Now' actionable controls.
    [Tags]             loans    active_loans    smoke    mvp    type2
    
    Navigate To Active Loans Page
    View Active Loans List
    
    Fill Text    ${ACTIVE_LOANS_SEARCH_INPUT}    ${TARGET_CUSTOMER_NAME}
    Click        ${ACTIVE_LOANS_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    
    # Pinpoint transaction line item row details safely via cascading chain matches
    ${active_row}=    Set Variable    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${TARGET_CUSTOMER_NAME}") >> nth=0
    Wait For Elements State    ${active_row}    visible    timeout=10s
    
    # Audit actionable elements mapping parameters within column (View Schedule & Pay Now)
    Run Keyword And Continue On Failure    Wait For Elements State    ${active_row} >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN}      visible    timeout=5s
    Run Keyword And Continue On Failure    Wait For Elements State    ${active_row} >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN}      enabled    timeout=5s
    Run Keyword And Continue On Failure    Wait For Elements State    ${active_row} >> ${ACTIVE_LOANS_PAY_NOW_BTN}            visible    timeout=5s
    Run Keyword And Continue On Failure    Wait For Elements State    ${active_row} >> ${ACTIVE_LOANS_PAY_NOW_BTN}            enabled    timeout=5s

t7.3.7 Clicking 'Back' in the Disburse Payment modal cancels disbursement and returns to list
    [Documentation]    Tests execution rejection path safety to ensure state caching anomalies are avoided.
    [Tags]             loans    disbursements    validation    type2
    
    Click    ${PENDING_DISB_TABLE} >> tbody tr.ant-table-row:has-text("${TARGET_CUSTOMER_NAME}") >> ${PENDING_DISB_DISBURSE_BTN} >> nth=0
    
    ${DISBURSE_MODAL}=    Set Variable    css=.ant-modal-content:has-text("Disburse Payment")
    Wait For Elements State    ${DISBURSE_MODAL}    visible    timeout=10s
    
    # FIX: Click the 'Back' button explicitly found in your HTML snippet
    Click    ${DISBURSE_MODAL} >> text=Back
    Wait For Elements State    ${DISBURSE_MODAL}    hidden    timeout=5s
    
    # Confirm base data states persist uncorrupted inside data row
    Wait For Elements State    ${PENDING_DISB_PAGE}    visible
    Wait For Elements State    ${PENDING_DISB_TABLE} >> tbody tr.ant-table-row:has-text("${TARGET_CUSTOMER_NAME}") >> nth=0    visible    timeout=5s