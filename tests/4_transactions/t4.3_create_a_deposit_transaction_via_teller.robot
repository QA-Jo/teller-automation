*** Settings ***
Documentation       t4.3 Create a Deposit Transaction via Teller
...                 Covers the complete deposit flow via the New Transaction modal:
...                 opening the modal, searching for an account by number and by name,
...                 selecting an account and verifying customer information,
...                 navigating to the Deposit form, filling form fields, verifying
...                 real-time summary updates, processing the deposit, and verifying
...                 the new transaction in the Transactions list.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/transactions.resource
Resource            ../../resources/keywords/accounts.resource

Suite Setup         Login To Teller App
Suite Teardown      Close Browser
Test Setup          Setup Transactions Page
Test Teardown       Close Modal If Open


*** Variables ***
${T43_MIN_AMOUNT_ERROR}    Amount must be greater than 1


*** Keywords ***
Navigate To Customer Info Step
    [Documentation]    Opens the New Transaction modal, searches for the test account, and
    ...                selects it — landing on the Customer Information step (Step 1).
    ...                Use this when you need to verify Customer Info fields (e.g. Daily
    ...                Limit Remaining) without proceeding to the Transaction form.
    [Arguments]    ${account_number}=${T43_ACCOUNT_NUMBER}
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${account_number}
    Select Account From Create Transaction Results    ${account_number}
    Wait For Elements State    text=Daily Limit Remaining >> nth=0    visible


*** Test Cases ***
t4.3.1 Open New Transaction Modal
    [Documentation]    Verify that clicking the New Transaction button opens the Create Transaction
    ...                modal with the Customer Information step visible, and the account search
    ...                field and Search button are present and enabled.
    [Tags]             transactions    create    deposit    smoke    mvp    type2
    Wait For Elements State    ${NEW_TXN_BTN}                    visible
    Click                      ${NEW_TXN_BTN}
    Wait For Elements State    ${CREATE_TXN_MODAL}               visible
    Wait For Elements State    text=Search Customer               visible
    Wait For Elements State    ${CREATE_TXN_SEARCH_INPUT}        visible
    Wait For Elements State    ${CREATE_TXN_SEARCH_BTN}          enabled

t4.3.2 Search by Account Number
    [Documentation]    Verify that entering a valid account number and clicking Search returns
    ...                a result list where each entry displays:
    ...                Account Name, Account Number, account type (e.g. Savings),
    ...                Balance, and Account Status.
    [Tags]             transactions    create    deposit    smoke    mvp    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T43_ACCOUNT_NUMBER}
    # Verify the matching result card is visible
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T43_ACCOUNT_NUMBER}")
    ...    visible
    # Verify all expected fields are displayed per result entry
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T43_ACCOUNT_NUMBER}"):has-text("${T43_ACCOUNT_NAME}")
    ...    visible
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T43_ACCOUNT_NUMBER}"):has-text("${T43_ACCOUNT_TYPE}")
    ...    visible
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T43_ACCOUNT_NUMBER}"):has-text("${T43_ACCOUNT_STATUS}")
    ...    visible

t4.3.3 Search by Account Name
    [Documentation]    Verify that entering a valid account holder name returns one or more
    ...                matching results. Each result entry displays Account Name, Account Number,
    ...                account type (e.g. Savings), Balance, and Account Status.
    [Tags]             transactions    create    deposit    smoke    mvp    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T43_CUSTOMER_NAME}
    # Verify at least one result card containing the searched name is visible
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T43_CUSTOMER_NAME}") >> nth=0
    ...    visible
    # Verify common fields are shown per result entry
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T43_CUSTOMER_NAME}"):has-text("${T43_ACCOUNT_TYPE}") >> nth=0
    ...    visible
    Wait For Elements State
    ...    css=.ant-modal-content [role="button"]:has-text("${T43_CUSTOMER_NAME}"):has-text("${T43_ACCOUNT_STATUS}") >> nth=0
    ...    visible

t4.3.4 Select Account and Verify Customer Information
    [Documentation]    Verify that selecting an account from search results navigates to the
    ...                Customer Information step, which displays: Customer Name, Account Number,
    ...                Account Type, Status, Current Balance, Daily Limit Remaining,
    ...                and Contact Information (Mobile Number and Email).
    [Tags]             transactions    create    deposit    smoke    mvp    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T43_ACCOUNT_NUMBER}
    Select Account From Create Transaction Results    ${T43_ACCOUNT_NUMBER}
    # Verify all fields — continue on failure so ALL mismatches are reported
    # Verify account and customer identity details
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Name           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T43_CUSTOMER_NAME} >> nth=0       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Number         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T43_ACCOUNT_NUMBER} >> nth=0      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Type           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T43_ACCOUNT_TYPE} >> nth=0        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Status                 visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T43_ACCOUNT_STATUS} >> nth=0      visible
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

