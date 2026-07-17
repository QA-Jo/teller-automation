*** Settings ***
Library     Browser
Resource    common.resource
Resource    ../locators/transactions_locators.resource


*** Keywords ***
Navigate To Transactions
    [Documentation]    Navigates to the Transactions module via the sidebar
    Click                      ${TRANSACTIONS_MENU}
    Wait For Load Spinner To Disappear
    Get Url                    contains    /transactions

Setup Transactions Page
    [Documentation]    Navigates to the Transactions module and ensures a clean state.
    ...                Uses Reload first to clear any modal state before navigating.
    ...                Paces between tests so the suite stays under the backend request
    ...                rate limit (bursts of ~13 requests return HTTP 429 for ~1 hour).
    Sleep    12s
    Reload
    Wait For Load Spinner To Disappear
    Navigate To Transactions

Filter Txn Results Should Contain Only Type
    [Documentation]    Verifies all visible transaction rows match the expected type display text.
    ...                If data exists, opens the first row's detail modal and verifies required fields.
    ...                For External type, also verifies the Instapay Reference Number field.
    ...                If no data, verifies the "No Data" message.
    [Arguments]        ${expected_type}
    Wait For Load Spinner To Disappear
    Sleep    1s
    ${no_data_visible}=    Run Keyword And Return Status
    ...                    Wait For Elements State    ${TXN_NO_DATA_MESSAGE}    visible    timeout=3s
    IF    ${no_data_visible}
        Log    No data found for type: ${expected_type}
    ELSE
        ${total_rows}=      Get Element Count    css=.ant-table-body table tbody tr:not([aria-hidden="true"]):not(:empty)
        ${matching_rows}=   Get Element Count    css=.ant-table-body table tbody tr:not([aria-hidden="true"]):has-text("${expected_type}")
        Should Be Equal    ${total_rows}    ${matching_rows}
        ...    Expected all ${total_rows} rows to have type "${expected_type}", but only ${matching_rows} matched
        Log    All ${total_rows} rows contain type "${expected_type}"
        Wait For Load Spinner To Disappear
        Click    ${TXN_VIEW_BTN} >> nth=0
        Wait For Elements State    ${TXN_DETAIL_MODAL}                                       visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction ID                visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Type              visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Amount            visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Service Fee                  visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Remarks                      visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Status            visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Account Name           visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Account Name          visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Account Number         visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Account Number        visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Created on                   visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Updated on                   visible
        IF    '${expected_type}' == 'External'
            Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Instapay Reference Number    visible
            # Check if External transaction is Cash In or Send Money
            ${is_cash_in}=    Run Keyword And Return Status
            ...               Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Cash In    visible    timeout=2s
            IF    ${is_cash_in}
                Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Bank Code    visible
                Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Bank Name    visible
            ELSE
                Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Bank Code    visible
                Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Bank Name    visible
            END
        END
        Click    ${TXN_DETAIL_BACK_BTN}
        Wait For Elements State    ${TXN_DETAIL_MODAL}    hidden
    END

Filter Txn Results Should Contain Only Status
    [Documentation]    Verifies all visible transaction rows match the expected status.
    ...                If data exists, opens the first row's detail modal and verifies required fields.
    ...                If no data, verifies the "No Data" message.
    [Arguments]        ${expected_status}
    Wait For Load Spinner To Disappear
    Sleep    1s
    ${no_data_visible}=    Run Keyword And Return Status
    ...                    Wait For Elements State    ${TXN_NO_DATA_MESSAGE}    visible    timeout=3s
    IF    ${no_data_visible}
        Log    No data found for status: ${expected_status}
    ELSE
        ${total_rows}=      Get Element Count    css=.ant-table-body table tbody tr:not([aria-hidden="true"]):not(:empty)
        ${matching_rows}=   Get Element Count    css=.ant-table-body table tbody tr:not([aria-hidden="true"]):has-text("${expected_status}")
        Should Be Equal    ${total_rows}    ${matching_rows}
        ...    Expected all ${total_rows} rows to have status "${expected_status}", but only ${matching_rows} matched
        Log    All ${total_rows} rows contain status "${expected_status}"
        Wait For Load Spinner To Disappear
        Click    ${TXN_VIEW_BTN} >> nth=0
        Wait For Elements State    ${TXN_DETAIL_MODAL}                                       visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction ID                visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Type              visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Amount            visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Service Fee                  visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Remarks                      visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Transaction Status            visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Account Name           visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Account Name          visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Debit Account Number         visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Credit Account Number        visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Created on                   visible
        Wait For Elements State    ${TXN_DETAIL_MODAL} >> text=Updated on                   visible
        Click    ${TXN_DETAIL_BACK_BTN}
        Wait For Elements State    ${TXN_DETAIL_MODAL}    hidden
    END

