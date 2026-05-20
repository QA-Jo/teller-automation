*** Settings ***
Documentation       Test suite for the Loans module.
Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/loans.resource

Suite Setup         Login To Teller App
Suite Teardown      Logout From Teller App

*** Variables ***
${TARGET_PENDING_LOAN}      LN-PEND-88412
${TARGET_DISB_LOAN}         LN-CLEARED-3091
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


t7.1.5 Execute Processing Workflow Actions for Loan Records
    [Tags]             loans    functional    regression    type1
    # 1. Test Approval & Rejection Sequences
    Navigate To Pending Applications Page
    Approve Loan                     ${TARGET_PENDING_LOAN}
    Reject Loan                      ${TARGET_PENDING_LOAN}    ${REJECTION_NOTE}
    
    # 2. Test Disbursement Sequence
    Navigate To Pending Disbursements Page
    Disburse Loan                    ${TARGET_DISB_LOAN}