t4.3.5 Navigate to Transaction Type – Deposit
    [Documentation]    Verify that clicking the Deposit button from the Customer Information
    ...                step navigates to the Transaction step for Deposit, showing:
    ...                - Two panels: "Deposit Funds" and "Transaction Summary"
    ...                - Deposit Funds panel pre-filled with Account Name, Account Number
    ...                  (with account type e.g. Savings), and Current Balance
    ...                - Deposit Type dropdown, Deposit Amount input, Transaction Notes field
    ...                - Cancel and Process Deposit buttons
    [Tags]             transactions    create    deposit    smoke    mvp    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T43_ACCOUNT_NUMBER}
    Select Account From Create Transaction Results    ${T43_ACCOUNT_NUMBER}
    Click                      ${CREATE_TXN_DEPOSIT_BTN}
    # Verify both panel headings are visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Deposit Funds >> nth=0          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Transaction Summary >> nth=0    visible
    # Verify Deposit Funds panel pre-fills account info from the selected account
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T43_ACCOUNT_NAME} >> nth=0    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T43_ACCOUNT_NUMBER} >> nth=0  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T43_ACCOUNT_TYPE} >> nth=0    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Current Balance >> nth=0        visible
    # Verify form inputs are present
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_TYPE_SELECT}            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_AMOUNT_INPUT}           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_NOTES_INPUT}            visible
    # Verify action buttons are present
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_CANCEL_BTN}             visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    visible

t4.3.6 Real-Time Summary Updates with Deposit Amount
    [Documentation]    Verify that the Transaction Summary panel updates immediately as the
    ...                user fills in the deposit form:
    ...                - Entering an amount shows the deposit amount in the summary
    ...                - The summary displays New Balance = Current Balance + deposit amount (correct math)
    [Tags]             transactions    create    deposit    regression    mvp    type2
    Navigate To Deposit Step
    # Select deposit type
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T43_DEPOSIT_TYPE}")
    Wait For Load Spinner To Disappear
    # Capture Current Balance from the summary panel BEFORE entering the amount
    ${current_balance_str}=    Get Transaction Summary Field Value    Current Balance
    ${current_balance}=        Evaluate    float('${current_balance_str}'.replace(',', ''))
    # Enter the deposit amount
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T43_DEPOSIT_AMOUNT}
    Wait For Elements State    text=${T43_DEPOSIT_AMOUNT_FORMATTED} >> nth=0    visible
    Wait For Elements State    text=New Balance >> nth=0              visible
    # Compute expected new balance and assert the summary shows the correct value
    ${deposit}=                Evaluate    float(str('${T43_DEPOSIT_AMOUNT}').replace(',', ''))
    ${expected_new_balance}=   Evaluate    round(${current_balance} + ${deposit}, 2)
    ${new_balance_str}=        Get Transaction Summary Field Value    New Balance
    ${displayed_new_balance}=  Evaluate    float('${new_balance_str}'.replace(',', ''))
    Should Be Equal As Numbers    ${displayed_new_balance}    ${expected_new_balance}
    ...    msg=Summary New Balance is wrong: expected ${expected_new_balance} (${current_balance} + ${deposit}) but got ${displayed_new_balance}