Select Txn Date Range From AntD Picker
    [Documentation]    Selects a date range from the AntD dual-panel RangePicker on the Transactions page.
    ...                Opens the picker via the Start Date input and clicks both start and end dates.
    ...                Navigates forward in the picker to reach the target months.
    ...                Expects dates in YYYY-MM-DD format.
    [Arguments]    ${date_from}    ${date_to}
    ${day_from}=      Evaluate    str(int('${date_from}'.split('-')[2]))
    ${day_to}=        Evaluate    str(int('${date_to}'.split('-')[2]))
    ${month_from}=    Evaluate    __import__('datetime').datetime(int('${date_from}'.split('-')[0]), int('${date_from}'.split('-')[1]), 1).strftime('%b %Y')
    ${month_to}=      Evaluate    __import__('datetime').datetime(int('${date_to}'.split('-')[0]), int('${date_to}'.split('-')[1]), 1).strftime('%b %Y')
    # Open the range picker by clicking the Start Date input
    Click    ${TXN_DATE_START_INPUT}
    Sleep    0.5s
    Wait For Elements State    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden)    visible
    # Navigate forward until start month is visible in either panel
    FOR    ${i}    IN RANGE    24
        ${left_month}=     Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-month-btn
        ${left_year}=      Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-year-btn
        ${right_month}=    Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:last-of-type .ant-picker-month-btn
        ${right_year}=     Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:last-of-type .ant-picker-year-btn
        ${found}=    Evaluate    '${month_from}' in '${left_month} ${left_year}' or '${month_from}' in '${right_month} ${right_year}'
        IF    ${found}    BREAK
        # Navigate backward if the target month is before the current panel, else forward.
        # (Forward-only navigation hits the disabled next button for past date ranges.)
        ${go_back}=    Evaluate    __import__('datetime').datetime.strptime('${month_from}', '%b %Y') < __import__('datetime').datetime.strptime('${left_month} ${left_year}', '%b %Y')
        IF    ${go_back}
            Click    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-header-prev-btn >> nth=0
        ELSE
            Click    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-header-super-next-btn >> nth=0
        END
        Sleep    0.3s
    END
    # Click start date in the correct panel
    ${left_month}=    Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-month-btn
    ${left_year}=     Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-year-btn
    ${in_left}=    Evaluate    '${month_from}' in '${left_month} ${left_year}'
    IF    ${in_left}
        Click    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-cell-in-view:not(.ant-picker-cell-disabled) .ant-picker-cell-inner:text-is("${day_from}")
    ELSE
        Click    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:last-of-type .ant-picker-cell-in-view:not(.ant-picker-cell-disabled) .ant-picker-cell-inner:text-is("${day_from}")
    END
    Sleep    0.3s
    # Navigate forward until end month is visible (picker stays open after start date click)
    FOR    ${i}    IN RANGE    24
        ${left_month}=     Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-month-btn
        ${left_year}=      Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-year-btn
        ${right_month}=    Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:last-of-type .ant-picker-month-btn
        ${right_year}=     Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:last-of-type .ant-picker-year-btn
        ${found}=    Evaluate    '${month_to}' in '${left_month} ${left_year}' or '${month_to}' in '${right_month} ${right_year}'
        IF    ${found}    BREAK
        # Navigate backward if the target month is before the current panel, else forward.
        ${go_back}=    Evaluate    __import__('datetime').datetime.strptime('${month_to}', '%b %Y') < __import__('datetime').datetime.strptime('${left_month} ${left_year}', '%b %Y')
        IF    ${go_back}
            Click    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-header-prev-btn >> nth=0
        ELSE
            Click    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-header-super-next-btn >> nth=0
        END
        Sleep    0.3s
    END
    # Click end date in the correct panel
    ${left_month}=    Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-month-btn
    ${left_year}=     Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-year-btn
    ${in_left}=    Evaluate    '${month_to}' in '${left_month} ${left_year}'
    IF    ${in_left}
        Click    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-cell-in-view:not(.ant-picker-cell-disabled) .ant-picker-cell-inner:text-is("${day_to}")
    ELSE
        Click    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:last-of-type .ant-picker-cell-in-view:not(.ant-picker-cell-disabled) .ant-picker-cell-inner:text-is("${day_to}")
    END
    Sleep    0.3s

