*** Settings ***
Documentation       Test suite for the Loans module.
Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/loans.resource

Suite Setup         Login To Teller App
Suite Teardown      Logout From Teller App

*** Variables ***
${TARGET_PENDING_LOAN}      Loans Edit 1
${TARGET_DISB_LOAN}         Loan 0603172028
${REJECTION_NOTE}           Insufficient collateral valuation profiles.

*** Test Cases ***

t7.1.1 Access the Loans module and view the list of active loans
    [Tags]             loans    active_loans    smoke    mvp    type1
    Navigate To Active Loans Page
    View Active Loans List
    
    # Column verification — continue on failure to audit all fields
    Run Keyword And Continue On Failure    Wait For Elements State    text=Loan Account No.    visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Customer Name       visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Loan Name           visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Approved by         visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Total Loan Amount   visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text="Action"            visible    timeout=3s

    # Row button existence checking — table has many rows, check first occurrence
    Run Keyword And Continue On Failure    Wait For Elements State    ${ACTIVE_LOANS_VIEW_SCHEDULE_BTN} >> nth=0    visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    ${ACTIVE_LOANS_PAY_NOW_BTN} >> nth=0          visible    timeout=3s


t7.1.2 Access the Loans module and view the list of pending loan applications
    [Tags]             loans    pending_apps    smoke    mvp    type1
    Navigate To Pending Applications Page
    View Pending Applications List
    
    Run Keyword And Continue On Failure    Wait For Elements State    text=Customer ID         visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Customer Name       visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Loan Name           visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Loan Category       visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Total Loan Amount   visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text="Action"            visible    timeout=3s


t7.1.3 Access the Loans module and view the list of pending disbursement applications
    [Tags]             loans    disbursements    smoke    mvp    type1
    Navigate To Pending Disbursements Page
    View Pending Disbursements List
    
    Run Keyword And Continue On Failure    Wait For Elements State    text=Customer ID             visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Customer Name           visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Loan Name               visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Approved By             visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Total Loan Amount       visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Application Details     visible    timeout=3s


t7.1.4 Access the Loans module and view the list of rejected loan applications
    [Tags]             loans    rejected_loans    smoke    mvp    type1
    Navigate To Rejected Loans Page
    View Rejected Loans List
    
    Run Keyword And Continue On Failure    Wait For Elements State    text=Customer ID         visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Customer Name       visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Loan Name           visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Loan Category       visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Total Loan Amount   visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Rejected by         visible    timeout=3s
    Run Keyword And Continue On Failure    Wait For Elements State    text=Rejection Remarks   visible    timeout=3s


t7.1.5 Pagination and Navigation - Active Loans
    [Documentation]    Verify pagination on Active Loans: Next loads page 2, page 3 if present,
    ...                Back returns. Skipped when only one page exists.
    [Tags]             loans    active_loans    smoke    mvp    type1    pagination
    Navigate To Active Loans Page
    View Active Loans List
    ${has_multiple_pages}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${PAGINATION_NEXT}    enabled    timeout=3s
    IF    ${has_multiple_pages}
        Click                      ${PAGINATION_NEXT}
        Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ${page3_exists}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=li.ant-pagination-item[title="3"]    visible    timeout=2s
        IF    ${page3_exists}
            Click                      css=li.ant-pagination-item[title="3"]
            Wait For Elements State    css=li.ant-pagination-item-active[title="3"]    visible
            Click                      ${PAGINATION_PREV}
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ELSE
            Click                      ${PAGINATION_PREV}
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("1")    visible
        END
    ELSE
        Log    Only one page of active loans — pagination navigation skipped
        Wait For Elements State    ${PAGINATION_NEXT}    disabled
    END


