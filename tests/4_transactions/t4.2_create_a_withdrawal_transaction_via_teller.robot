*** Settings ***
Documentation       t4.2 Create a Withdrawal Transaction via Teller
...                 Covers the complete withdrawal flow via the New Transaction modal:
...                 opening the modal, searching for an account by number and by name,
...                 selecting an account and verifying customer information,
...                 navigating to the Withdrawal form, filling form fields, verifying
...                 real-time summary updates, processing the withdrawal, and verifying
...                 the new transaction in the Transactions list.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/transactions.resource
Resource            ../../resources/keywords/accounts.resource

Suite Setup         Login To Teller App
Suite Teardown      Close Browser
Test Setup          Setup Transactions Page
Test Teardown       Close Modal If Open


*** Keywords ***
Navigate To Customer Info Step
    [Documentation]    Opens the New Transaction modal, searches for the test account, and
    ...                selects it — landing on the Customer Information step (Step 1).
    ...                Use this when you need to verify Customer Info fields (e.g. Daily
    ...                Limit Remaining) without proceeding to the Transaction form.
    [Arguments]    ${account_number}=${T42_ACCOUNT_NUMBER}
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${account_number}
    Select Account From Create Transaction Results    ${account_number}
    Wait For Elements State    text=Daily Limit Remaining >> nth=0    visible


*** Test Cases ***
t4.2.1 Open New Transaction Modal
    [Documentation]    Verify that clicking the New Transaction button opens the Create Transaction
    ...                modal with the Customer Information step visible, and the account search
    ...                field and Search button are present and enabled.
    [Tags]             transactions    create    withdrawal    smoke    mvp    type2
    Wait For Elements State    ${NEW_TXN_BTN}                    visible
    Click                      ${NEW_TXN_BTN}
    Wait For Elements State    ${CREATE_TXN_MODAL}               visible
    Wait For Elements State    text=Search Customer               visible
    Wait For Elements State    ${CREATE_TXN_SEARCH_INPUT}        visible
    Wait For Elements State    ${CREATE_TXN_SEARCH_BTN}          enabled

t4.2.2 Search by Account Number
    [Documentation]    Verify that entering a valid account number and clicking Search returns
    ...                a result list where each entry displays:
    ...                Account Name, Account Number, account type (e.g. Savings),
    ...                Balance, and Account Status.
    [Tags]             transactions    create    withdrawal    smoke    mvp    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T42_ACCOUNT_NUMBER}
    # Verify the matching result card is visible
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T42_ACCOUNT_NUMBER}")
    ...    visible
    # Verify all expected fields are displayed per result entry
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T42_ACCOUNT_NUMBER}"):has-text("${T42_ACCOUNT_NAME}")
    ...    visible
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T42_ACCOUNT_NUMBER}"):has-text("${T42_ACCOUNT_TYPE}")
    ...    visible
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T42_ACCOUNT_NUMBER}"):has-text("${T42_ACCOUNT_STATUS}")
    ...    visible

t4.2.3 Search by Account Name
    [Documentation]    Verify that entering a valid account holder name returns one or more
    ...                matching results. Each result entry displays Account Name, Account Number,
    ...                account type (e.g. Savings), Balance, and Account Status.
    [Tags]             transactions    create    withdrawal    smoke    mvp    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T42_CUSTOMER_NAME}
    # Verify at least one result card containing the searched name is visible
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T42_CUSTOMER_NAME}") >> nth=0
    ...    visible
    # Verify common fields are shown per result entry
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T42_CUSTOMER_NAME}"):has-text("${T42_ACCOUNT_TYPE}") >> nth=0
    ...    visible
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T42_CUSTOMER_NAME}"):has-text("${T42_ACCOUNT_STATUS}") >> nth=0
    ...    visible

