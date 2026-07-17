*** Settings ***
Library     Browser
Resource    common.resource
Resource    ../locators/products_locators.resource


*** Keywords ***
Navigate To Products
    [Documentation]    Navigates to the Products module via the sidebar and waits for the page to load.
    Click                      ${PRODUCTS_MENU}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${PRODUCTS_LIST_PAGE}    visible

Setup Products Page
    [Documentation]    Navigates to the Products module for a clean test state.
    ...                Dismisses any leave page confirmation dialog if present.
    ...                Paces between tests to stay under the backend request rate limit
    ...                (bursts of ~13 requests return HTTP 429 for ~1 hour).
    Sleep    12s
    # Click products menu to navigate (may trigger leave confirmation if on edit page)
    Click    ${PRODUCTS_MENU}
    # Dismiss leave page confirmation if it appears (e.g. after editing a product)
    ${dialog_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LEAVE_PAGE_CONFIRM_MODAL}    visible    timeout=2s
    IF    ${dialog_visible}
        Click    ${LEAVE_PAGE_CONFIRM_BTN}
        Wait For Load Spinner To Disappear
    END
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${PRODUCTS_LIST_PAGE}    visible

Count All Active Product Rows
    [Documentation]    Navigates through all pages of the Active Products table and returns
    ...                the total number of visible rows across all pages.
    ...                Returns to page 1 after counting.
    ${total}=    Set Variable    ${0}
    WHILE    True
        Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE_ROWS} >> nth=0    visible    timeout=10s
        ${page_count}=    Get Element Count    ${ACTIVE_PRODUCTS_TABLE_ROWS}
        ${total}=         Evaluate    ${total} + ${page_count}
        ${on_last_page}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${PRODUCTS_PAGINATION_NEXT_DISABLED}    visible    timeout=2s
        IF    ${on_last_page}    BREAK
        Click    ${PRODUCTS_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
    # Return to page 1 by clicking the first page button
    ${not_on_first_page}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${PRODUCTS_PAGINATION_FIRST}    visible    timeout=2s
    IF    ${not_on_first_page}
        Click    ${PRODUCTS_PAGINATION_FIRST}
        Wait For Load Spinner To Disappear
    END
    RETURN    ${total}

Find Active Product Row
    [Documentation]    Navigates through all pages of the Active Products table until a row
    ...                matching the given product name is found. Fails if not found on any page.
    [Arguments]        ${product_name}
    WHILE    True
        ${found}=    Run Keyword And Return Status
        ...    Wait For Elements State
        ...    css=[data-testid="table-products-active"] tbody tr:has-text("${product_name}") >> nth=0
        ...    visible    timeout=3s
        IF    ${found}    RETURN
        ${next_disabled}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${PRODUCTS_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
        IF    ${next_disabled}
            Fail    Product "${product_name}" not found in Active Products table
        END
        Click    ${PRODUCTS_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