t4.3.7 Process Deposit and Review
    [Documentation]    Verify that completing the deposit form and clicking Process Deposit
    ...                navigates to the Review step which displays:
    ...                - "Deposit Successful" heading and sub-message
    ...                - Labels: Transaction ID, Customer, Account number, Transaction Type,
    ...                  Amount, Date & Time, Auth Code, Notes, Previous Balance, New Balance
    ...                - Correct Customer Name, Account Number, Transaction Type, Amount (exact match)
    ...                - New Balance = Previous Balance + Deposit Amount (math validation)
    ...                - Print Receipt and New Transaction buttons
    [Tags]             transactions    create    deposit    smoke    mvp    type2
    Navigate To Deposit Step
    # Fill the deposit form
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T43_DEPOSIT_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T43_DEPOSIT_AMOUNT}
    Fill Text                  ${CREATE_TXN_NOTES_INPUT}     ${T43_DEPOSIT_NOTES}
    # Submit the deposit
    Click                      ${CREATE_TXN_PROCESS_DEPOSIT_BTN}
    Wait For Load Spinner To Disappear
    # Label assertions — verify all receipt field labels are present
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Deposit Successful >> nth=0                       visible
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
    ${_cust_name}=    Get Text    :text-is("${T43_CUSTOMER_NAME}") >> nth=0
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_cust_name}    ${T43_CUSTOMER_NAME}
    ...    msg=Customer Name mismatch: expected '${T43_CUSTOMER_NAME}' but got '${_cust_name}'
    ${_acct_no}=      Get Text    :text-is("${T43_ACCOUNT_NUMBER}") >> nth=0
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_acct_no}    ${T43_ACCOUNT_NUMBER}
    ...    msg=Account Number mismatch: expected '${T43_ACCOUNT_NUMBER}' but got '${_acct_no}'
    ${_d_type}=       Get Text    :text-is("${T43_DEPOSIT_TYPE}") >> nth=0
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_d_type}    ${T43_DEPOSIT_TYPE}
    ...    msg=Deposit Type mismatch: expected '${T43_DEPOSIT_TYPE}' but got '${_d_type}'
    ${_d_amount}=     Get Text    :text-is("${T43_DEPOSIT_AMOUNT_FORMATTED}") >> nth=0
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Strings    ${_d_amount}    ${T43_DEPOSIT_AMOUNT_FORMATTED}
    ...    msg=Deposit Amount mismatch: expected '${T43_DEPOSIT_AMOUNT_FORMATTED}' but got '${_d_amount}'
    # Assert receipt New Balance = Previous Balance + Deposit Amount
    ${prev_balance_str}=       Get Transaction Summary Field Value    Previous Balance
    ${prev_balance}=           Evaluate    float('${prev_balance_str}'.replace(',', ''))
    ${deposit}=                Evaluate    float(str('${T43_DEPOSIT_AMOUNT}').replace(',', ''))
    ${expected_new_balance}=   Evaluate    round(${prev_balance} + ${deposit}, 2)
    ${new_balance_str}=        Get Transaction Summary Field Value    New Balance
    ${displayed_new_balance}=  Evaluate    float('${new_balance_str}'.replace(',', ''))
    Should Be Equal As Numbers    ${displayed_new_balance}    ${expected_new_balance}
    ...    msg=Receipt New Balance is wrong: expected ${expected_new_balance} (${prev_balance} + ${deposit}) but got ${displayed_new_balance}
    # Verify the action buttons on the confirmation screen
    # hidden for now
    # Run Keyword And Continue On Failure
    # ...    Wait For Elements State    ${CREATE_TXN_PRINT_RECEIPT_BTN}       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${CREATE_TXN_NEW_TXN_BTN_CONFIRM}     visible

t4.3.8 Verify Newest Transaction Appears at the Top (Deposit)
    [Documentation]    Verify that after completing the deposit flow and closing the confirmation,
    ...                the new Deposit transaction appears as the most recent (first) row
    ...                in the Transactions list, showing:
    ...                Transaction Type = Deposit, Credit Account Number = customer account,
    ...                Debit Account Number = N/A, and Status column visible.
    [Tags]             transactions    create    deposit    smoke    mvp    type2
    # Complete the full deposit flow
    Navigate To Deposit Step
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T43_DEPOSIT_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T43_DEPOSIT_AMOUNT}
    Fill Text                  ${CREATE_TXN_NOTES_INPUT}     ${T43_DEPOSIT_NOTES}
    Click                      ${CREATE_TXN_PROCESS_DEPOSIT_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_NEW_TXN_BTN_CONFIRM}    visible
    # Navigate back to the Transactions list via browser back button
    Go Back
    Wait For Load Spinner To Disappear
    # Verify the newest transaction (first row) is the Deposit just created
    Wait For Elements State
    ...    css=.ant-table-body table tbody tr:not([aria-hidden="true"]) >> nth=0
    ...    visible
    ${first_row_text}=    Get Text
    ...    css=.ant-table-body table tbody tr:not([aria-hidden="true"]) >> nth=0
    Should Contain    ${first_row_text}    Deposit
    Should Contain    ${first_row_text}    ${T43_ACCOUNT_NUMBER}

