*** Settings ***
Documentation       t7.4 Loan Schedule View
...                 Validates the presentation, structural layout, metrics, and empty states 
...                 of the individual Loan Schedule dashboard for an active disbursed loan.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/customers.resource
Resource            ../../resources/keywords/loans.resource

Suite Setup         Run Keywords    Login To Teller App    AND    Fetch Latest Active Loan Account For Target
Suite Teardown      Close Browser
Test Setup          Navigate To Active Loans Page And Verify
Test Teardown       Close Modal If Open


*** Keywords ***
Fetch Latest Active Loan Account For Target
    [Documentation]    Dynamically grabs the most recently disbursed account number 
    ...                for our target customer so we don't have to hardcode it in YAML.
    Navigate To Active Loans Page
    Wait For Elements State      ${ACTIVE_LOANS_PAGE}    visible    timeout=10s
    
    # Search for our specific test customer
    Fill Text                    ${ACTIVE_LOANS_SEARCH_INPUT}    ${T74_TARGET_CUSTOMER_NAME}
    Click                        ${ACTIVE_LOANS_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    
    # Grab the exact text of the Account Number cell from row 0 (the newest one)
    Wait For Elements State      ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row >> nth=0    visible    timeout=10s
    ${dynamic_account_no}=       Get Text    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row >> nth=0 >> td >> nth=0
    
    # Save it as a global suite variable. This temporarily overwrites whatever is in the YAML file!
    Set Suite Variable           ${T74_TARGET_ACCOUNT_NO}    ${dynamic_account_no}
    Log                          Successfully fetched dynamic Account Number: ${T74_TARGET_ACCOUNT_NO}


Navigate To Active Loans Page And Verify
    [Documentation]    Ensures clean routing to the Active Loans list before execution.
    Navigate To Active Loans Page
    View Active Loans List


Access Specific Loan Schedule
    [Documentation]    Helper keyword to bypass repetitive navigation for tests 2-5. 
    ...                Searches the Active Loans grid and enters the schedule view.
    Fill Text                    ${ACTIVE_LOANS_SEARCH_INPUT}    ${T74_TARGET_ACCOUNT_NO}
    Click                        ${ACTIVE_LOANS_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    
    ${target_row}=    Set Variable    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T74_TARGET_ACCOUNT_NO}") >> nth=0
    Wait For Elements State      ${target_row}    visible    timeout=10s
    Click                        ${target_row} >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN}
    
    Wait For Elements State      ${LOAN_SCHEDULE_PAGE}    visible    timeout=10s


*** Test Cases ***

t7.4.1 Verify navigation and page redirection to the Loan Schedule via the Active Loans grid
    [Documentation]    Identifies a valid active loan row, clicks View Schedule, and validates 
    ...                the system successfully routes to the schedule dashboard.
    [Tags]             loans    loan_schedule    navigation    smoke    mvp    type2
    
    Fill Text                    ${ACTIVE_LOANS_SEARCH_INPUT}    ${T74_TARGET_ACCOUNT_NO}
    Click                        ${ACTIVE_LOANS_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    
    ${target_row}=    Set Variable    ${ACTIVE_LOANS_TABLE} >> tbody tr.ant-table-row:has-text("${T74_TARGET_ACCOUNT_NO}") >> nth=0
    Wait For Elements State      ${target_row}    visible    timeout=10s
    
    Click                        ${target_row} >> ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN}
    
    # Assert successful page container mount
    Wait For Elements State      ${LOAN_SCHEDULE_PAGE}    visible    timeout=10s
    
    # Assert the dynamic URL router path includes the target account number
    ${current_url}=    Get Url
    Should Contain     ${current_url}    /loans/active/${T74_TARGET_ACCOUNT_NO}/schedule


