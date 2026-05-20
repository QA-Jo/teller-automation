*** Settings ***
Documentation       t4.1 View all list of Transactions
...                 Covers entry point via Transactions sidebar, pagination, transaction detail view,
...                 search by ID, date range filtering, type filtering, status filtering,
...                 and total balance verification.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/transactions.resource

Suite Setup         Login To Teller App
Suite Teardown      Close Browser
Test Setup          Setup Transactions Page
Test Teardown       Close Modal If Open


*** Variables ***
${TXN_ROW}                  css=.ant-table-body table tbody tr:has-text("${T4_VALID_TXN_ID}")
${NON_EXISTING_TXN_ID}      NONEXISTENT99999

# Date range for t4.1.6 — negative test (future date with no expected data)
${DATE_EMPTY_FROM}          2027-01-01
${DATE_EMPTY_TO}            2027-01-31


*** Test Cases ***
t4.1.1 View Transaction History (Entry Point)
    [Documentation]    Verify that navigating to the Transactions module displays the Transactions page
    ...                with all required table columns and action buttons visible.
    [Tags]             transactions    smoke    mvp    type1
    Get Url                    contains    /transactions
    # Verify all fields — continue on failure so ALL mismatches are reported
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction ID            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction Type          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Date & Time               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Credit Account Number     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Debit Account Number      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Total Amount              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Status                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text="Action"    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_VIEW_BTN} >> nth=0      visible
# Hidden for now since download functionality is not yet implemented — will cause test failure until implemented
    # Run Keyword And Continue On Failure
    # ...    Wait For Elements State    ${TXN_DOWNLOAD_BTN} >> nth=0  visible

t4.1.2 Pagination in Viewing Transaction History
    [Documentation]    Verify pagination controls work correctly:
    ...                Next loads page 2, clicking page 3 loads page 3,
    ...                and Back returns to page 2.
    [Tags]             transactions     smoke    mvp    type1    pagination
    # Click Next arrow to go to page 2
    Click                      ${PAGINATION_NEXT}
    Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
    # Click page number 3
    Click                      css=li.ant-pagination-item[title="3"]
    Wait For Elements State    css=li.ant-pagination-item-active[title="3"]    visible
    # Click Back arrow to return to page 2
    Click                      ${PAGINATION_PREV}
    Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible

t4.1.4 View Specific Transaction Details
    [Documentation]    Verify that clicking the Eye icon opens the transaction detail modal
    ...                with all required field labels and the modal closes cleanly.
    [Tags]             transactions    smoke    mvp    type1
    Click                      ${TXN_VIEW_BTN} >> nth=0
    Wait For Elements State    ${TXN_DETAIL_MODAL}                                       visible
    # Verify all fields — continue on failure so ALL mismatches are reported
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction ID                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Type              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Amount            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Service Fee                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Remarks                      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Status            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Account Name           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Account Name          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Account Number         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Account Number        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Created on                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Updated on                   visible
    # Close modal and verify return to the transaction list
    Click                      ${TXN_DETAIL_BACK_BTN}
    Wait For Elements State    ${TXN_DETAIL_MODAL}    hidden
    Wait For Elements State    ${TXN_TABLE}           visible