t4.3.9 View Details of the Newest Transaction (Deposit)
    [Documentation]    Verify that clicking the View (eye) icon for the newest Deposit
    ...                transaction opens the detail modal which shows all relevant data:
    ...                - Transaction Type = Deposit
    ...                - Transaction Amount, Service Fee, Remarks, Transaction Status
    ...                - Credit Account Name = customer account
    ...                - Credit Account Number = customer account number
    ...                - Debit Account Name = N/A
    ...                - Debit Account Number = N/A
    ...                - Created on and Updated on timestamps
    [Tags]             transactions    create    deposit    smoke    mvp    type2
    # Complete the full deposit flow
    Navigate To Deposit Step
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T43_DEPOSIT_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T43_DEPOSIT_AMOUNT}
    Fill Text                  ${CREATE_TXN_NOTES_INPUT}     ${T43_DEPOSIT_NOTES}
    Click                      ${CREATE_TXN_PROCESS_DEPOSIT_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_NEW_TXN_BTN_CONFIRM}    visible
    # Navigate back to the Transactions list via browser back button
    Go Back
    Wait For Load Spinner To Disappear
    # Open the detail modal for the newest (first) transaction
    Click                      ${TXN_VIEW_BTN} >> nth=0
    Wait For Elements State    ${TXN_DETAIL_MODAL}                                              visible
    # Verify all required field labels in the detail modal
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction ID                       visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Type                     visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Amount                   visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Service Fee                          visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Remarks                              visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Status                   visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Account Name                   visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Account Number                 visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Account Name                  visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Account Number                visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Created on                           visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Updated on                           visible
    # Verify Deposit-specific values: credit is customer account, debit is N/A
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=${T43_ACCOUNT_NAME}                  visible
    Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=${T43_ACCOUNT_NUMBER}                visible
    Wait For Elements State
    ...    ${TXN_DETAIL_MODAL} >> :text-is("Deposit")
    ...    visible
    # Close the detail modal
    Click                      ${TXN_DETAIL_BACK_BTN}
    Wait For Elements State    ${TXN_DETAIL_MODAL}    hidden
    Wait For Elements State    ${TXN_TABLE}            visible


# ====================================================================
# NEGATIVE / VALIDATION
# ====================================================================

t4.3.10 Validate High Deposit Amount (No Maximum Limit)
    [Documentation]    Verify that the system accepts deposit amounts with no upper cap:
    ...                500,000 / 500,001 / 1,000,000 are each processed successfully.
    ...                No error message related to a maximum amount is shown, and each
    ...                deposit advances to the Deposit Successful confirmation screen.
    [Tags]             transactions    create    deposit    validation    regression    type2
    FOR    ${amount}    IN
    ...    ${T43_HIGH_DEPOSIT_AMOUNT_1}
    ...    ${T43_HIGH_DEPOSIT_AMOUNT_2}
    ...    ${T43_HIGH_DEPOSIT_AMOUNT_3}
        Setup Transactions Page
        Navigate To Deposit Step
        Click                      ${CREATE_TXN_TYPE_SELECT}
        Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
        Click
        ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T43_DEPOSIT_TYPE}")
        Wait For Load Spinner To Disappear
        Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${amount}
        Wait For Load Spinner To Disappear
        # No error should be shown for any of these amounts
        ${has_error}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${CREATE_TXN_FORM_ERROR}    visible    timeout=2s
        Should Not Be True    ${has_error}
        ...    msg=No validation error should appear for deposit amount ${amount}
        # Process Deposit button must be enabled
        Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    enabled
        # Submit and verify deposit is processed successfully
        Click                      ${CREATE_TXN_PROCESS_DEPOSIT_BTN}
        Wait For Load Spinner To Disappear
        Wait For Elements State    text=Deposit Successful >> nth=0    visible
    END

t4.3.11 Search with Invalid Account Number
    [Documentation]    Verify that searching by a non-existent account number in the Create
    ...                Transaction modal shows an empty-state / "No accounts found" message.
    [Tags]             transactions    create    deposit    negative    smoke    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T43_INVALID_ACCOUNT_NUMBER}
    Wait For Elements State    ${CREATE_TXN_NO_RESULTS_MSG}    visible

t4.3.12 Search with Invalid Account Name
    [Documentation]    Verify that searching by a non-existent account name in the Create
    ...                Transaction modal shows an empty-state / "No accounts found" message.
    [Tags]             transactions    create    deposit    negative    smoke    type2
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${T43_INVALID_ACCOUNT_NAME}
    Wait For Elements State    ${CREATE_TXN_NO_RESULTS_MSG}    visible

t4.3.13 Validate Deposit Type Required
    [Documentation]    Verify that the Process Deposit button is disabled when no
    ...                Deposit Type is selected — even if an amount is entered.
    ...                The type dropdown is required and the button must not activate without it.
    [Tags]             transactions    deposit    validation    smoke    type2
    Navigate To Deposit Step
    # No type selected — button must be disabled immediately
    Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    disabled
    # Enter a valid amount without selecting a type — button must remain disabled
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T43_DEPOSIT_AMOUNT}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    disabled

