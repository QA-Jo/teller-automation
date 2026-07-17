*** Settings ***
Library     Browser
Resource    common.resource
Resource    ../locators/accounts_locators.resource


*** Keywords ***
Navigate To Accounts
    [Documentation]    Navigates to the Accounts module via the sidebar.
    ...                The sidebar click already loads the accounts list, so we do NOT reload
    ...                here — an extra reload doubles the /bank/v1/accounts request rate and
    ...                helps trip the backend's 429 rate limit during a full suite run.
    Click                      ${ACCOUNTS_MENU}
    Wait For Elements State    ${ACCOUNTS_SEARCH_FIELD}    visible
    Get Url                    contains    /accounts
    # Wait for the accounts data to finish loading so tests don't race the transient
    # empty state and read a "No data" placeholder before rows render.
    Wait For Load Spinner To Disappear

Navigate To Account Transactions
    [Documentation]    Navigates to the Transaction History page for a specific account
    ...                by searching for it in the Accounts module and clicking View Transactions.
    [Arguments]        ${account_number}
    Navigate To Accounts
    # Search for the account and wait for its row. The ITG accounts list intermittently
    # renders an empty "No data" table even though the API returns the account, so retry
    # the search (with a reload) a few times to ride out the flaky empty render.
    FOR    ${attempt}    IN RANGE    3
        Fill Text                  ${ACCOUNTS_SEARCH_FIELD}    ${account_number}
        Click                      ${ACCOUNTS_SEARCH_BUTTON}
        Wait For Load Spinner To Disappear
        ${row_found}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=tr.ant-table-row:has-text("${account_number}")    visible    timeout=8s
        IF    ${row_found}    BREAK
        Reload
        Wait For Load Spinner To Disappear
    END
    Click                      css=tr:has-text("${account_number}") >> ${VIEW_ACCOUNT_TRANSACTIONS_LINK}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${ACCT_TXN_SEARCH_FIELD}    visible

Filter Accounts Results Should Contain Only Status
    [Documentation]    Verifies that all visible rows in the accounts table match the expected status,
    ...                or that a "No Data" message is shown if no matching records exist.
    ...                Iterates through all pagination pages to verify each page.
    [Arguments]        ${expected_status}
    Sleep    1s    # Wait for filter to apply
    ${no_data_visible}=    Run Keyword And Return Status
    ...                    Wait For Elements State    ${NO_DATA_MESSAGE}    visible    timeout=3s
    IF    ${no_data_visible}
        Log    No data found for status: ${expected_status}
    ELSE
        ${page}=    Set Variable    1
        WHILE    ${page} <= 100    # Safety limit to prevent infinite loop
            # Wait out any loading spinner before reading rows / clicking pagination —
            # the ant-spin blur overlay intercepts pointer events and detaches rows mid-click.
            Wait For Load Spinner To Disappear
            # After a Next click the table flashes AntD's empty-state placeholder row
            # (<tr class="ant-table-placeholder">…No data…</tr>) in the window between the
            # spinner clearing and the next page painting. Wait for a real data row
            # (.ant-table-row) to settle so we don't read that placeholder — it would be
            # counted as a non-matching row and fail the assertion spuriously.
            ${has_rows}=    Run Keyword And Return Status
            ...    Wait For Elements State    css=.ant-table-body table tbody tr.ant-table-row >> nth=0    visible    timeout=15s
            IF    not ${has_rows}
                # No data rows settled — confirm it is the genuine empty state, then stop.
                Wait For Elements State    ${NO_DATA_MESSAGE}    visible    timeout=3s
                Log    Page ${page}: No data on this page — ending pagination.
                BREAK
            END
            # Count only real AntD data rows; the placeholder row is excluded by the class.
            ${total_rows}=      Get Element Count    css=.ant-table-body table tbody tr.ant-table-row
            ${matching_rows}=   Get Element Count    css=.ant-table-body table tbody tr.ant-table-row:has-text("${expected_status}")
            Should Be Equal    ${total_rows}    ${matching_rows}
            ...    Page ${page}: Expected all ${total_rows} rows to have status "${expected_status}", but only ${matching_rows} matched
            Log    Page ${page}: All ${total_rows} rows contain status "${expected_status}"
            ${next_disabled}=    Run Keyword And Return Status
            ...                  Wait For Elements State    css=.ant-pagination-next.ant-pagination-disabled    visible    timeout=1s
            IF    ${next_disabled}
                Log    Reached last page (page ${page})
                BREAK
            END
            Click    css=.ant-pagination-next button
            Wait For Load Spinner To Disappear    # Wait for the next page to finish loading
            ${page}=    Evaluate    ${page} + 1
        END
    END

