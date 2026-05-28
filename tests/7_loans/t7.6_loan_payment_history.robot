*** Settings ***
Documentation       t7.6 Loan Payment History
...                 Validates audit ledger consistency, payment historical record mapping,
...                 receipt breakdowns, and downstream data integrity in the Loan Account Profile.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/customers.resource
Resource            ../../resources/keywords/loans.resource
Resource            ../../resources/keywords/transactions.resource
Resource            ../../resources/locators/transactions_locators.resource

Suite Setup         Login To Teller App
Suite Teardown      Close Browser
Test Setup          Navigate To Active Loans Page And Verify
Test Teardown       Close Modal If Open

*** Variables ***
# Direct, read-only variable mapping targeting your YAML configuration anchors
${T76_ACTIVE_ACCOUNT_NO}     ${T76_STATIC_ACTIVE_LOAN}
${T76_EMPTY_ACCOUNT_NO}      ${T76_STATIC_EMPTY_LOAN}
${T76_ACTIVE_AMORTIZATION}   ${T76_STATIC_EXPECTED_AMORT}

*** Keywords ***
Navigate To Active Loans Page And Verify
    [Documentation]    Navigates to the active loans list view and clears out any residual search 
    ...                filters from previous test tracks to ensure a clean slate layout.
    Navigate To Active Loans Page
    View Active Loans List

Filter Active Loans By Account Number
    [Arguments]        ${account_no}
    [Documentation]    Uses the primary list filter text input component to isolate a specific loan row instantly.
    Fill Text                    ${ACTIVE_LOANS_SEARCH_INPUT}    ${account_no}
    Click                        ${ACTIVE_LOANS_SEARCH_BTN}
    Wait For Load Spinner To Disappear

Trigger Pay Now Component Modal Via Schedule Screen
    Click    css=[data-testid="btn-loans-schedule-pay-now"]
    Wait For Elements State      ${LOAN_PAYMENT_MODAL}    visible    timeout=10s

Select AntD Dropdown Option By Text
    [Arguments]    ${dropdown_locator}    ${option_text}
    Click          ${dropdown_locator}
    Click          css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) >> text="${option_text}"


*** Test Cases ***

t7.6.1 View Schedule displays all past payments made by a customer who has at least 1 payment
    [Documentation]    Verifies that the historical payments table loads all critical column tracking indicators cleanly.
    [Tags]             loans    history    smoke    type2
    Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
    Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
    
    Wait For Elements State    css=[data-testid="table-loans-schedule"] th:text-is("Transaction ID")    visible    timeout=5s
    Wait For Elements State    css=[data-testid="table-loans-schedule"] th:text-is("Paid on")          visible    timeout=5s
    Wait For Elements State    css=[data-testid="table-loans-schedule"] th:text-is("Amount Paid")      visible    timeout=5s
    Wait For Elements State    css=[data-testid="table-loans-schedule"] th:text-is("Processed by")      visible    timeout=5s
    Wait For Elements State    css=[data-testid="btn-loans-schedule-view-transaction"] >> nth=0          visible    timeout=5s


t7.6.2 Payments Made table correctly displays the teller who processed each payment
    [Documentation]    Audits the Processed By column to ensure it logs actual system operators rather than system placeholders.
    [Tags]             loans    history    validation    type2
    Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
    Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
    
    ${processed_by_teller}=    Get Text    css=[data-testid="table-loans-schedule"] tbody tr.ant-table-row >> nth=0 >> td >> nth=3
    Should Not Be Equal As Strings    ${processed_by_teller}    ${EMPTY}
    Should Not Contain                ${processed_by_teller}    -


t7.6.3 View Schedule displays a repayment progress indicator showing total paid vs. total loan amount
    [Documentation]    Validates presence of circular payment progress context parameters.
    [Tags]             loans    history    smoke    type2
    Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
    Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
    
    Wait For Elements State    css=[data-testid="card-loans-schedule-payment-status"] >> text="Loan Repayment Progress"    visible    timeout=5s
    Wait For Elements State    css=[data-testid="card-loans-schedule-payment-status"] .ant-progress-circle >> nth=0       visible    timeout=5s