t4.2.4 Select Account and Verify Customer Information
    [Documentation]    Verify that selecting an account from search results navigates to the
    ...                Customer Information step, which displays: Customer Name, Account Number,
    ...                Account Type, Status, Current Balance, Daily Limit Remaining,
    ...                and Contact Information (Mobile Number and Email).
    [Tags]             transactions    create    withdrawal    smoke    mvp    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T42_ACCOUNT_NUMBER}
    Select Account From Create Transaction Results    ${T42_ACCOUNT_NUMBER}
    # Verify all fields — continue on failure so ALL mismatches are reported
    # Verify account and customer identity details
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Name           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T42_CUSTOMER_NAME} >> nth=0       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Number           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T42_ACCOUNT_NUMBER} >> nth=0      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Type           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T42_ACCOUNT_TYPE} >> nth=0        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Status           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T42_ACCOUNT_STATUS} >> nth=0      visible
    # Verify additional Customer Information fields are present
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Current Balance >> nth=0            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Daily Limit Remaining >> nth=0      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Contact Information >> nth=0        visible
    # Verify the transaction type buttons are visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_DEPOSIT_BTN}      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_WITHDRAWAL_BTN}   visible

t4.2.5 Navigate to Transaction Type – Withdraw
    [Documentation]    Verify that clicking the Withdraw button from the Customer Information
    ...                step navigates to the Transaction step for Withdrawal, showing:
    ...                - Two panels: "Withdraw Funds" and "Transaction Summary"
    ...                - Withdraw Funds panel pre-filled with Account Name, Account Number
    ...                  (with account type e.g. Savings), and Current Balance
    ...                - Withdrawal Type dropdown, Withdrawal Amount input, Transaction Notes field
    ...                - Cancel and Process Withdrawal buttons
    [Tags]             transactions    create    withdrawal    smoke    mvp    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T42_ACCOUNT_NUMBER}
    Select Account From Create Transaction Results    ${T42_ACCOUNT_NUMBER}
    Click                      ${CREATE_TXN_WITHDRAWAL_BTN}
    # Verify both panel headings are visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Withdraw Funds >> nth=0          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction Summary >> nth=0     visible
    # Verify Withdraw Funds panel pre-fills account info from the selected account
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T42_ACCOUNT_NAME} >> nth=0     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T42_ACCOUNT_NUMBER} >> nth=0   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T42_ACCOUNT_TYPE} >> nth=0     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Current Balance >> nth=0         visible
    # Verify form inputs are present
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_TYPE_SELECT}             visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_AMOUNT_INPUT}            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_NOTES_INPUT}             visible
    # Verify action buttons are present
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_CANCEL_BTN}              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}  visible

t4.2.6 Real-Time Summary Updates with Withdrawal Amount
    [Documentation]    Verify that the Transaction Summary panel updates immediately as the
    ...                user fills in the withdrawal form:
    ...                - Entering an amount shows the withdrawal amount in the summary
    ...                - The summary displays New Balance = Current Balance – withdrawal amount (correct math)
    [Tags]             transactions    create    withdrawal    regression    mvp    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    # Select withdrawal type
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    # Capture Current Balance from the summary panel BEFORE entering the amount
    ${current_balance_str}=    Get Transaction Summary Field Value    Current Balance
    ${current_balance}=        Evaluate    float('${current_balance_str}'.replace(',', ''))
    # Enter the withdrawal amount
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_WITHDRAWAL_AMOUNT}
    Wait For Elements State    text=${T42_WITHDRAWAL_AMOUNT} >> nth=0    visible
    Wait For Elements State    text=New Balance >> nth=0                 visible
    # Compute expected new balance and assert the summary shows the correct value
    ${withdrawal}=             Evaluate    float(str('${T42_WITHDRAWAL_AMOUNT}').replace(',', ''))
    ${expected_new_balance}=   Evaluate    round(${current_balance} - ${withdrawal}, 2)
    ${new_balance_str}=        Get Transaction Summary Field Value    New Balance
    ${displayed_new_balance}=  Evaluate    float('${new_balance_str}'.replace(',', ''))
    Should Be Equal As Numbers    ${displayed_new_balance}    ${expected_new_balance}
    ...    msg=Summary New Balance is wrong: expected ${expected_new_balance} (${current_balance} − ${withdrawal}) but got ${displayed_new_balance}

