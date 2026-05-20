*** Settings ***
Documentation       t3.2 View the List of Transactions of a Bank Account
...                 Covers entry point via Accounts module, pagination, transaction detail view,
...                 search by ID, date range filtering, type filtering, status filtering,
...                 and navigation back to Accounts list.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/accounts.resource

Suite Setup         Login To Teller App
Suite Teardown      Close Browser
Test Setup          Setup Account Transaction Page
Test Teardown       Close Modal If Open


*** Keywords ***
Setup Account Transaction Page
    [Documentation]    Navigates to the Transaction History page for the target account
    ...                via the Accounts module and ensures a clean state.
    Navigate To Account Transactions    ${VALID_ACCOUNT_ID}
    Reload
    Wait For Load Spinner To Disappear


*** Variables ***
${TXN_ROW}                  css=.ant-table-body table tbody tr:has-text("${VALID_TXN_ID}")
${NON_EXISTING_TXN_ID}      NONEXISTENT99999


*** Test Cases ***
t3.2.1 View Account Transaction History (Entry Point)
    [Documentation]    Verify that clicking View Transactions from the Accounts module navigates
    ...                to the Transaction History page with all required columns and action buttons.
    [Tags]             accounts    transactions    smoke    mvp    type1
    Get Url                    contains    /transactions
    # Verify all fields — continue on failure so ALL mismatches are reported
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction ID                                       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction Type                                     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Date & Time                                          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Debit Amount                                         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Credit Amount                                        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Status                                               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Last Updated                                         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text="Action"                                             visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${VIEW_TXN_BTN} >> nth=0                                 visible
    #hidden for now  
    # Run Keyword And Continue On Failure
    # ...    Wait For Elements State    ${DOWNLOAD_TXN_BTN} >> nth=0                             visible

t3.2.2 Pagination in Viewing Transaction History
    [Documentation]    Verify pagination controls work correctly:
    ...                Next loads page 2, clicking page 3 loads page 3,
    ...                and Back returns to page 2. Skips if only one page exists.
    [Tags]             accounts    transactions    smoke    mvp    type1    pagination
    ${has_multiple_pages}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${PAGINATION_NEXT}    enabled    timeout=3s
    IF    ${has_multiple_pages}
        # Click Next arrow to go to page 2
        Click                      ${PAGINATION_NEXT}
        Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        # Click page number 3 if it exists
        ${page3_exists}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=li.ant-pagination-item[title="3"]    visible    timeout=2s
        IF    ${page3_exists}
            Click                      css=li.ant-pagination-item[title="3"]
            Wait For Elements State    css=li.ant-pagination-item-active[title="3"]    visible
            # Click Back arrow to return to page 2
            Click                      ${PAGINATION_PREV}
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ELSE
            # Only 2 pages — click Back to return to page 1
            Click                      ${PAGINATION_PREV}
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("1")    visible
        END
    ELSE
        Log    Only one page of transactions — pagination navigation skipped
        Wait For Elements State    ${PAGINATION_NEXT}    disabled
    END

t3.2.3 View Specific Transaction Details (via Accounts)
    [Documentation]    Verify that clicking the Eye icon opens the transaction detail modal
    ...                with all required field labels, and the modal closes cleanly.
    [Tags]             accounts    transactions    smoke    mvp    type1
    Click                      ${VIEW_TXN_BTN} >> nth=0
    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL}                                    visible
    # Verify all fields — continue on failure so ALL mismatches are reported
    # Verify all required field labels are present in the modal
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction ID             visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction Type           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction Amount         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Service Fee               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Remarks                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction Status         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Debit Account Name        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Credit Account Name       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Debit Account Number      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Credit Account Number     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Created on                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Updated on                visible
    # Close modal and verify return to transaction list
    Click                      ${ACCT_TXN_DETAIL_BACK_BTN}
    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL}    hidden
    Wait For Elements State    ${ACCT_TXN_TABLE}           visible