Verify Txn Dates Within Range
    [Documentation]    Verifies that all visible transaction dates in the Date & Time column
    ...                fall within the specified date range.
    ...                Handles the "DD Mon YYYY\nHH:MM:SS" format displayed in the table.
    [Arguments]        ${date_from}    ${date_to}
    ${result}=    Evaluate JavaScript    ${None}
    ...    () => {
    ...        const months = {Jan:0,Feb:1,Mar:2,Apr:3,May:4,Jun:5,Jul:6,Aug:7,Sep:8,Oct:9,Nov:10,Dec:11};
    ...        const parseBoundaryDate = (str) => {
    ...            const p = str.split('-');
    ...            return new Date(parseInt(p[0]), parseInt(p[1]) - 1, parseInt(p[2]));
    ...        };
    ...        const parseTableDate = (str) => {
    ...            const parts = str.split(' ');
    ...            if (parts.length < 3) return new Date(NaN);
    ...            const day = parseInt(parts[0]);
    ...            const mon = parts[1];
    ...            const yearPart = parts[2].split(String.fromCharCode(10))[0];
    ...            const year = parseInt(yearPart);
    ...            if (isNaN(day) || isNaN(year) || !months.hasOwnProperty(mon)) return new Date(NaN);
    ...            return new Date(year, months[mon], day);
    ...        };
    ...        const dateFrom = parseBoundaryDate('${date_from}');
    ...        const dateTo = parseBoundaryDate('${date_to}');
    ...        dateTo.setHours(23, 59, 59, 999);
    ...        const rows = document.querySelectorAll('.ant-table-body table tbody tr:not([aria-hidden="true"])');
    ...        let total = 0;
    ...        let withinRange = 0;
    ...        let outOfRange = [];
    ...        rows.forEach(row => {
    ...            const cells = row.querySelectorAll('td');
    ...            if (cells.length >= 3) {
    ...                const dateText = cells[2].innerText.trim();
    ...                if (dateText) {
    ...                    total++;
    ...                    const rowDate = parseTableDate(dateText);
    ...                    if (rowDate >= dateFrom && rowDate <= dateTo) {
    ...                        withinRange++;
    ...                    } else {
    ...                        outOfRange.push(dateText);
    ...                    }
    ...                }
    ...            }
    ...        });
    ...        return { total, withinRange, outOfRange };
    ...    }
    Should Be Equal    ${result}[total]    ${result}[withinRange]
    ...    msg=Expected all ${result}[total] transactions to be within date range ${date_from} to ${date_to}, but found ${result}[outOfRange] outside range

Open New Transaction Modal
    [Documentation]    Opens the New Transaction modal from the Transactions page
    ...                and waits for the Customer Information search step to be visible.
    Wait For Elements State    ${NEW_TXN_BTN}               visible
    Click                      ${NEW_TXN_BTN}
    Wait For Elements State    ${CREATE_TXN_MODAL}          visible
    Wait For Elements State    ${CREATE_TXN_SEARCH_INPUT}   visible

Search Account In Create Transaction Modal
    [Documentation]    Types a search term (account number or name) into the Create Transaction
    ...                modal search input and clicks the Search button.
    [Arguments]        ${search_term}
    Fill Text                  ${CREATE_TXN_SEARCH_INPUT}    ${search_term}
    Click                      ${CREATE_TXN_SEARCH_BTN}
    Wait For Load Spinner To Disappear

Select Account From Create Transaction Results
    [Documentation]    Clicks the search result item that contains the given account number,
    ...                then waits for the modal to advance to the Transaction step.
    [Arguments]        ${account_number}
    Wait For Elements State    css=.ant-modal-content [role="button"]:has-text("${account_number}")    visible
    Click                      css=.ant-modal-content [role="button"]:has-text("${account_number}") >> nth=0
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${CREATE_TXN_DEPOSIT_BTN}    visible