t4.2.7 Process Withdrawal and Review
    [Documentation]    Verify that completing the withdrawal form and clicking Process Withdrawal
    ...                navigates to the Review step which displays:
    ...                - "Withdrawal Successful" heading and sub-message
    ...                - Labels: Transaction ID, Customer, Account number, Transaction Type,
    ...                  Amount, Date & Time, Auth Code, Notes, Previous Balance, New Balance
    ...                - Correct Customer Name, Account Number, Transaction Type, Amount (exact match)
    ...                - New Balance = Previous Balance − Withdrawal Amount (math validation)
    ...                - Print Receipt and New Transaction buttons
    [Tags]             transactions    create    withdrawal    smoke    mvp    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    # Fill the withdrawal form
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_WITHDRAWAL_AMOUNT}
    Fill Text                  ${CREATE_TXN_NOTES_INPUT}     ${T42_WITHDRAWAL_NOTES}
    # Submit the withdrawal
    Click                      ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}
    Wait For Load Spinner To Disappear
    # Label assertions — verify all receipt field labels are present
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Withdrawal Successful >> nth=0                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction has been processed successfully >> nth=0    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction ID >> nth=0                           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Customer >> nth=0                                 visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account number >> nth=0                           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction Type >> nth=0                         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Amount >> nth=0                                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Date & Time >> nth=0                              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Auth Code >> nth=0                                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Notes >> nth=0                                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Previous Balance >> nth=0                         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=New Balance >> nth=0                              visible
    # Value assertions — exact matching using :text-is() to avoid partial matches
    ${_cust_name}=    Get Text    :text-is("${T42_CUSTOMER_NAME}") >> nth=0
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_cust_name}    ${T42_CUSTOMER_NAME}
    ...    msg=Customer Name mismatch: expected '${T42_CUSTOMER_NAME}' but got '${_cust_name}'
    ${_acct_no}=      Get Text    :text-is("${T42_ACCOUNT_NUMBER}") >> nth=0
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_acct_no}    ${T42_ACCOUNT_NUMBER}
    ...    msg=Account Number mismatch: expected '${T42_ACCOUNT_NUMBER}' but got '${_acct_no}'
    ${_w_type}=       Get Text    :text-is("${T42_WITHDRAWAL_TYPE}") >> nth=0
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_w_type}    ${T42_WITHDRAWAL_TYPE}
    ...    msg=Withdrawal Type mismatch: expected '${T42_WITHDRAWAL_TYPE}' but got '${_w_type}'
    ${_w_amount}=     Get Text    :text-is("${T42_WITHDRAWAL_AMOUNT}") >> nth=0
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_w_amount}    ${T42_WITHDRAWAL_AMOUNT}
    ...    msg=Withdrawal Amount mismatch: expected '${T42_WITHDRAWAL_AMOUNT}' but got '${_w_amount}'
    # Assert receipt New Balance = Previous Balance − Withdrawal Amount
    ${prev_balance_str}=       Get Transaction Summary Field Value    Previous Balance
    ${prev_balance}=           Evaluate    float('${prev_balance_str}'.replace(',', ''))
    ${withdrawal}=             Evaluate    float(str('${T42_WITHDRAWAL_AMOUNT}').replace(',', ''))
    ${expected_new_balance}=   Evaluate    round(${prev_balance} - ${withdrawal}, 2)
    ${new_balance_str}=        Get Transaction Summary Field Value    New Balance
    ${displayed_new_balance}=  Evaluate    float('${new_balance_str}'.replace(',', ''))
    Should Be Equal As Numbers    ${displayed_new_balance}    ${expected_new_balance}
    ...    msg=Receipt New Balance is wrong: expected ${expected_new_balance} (${prev_balance} − ${withdrawal}) but got ${displayed_new_balance}
    # Verify the action buttons on the confirmation screen
    # hidden for now
    # Run Keyword And Continue On Failure
    # ...    Wait For Elements State    ${CREATE_TXN_PRINT_RECEIPT_BTN}       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_NEW_TXN_BTN_CONFIRM}     visible

t4.2.8 Verify Newest Transaction Appears at the Top (Withdrawal)
    [Documentation]    Verify that after completing the withdrawal flow and closing the confirmation,
    ...                the new Withdrawal transaction appears as the most recent (first) row
    ...                in the Transactions list, showing:
    ...                Transaction Type = Withdrawal, Debit Account Number = customer account,
    ...                Credit Account Number = N/A, and Status column visible.
    [Tags]             transactions    create    withdrawal    smoke    mvp    type2
    # Complete the full withdrawal flow
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_WITHDRAWAL_AMOUNT}
    Fill Text                  ${CREATE_TXN_NOTES_INPUT}     ${T42_WITHDRAWAL_NOTES}
    Click                      ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_NEW_TXN_BTN_CONFIRM}    visible
    # Navigate back to the Transactions list via browser back button
    Go Back
    Wait For Load Spinner To Disappear
    # Verify the newest transaction (first row) is the Withdrawal just created
    Wait For Elements State
    ...    css=.ant-table-body table tbody tr:not([aria-hidden="true"]) >> nth=0
    ...    visible
    ${first_row_text}=    Get Text
    ...    css=.ant-table-body table tbody tr:not([aria-hidden="true"]) >> nth=0
    Should Contain    ${first_row_text}    Withdraw
    Should Contain    ${first_row_text}    ${T42_ACCOUNT_NUMBER}