t3.2.4 Search Transaction by ID and View Details (via Accounts)
    [Documentation]    Verify that searching by a valid Transaction ID returns exactly one record,
    ...                and the detail modal displays all expected field values accurately.
    [Tags]             accounts    transactions    smoke    mvp    type1
    Fill Text                  ${ACCT_TXN_SEARCH_FIELD}    ${VALID_TXN_ID}
    Click                      ${ACCT_TXN_SEARCH_BUTTON}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${TXN_ROW}    visible
    Get Element Count          css=.ant-table-body table tbody tr:not([aria-hidden="true"])    ==    1
    # Open transaction detail modal
    Click                      ${TXN_ROW} >> ${VIEW_TXN_BTN}
    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL}                                        visible
    # Verify all field values using exact text matching (:text-is)
    ${_txn_id}=        Get Text    ${ACCT_TXN_DETAIL_MODAL} >> :text-is("${VALID_TXN_ID}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_txn_id}    ${VALID_TXN_ID}
    ...    msg=Transaction ID mismatch: expected '${VALID_TXN_ID}' but got '${_txn_id}'
    ${_txn_type}=      Get Text    ${ACCT_TXN_DETAIL_MODAL} >> :text-is("${TXN_TYPE}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_txn_type}    ${TXN_TYPE}
    ...    msg=Transaction Type mismatch: expected '${TXN_TYPE}' but got '${_txn_type}'
    ${_txn_amount}=    Get Text    ${ACCT_TXN_DETAIL_MODAL} >> :text-is("${TXN_AMOUNT}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_txn_amount}    ${TXN_AMOUNT}
    ...    msg=Transaction Amount mismatch: expected '${TXN_AMOUNT}' but got '${_txn_amount}'
    ${_svc_fee}=       Get Text    ${ACCT_TXN_DETAIL_MODAL} >> :text-is("${TXN_SERVICE_FEE}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_svc_fee}    ${TXN_SERVICE_FEE}
    ...    msg=Service Fee mismatch: expected '${TXN_SERVICE_FEE}' but got '${_svc_fee}'
    ${_remarks}=       Get Text    ${ACCT_TXN_DETAIL_MODAL} >> :text-is("${TXN_REMARKS}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_remarks}    ${TXN_REMARKS}
    ...    msg=Remarks mismatch: expected '${TXN_REMARKS}' but got '${_remarks}'
    ${_status}=        Get Text    ${ACCT_TXN_DETAIL_MODAL} >> :text-is("${TXN_STATUS}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_status}    ${TXN_STATUS}
    ...    msg=Transaction Status mismatch: expected '${TXN_STATUS}' but got '${_status}'
    ${_debit_name}=    Get Text    ${ACCT_TXN_DETAIL_MODAL} >> :text-is("${TXN_DEBIT_ACCT_NAME}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_debit_name}    ${TXN_DEBIT_ACCT_NAME}
    ...    msg=Debit Account Name mismatch: expected '${TXN_DEBIT_ACCT_NAME}' but got '${_debit_name}'
    ${_credit_name}=   Get Text    ${ACCT_TXN_DETAIL_MODAL} >> :text-is("${TXN_CREDIT_ACCT_NAME}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_credit_name}    ${TXN_CREDIT_ACCT_NAME}
    ...    msg=Credit Account Name mismatch: expected '${TXN_CREDIT_ACCT_NAME}' but got '${_credit_name}'
    ${_debit_no}=      Get Text    ${ACCT_TXN_DETAIL_MODAL} >> :text-is("${TXN_DEBIT_ACCT_NO}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_debit_no}    ${TXN_DEBIT_ACCT_NO}
    ...    msg=Debit Account Number mismatch: expected '${TXN_DEBIT_ACCT_NO}' but got '${_debit_no}'
    ${_credit_no}=     Get Text    ${ACCT_TXN_DETAIL_MODAL} >> :text-is("${TXN_CREDIT_ACCT_NO}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_credit_no}    ${TXN_CREDIT_ACCT_NO}
    ...    msg=Credit Account Number mismatch: expected '${TXN_CREDIT_ACCT_NO}' but got '${_credit_no}'
    ${_created_on}=    Get Text    ${ACCT_TXN_DETAIL_MODAL} >> :text-is("${TXN_CREATED_ON}") >> nth=0
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_created_on}    ${TXN_CREATED_ON}
    ...    msg=Created On mismatch: expected '${TXN_CREATED_ON}' but got '${_created_on}'
    # Close modal and verify return to filtered list
    Click                      ${ACCT_TXN_DETAIL_BACK_BTN}
    Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL}    hidden
    Wait For Elements State    ${TXN_ROW}                  visible

t3.2.5 Search Transactions Using Date Range (via Accounts)
    [Documentation]    Verify the date range filter shows only transactions within the selected range.
    [Tags]             accounts    transactions    regression    mvp    type1
    skip
    # Apply a date range with known results
    Click                      ${DATE_TIME_FILTER}
    Wait For Elements State    ${DATE_START_INPUT}    visible
    Select Date Range From AntD Picker    ${DATE_FROM}    ${DATE_TO}
    Click                      ${DATE_FILTER_SEARCH_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    # Verify at least one result row is visible
    Wait For Elements State    css=.ant-table-body table tbody tr:not([aria-hidden="true"]) >> nth=0    visible
    # Verify all transaction dates are within the specified range
    Verify Acct Txn Dates Within Range    ${DATE_FROM}    ${DATE_TO}
    # Verify all required columns are still present after filtering
    # Verify all fields — continue on failure so ALL mismatches are reported
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction ID       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction Type     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Date & Time          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Debit Amount         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Credit Amount        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Status               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Last Updated         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text="Action"             visible

t3.2.6 Filter Transactions by Type: Send Money (via Accounts)
    [Documentation]    Verify filtering by Send Money shows only Send Money transactions.
    ...                If data exists, verifies the detail modal contains all required fields.
    ...                If no data, verifies the "No Data" message.
    [Tags]             accounts    transactions    smoke    mvp    type1
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_TYPE_SEND_MONEY}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    Filter Acct Txn Results Should Contain Only Type    Send Money

t3.2.7 Filter Transactions by Type: Receive Money (via Accounts)
    [Documentation]    Verify filtering by Receive Money shows only Receive Money transactions.
    ...                If data exists, verifies the detail modal contains all required fields.
    ...                If no data, verifies the "No Data" message.
    [Tags]             accounts    transactions    smoke    mvp    type1
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_TYPE_RECEIVE_MONEY}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    Filter Acct Txn Results Should Contain Only Type    Receive Money

t3.2.8 Filter Transactions by Type: Fund Transfer (via Accounts)
    [Documentation]    Verify filtering by Fund Transfer shows only Fund Transfer transactions.
    ...                If data exists, verifies the detail modal contains all required fields.
    ...                If no data, verifies the "No Data" message.
    [Tags]             accounts    transactions    smoke    mvp    type1
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_TYPE_FUND_TRANSFER}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    Filter Acct Txn Results Should Contain Only Type    Fund Transfer

t3.2.9 Filter Transactions by Type: Cash Withdrawal (via Accounts)
    [Documentation]    Verify filtering by Cash Withdrawal shows only Cash Withdrawal transactions.
    ...                If no data, verifies the "No Data" message.
    [Tags]             accounts    transactions    smoke    mvp    type2
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_TYPE_CASH_WITHDRAWAL}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    Filter Acct Txn Results Should Contain Only Type    Cash Withdrawal

t3.2.10 Filter Transactions by Type: Cash Deposit (via Accounts)
    [Documentation]    Verify filtering by Cash Deposit shows only Cash Deposit transactions.
    ...                If no data, verifies the "No Data" message.
    [Tags]             accounts    transactions    smoke    mvp    type2
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_TYPE_CASH_DEPOSIT}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    Filter Acct Txn Results Should Contain Only Type    Cash Deposit

t3.2.11 Filter Transactions by Type: Savings Interest (via Accounts)
    [Documentation]    Verify filtering by Savings Interest shows only Savings Interest transactions.
    ...                If no data, verifies the "No Data" message.
    [Tags]             accounts    transactions    smoke    mvp    type2
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_TYPE_SAVINGS_INTEREST}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    Filter Acct Txn Results Should Contain Only Type    Savings Interest

t3.2.12 Filter Transactions by Type: Loan Disbursement (via Accounts)
    [Documentation]    Verify filtering by Loan Disbursement shows only Loan Disbursement transactions.
    ...                If no data, verifies the "No Data" message.
    [Tags]             accounts    transactions    smoke    mvp    type2
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_TYPE_LOAN_DISBURSEMENT}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    Filter Acct Txn Results Should Contain Only Type    Loan Disbursement

t3.2.13 Filter Transactions by Type: Loan Payment (via Accounts)
    [Documentation]    Verify filtering by Loan Payment shows only Loan Payment transactions.
    ...                If no data, verifies the "No Data" message.
    [Tags]             accounts    transactions    smoke    mvp    type2
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_TYPE_LOAN_PAYMENT}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    Filter Acct Txn Results Should Contain Only Type    Loan Payment

t3.2.14 Filter Transactions by Status: Pending (via Accounts)
    [Documentation]    Verify filtering by Pending status shows only Pending transactions.
    ...                If data exists, verifies the detail modal contains all required fields.
    ...                If no data, verifies the "No Data" message.
    [Tags]             accounts    transactions    smoke    mvp    type1
    Click                      ${TXN_STATUS_FILTER}
    Click                      ${TXN_STATUS_PENDING}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    Filter Acct Txn Results Should Contain Only Status    Pending

t3.2.15 Filter Transactions by Status: Success (via Accounts)
    [Documentation]    Verify filtering by Success status shows only Success transactions.
    ...                If data exists, verifies the detail modal contains all required fields.
    ...                If no data, verifies the "No Data" message.
    [Tags]             accounts    transactions    smoke    mvp    type1
    Click                      ${TXN_STATUS_FILTER}
    Click                      ${TXN_STATUS_SUCCESS}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    Filter Acct Txn Results Should Contain Only Status    Success

t3.2.16 Filter Transactions by Status: Failed (via Accounts)
    [Documentation]    Verify filtering by Failed status shows only Failed transactions.
    ...                If data exists, verifies the detail modal contains all required fields.
    ...                If no data, verifies the "No Data" message.
    [Tags]             accounts    transactions    smoke    mvp    type1
    Click                      ${TXN_STATUS_FILTER}
    Click                      ${TXN_STATUS_FAILED}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCT_TXN_TABLE}    visible
    Filter Acct Txn Results Should Contain Only Status    Failed

t3.2.17 Navigate Back to Accounts List (from View Transactions)
    [Documentation]    Verify that clicking the Accounts breadcrumb link returns the user
    ...                to the main Accounts List View.
    [Tags]             accounts    transactions    smoke    mvp    type1
    Wait For Elements State    ${ACCOUNTS_BREADCRUMB_LINK}    visible
    Click                      ${ACCOUNTS_BREADCRUMB_LINK}
    Wait For Elements State    ${ACCOUNTS_SEARCH_FIELD}       visible
    Get Url                    contains    /accounts
