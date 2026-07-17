*** Settings ***
Documentation       t5.2 View the List of Archived Products
...                 Covers Archived Products tab load and column validation,
...                 pagination across the archived list, tab count badge validation,
...                 and restoring an archived product back to active status.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/products.resource

Suite Setup         Login To Teller App
Suite Teardown      Close Browser
Test Setup          Setup Archived Products Page
Test Teardown       Close Modal If Open


*** Keywords ***
Setup Archived Products Page
    [Documentation]    Navigates to the Products module then switches to the Archived Products tab
    ...                for a clean test state. Navigating to the module always resets to page 1.
    Setup Products Page
    Click    ${ARCHIVED_PRODUCTS_TAB}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE}    visible

Count All Archived Product Rows
    [Documentation]    Navigates through all pages of the Archived Products table and returns
    ...                the total number of visible rows across all pages.
    ...                Returns to page 1 after counting.
    ${total}=    Set Variable    ${0}
    # SPA preserves pagination state across navigation — always reset to page 1 before counting
    ${has_page_1}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${ARCHIVED_PAGINATION_FIRST}    visible    timeout=2s
    IF    ${has_page_1}
        Click    ${ARCHIVED_PAGINATION_FIRST}
        Wait For Load Spinner To Disappear
    END
    WHILE    True
        Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE_ROWS} >> nth=0    visible    timeout=10s
        # AntD transiently adds ant-pagination-disabled during page transitions — poll until stable
        FOR    ${_}    IN RANGE    10
            ${state_a}=    Run Keyword And Return Status
            ...    Wait For Elements State    ${ARCHIVED_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
            Sleep    1s
            ${state_b}=    Run Keyword And Return Status
            ...    Wait For Elements State    ${ARCHIVED_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
            IF    $state_a == $state_b    BREAK
        END
        ${page_count}=    Get Element Count    ${ARCHIVED_PRODUCTS_TABLE_ROWS}
        ${total}=         Evaluate    ${total} + ${page_count}
        IF    ${state_b}    BREAK
        Click    ${ARCHIVED_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
    # Return to page 1 by clicking the first page button
    ${not_on_first_page}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${ARCHIVED_PAGINATION_FIRST}    visible    timeout=2s
    IF    ${not_on_first_page}
        Click    ${ARCHIVED_PAGINATION_FIRST}
        Wait For Load Spinner To Disappear
    END
    RETURN    ${total}


*** Test Cases ***
t5.2.1 View Archived Products List
    [Documentation]    Verify that clicking the Archived Products tab updates the product list
    ...                to display only archived records, and that all expected column headers
    ...                are present and visible: Product ID, Product Name, Product Category,
    ...                Originally Created by, Created at, Deleted by, Deleted on, and Action.
    ...                Also verifies that the Restore action button is visible per row.
    [Tags]             products    archived    smoke    mvp    type2
    # Verify Archived Products table is loaded
    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE}    visible
    # Verify all expected column headers are present
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE} >> text=Product ID              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE} >> text=Product Name            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE} >> text=Product Category        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE} >> text=Originally Created by   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE} >> text=Created at              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE} >> text=Deleted by              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE} >> text=Deleted on              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE} >> text=Action                  visible
    # Verify at least one row is present
    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE_ROWS} >> nth=0    visible
    # Verify the Restore action button is visible for the first row
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${RESTORE_PRODUCT_BTN} >> nth=0    visible