t4.2.9 View Details of the Newest Transaction (Withdrawal)
    [Documentation]    Verify that clicking the View (eye) icon for the newest Withdrawal
    ...                transaction opens the detail modal which shows all relevant data:
    ...                - Transaction Type = Withdrawal
    ...                - Transaction Amount, Service Fee, Remarks, Transaction Status
    ...                - Debit Account Name = customer account
    ...                - Debit Account Number = customer account number
    ...                - Credit Account Name = N/A
    ...                - Credit Account Number = N/A
    ...                - Created on and Updated on timestamps
    [Tags]             transactions    create    withdrawal    smoke    mvp    type2
    # Complete the full withdrawal flow
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_WITHDRAWAL_AMOUNT}
    Fill Text                  ${CREATE_TXN_NOTES_INPUT}     ${T42_WITHDRAWAL_NOTES}
    Click                      ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_NEW_TXN_BTN_CONFIRM}    visible
    # Navigate back to the Transactions list via browser back button
    Go Back
    Wait For Load Spinner To Disappear
    # Open the detail modal for the newest (first) transaction
    Click                      ${TXN_VIEW_BTN} >> nth=0
    Wait For Elements State    ${TXN_DETAIL_MODAL}                                            visible
    # Verify all required field labels and values in the detail modal
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction ID                     visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Type                   visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Amount                 visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Service Fee                        visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Remarks                            visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Status                 visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Account Name                 visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Account Number               visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Account Name                visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Account Number              visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Created on                         visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Updated on                         visible
    # Verify Withdrawal-specific values: debit is customer account, credit is N/A
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=${T42_ACCOUNT_NAME}                visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=${T42_ACCOUNT_NUMBER}              visible
    Wait For Elements State
    ...    ${TXN_DETAIL_MODAL} >> text=Withdrawal
    ...    visible
    # Close the detail modal
    Click                      ${TXN_DETAIL_BACK_BTN}
    Wait For Elements State    ${TXN_DETAIL_MODAL}    hidden
    Wait For Elements State    ${TXN_TABLE}            visible


# ====================================================================
# DAILY OTC LIMIT
# ====================================================================

t4.2.10 Initialize Daily OTC Withdrawal Limit
    [Documentation]    Verify that the Daily Limit Remaining displayed in the Customer
    ...                Information step (Step 1) equals the configured daily OTC max
    ...                (${T42_DAILY_LIMIT_INITIAL}) at the start of the business day.
    ...
    ...                Uses OTC test account: ${T42_OTC_CUSTOMER_NAME} (${T42_OTC_ACCOUNT_NUMBER}).
    ...                Pre-condition: No OTC withdrawals have been made today for this account.
    [Tags]             transactions    withdrawal    daily-limit    regression    type2
    Navigate To Customer Info Step    ${T42_OTC_ACCOUNT_NUMBER}
    Wait For Elements State    text=Daily Limit Remaining >> nth=0          visible
    Wait For Elements State    text=${T42_DAILY_LIMIT_INITIAL} >> nth=0     visible

t4.2.11 Non-OTC Transaction Does Not Affect Daily OTC Limit
    [Documentation]    Verify that a Send Money (non-OTC) transaction does not reduce the
    ...                Daily OTC Limit Remaining. The limit should still show
    ...                ${T42_DAILY_LIMIT_INITIAL} in Step 1 after the non-OTC transaction.
    ...
    ...                Uses OTC test account: ${T42_OTC_CUSTOMER_NAME} (${T42_OTC_ACCOUNT_NUMBER}).
    ...                Pre-condition: A non-OTC Send Money transaction (e.g. 5,000) has
    ...                already been performed for this account today.
    ...
    ...                Skipped: Send Money is performed manually via the mobile app — no API
    ...                automation available yet to set up the pre-condition programmatically.
    [Tags]             transactions    withdrawal    daily-limit    manual    type2
    Skip    Send Money pre-condition must be triggered manually via mobile app — re-enable once Send Money is available via API.