Filter Acct Txn Results Should Contain Only Type
    [Documentation]    Verifies that all visible transaction rows match the expected type.
    ...                If data exists, clicks the first row's Eye icon and verifies the detail modal,
    ...                then closes it. If no data, verifies the "No Data" message.
    [Arguments]        ${expected_type}
    Wait For Load Spinner To Disappear
    Sleep    1s    # Wait for filter to apply
    ${no_data_visible}=    Run Keyword And Return Status
    ...                    Wait For Elements State    ${NO_DATA_MESSAGE}    visible    timeout=3s
    IF    ${no_data_visible}
        Log    No data found for type: ${expected_type}
    ELSE
        ${total_rows}=      Get Element Count    css=.ant-table-body table tbody tr:not([aria-hidden="true"]):not(:empty)
        ${matching_rows}=   Get Element Count    css=.ant-table-body table tbody tr:not([aria-hidden="true"]):has-text("${expected_type}")
        Should Be Equal    ${total_rows}    ${matching_rows}
        ...    Expected all ${total_rows} rows to have type "${expected_type}", but only ${matching_rows} matched
        Log    All ${total_rows} rows contain type "${expected_type}"
        Wait For Load Spinner To Disappear
        Click    ${VIEW_TXN_BTN} >> nth=0
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL}                                    visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction ID             visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction Type           visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction Amount         visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Service Fee               visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Remarks                   visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction Status         visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Debit Account Name        visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Credit Account Name       visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Debit Account Number      visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Credit Account Number     visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Created on                visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Updated on                visible
        Click    ${ACCT_TXN_DETAIL_BACK_BTN}
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL}    hidden
    END

Filter Acct Txn Results Should Contain Only Status
    [Documentation]    Verifies that all visible transaction rows match the expected status.
    ...                If data exists, clicks the first row's Eye icon and verifies the detail modal,
    ...                then closes it. If no data, verifies the "No Data" message.
    [Arguments]        ${expected_status}
    Wait For Load Spinner To Disappear
    Sleep    1s    # Wait for filter to apply
    ${no_data_visible}=    Run Keyword And Return Status
    ...                    Wait For Elements State    ${NO_DATA_MESSAGE}    visible    timeout=3s
    IF    ${no_data_visible}
        Log    No data found for status: ${expected_status}
    ELSE
        ${total_rows}=      Get Element Count    css=.ant-table-body table tbody tr:not([aria-hidden="true"]):not(:empty)
        ${matching_rows}=   Get Element Count    css=.ant-table-body table tbody tr:not([aria-hidden="true"]):has-text("${expected_status}")
        Should Be Equal    ${total_rows}    ${matching_rows}
        ...    Expected all ${total_rows} rows to have status "${expected_status}", but only ${matching_rows} matched
        Log    All ${total_rows} rows contain status "${expected_status}"
        Wait For Load Spinner To Disappear
        Click    ${VIEW_TXN_BTN} >> nth=0
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL}                                    visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction ID             visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction Type           visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction Amount         visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Service Fee               visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Remarks                   visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Transaction Status         visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Debit Account Name        visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Credit Account Name       visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Debit Account Number      visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Credit Account Number     visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Created on                visible
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL} >> text=Updated on                visible
        Click    ${ACCT_TXN_DETAIL_BACK_BTN}
        Wait For Elements State    ${ACCT_TXN_DETAIL_MODAL}    hidden
    END

Verify Acct Txn Dates Within Range
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

Select Date Range From AntD Picker
    [Documentation]    Selects a date range from the AntD dual-panel RangePicker.
    ...                Opens the picker ONCE via the Start Date input and clicks both start
    ...                and end dates without reopening. Expects dates in YYYY-MM-DD format.
    ...                Reads .ant-picker-month-btn and .ant-picker-year-btn separately to
    ...                avoid Get Text concatenating them without a space (e.g. "Feb2026").
    [Arguments]    ${date_from}    ${date_to}
    ${day_from}=      Evaluate    str(int('${date_from}'.split('-')[2]))
    ${day_to}=        Evaluate    str(int('${date_to}'.split('-')[2]))
    ${month_from}=    Evaluate    __import__('datetime').datetime(int('${date_from}'.split('-')[0]), int('${date_from}'.split('-')[1]), 1).strftime('%b %Y')
    ${month_to}=      Evaluate    __import__('datetime').datetime(int('${date_to}'.split('-')[0]), int('${date_to}'.split('-')[1]), 1).strftime('%b %Y')
    # Open the range picker by clicking Start Date input only once
    Click    ${DATE_START_INPUT}
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
    # Navigate forward if end month not yet visible (picker stays open after start date click)
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
    # Click end date in the correct panel (picker is still open)
    ${left_month}=    Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-month-btn
    ${left_year}=     Get Text    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-year-btn
    ${in_left}=    Evaluate    '${month_to}' in '${left_month} ${left_year}'
    IF    ${in_left}
        Click    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:first-of-type .ant-picker-cell-in-view:not(.ant-picker-cell-disabled) .ant-picker-cell-inner:text-is("${day_to}")
    ELSE
        Click    css=.ant-picker-dropdown:not(.ant-picker-dropdown-hidden) .ant-picker-panel:last-of-type .ant-picker-cell-in-view:not(.ant-picker-cell-disabled) .ant-picker-cell-inner:text-is("${day_to}")
    END
    Sleep    0.3s