t4.1.5 Search Transaction by ID and View Details
    [Documentation]    Verify that searching by a known valid Transaction ID returns exactly one record,
    ...                the detail modal displays all expected field values accurately including
    ...                Instapay Reference Number and Bank Code/Name for External transactions,
    ...                and the modal closes cleanly returning to the filtered list.
    [Tags]             transactions    smoke    mvp    type1    external
    Fill Text                  ${TXN_SEARCH_FIELD}    ${T4_VALID_TXN_ID}
    Click                      ${TXN_SEARCH_BUTTON}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${TXN_ROW}    visible
    Get Element Count          css=.ant-table-body table tbody tr:not([aria-hidden="true"])    ==    1
    # Open transaction detail modal
    Click                      ${TXN_ROW} >> ${TXN_VIEW_BTN}
    Wait For Elements State    ${TXN_DETAIL_MODAL}                                           visible
    # Verify all field values using exact text matching (:text-is)
    ${_txn_id}=             Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_VALID_TXN_ID}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_txn_id}    ${T4_VALID_TXN_ID}
    ...    msg=Transaction ID mismatch: expected '${T4_VALID_TXN_ID}' but got '${_txn_id}'
    ${_txn_type}=           Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_TYPE}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_txn_type}    ${T4_TXN_TYPE}
    ...    msg=Transaction Type mismatch: expected '${T4_TXN_TYPE}' but got '${_txn_type}'
    ${_txn_amount}=         Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_AMOUNT}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_txn_amount}    ${T4_TXN_AMOUNT}
    ...    msg=Transaction Amount mismatch: expected '${T4_TXN_AMOUNT}' but got '${_txn_amount}'
    ${_svc_fee}=            Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_SERVICE_FEE}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_svc_fee}    ${T4_TXN_SERVICE_FEE}
    ...    msg=Service Fee mismatch: expected '${T4_TXN_SERVICE_FEE}' but got '${_svc_fee}'
    ${_remarks}=            Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_REMARKS}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_remarks}    ${T4_TXN_REMARKS}
    ...    msg=Remarks mismatch: expected '${T4_TXN_REMARKS}' but got '${_remarks}'
    ${_status}=             Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_STATUS}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_status}    ${T4_TXN_STATUS}
    ...    msg=Transaction Status mismatch: expected '${T4_TXN_STATUS}' but got '${_status}'
    ${_instapay}=           Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_INSTAPAY_REF}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_instapay}    ${T4_TXN_INSTAPAY_REF}
    ...    msg=Instapay Reference mismatch: expected '${T4_TXN_INSTAPAY_REF}' but got '${_instapay}'
    ${_debit_name}=         Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_DEBIT_ACCT_NAME}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_debit_name}    ${T4_TXN_DEBIT_ACCT_NAME}
    ...    msg=Debit Account Name mismatch: expected '${T4_TXN_DEBIT_ACCT_NAME}' but got '${_debit_name}'
    ${_credit_name}=        Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_CREDIT_ACCT_NAME}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_credit_name}    ${T4_TXN_CREDIT_ACCT_NAME}
    ...    msg=Credit Account Name mismatch: expected '${T4_TXN_CREDIT_ACCT_NAME}' but got '${_credit_name}'
    ${_debit_no}=           Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_DEBIT_ACCT_NO}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_debit_no}    ${T4_TXN_DEBIT_ACCT_NO}
    ...    msg=Debit Account Number mismatch: expected '${T4_TXN_DEBIT_ACCT_NO}' but got '${_debit_no}'
    ${_credit_no}=          Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_CREDIT_ACCT_NO}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_credit_no}    ${T4_TXN_CREDIT_ACCT_NO}
    ...    msg=Credit Account Number mismatch: expected '${T4_TXN_CREDIT_ACCT_NO}' but got '${_credit_no}'
    ${_debit_bank_code}=    Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_CREDIT_BANK_CODE}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_debit_bank_code}    ${T4_TXN_CREDIT_BANK_CODE}
    ...    msg=Debit Bank Code mismatch: expected '${T4_TXN_CREDIT_BANK_CODE}' but got '${_debit_bank_code}'
    ${_debit_bank_name}=    Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_CREDIT_BANK_NAME}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_debit_bank_name}    ${T4_TXN_CREDIT_BANK_NAME}
    ...    msg=Debit Bank Name mismatch: expected '${T4_TXN_CREDIT_BANK_NAME}' but got '${_debit_bank_name}'
    ${_created_on}=         Get Text    ${TXN_DETAIL_MODAL} >> :text-is("${T4_TXN_CREATED_ON}")
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_created_on}    ${T4_TXN_CREATED_ON}
    ...    msg=Created On mismatch: expected '${T4_TXN_CREATED_ON}' but got '${_created_on}'
    # Close modal and verify return to the filtered list (always runs even if assertions above failed)
    Click                      ${TXN_DETAIL_BACK_BTN}
    Wait For Elements State    ${TXN_DETAIL_MODAL}    hidden
    Wait For Elements State    ${TXN_ROW}             visible