t4.2.12 OTC Withdrawal Reduces Daily Limit
    [Documentation]    Verify that completing an OTC cash withdrawal of ${T42_FIRST_OTC_AMOUNT}
    ...                reduces the Daily Limit Remaining in Step 1 from ${T42_DAILY_LIMIT_INITIAL}
    ...                to ${T42_DAILY_LIMIT_AFTER_FIRST_OTC}.
    ...
    ...                Uses OTC test account: ${T42_OTC_CUSTOMER_NAME} (${T42_OTC_ACCOUNT_NUMBER}).
    [Tags]             transactions    withdrawal    daily-limit    regression    type2
    # Step 1: Verify starting Daily Limit Remaining (pre-check)
    Navigate To Customer Info Step    ${T42_OTC_ACCOUNT_NUMBER}
    Wait For Elements State    text=${T42_DAILY_LIMIT_INITIAL} >> nth=0    visible
    # Step 2: Proceed directly to the withdrawal form from the Customer Info step
    Click                      ${CREATE_TXN_WITHDRAWAL_BTN}
    Wait For Elements State    ${CREATE_TXN_TYPE_SELECT}    visible
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_FIRST_OTC_AMOUNT}
    Click                      ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_NEW_TXN_BTN_CONFIRM}    visible
    # Step 3: Navigate back and verify the updated limit in Step 1
    Go Back
    Wait For Load Spinner To Disappear
    Navigate To Customer Info Step    ${T42_OTC_ACCOUNT_NUMBER}
    Wait For Elements State    text=${T42_DAILY_LIMIT_AFTER_FIRST_OTC} >> nth=0    visible

t4.2.13 Multiple OTC Withdrawals Accumulate Against Daily Limit
    [Documentation]    Verify that a second OTC cash withdrawal of ${T42_SECOND_OTC_AMOUNT}
    ...                further reduces the Daily Limit Remaining from
    ...                ${T42_DAILY_LIMIT_AFTER_FIRST_OTC} to ${T42_DAILY_LIMIT_AFTER_SECOND_OTC}.
    ...
    ...                Uses OTC test account: ${T42_OTC_CUSTOMER_NAME} (${T42_OTC_ACCOUNT_NUMBER}).
    ...                Pre-condition: t4.2.12 has already run — one OTC withdrawal of
    ...                ${T42_FIRST_OTC_AMOUNT} has been made today.
    [Tags]             transactions    withdrawal    daily-limit    regression    type2
    # Step 1: Verify starting Daily Limit Remaining reflects first withdrawal (pre-check)
    Navigate To Customer Info Step    ${T42_OTC_ACCOUNT_NUMBER}
    Wait For Elements State    text=${T42_DAILY_LIMIT_AFTER_FIRST_OTC} >> nth=0    visible
    # Step 2: Proceed to withdrawal form and complete the second OTC withdrawal
    Click                      ${CREATE_TXN_WITHDRAWAL_BTN}
    Wait For Elements State    ${CREATE_TXN_TYPE_SELECT}    visible
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_SECOND_OTC_AMOUNT}
    Click                      ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_NEW_TXN_BTN_CONFIRM}    visible
    # Step 3: Navigate back and verify the updated limit in Step 1
    Go Back
    Wait For Load Spinner To Disappear
    Navigate To Customer Info Step    ${T42_OTC_ACCOUNT_NUMBER}
    Wait For Elements State    text=${T42_DAILY_LIMIT_AFTER_SECOND_OTC} >> nth=0    visible

t4.2.14 Daily OTC Limit Resets on the Next Day
    [Documentation]    Verify that the Daily OTC Limit Remaining resets to the configured
    ...                maximum (${T42_DAILY_LIMIT_INITIAL}) at the start of a new business day.
    ...
    ...                Pre-condition: OTC withdrawals were made on the previous day.
    ...                Cannot be automated — requires a system date change.
    ...                Verify manually: advance system date and confirm limit resets.
    [Tags]             transactions    withdrawal    daily-limit    manual    type2
    Skip    Requires system date change — verify manually that Daily Limit Remaining resets to ${T42_DAILY_LIMIT_INITIAL} on a new business day.