t7.4.2 Verify accuracy of identifying information in the Schedule header view
    [Documentation]    Validates the dynamic layout breadcrumbs and header text strictly reflect 
    ...                the selected loan account parameters.
    [Tags]             loans    loan_schedule    layout    smoke    type2
    
    Access Specific Loan Schedule
    
    # 1. Verify Layout Breadcrumbs
    Run Keyword And Continue On Failure    Wait For Elements State    ${NAV_BREADCRUMB} >> text=Active Loans     visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${NAV_BREADCRUMB} >> text=View Schedule    visible
    
    # 2. Verify Identifiers (Account Number and Customer Name)
    Run Keyword And Continue On Failure    Wait For Elements State    ${HEADER_TITLE_BLOCK} >> text=${T74_TARGET_ACCOUNT_NO}       visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${HEADER_TITLE_BLOCK} >> text=${T74_TARGET_CUSTOMER_NAME}    visible


t7.4.3 Verify structural metrics and components inside the Payment Status card
    [Documentation]    Evaluates the data tracking blocks, circular chart attributes, and the 
    ...                presence of the embedded payment action trigger.
    [Tags]             loans    loan_schedule    metrics    smoke    type2
    
    Access Specific Loan Schedule
    
    Wait For Elements State    ${LOAN_SCHEDULE_STATUS_CARD}    visible    timeout=5s
    
    # 1. Verify Repayment Progress texts and graphical indicators
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_STATUS_CARD} >> text=Payment Status               visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_STATUS_CARD} >> text=Loan Repayment Progress      visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_STATUS_CARD} >> text=0%                           visible
    
    # Verify the specific metric ratio formatting ("0.00 / 10,091.91")
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_STATUS_CARD} >> text=0.00 /                       visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_STATUS_CARD} >> text=${T74_EXPECTED_REPAYMENT_TOTAL}  visible
    
    # 2. Verify Pay Now action button
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_STATUS_CARD} >> ${LOAN_SCHEDULE_PAY_NOW_BTN}      visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_STATUS_CARD} >> ${LOAN_SCHEDULE_PAY_NOW_BTN}      enabled


t7.4.4 Verify data parameters listed inside the Loan Details block
    [Documentation]    Checks the right-hand metadata component to ensure accurate calculation mappings 
    ...                are displayed for amortization, interest, and the originating disburser.
    [Tags]             loans    loan_schedule    validation    smoke    type2
    
    Access Specific Loan Schedule
    
    Wait For Elements State    ${LOAN_SCHEDULE_DETAILS_CARD}    visible    timeout=5s
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_DETAILS_CARD} >> text=Loan Details    visible
    
    # Map and assert key-value pairs inside the definition list
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_DETAILS_CARD} >> text=Monthly Amortization Amount:    visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_DETAILS_CARD} >> text=${T74_EXPECTED_AMORTIZATION}        visible
    
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_DETAILS_CARD} >> text=Interest Rate (%):              visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_DETAILS_CARD} >> text=${T74_EXPECTED_INTEREST}            visible
    
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_DETAILS_CARD} >> text=Loan Disbursed by:              visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_DETAILS_CARD} >> text=${T74_EXPECTED_DISBURSER}           visible


t7.4.5 Verify layout behavior for the Payments Made table when no payment history exists
    [Documentation]    Inspects the bottom transactions matrix for the correct columns and the specific 
    ...                empty-state inbox illustration/message for fresh accounts.
    [Tags]             loans    loan_schedule    layout    validation    type2
    
    Access Specific Loan Schedule
    
    Wait For Elements State    ${LOAN_SCHEDULE_TABLE}    visible    timeout=5s
    
    # 1. Audit structural headers
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_TABLE} >> text=Transaction ID    visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_TABLE} >> text=Paid on           visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_TABLE} >> text=Amount Paid       visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_TABLE} >> text=Processed by      visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_TABLE} >> text="Action"          visible
    
    # 2. Verify empty state illustration and text prompt
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_TABLE} >> css=.ant-empty-image                 visible
    Run Keyword And Continue On Failure    Wait For Elements State    ${LOAN_SCHEDULE_TABLE} >> text=No payment activity recorded.   visible