t4.3.14 Validate Deposit Amount Required
    [Documentation]    Verify that the Process Deposit button is disabled when the
    ...                Deposit Amount is blank, even after selecting a type.
    [Tags]             transactions    deposit    validation    smoke    type2
    Navigate To Deposit Step
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T43_DEPOSIT_TYPE}")
    Wait For Load Spinner To Disappear
    # Amount is still blank — button must remain disabled
    Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    disabled

t4.3.15 Validate Deposit Amount Format
    [Documentation]    Verify that non-numeric characters cannot be entered in the Deposit Amount
    ...                field. Attempting to type "abc" or a malformed number causes the field to
    ...                reset, and the Process Deposit button remains disabled.
    [Tags]             transactions    deposit    validation    negative    regression    type2
    Navigate To Deposit Step
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T43_DEPOSIT_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    five hundred
    Keyboard Key               press    Enter
    Wait For Load Spinner To Disappear
    # Verify field resets (value should not contain the non-numeric text)
    ${entered_value}=    Get Property    ${CREATE_TXN_AMOUNT_INPUT}    value
    Should Not Contain    ${entered_value}    five
    ...    msg=Amount field should reset after non-numeric input, but got: '${entered_value}'
    # Verify Process Deposit button remains disabled
    Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    disabled

t4.3.16 Validate Deposit Amount Negative or Zero
    [Documentation]    Verify that entering 0 triggers a validation error and the Process Deposit
    ...                button remains disabled. Negative values cannot be entered in the
    ...                numeric amount field (input rejects them).
    [Tags]             transactions    deposit    validation    negative    regression    type2
    Navigate To Deposit Step
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T43_DEPOSIT_TYPE}")
    Wait For Load Spinner To Disappear
    # Test negative value
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    -1
    Keyboard Key               press    Enter
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    disabled
    # Test zero value
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    0
    Keyboard Key               press    Enter
    Wait For Load Spinner To Disappear
    # Verify Process Deposit button remains disabled for zero amount
    Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    disabled

t4.3.17 Validate Minimum Deposit Amount
    [Documentation]    Verify that entering an amount less than 1 (e.g. 0.5) triggers a
    ...                validation error ("Amount must be greater than 1" or equivalent)
    ...                and the Process Deposit button remains disabled.
    [Tags]             transactions    deposit    validation    negative    regression    type2
    Navigate To Deposit Step
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T43_DEPOSIT_TYPE}")
    Wait For Load Spinner To Disappear
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    0.5
    Keyboard Key               press    Enter
    Wait For Load Spinner To Disappear
    # Verify error message is displayed
    Wait For Elements State    text=${T43_MIN_AMOUNT_ERROR}    visible
    # Verify Process Deposit button remains disabled for amount less than 1
    Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    disabled

t4.3.18 Validate Deposit Notes Max Length
    [Documentation]    Verify that the Transaction Notes field enforces a 300-character maximum.
    ...                Attempting to enter 301 characters should result in the stored value
    ...                being at most 300 characters (field truncates or rejects excess input).
    [Tags]             transactions    deposit    validation    regression    type2
    Navigate To Deposit Step
    ${long_text}=    Evaluate    'a' * 301
    Fill Text                  ${CREATE_TXN_NOTES_INPUT}    ${long_text}
    ${notes_value}=    Get Property    ${CREATE_TXN_NOTES_INPUT}    value
    ${notes_length}=   Get Length    ${notes_value}
    Should Be True    ${notes_length} <= 300
    ...    msg=Notes field should not accept more than 300 characters, but accepted ${notes_length}

t4.3.19 Validate Process Deposit Button Activation
    [Documentation]    Verify the Process Deposit button is only enabled after ALL required
    ...                fields are filled:
    ...                1. Initially disabled (no type, no amount).
    ...                2. Still disabled after selecting type only (no amount).
    ...                3. Enabled only after both type and valid amount are provided.
    [Tags]             transactions    deposit    validation    smoke    type2
    Navigate To Deposit Step
    # 1. No inputs — button must be disabled
    Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    disabled
    # 2. Type selected, amount still blank — button must remain disabled
    Click                      ${CREATE_TXN_TYPE_SELECT}
    Wait For Elements State    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden)    visible
    Click
    ...    css=.ant-select-dropdown:not(.ant-select-dropdown-hidden) .ant-select-item-option-content:has-text("${T43_DEPOSIT_TYPE}")
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    disabled
    # 3. Both type and valid amount filled — button must become enabled
    Fill Text                  ${CREATE_TXN_AMOUNT_INPUT}    ${T43_DEPOSIT_AMOUNT}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_PROCESS_DEPOSIT_BTN}    enabled