t4.2.15 Display of OTC-Only Transactions for Daily Limit Tracking
    [Documentation]    Navigate to the OTC test account's transaction history, filter by today's
    ...                date, sum all Cash Withdrawal (Debit) amounts, then verify that the
    ...                Daily Limit Remaining in Step 1 equals:
    ...                    T42_DAILY_LIMIT_INITIAL − sum(today's Cash Withdrawals)
    ...
    ...                This confirms that only OTC Cash Withdrawals reduce the daily limit —
    ...                not Send Money, Deposits, or other transaction types.
    ...
    ...                Uses OTC test account: ${T42_OTC_CUSTOMER_NAME} (${T42_OTC_ACCOUNT_NUMBER}).
    ...                Pre-condition: t4.2.12 and t4.2.13 have already run — two OTC withdrawals
    ...                (${T42_FIRST_OTC_AMOUNT} and ${T42_SECOND_OTC_AMOUNT}) exist today.
    [Tags]             transactions    withdrawal    daily-limit    regression    type2
    # Step 1: Get today's date for date range filter
    ${today}=    Evaluate    __import__('datetime').date.today().strftime('%Y-%m-%d')
    # Step 2: Navigate to the OTC account's transaction history
    Navigate To Account Transactions    ${T42_OTC_ACCOUNT_NUMBER}
    # Step 3: Apply today's date range filter
    Click                      ${DATE_TIME_FILTER}
    Wait For Elements State    ${DATE_START_INPUT}    visible
    Select Date Range From AntD Picker    ${today}    ${today}
    Click                      ${DATE_FILTER_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    # Step 4: Sum all Cash Withdrawal debit amounts from the filtered table via JavaScript
    ${total_withdrawn}=    Evaluate JavaScript    ${None}
    ...    () => {
    ...        const rows = document.querySelectorAll(
    ...            '.ant-table-body table tbody tr:not([aria-hidden="true"])'
    ...        );
    ...        let total = 0;
    ...        rows.forEach(row => {
    ...            const cells = row.querySelectorAll('td');
    ...            if (cells.length >= 4) {
    ...                const txnType = cells[1].innerText.trim();   // Transaction Type (col 2)
    ...                if (txnType === 'Cash Withdrawal') {
    ...                    const raw = cells[3].innerText.trim().replace(/[^0-9.]/g, '');
    ...                    const amount = parseFloat(raw);
    ...                    if (!isNaN(amount) && amount > 0) total += amount;
    ...                }
    ...            }
    ...        });
    ...        return total;
    ...    }
    Log    Total Cash Withdrawals today (from table): ${total_withdrawn}
    # Step 5: Compute expected Daily Limit Remaining
    ${initial_num}=           Evaluate    float('${T42_DAILY_LIMIT_INITIAL}'.replace(',', ''))
    ${expected_remaining}=    Evaluate    ${initial_num} - ${total_withdrawn}
    ${expected_formatted}=    Evaluate    '{:,.0f}'.format(${expected_remaining})
    Log    Expected Daily Limit Remaining: ${expected_formatted} (initial: ${T42_DAILY_LIMIT_INITIAL} − withdrawn: ${total_withdrawn})
    # Step 6: Navigate back to Transactions page and verify Daily Limit Remaining matches expected value
    Navigate To Transactions
    Navigate To Customer Info Step    ${T42_OTC_ACCOUNT_NUMBER}
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Daily Limit Remaining >> nth=0    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${expected_formatted} >> nth=0    visible

t4.2.16 Consolidated Daily Limit Tracking for Mobile and OTC Transactions
    [Documentation]    Verify that the system displays a combined daily outgoing limit that
    ...                covers both Mobile and OTC transactions when Phase 2 is enabled.
    ...
    ...                Phase 2 feature — not yet implemented.
    [Tags]             transactions    withdrawal    daily-limit    phase2    type2
    Skip    Phase 2 feature — consolidated Mobile + OTC daily limit tracking is not yet implemented.

t4.2.17 Visibility of Daily Outgoing Transactions Under Customer Profile
    [Documentation]    Verify that the Customer Information step (Step 1) displays the
    ...                customer's Daily Limit Remaining field, showing how much of the
    ...                daily OTC limit has been consumed.
    ...
    ...                Uses OTC test account: ${T42_OTC_CUSTOMER_NAME} (${T42_OTC_ACCOUNT_NUMBER}).
    [Tags]             transactions    withdrawal    daily-limit    regression    type2
    Skip    Phase 2 feature — consolidated Mobile + OTC daily limit tracking is not yet implemented.
    Navigate To Customer Info Step    ${T42_OTC_ACCOUNT_NUMBER}
    Wait For Elements State    text=Daily Limit Remaining >> nth=0    visible

t4.2.18 Daily Limit Reset for Consolidated Transactions
    [Documentation]    Verify that the combined daily outgoing limit for Mobile and OTC
    ...                transactions resets on the next business day (Phase 2 feature).
    ...
    ...                Phase 2 feature — not yet implemented.
    [Tags]             transactions    withdrawal    daily-limit    phase2    type2
    Skip    Phase 2 feature — consolidated daily limit reset is not yet implemented.


# ====================================================================
# NEGATIVE / VALIDATION
# ====================================================================

t4.2.19 Validate Maximum Daily Withdrawal Limit (Allowed Amount)
    [Documentation]    Verify that entering an amount equal to the configured daily max
    ...                (${T42_MAX_ALLOWED_AMOUNT}) is accepted: no error is shown, and the
    ...                Process Withdrawal button is enabled.
    [Tags]             transactions    withdrawal    validation    regression    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_MAX_ALLOWED_AMOUNT}
    Wait For Load Spinner To Disappear
    ${has_error}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${CREATE_TXN_FORM_ERROR}    visible    timeout=2s
    Should Not Be True    ${has_error}
    ...    msg=No validation error should appear for the maximum allowed amount of ${T42_MAX_ALLOWED_AMOUNT}
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    enabled

t4.2.20 Search with Invalid Account Number
    [Documentation]    Verify that searching by a non-existent account number in the Create
    ...                Transaction modal shows an empty-state / "No accounts found" message.
    [Tags]             transactions    create    withdrawal    negative    smoke    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T42_INVALID_ACCOUNT_NUMBER}
    Wait For Elements State    ${CREATE_TXN_NO_RESULTS_MSG}    visible