t4.1.6 Search Transactions Using Date Range
    [Documentation]    Verify the date range filter shows only transactions within the selected range.
    [Tags]             transactions    regression    mvp    type1
    skip
    Click                      ${TXN_DATE_TIME_FILTER}
    Wait For Elements State    ${TXN_DATE_START_INPUT}    visible
    Select Txn Date Range From AntD Picker    ${T4_DATE_FROM}    ${T4_DATE_TO}
    Click                      ${TXN_DATE_FILTER_SEARCH_BTN}
    Wait For Elements State    ${TXN_TABLE}    visible
    Wait For Elements State    css=.ant-table-body table tbody tr:not([aria-hidden="true"]) >> nth=0    visible
    Verify Txn Dates Within Range    ${T4_DATE_FROM}    ${T4_DATE_TO}
    # Verify all required columns are still present after filtering
    # Verify all fields — continue on failure so ALL mismatches are reported
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction ID           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction Type         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Date & Time              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Credit Account Number    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Debit Account Number     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Total Amount             visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Status                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text="Action"    visible

t4.1.7 Filter Transactions by Type: External Transfer
    [Documentation]    Verify filtering by External Transfer type shows only External Transfer transactions.
    ...                The detail view includes Instapay Reference Number for External Transfer transactions.
    ...                If no External Transfer transactions exist, the system displays "No Data".
    [Tags]             transactions    smoke    mvp    type1
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_FILTER_EXTERNAL}
    Click                      ${TXN_FILTER_APPLY_BTN}
    Wait For Elements State    ${TXN_TABLE}    visible
    Filter Txn Results Should Contain Only Type    External Transfer

t4.1.8 Filter Transactions by Type: Internal Transfer
    [Documentation]    Verify filtering by Internal Transfer type shows only Internal Transfer transactions.
    ...                If no Internal Transfer transactions exist, the system displays "No Data".
    [Tags]             transactions    smoke    mvp    type1
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_FILTER_INTERNAL}
    Click                      ${TXN_FILTER_APPLY_BTN}
    Wait For Elements State    ${TXN_TABLE}    visible
    Filter Txn Results Should Contain Only Type    Internal Transfer

t4.1.9 Filter Transactions by Type: Cash Withdrawal
    [Documentation]    Verify filtering by Cash Withdrawal type shows only Cash Withdrawal transactions.
    ...                If no Cash Withdrawal transactions exist, the system displays "No Data".
    [Tags]             transactions    smoke    mvp    type2
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_FILTER_WITHDRAWAL}
    Click                      ${TXN_FILTER_APPLY_BTN}
    Wait For Elements State    ${TXN_TABLE}    visible
    Filter Txn Results Should Contain Only Type    Cash Withdrawal

t4.1.10 Filter Transactions by Type: Cash Deposit
    [Documentation]    Verify filtering by Cash Deposit type shows only Cash Deposit transactions.
    ...                If no Cash Deposit transactions exist, the system displays "No Data".
    [Tags]             transactions    smoke    mvp    type2
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_FILTER_DEPOSIT}
    Click                      ${TXN_FILTER_APPLY_BTN}
    Wait For Elements State    ${TXN_TABLE}    visible
    Filter Txn Results Should Contain Only Type    Cash Deposit

t4.1.11 Filter Transactions by Type: Interest Crediting
    [Documentation]    Verify filtering by Interest Crediting type shows only Interest Crediting transactions.
    ...                If no Interest Crediting transactions exist, the system displays "No Data".
    [Tags]             transactions    smoke    mvp    type2
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_FILTER_INTEREST_CREDITING}
    Click                      ${TXN_FILTER_APPLY_BTN}
    Wait For Elements State    ${TXN_TABLE}    visible
    Filter Txn Results Should Contain Only Type    Interest Crediting

t4.1.12 Filter Transactions by Type: Loan Disbursement
    [Documentation]    Verify filtering by Loan Disbursement type shows only Loan Disbursement transactions.
    ...                If no Loan Disbursement transactions exist, the system displays "No Data".
    [Tags]             transactions    smoke    mvp    type2
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_FILTER_LOAN_DISBURSEMENT}
    Click                      ${TXN_FILTER_APPLY_BTN}
    Wait For Elements State    ${TXN_TABLE}    visible
    Filter Txn Results Should Contain Only Type    Loan Disbursement