t5.2.2 Pagination: Archived Products Tab
    [Documentation]    Verify that pagination controls on the Archived Products tab work correctly:
    ...                Next navigates to page 2, clicking page 3 directly jumps to page 3,
    ...                and Back returns to page 2. Data integrity is maintained across pages
    ...                with no duplication or missing records. The current page is clearly
    ...                indicated in the UI.
    [Tags]             products    archived    pagination    smoke    mvp    type2

    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE}    visible
    # Step 1: Click Next — expect to land on page 2
    ${next_disabled}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${ARCHIVED_PAGINATION_NEXT_DISABLED}    visible    timeout=2s
    Skip If    ${next_disabled}    Archived Products list has only one page — pagination test skipped
    ${page_1_rows}=    Get Element Count    ${ARCHIVED_PRODUCTS_TABLE_ROWS}
    Click    ${ARCHIVED_PAGINATION_NEXT}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE}    visible
    # Verify page 2 is active in the pagination UI
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    css=.ant-pagination-item-2.ant-pagination-item-active:visible    visible
    ${page_2_rows}=    Get Element Count    ${ARCHIVED_PRODUCTS_TABLE_ROWS}
    Should Be True    ${page_2_rows} > 0
    ...    msg=Page 2 should contain at least one row
    # Step 2: Click page 3 directly — skip if page 3 does not exist
    ${page_3_exists}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${ARCHIVED_PAGINATION_PAGE_3}    visible    timeout=2s
    IF    ${page_3_exists}
        Click    ${ARCHIVED_PAGINATION_PAGE_3}
        Wait For Load Spinner To Disappear
        Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE}    visible
        # Verify page 3 is active in the pagination UI
        Run Keyword And Continue On Failure
        ...    Wait For Elements State    css=.ant-pagination-item-3.ant-pagination-item-active:visible    visible
        ${page_3_rows}=    Get Element Count    ${ARCHIVED_PRODUCTS_TABLE_ROWS}
        Should Be True    ${page_3_rows} > 0
        ...    msg=Page 3 should contain at least one row
        # Step 3: Click Back (Prev) — expect to return to page 2
        Click    ${ARCHIVED_PAGINATION_PREV}
        Wait For Load Spinner To Disappear
        Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE}    visible
        Run Keyword And Continue On Failure
        ...    Wait For Elements State    css=.ant-pagination-item-2.ant-pagination-item-active:visible    visible
        ${back_rows}=    Get Element Count    ${ARCHIVED_PRODUCTS_TABLE_ROWS}
        Should Be Equal As Integers    ${back_rows}    ${page_2_rows}
        ...    msg=Row count after clicking Back should match page 2 row count (${page_2_rows}) but got ${back_rows}
    ELSE
        Log    Page 3 does not exist — skipping page 3 click and Back verification
        # Still verify Back from page 2 returns to page 1
        Click    ${ARCHIVED_PAGINATION_PREV}
        Wait For Load Spinner To Disappear
        Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE}    visible
        Run Keyword And Continue On Failure
        ...    Wait For Elements State    css=.ant-pagination-item-1.ant-pagination-item-active:visible    visible
        ${back_rows}=    Get Element Count    ${ARCHIVED_PRODUCTS_TABLE_ROWS}
        Should Be Equal As Integers    ${back_rows}    ${page_1_rows}
        ...    msg=Row count after clicking Back should match page 1 row count (${page_1_rows}) but got ${back_rows}
    END

t5.2.3 Archived Products Tab Number
    [Documentation]    Verify that the count badge shown in the Archived Products tab matches
    ...                the total product count displayed in the table pagination summary.
    [Tags]             products    archived    smoke    mvp    type2

    Wait For Elements State    ${ARCHIVED_PRODUCTS_TAB_BTN}    visible
    # Read the count badge from the tab label
    ${tab_text}=    Get Text    ${ARCHIVED_PRODUCTS_TAB_BTN}
    ${tab_count}=   Evaluate   int([w for w in '''${tab_text}'''.split() if w.isdigit()][-1])
    Log    Tab badge shows: ${tab_count} archived products
    # Count all rows across all pages
    ${total_rows}=    Count All Archived Product Rows
    Log    Table total row count: ${total_rows}
    Should Be Equal As Integers    ${total_rows}    ${tab_count}
    ...    msg=Tab badge shows ${tab_count} archived products but table has ${total_rows} rows

t5.2.4 Restore Product
    [Documentation]    Verify that clicking Restore on an archived product opens a confirmation
    ...                modal ("Restore Product?"), confirming removes it from the Archived Products
    ...                list, and it reappears under the Active Products tab.
    [Tags]             products    archived    restore    smoke    mvp    type2
    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE}    visible
    # Verify at least one archived product is available to restore
    ${has_rows}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE_ROWS} >> nth=0    visible    timeout=5s
    Skip If    not ${has_rows}    No archived products available to restore
    # Capture the product name before restoring (second column)
    ${product_name_raw}=    Get Text
    ...    ${ARCHIVED_PRODUCTS_TABLE_ROWS} >> nth=0 >> css=td >> nth=1
    ${product_name}=    Evaluate    '''${product_name_raw}'''.split('\\n')[0].strip()
    Log    Restoring product: ${product_name}
    # Click the Restore button for the first archived product
    Click    ${RESTORE_PRODUCT_BTN} >> nth=0
    Wait For Load Spinner To Disappear
    # Verify the Restore confirmation modal appears with correct title and message
    Wait For Elements State    ${PRODUCT_UPDATE_STATUS_MODAL}    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    ${PRODUCT_UPDATE_STATUS_MODAL} >> text=Restore Product?
    ...    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    ${PRODUCT_UPDATE_STATUS_MODAL} >> text=Are you sure you want to restore this product to active status?
    ...    visible
    # Confirm the restore
    Click    ${RESTORE_PRODUCT_CONFIRM_BTN}
    Wait For Load Spinner To Disappear
    Reload
    Wait For Load Spinner To Disappear
    Click    ${ARCHIVED_PRODUCTS_TAB}
    Wait For Load Spinner To Disappear
    # Verify the product is no longer in the Archived Products table
    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE}    visible
    Wait For Elements State
    ...    css=[data-testid="table-products-archived"] tbody tr:has-text("${product_name}") >> nth=0
    ...    hidden    timeout=15s
    ...    message=Product "${product_name}" should have been removed from the Archived Products table after restoring
    # Verify the restored product now appears in the Active Products tab
    Click    ${ACTIVE_PRODUCTS_TAB}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE}    visible
    Wait For Elements State
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("${product_name}") >> nth=0
    ...    visible