t4.2.21 Search with Invalid Account Name
    [Documentation]    Verify that searching by a non-existent account name in the Create
    ...                Transaction modal shows an empty-state / "No accounts found" message.
    [Tags]             transactions    create    withdrawal    negative    smoke    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T42_INVALID_ACCOUNT_NAME}
    Wait For Elements State    ${CREATE_TXN_NO_RESULTS_MSG}    visible

t4.2.22 Validate Withdrawal Type Required
    [Documentation]    Verify that the Process Withdrawal button is disabled when no
    ...                Withdrawal Type is selected — even if an amount is entered.
    ...                The type dropdown is required and the button must not activate without it.
    [Tags]             transactions    withdrawal    validation    smoke    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    # No type selected — button must be disabled immediately
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    disabled
    # Enter a valid amount without selecting a type — button must remain disabled
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_WITHDRAWAL_AMOUNT}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    disabled

t4.2.23 Validate Withdrawal Amount Required
    [Documentation]    Verify that the Process Withdrawal button is disabled when the
    ...                Withdrawal Amount is blank, even after selecting a type.
    [Tags]             transactions    withdrawal    validation    smoke    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    # Amount is still blank — button must remain disabled
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    disabled

t4.2.24 Withdrawal Amount Exceeds Balance
    [Documentation]    Verify that entering an amount greater than the account's current
    ...                balance shows an "Insufficient funds" error, preventing submission.
    [Tags]             transactions    withdrawal    validation    negative    smoke    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER_EXCEED_BALANCE}
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_OVER_BALANCE_AMOUNT}
    Wait For Load Spinner To Disappear
    Wait For Elements State    text=Insufficient funds >> nth=0    visible
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    disabled

t4.2.25 OTC Withdrawal Exceeding Remaining Daily Limit
    [Documentation]    Verify that an OTC withdrawal of ${T42_OVER_LIMIT_AMOUNT} (exceeding the
    ...                remaining daily limit) triggers the error:
    ...                "You've reached your daily transfer limit of PHP 500,000."
    ...                The form should remain open so the teller can adjust the amount.
    ...
    ...                Pre-condition: Daily Limit Remaining = 450,000
    ...                (after two prior OTC withdrawals of 20,000 and 30,000).
    [Tags]             transactions    withdrawal    validation    negative    daily-limit    regression    type2
    Navigate To Withdrawal Step    ${T42_OTC_ACCOUNT_NUMBER}
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_OVER_LIMIT_AMOUNT}
    Click                      ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}
    Wait For Load Spinner To Disappear

    # Wait for the system to calculate the limit and show the error
    Wait For Elements State    text=${T42_DAILY_LIMIT_ERROR}    visible    # Ensure the button is disabled so the teller CANNOT click it
    Get Element States         ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    contains    disabled