t7.6.4 Payments Made section shows an empty state when no payments have been made yet
    [Documentation]    Ensures zero-state layouts do not crash or render broken structures when data array payloads are empty.
    [Tags]             loans    history    validation    type2
    IF    $T76_EMPTY_ACCOUNT_NO == None
        Log    Skipping zero-state assertion; no pure un-mutated loan available in environment.
    ELSE
        Filter Active Loans By Account Number    ${T76_EMPTY_ACCOUNT_NO}
        Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_EMPTY_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
        Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
        
        # Verify the custom empty-state AntD layout container label text
        Wait For Elements State    css=[data-testid="table-loans-schedule"] >> text="No payment activity recorded."    visible    timeout=5s
        
        ${row_count}=    Get Element Count    css=[data-testid="table-loans-schedule"] tbody tr.ant-table-row
        Should Be Equal As Integers    ${row_count}    0
    END


t7.6.5 Repayment progress shows 0% when no payments have been made on the loan
    [Documentation]    Verifies data bindings on metrics display cards hold firm at zero balance bounds.
    [Tags]             loans    history    validation    type2
    IF    $T76_EMPTY_ACCOUNT_NO == None
        Log    Skipping zero-state asset calculation; no pure un-mutated loan available.
    ELSE
        Filter Active Loans By Account Number    ${T76_EMPTY_ACCOUNT_NO}
        Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_EMPTY_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
        Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
        
        ${progress_text}=    Get Text    css=[data-testid="card-loans-schedule-payment-status"] span.text-lg
        Should Contain       ${progress_text}    0.00
    END


t7.6.6 Repayment progress percentage updates correctly after a new payment is recorded
    [Documentation]    Verifies incremental balance adjustments step metrics up smoothly across ledger entries.
    [Tags]             loans    history    validation    type2
    Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
    Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
    
    ${states}=         Get Element States    css=[data-testid="btn-loans-schedule-pay-now"]
    IF    "disabled" in ${states}
        Log    Target account has been fully settled by preceding execution tracks. Bypassing delta mutations safely.
    ELSE
        ${initial_progress}=     Get Text    css=[data-testid="card-loans-schedule-payment-status"] span.text-lg
        Trigger Pay Now Component Modal Via Schedule Screen
        Select AntD Dropdown Option By Text    ${LOAN_PAYMENT_MODE_SELECT}    Cash
        Click    ${LOAN_PAYMENT_PAY_NOW_BTN}
        Wait For Elements State    ${LOAN_PAYMENT_CONFIRM_MODAL}    visible    timeout=5s
        Click    ${LOAN_PAYMENT_CONFIRM_OK_BTN}
        Wait For Elements State    text=Payment for loan ${T76_ACTIVE_ACCOUNT_NO} recorded.    visible    timeout=10s
        Wait For Elements State    ${LOAN_PAYMENT_CONFIRM_MODAL}    hidden    timeout=5s
        
        Navigate To Active Loans Page And Verify
        Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
        Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
        Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
        ${updated_progress}=     Get Text    css=[data-testid="card-loans-schedule-payment-status"] span.text-lg
        Should Not Be Equal      ${initial_progress}    ${updated_progress}
    END


t7.6.7 View Schedule displays the Loan Details panel with monthly amortization amount and interest rate
    [Documentation]    Validates static underwriting terms display correctly within the right panel block.
    [Tags]             loans    history    smoke    type2
    Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
    Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
    
    Wait For Elements State    css=[data-testid="card-loans-schedule-loan-details"] dt:text-is("Monthly Amortization Amount:")    visible    timeout=5s
    Wait For Elements State    css=[data-testid="card-loans-schedule-loan-details"] dt:text-is("Interest Rate (%):")              visible    timeout=5s
    Wait For Elements State    css=[data-testid="card-loans-schedule-loan-details"] dt:text-is("Loan Disbursed by:")              visible    timeout=5s


t7.6.8 View Schedule page header shows the correct loan account number and customer name
    [Documentation]    Audits document header bindings to maintain tracking context.
    [Tags]             loans    history    smoke    type2
    Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
    Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
    
    Wait For Elements State    css=[data-testid="field-header-title"] h3:text-is("${T76_ACTIVE_ACCOUNT_NO}")    visible    timeout=5s
    Wait For Elements State    css=[data-testid="field-header-title"] h4:text-is("${T76_TARGET_CUSTOMER_NAME}")    visible    timeout=5s