t7.1.6 Pagination and Navigation - Pending Applications
    [Documentation]    Verify pagination on Pending Applications.
    [Tags]             loans    pending_apps    smoke    mvp    type1    pagination
    Navigate To Pending Applications Page
    View Pending Applications List
    ${has_multiple_pages}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${PAGINATION_NEXT}    enabled    timeout=3s
    IF    ${has_multiple_pages}
        Click                      ${PAGINATION_NEXT}
        Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ${page3_exists}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=li.ant-pagination-item[title="3"]    visible    timeout=2s
        IF    ${page3_exists}
            Click                      css=li.ant-pagination-item[title="3"]
            Wait For Elements State    css=li.ant-pagination-item-active[title="3"]    visible
            Click                      ${PAGINATION_PREV}
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ELSE
            Click                      ${PAGINATION_PREV}
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("1")    visible
        END
    ELSE
        Log    Only one page of pending applications — pagination navigation skipped
        Wait For Elements State    ${PAGINATION_NEXT}    disabled
    END


t7.1.7 Pagination and Navigation - Pending Disbursements
    [Documentation]    Verify pagination on Pending Disbursements.
    [Tags]             loans    disbursements    smoke    mvp    type1    pagination
    Navigate To Pending Disbursements Page
    View Pending Disbursements List
    ${has_multiple_pages}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${PAGINATION_NEXT}    enabled    timeout=3s
    IF    ${has_multiple_pages}
        Click                      ${PAGINATION_NEXT}
        Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ${page3_exists}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=li.ant-pagination-item[title="3"]    visible    timeout=2s
        IF    ${page3_exists}
            Click                      css=li.ant-pagination-item[title="3"]
            Wait For Elements State    css=li.ant-pagination-item-active[title="3"]    visible
            Click                      ${PAGINATION_PREV}
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ELSE
            Click                      ${PAGINATION_PREV}
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("1")    visible
        END
    ELSE
        Log    Only one page of pending disbursements — pagination navigation skipped
        Wait For Elements State    ${PAGINATION_NEXT}    disabled
    END


t7.1.8 Pagination and Navigation - Rejected Loans
    [Documentation]    Verify pagination on Rejected Loans.
    [Tags]             loans    rejected_loans    smoke    mvp    type1    pagination
    Navigate To Rejected Loans Page
    View Rejected Loans List
    ${has_multiple_pages}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${PAGINATION_NEXT}    enabled    timeout=3s
    IF    ${has_multiple_pages}
        Click                      ${PAGINATION_NEXT}
        Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ${page3_exists}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=li.ant-pagination-item[title="3"]    visible    timeout=2s
        IF    ${page3_exists}
            Click                      css=li.ant-pagination-item[title="3"]
            Wait For Elements State    css=li.ant-pagination-item-active[title="3"]    visible
            Click                      ${PAGINATION_PREV}
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ELSE
            Click                      ${PAGINATION_PREV}
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("1")    visible
        END
    ELSE
        Log    Only one page of rejected loans — pagination navigation skipped
        Wait For Elements State    ${PAGINATION_NEXT}    disabled
    END


t7.1.9 Search Active Loans by Account Number
    [Documentation]    Search Active Loans by a known account number and verify at least
    ...                one matching row is returned. Clears the search at the end.
    [Tags]             loans    active_loans    smoke    mvp    type1    search
    Navigate To Active Loans Page
    View Active Loans List
    Fill Text                  ${ACTIVE_LOANS_SEARCH_INPUT}    ${T71_ACTIVE_LOAN_SEARCH}
    Click                      ${ACTIVE_LOANS_SEARCH_BTN}
    Wait For Elements State    ${ACTIVE_LOANS_TABLE} >> tbody tr:has-text("${T71_ACTIVE_LOAN_SEARCH}") >> nth=0    visible    timeout=5s
    # Clear search and verify list reloads
    Fill Text                  ${ACTIVE_LOANS_SEARCH_INPUT}    ${EMPTY}
    Click                      ${ACTIVE_LOANS_SEARCH_BTN}
    Wait For Elements State    ${ACTIVE_LOANS_TABLE}    visible