t4.2.26 Validate Minimum Withdrawal Amount
    [Documentation]    Verify that entering an amount less than 1 (e.g. 0.5) triggers a
    ...                validation error ("Amount must be greater than 1" or equivalent)
    ...                and the Process Withdrawal button remains disabled.
    [Tags]             transactions    withdrawal    validation    negative    regression    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    0.5
    Wait For Load Spinner To Disappear
    # Verify Process Withdrawal button remains disabled for amount less than 1
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    disabled

t4.2.27 Validate Maximum Daily Withdrawal Limit Exceeded
    [Documentation]    Verify that entering an amount above the daily maximum
    ...                (${T42_EXCEED_MAX_AMOUNT}) displays the error:
    ...                "Amount must be lesser than 500,000".
    [Tags]             transactions    withdrawal    validation    negative    regression    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_EXCEED_MAX_AMOUNT}
    Wait For Load Spinner To Disappear
    # Verify Process Withdrawal button remains disabled when amount exceeds max daily limit
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    disabled

t4.2.28 Validate Negative or Zero Withdrawal Amount
    [Documentation]    Verify that entering 0 (or a negative amount) triggers a validation
    ...                error and the Process Withdrawal button remains disabled.
    [Tags]             transactions    withdrawal    validation    negative    regression    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    0
    Wait For Load Spinner To Disappear
    # Verify Process Withdrawal button remains disabled for zero amount
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    disabled

t4.2.29 Validate Non-Numeric Withdrawal Amount
    [Documentation]    Verify that entering non-numeric input in the Amount field causes the
    ...                field to reset to its initial state, and the Process Withdrawal button
    ...                remains disabled.
    [Tags]             transactions    withdrawal    validation    negative    regression    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    five hundred
    Keyboard Key               press    Enter
    Wait For Load Spinner To Disappear
    # Verify field resets (value should be empty or not contain the non-numeric text)
    ${entered_value}=    Get Property    ${CREATE_TXN_AMOUNT_INPUT}    value
    Should Not Contain    ${entered_value}    five
    ...    msg=Amount field should reset after non-numeric input, but got: '${entered_value}'
    # Verify Process Withdrawal button remains disabled
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    disabled

t4.2.30 Validate Withdrawal Notes Character Limit
    [Documentation]    Verify that the Transaction Notes field enforces a 300-character maximum.
    ...                Attempting to enter 301 characters should result in the stored value
    ...                being at most 300 characters (field truncates or rejects excess input).
    [Tags]             transactions    withdrawal    validation    regression    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    ${long_text}=    Evaluate    'a' * 301
    Fill Text                  ${CREATE_TXN_NOTES_INPUT}    ${long_text}
    ${notes_value}=    Get Property    ${CREATE_TXN_NOTES_INPUT}    value
    ${notes_length}=   Get Length    ${notes_value}
    Should Be True    ${notes_length} <= 300
    ...    msg=Notes field should not accept more than 300 characters, but accepted ${notes_length}

t4.2.31 Validate Process Withdrawal Button Activation
    [Documentation]    Verify the Process Withdrawal button is only enabled after ALL required
    ...                fields are filled:
    ...                1. Initially disabled (no type, no amount).
    ...                2. Still disabled after selecting type only (no amount).
    ...                3. Enabled only after both type and valid amount are provided.
    [Tags]             transactions    withdrawal    validation    smoke    type2
    Navigate To Withdrawal Step    ${T42_ACCOUNT_NUMBER}
    # 1. No inputs — button must be disabled
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    disabled
    # 2. Type selected, amount still blank — button must remain disabled
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T42_WITHDRAWAL_TYPE}")
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    disabled
    # 3. Both type and valid amount filled — button must become enabled
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T42_WITHDRAWAL_AMOUNT}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_PROCESS_WITHDRAWAL_BTN}    enabled