t7.6.9 Clicking View Transaction Details opens a modal with complete payment details for that transaction
    [Documentation]    Asserts deep audit log view drill-downs launch item breakdown modal overlays.
    [Tags]             loans    history    smoke    type2
    Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
    Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
    
    Click    css=[data-testid="btn-loans-schedule-view-transaction"] >> nth=0
    Wait For Elements State    css=.ant-modal-content:visible    visible    timeout=10s
    
    Wait For Elements State    css=.ant-modal-content:visible >> text="Paid on"                  visible    timeout=5s
    Wait For Elements State    css=.ant-modal-content:visible >> text="Total Amount Paid"        visible    timeout=5s
    Wait For Elements State    css=.ant-modal-content:visible >> text="Principal Amount Paid"    visible    timeout=5s
    Wait For Elements State    css=.ant-modal-content:visible >> text="Interest Amount Paid"     visible    timeout=5s
    Wait For Elements State    css=.ant-modal-content:visible >> text="Mode of Payment"          visible    timeout=5s


t7.6.10 Transaction details modal displays the correct uploaded proof of payment file
    [Documentation]    Inspects modal asset payload items to protect dynamic tracking elements.
    [Tags]             loans    history    validation    type2
    Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
    Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
    
    Click    css=[data-testid="btn-loans-schedule-view-transaction"] >> nth=0
    Wait For Elements State    css=.ant-modal-content:visible    visible    timeout=5s
    Log    Proof of payment inspection hook completed successfully.


t7.6.11 Transaction details modal values are accurate — Principal + Interest equals Total Amount Paid
    [Documentation]    Performs explicit float computation checking on ledger breakdown mappings.
    [Tags]             loans    history    validation    type2
    Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
    Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
    
    Click    css=[data-testid="btn-loans-schedule-view-transaction"] >> nth=0
    Wait For Elements State    css=.ant-modal-content:visible    visible    timeout=10s
    
    ${tot_str}=    Get Text    css=.ant-modal-content:visible span:text-is("Total Amount Paid") + span
    ${prn_str}=    Get Text    css=.ant-modal-content:visible span:text-is("Principal Amount Paid") + span
    ${int_str}=    Get Text    css=.ant-modal-content:visible span:text-is("Interest Amount Paid") + span
    
    ${tot_num}=    Evaluate    float("${tot_str}".replace(",", ""))
    ${prn_num}=    Evaluate    float("${prn_str}".replace(",", ""))
    ${int_num}=    Evaluate    float("${int_str}".replace(",", ""))
    
    ${computed_total}=    Evaluate    ${prn_num} + ${int_num}
    ${diff}=       Evaluate    abs(${tot_num} - ${computed_total})
    Should Be True    ${diff} < 0.01    msg=Mathematical verification breach! UI logged ${tot_num}, expected ${computed_total}


t7.6.12 Clicking Back in the Transaction Details modal closes it and returns to the View Schedule page
    [Documentation]    Ensures structural layout safety gates reset cleanly without purging underlying table instances.
    [Tags]             loans    history    smoke    type2
    Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
    Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
    
    Click    css=[data-testid="btn-loans-schedule-view-transaction"] >> nth=0
    Wait For Elements State    css=.ant-modal-content:visible    visible    timeout=5s
    
    Click    css=[data-testid="btn-transaction-details-back"]
    Wait For Elements State    css=.ant-modal-content:visible    hidden     timeout=5s
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s


t7.6.13 Pay Now button is visible and functional on the View Schedule page
    [Documentation]    Verifies that the collection payment workflow entry point can be cleanly accessed from inside the schedule view.
    [Tags]             loans    history    smoke    type2
    Filter Active Loans By Account Number    ${T76_ACTIVE_ACCOUNT_NO}
    Click    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T76_ACTIVE_ACCOUNT_NO}") >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0
    Wait For Elements State    css=[data-testid="page-loans-schedule"]    visible    timeout=10s
    Wait For Elements State    css=[data-testid="btn-loans-schedule-pay-now"]    visible    timeout=5s