Navigate To Deposit Step
    [Documentation]    Navigates from the Transactions page through the New Transaction modal
    ...                all the way to the Deposit form (Step 2 with deposit fields visible).
    ...                Opens modal → searches by account number → selects account → clicks Deposit.
    [Arguments]        ${account_number}=${T43_ACCOUNT_NUMBER}
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${account_number}
    Select Account From Create Transaction Results    ${account_number}
    Click                      ${CREATE_TXN_DEPOSIT_BTN}
    Wait For Elements State    ${CREATE_TXN_TYPE_SELECT}    visible
    Wait For Elements State    ${CREATE_TXN_AMOUNT_INPUT}    visible

Navigate To Withdrawal Step
    [Documentation]    Navigates from the Transactions page through the New Transaction modal
    ...                all the way to the Withdrawal form (Transaction step with withdrawal fields visible).
    ...                Opens modal → searches by account number → selects account → clicks Withdraw.
    [Arguments]        ${account_number}
    Open New Transaction Modal
    Search Account In Create Transaction Modal    ${account_number}
    Select Account From Create Transaction Results    ${account_number}
    Click                      ${CREATE_TXN_WITHDRAWAL_BTN}
    Wait For Elements State    ${CREATE_TXN_TYPE_SELECT}    visible
    Wait For Elements State    ${CREATE_TXN_AMOUNT_INPUT}    visible


Get Transaction Summary Field Value
    [Documentation]    Reads a numeric value from the Transaction Summary panel (or receipt screen)
    ...                by its exact label text (e.g. "Current Balance", "New Balance", "Previous Balance").
    ...                Uses JavaScript to locate the leaf text node matching the label, then reads
    ...                the adjacent value element. Returns a clean numeric string with commas and
    ...                currency symbols stripped (e.g. "8685.00"). Fails if the label is not found.
    [Arguments]        ${label}
    ${value}=    Evaluate JavaScript    ${None}
    ...    () => {
    ...        const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null);
    ...        let node;
    ...        while ((node = walker.nextNode())) {
    ...            const text = node.textContent.trim();
    ...            if (text === '${label}' || text === '${label}:') {
    ...                const el = node.parentElement;
    ...                // Strategy 1: next element sibling of the label element itself
    ...                const nextSib = el.nextElementSibling;
    ...                if (nextSib) {
    ...                    const txt = nextSib.textContent.trim().replace(/[,₱\s]/g, '');
    ...                    if (txt !== '' && !isNaN(parseFloat(txt.replace(/^-/, '')))) return txt;
    ...                }
    ...                // Strategy 2: next sibling of the label's parent (row-level sibling)
    ...                const parent = el.parentElement;
    ...                if (parent && parent.parentElement) {
    ...                    const siblings = Array.from(parent.parentElement.children);
    ...                    const idx = siblings.indexOf(parent);
    ...                    for (let i = idx + 1; i < Math.min(idx + 3, siblings.length); i++) {
    ...                        const txt = siblings[i].textContent.trim().replace(/[,₱\s]/g, '');
    ...                        if (txt !== '' && !isNaN(parseFloat(txt.replace(/^-/, '')))) return txt;
    ...                    }
    ...                }
    ...            }
    ...        }
    ...        return null;
    ...    }
    Should Not Be Equal    ${value}    ${None}
    ...    msg=Could not find Transaction Summary value for label: "${label}"
    RETURN    ${value}

Sum All Account Balances
    [Documentation]    Sums all account Balance column values across all pages of the Accounts table.
    ...                Balance column is at index 2 (Account No, Account Name, Balance, ...).
    ...                Returns the total as a floating-point number.
    ${total}=    Set Variable    ${0}
    WHILE    True
        ${page_sum}=    Evaluate JavaScript    ${None}
        ...    () => {
        ...        const rows = document.querySelectorAll('.ant-table-body table tbody tr:not([aria-hidden="true"])');
        ...        let sum = 0;
        ...        rows.forEach(row => {
        ...            const cells = row.querySelectorAll('td');
        ...            if (cells.length >= 3) {
        ...                const balanceText = cells[2].innerText.trim();
        ...                const num = parseFloat(balanceText.replace(/[₱,\s]/g, ''));
        ...                if (!isNaN(num)) sum += num;
        ...            }
        ...        });
        ...        return Math.round(sum * 100) / 100;
        ...    }
        ${total}=    Evaluate    round(${total} + ${page_sum}, 2)
        ${next_disabled}=    Run Keyword And Return Status
        ...                  Wait For Elements State    css=.ant-pagination-next.ant-pagination-disabled    visible    timeout=1s
        IF    ${next_disabled}    BREAK
        Click    css=.ant-pagination-next button
        Sleep    0.5s
    END
    RETURN    ${total}