t4.1.13 Filter Transactions by Type: Loan Payment
    [Documentation]    Verify filtering by Loan Payment type shows only Loan Payment transactions.
    ...                If no Loan Payment transactions exist, the system displays "No Data".
    [Tags]             transactions    smoke    mvp    type2
    Click                      ${TXN_TYPE_FILTER}
    Click                      ${TXN_FILTER_LOAN_PAYMENT}
    Click                      ${TXN_FILTER_APPLY_BTN}
    Wait For Elements State    ${TXN_TABLE}    visible
    Filter Txn Results Should Contain Only Type    Loan Payment

t4.1.14 Filter Transactions by Status: Pending
    [Documentation]    Verify filtering by Pending status shows only Pending transactions.
    ...                If no Pending transactions exist, the system displays "No Data".
    [Tags]             transactions    smoke    mvp    type1
    Click                      ${TXN_STATUS_FILTER}
    Click                      ${TXN_STATUS_PENDING}
    Click                      ${TXN_FILTER_APPLY_BTN}
    Wait For Elements State    ${TXN_TABLE}    visible
    Filter Txn Results Should Contain Only Status    Pending

t4.1.15 Filter Transactions by Status: Success
    [Documentation]    Verify filtering by Success status shows only Success transactions.
    ...                If no Success transactions exist, the system displays "No Data".
    [Tags]             transactions    smoke    mvp    type1
    Click                      ${TXN_STATUS_FILTER}
    Click                      ${TXN_STATUS_SUCCESS}
    Click                      ${TXN_FILTER_APPLY_BTN}
    Wait For Elements State    ${TXN_TABLE}    visible
    Filter Txn Results Should Contain Only Status    Success

t4.1.16 Filter Transactions by Status: Failed
    [Documentation]    Verify filtering by Failed status shows only Failed transactions.
    ...                If no Failed transactions exist, the system displays "No Data".
    [Tags]             transactions    smoke    mvp    type1
    Click                      ${TXN_STATUS_FILTER}
    Click                      ${TXN_STATUS_FAILED}
    Click                      ${TXN_FILTER_APPLY_BTN}
    Wait For Elements State    ${TXN_TABLE}    visible
    Filter Txn Results Should Contain Only Status    Failed

t4.1.17 Verify Total Balance Calculation
    [Documentation]    Verify the Total Balance displayed on the Transactions page equals
    ...                the sum of all account balances from the Accounts module.
    [Tags]             transactions    smoke    mvp    skip    type1
    # Step 1: Get Total Balance value from Transactions page
    Wait For Elements State    ${TOTAL_BALANCE_CARD}    visible
    ${balance_text}=           Get Text    ${TOTAL_BALANCE_CARD}
    Should Contain             ${balance_text}    Total Balance
    Should Match Regexp        ${balance_text}    PHP\\s+[0-9,]+\\.[0-9]{2}
    ${total_str}=              Evaluate
    ...    '''${balance_text}'''.replace('Total Balance', '').replace(':', '').replace('PHP', '').replace(',', '').replace('\\n', ' ').strip()
    ${transactions_total}=     Convert To Number    ${total_str}
    # Step 2: Navigate to Accounts and sum all account balances across all pages
    Click                      ${SIDEBAR_ACCOUNTS}
    Wait For Load Spinner To Disappear
    Wait For Elements State    css=.ant-table-body table    visible
    ${accounts_sum}=           Sum All Account Balances
    # Step 3: Navigate back to Transactions and compare
    Navigate To Transactions
    ${txn_rounded}=            Evaluate    round(${transactions_total}, 2)
    ${acc_rounded}=            Evaluate    round(${accounts_sum}, 2)
    Should Be Equal As Numbers    ${txn_rounded}    ${acc_rounded}
    ...    msg=Total Balance on Transactions page (${txn_rounded}) does not match sum of account balances (${acc_rounded})
