*** Settings ***
Documentation       t3.1 View the List of Accounts
...                 Covers initial load, pagination, search by account number and name,
...                 search for non-existing account, and status filtering.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/accounts.resource

Suite Setup         Login To Teller App
Suite Teardown      Close Browser
Test Setup          Reload


*** Variables ***
${NON_EXISTING_ACCOUNT}     NONEXISTENTACC
${EXPECTED_STATUS}          Active
${ACCOUNT_ROW}              css=table tbody tr:has-text("${VALID_ACCOUNT_NUMBER}")


*** Test Cases ***
t3.1.1 Initial Load and View of All Accounts List
    [Documentation]    Verify that navigating to the Accounts module displays the accounts list
    ...                with all required columns and the View Account Transactions action link visible.
    [Tags]             accounts    smoke    mvp    type1
    Navigate To Accounts
    # Verify all fields — continue on failure so ALL mismatches are reported
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account No                                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Name                                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Balance                                       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Status                                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Created on                                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text="Action"                                      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${VIEW_ACCOUNT_TRANSACTIONS_LINK} >> nth=0         visible

t3.1.2 Pagination and Navigation on Accounts List
    [Documentation]    Verify that pagination controls work correctly:
    ...                Next loads page 2, clicking page 3 loads page 3,
    ...                and Back returns to page 2.
    ...                Skipped when the accounts list has only one page.
    [Tags]             accounts    mvp    type1    pagination    smoke
    Navigate To Accounts
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
        Log    Only one page of accounts — pagination navigation skipped
        Wait For Elements State    ${PAGINATION_NEXT}    disabled
    END

t3.1.3 Search for Account by Number (Valid)
    [Documentation]    Verify that searching by a valid Account Number returns exactly one record
    ...                and all required columns are visible in the results.
    [Tags]             accounts    smoke    mvp    type1
    Navigate To Accounts
    Fill Text                  ${ACCOUNTS_SEARCH_FIELD}    ${VALID_ACCOUNT_NUMBER}
    Click                      ${ACCOUNTS_SEARCH_BUTTON}
    Wait For Load Spinner To Disappear
    Wait For Elements State    css=table tbody tr:not([aria-hidden="true"])    visible
    Get Element Count          css=table tbody tr:not([aria-hidden="true"])    ==    1
    # Verify all fields — continue on failure so ALL mismatches are reported
    # Verify required columns are visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account No                                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Name                                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Balance                                       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Status                                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Created on                                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text="Action"                                      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${VIEW_ACCOUNT_TRANSACTIONS_LINK}                  visible
    # Verify the specific account row values
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCOUNT_ROW} >> text=${VALID_ACCOUNT_NUMBER}     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCOUNT_ROW} >> text=${EXPECTED_ACCOUNT_NAME}    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCOUNT_ROW} >> text=${EXPECTED_BALANCE}         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCOUNT_ROW} >> text=${EXPECTED_STATUS}          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACCOUNT_ROW} >> text=${EXPECTED_CREATED_ON}      visible
    # Clear search and verify list reloads
    Fill Text                  ${ACCOUNTS_SEARCH_FIELD}    ${EMPTY}
    Click                      ${ACCOUNTS_SEARCH_BUTTON}
    Wait For Elements State    ${ACCOUNTS_SEARCH_FIELD}    visible