t7.1.10 Search Pending Applications by Customer Name
    [Documentation]    Search Pending Applications by a known customer name and verify
    ...                at least one matching row is returned. Clears the search at the end.
    [Tags]             loans    pending_apps    smoke    mvp    type1    search
    Navigate To Pending Applications Page
    View Pending Applications List
    Fill Text                  ${PENDING_APPS_SEARCH_INPUT}    ${T71_PENDING_APP_SEARCH}
    Click                      ${PENDING_APPS_SEARCH_BTN}
    Wait For Elements State    ${PENDING_APPS_TABLE} >> tbody tr:has-text("${T71_PENDING_APP_SEARCH}") >> nth=0    visible    timeout=5s
    Fill Text                  ${PENDING_APPS_SEARCH_INPUT}    ${EMPTY}
    Click                      ${PENDING_APPS_SEARCH_BTN}
    Wait For Elements State    ${PENDING_APPS_TABLE}    visible


t7.1.11 Search Pending Disbursements by Customer Name
    [Documentation]    Search Pending Disbursements by a known customer name and verify
    ...                at least one matching row is returned. Clears the search at the end.
    [Tags]             loans    disbursements    smoke    mvp    type1    search
    Navigate To Pending Disbursements Page
    View Pending Disbursements List
    Fill Text                  ${PENDING_DISB_SEARCH_INPUT}    ${T71_PENDING_DISB_SEARCH}
    Click                      ${PENDING_DISB_SEARCH_BTN}
    Wait For Elements State    ${PENDING_DISB_TABLE} >> tbody tr:has-text("${T71_PENDING_DISB_SEARCH}") >> nth=0    visible    timeout=5s
    Fill Text                  ${PENDING_DISB_SEARCH_INPUT}    ${EMPTY}
    Click                      ${PENDING_DISB_SEARCH_BTN}
    Wait For Elements State    ${PENDING_DISB_TABLE}    visible


t7.1.12 Search Rejected Loans by Customer Name
    [Documentation]    Search Rejected Loans by a known customer name and verify at least
    ...                one matching row is returned. Clears the search at the end.
    [Tags]             loans    rejected_loans    smoke    mvp    type1    search
    Navigate To Rejected Loans Page
    View Rejected Loans List
    Fill Text                  ${REJECTED_APPS_SEARCH_INPUT}    ${T71_REJECTED_LOAN_SEARCH}
    Click                      ${REJECTED_APPS_SEARCH_BTN}
    Wait For Elements State    ${REJECTED_APPS_TABLE} >> tbody tr:has-text("${T71_REJECTED_LOAN_SEARCH}") >> nth=0    visible    timeout=5s
    Fill Text                  ${REJECTED_APPS_SEARCH_INPUT}    ${EMPTY}
    Click                      ${REJECTED_APPS_SEARCH_BTN}
    Wait For Elements State    ${REJECTED_APPS_TABLE}    visible


t7.1.13 Execute Processing Workflow Actions for Loan Records
    [Tags]             loans    functional    regression    type1
    # 1. Test Approval & Rejection Sequences
    Navigate To Pending Applications Page
    View Pending Applications List
    Fill Text                        ${PENDING_APPS_SEARCH_INPUT}    ${TARGET_PENDING_LOAN}
    Click                            ${PENDING_APPS_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    Approve Loan                     ${TARGET_PENDING_LOAN}
    Reject Loan                      ${TARGET_PENDING_LOAN}    ${REJECTION_NOTE}

    # 2. Test Disbursement Sequence
    Navigate To Pending Disbursements Page
    View Pending Disbursements List
    Fill Text                        ${PENDING_DISB_SEARCH_INPUT}    ${TARGET_DISB_LOAN}
    Click                            ${PENDING_DISB_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    Disburse Loan                    ${TARGET_DISB_LOAN}