t3.1.4 Search for Account by Name (Valid)
    [Documentation]    Verify that searching by a valid Account Name returns matching records.
    ...                All visible results should contain the searched name.
    [Tags]             accounts    smoke    mvp    type1
    Navigate To Accounts
    Fill Text                  ${ACCOUNTS_SEARCH_FIELD}    ${VALID_ACCOUNT_NAME}
    Click                      ${ACCOUNTS_SEARCH_BUTTON}
    Wait For Load Spinner To Disappear
    # Verify at least one result row is visible
    Wait For Elements State    css=.ant-table-body table tbody tr:not([aria-hidden="true"]) >> nth=0    visible
    # Verify all visible rows contain the searched name
    ${total_rows}=             Get Element Count    css=.ant-table-body table tbody tr:not([aria-hidden="true"])
    ${matching_rows}=          Get Element Count    css=.ant-table-body table tbody tr:not([aria-hidden="true"]):has-text("${VALID_ACCOUNT_NAME}")
    Should Be Equal            ${total_rows}    ${matching_rows}
    ...    msg=Expected all ${total_rows} rows to contain "${VALID_ACCOUNT_NAME}", but only ${matching_rows} matched
    # Verify all fields — continue on failure so ALL mismatches are reported
    # Verify required column headers are visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account No                                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Name                                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Balance                                       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Account Status                                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Created on                                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text="Action"                                      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${VIEW_ACCOUNT_TRANSACTIONS_LINK} >> nth=0         visible
    # Clear search and verify list reloads
    Fill Text                  ${ACCOUNTS_SEARCH_FIELD}    ${EMPTY}
    Click                      ${ACCOUNTS_SEARCH_BUTTON}
    Wait For Elements State    ${ACCOUNTS_SEARCH_FIELD}    visible

t3.1.5 Search for Non-Existing Account
    [Documentation]    Verify that searching for a non-existing account value shows a "No Data" message
    ...                with an empty table and no application errors.
    [Tags]             accounts    negative    mvp    type1
    Navigate To Accounts
    Fill Text                  ${ACCOUNTS_SEARCH_FIELD}    ${NON_EXISTING_ACCOUNT}
    Click                      ${ACCOUNTS_SEARCH_BUTTON}
    Wait For Load Spinner To Disappear
    Wait For Elements State    css=.ant-empty-description:has-text("No data")    visible
    Wait For Elements State    ${ACCOUNTS_TABLE}                                 visible

t3.1.6 Filter Accounts List by Status: Active
    [Documentation]    Verify that filtering by Active status shows only Active accounts.
    ...                If no Active accounts exist, a "No Data" message is shown.
    [Tags]             accounts    smoke    mvp    type1
    Navigate To Accounts
    Click                      ${ACCOUNT_STATUS_FILTER}
    Click                      ${FILTER_OPTION_ACTIVE}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCOUNTS_TABLE}           visible
    Filter Accounts Results Should Contain Only Status    Active


t3.1.7 Filter Accounts List by Status: Dormant
    [Documentation]    Verify that filtering by Dormant status shows only Dormant accounts.
    ...                If no Dormant accounts exist, a "No Data" message is shown.
    [Tags]             accounts    smoke    mvp    type1
    Navigate To Accounts
    Click                      ${ACCOUNT_STATUS_FILTER}
    Click                      ${FILTER_OPTION_DORMANT}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCOUNTS_TABLE}           visible
    Filter Accounts Results Should Contain Only Status    Dormant

t3.1.8 Filter Accounts List by Status: Frozen
    [Documentation]    Verify that filtering by Frozen status shows only Frozen accounts.
    ...                If no Frozen accounts exist, a "No Data" message is shown.
    [Tags]             accounts    smoke    mvp    type1
    Navigate To Accounts
    Click                      ${ACCOUNT_STATUS_FILTER}
    Click                      ${FILTER_OPTION_FROZEN}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCOUNTS_TABLE}           visible
    Filter Accounts Results Should Contain Only Status    Frozen

t3.1.9 Filter Accounts List by Status: Closed
    [Documentation]    Verify that filtering by Closed status shows only Closed accounts.
    ...                If no Closed accounts exist, a "No Data" message is shown.
    [Tags]             accounts    smoke    mvp    type1
    Navigate To Accounts
    Click                      ${ACCOUNT_STATUS_FILTER}
    Click                      ${FILTER_OPTION_CLOSED}
    Click                      ${FILTER_APPLY_BTN}
    Wait For Elements State    ${ACCOUNTS_TABLE}           visible
    Filter Accounts Results Should Contain Only Status    Closed

