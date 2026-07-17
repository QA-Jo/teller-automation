*** Settings ***
Documentation       t5.1 View the List of Active Products
...                 Covers initial page load and default view, tab count validation,
...                 viewing product details, editing Savings and Loans products,
...                 and edit form validation for both required fields and invalid input.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/products.resource

Suite Setup         Login To Teller App
Suite Teardown      Close Browser
Test Setup          Setup Products Page
Test Teardown       Close Modal If Open


*** Keywords ***
Navigate To Edit Savings Product
    [Documentation]    Scans all pages of the Active Products table to find the product by name
    ...                and clicks its Edit button. Fails if the product is not found.
    [Arguments]        ${product_name}=${T51_SAVINGS_PRODUCT_NAME}
    ${found}=    Set Variable    ${FALSE}
    WHILE    True
        ${exists}=    Run Keyword And Return Status
        ...    Wait For Elements State
        ...    css=[data-testid="table-products-active"] tbody tr:has-text("${product_name}") >> nth=0
        ...    visible    timeout=2s
        IF    ${exists}
            ${found}=    Set Variable    ${TRUE}
            BREAK
        END
        ${next_disabled}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${PRODUCTS_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
        IF    ${next_disabled}    BREAK
        Click    ${PRODUCTS_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
    Should Be True    ${found}    msg=Product "${product_name}" not found in the Active Products table
    Click
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("${product_name}") [data-testid="btn-products-edit"] >> nth=0
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${EDIT_PRODUCT_PAGE}    visible

Navigate To Edit Loans Product
    [Documentation]    Scans all pages of the Active Products table to find the loans product by name
    ...                and clicks its Edit button. Skips if the product is not found.
    [Arguments]        ${product_name}=${T51_LOANS_PRODUCT_NAME}
    ${found}=    Set Variable    ${FALSE}
    WHILE    True
        ${exists}=    Run Keyword And Return Status
        ...    Wait For Elements State
        ...    css=[data-testid="table-products-active"] tbody tr:has-text("${product_name}") >> nth=0
        ...    visible    timeout=2s
        IF    ${exists}
            ${found}=    Set Variable    ${TRUE}
            BREAK
        END
        ${next_disabled}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${PRODUCTS_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
        IF    ${next_disabled}    BREAK
        Click    ${PRODUCTS_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
    Skip If    not ${found}    No "${product_name}" product available in this environment
    Click
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("${product_name}") [data-testid="btn-products-edit"] >> nth=0
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${EDIT_PRODUCT_PAGE}    visible


*** Test Cases ***
t5.1.1 Initial Load and Active Products View
    [Documentation]    Verify that navigating to the Products module loads the page correctly,
    ...                defaults to the Active Products tab, displays all expected table columns,
    ...                shows "N/A" for rows with no Updated by entry, and shows the correct
    ...                action buttons (View, Edit, Archive) per product row.
    [Tags]             products    active    smoke    mvp    type2
    # Verify Products page and Active tab load by default
    Wait For Elements State    ${PRODUCTS_LIST_PAGE}        visible
    Wait For Elements State    ${ACTIVE_PRODUCTS_TAB}       visible
    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE}     visible
# Verify all expected column headers are present using specific TH selectors
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE} >> th:has-text("Product ID")          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE} >> th:has-text("Product Name")        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE} >> th:has-text("Product Category")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE} >> th:has-text("Created by")          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE} >> th:has-text("Created on")          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE} >> th:text-is("Updated by")           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE} >> th:text-is("Updated on")           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE} >> th:has-text("Action")              visible
    # Verify at least one row shows N/A in Updated by (default when no update has been made)
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("N/A") >> nth=0
    ...    visible
    # Verify action buttons are visible for the first row
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${VIEW_PRODUCT_BTN} >> nth=0      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${EDIT_PRODUCT_BTN} >> nth=0      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${ARCHIVE_PRODUCT_BTN} >> nth=0   visible

t5.1.2 Active Products Tab Number
    [Documentation]    Verify that the count shown in the Active Products tab badge matches
    ...                the total product count displayed in the table pagination summary.
    [Tags]             products    active    smoke    mvp    type2
    Wait For Elements State    ${ACTIVE_PRODUCTS_TAB}    visible
    # Read the count badge from the tab label
    ${tab_text}=    Get Text    ${ACTIVE_PRODUCTS_TAB_BTN}
    ${tab_count}=   Evaluate   int([w for w in '''${tab_text}'''.split() if w.isdigit()][-1])
    Log    Tab badge shows: ${tab_count} active products
    # Count all rows across all pages
    ${total_rows}=    Count All Active Product Rows
    Log    Table total row count: ${total_rows}
    Should Be Equal As Integers    ${total_rows}    ${tab_count}
    ...    msg=Tab badge shows ${tab_count} active products but table has ${total_rows} rows

t5.1.3 Action: View Details of Savings Product
    [Documentation]    Verify that clicking View on a Savings product opens the Product Details
    ...                modal displaying the Product ID, Customer Form column, and all expected
    ...                sections in the Product Configurations column:
    ...                Product Details, Eligibility, Account Configuration,
    ...                Interest Configuration, and Fees & Charges.
    [Tags]             products    active    smoke    mvp    type2
    # Verify a Savings product row exists in the table
    Wait For Elements State
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("Savings") >> nth=0
    ...    visible
    # Click the View action for the first Savings product
    Click
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("Savings") [data-testid="btn-products-view"] >> nth=0
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${PRODUCT_DETAILS_MODAL}    visible
    # Verify the modal top-level structure
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=/PROD_/                 visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-xl:text-is("Customer Form")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Product Configuration   visible
    # Product Details section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Product name            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Product type            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Description")    visible
    # Eligibility for Customer Type section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Minimum age             visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Required documents      visible
    # Account Configuration section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Average daily balance   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Initial deposit         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Overdrafts              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Withdrawal limit frequency    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Withdrawal limit amount       visible
    # Interest Configuration section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Interest rate(%)        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Interest type           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Interest time period    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Interest rate structure    visible
    # Fees & Charges section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Excess withdrawal fee   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Dormancy fee            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Account closure fee     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Tax rate type           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=Tax rate value          visible

t5.1.4 Action: View Details of Loans Product
    [Documentation]    Verify that clicking View on a Loans product opens the Product Details
    ...                modal displaying the Product ID, Customer Form column, and all expected
    ...                sections in the Product Configurations column:
    ...                Product Definition, Product Details, Loan Features, Eligibility Criteria,
    ...                Pricing & Fees, and Loan Details.
    [Tags]             products    active    smoke    mvp    type2
    # Verify a Loan product row exists in the table - skip if not
    ${loan_exists}=    Run Keyword And Return Status
    ...    Wait For Elements State
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("Loan") >> nth=0
    ...    visible    timeout=5s
    Skip If    not ${loan_exists}    No Loan product available in this environment
    # Click the View action for the first Loan product
    Click
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("Loan") [data-testid="btn-products-view"] >> nth=0
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${PRODUCT_DETAILS_MODAL}    visible
    # Verify the modal top-level structure
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> text=/PROD_/                 visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-xl:text-is("Customer Form")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-xl:text-is("Product Configuration")    visible
    # Product Definition section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Loan type")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Preferred customers")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Loan purpose")    visible
    # Product Details section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Product name")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Product type")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Description")    visible
    # Loan Features section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Minimum loan amount")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Maximum loan amount")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Loan term length")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Loan term unit")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Interest rate type")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Repayment method")    visible
    # Eligibility Criteria section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Minimum age")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Maximum age")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Minimum income level")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Credit score")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Employment type")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Required documents")    visible
    # Pricing & Fees section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Interest rate (%)")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Interest rate structure")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Processing fee")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Processing fee type")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Penalty interest rate (%)")    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PRODUCT_DETAILS_MODAL} >> p.text-sm:text-is("Penalty conditions")    visible


# ====================================================================
# EDIT PRODUCT
# ====================================================================

t5.1.5 Edit Active Savings Product – Display Prepopulated Form
    [Documentation]    Verify that clicking Edit on a Savings product opens the Edit Product
    ...                Form page with all existing product fields pre-populated and editable.
    [Tags]             products    active    edit    smoke    mvp    type2
    Navigate To Edit Savings Product    ${T51_SAVINGS_PRODUCT_NAME}
    # Verify the Edit Product page is displayed
    Wait For Elements State    ${EDIT_PRODUCT_PAGE}    visible
    # Verify product name field is pre-populated (not empty)
    ${product_name_value}=    Get Property
    ...    css=[data-testid="page-products-edit"] input[type="text"] >> nth=0
    ...    value
    Should Not Be Empty    ${product_name_value}
    ...    msg=Product name field should be pre-populated but was empty
    # Verify Save Changes button is visible
    Wait For Elements State    ${EDIT_PRODUCT_SAVE_BTN}    visible

t5.1.6 Save Updated Savings Product – Record New Values
    [Documentation]    Verify that modifying a field on a Savings product and clicking
    ...                Save Changes persists the update successfully.
    [Tags]             products    active    edit    smoke    mvp    type2
    
    # 1. Paginate to find the product row and read its current Product ID version
    ${found}=    Set Variable    ${FALSE}
    WHILE    True
        ${exists}=    Run Keyword And Return Status
        ...    Wait For Elements State
        ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_SAVINGS_PRODUCT_NAME}") >> nth=0
        ...    visible    timeout=2s
        IF    ${exists}
            ${found}=    Set Variable    ${TRUE}
            BREAK
        END
        ${next_disabled}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${PRODUCTS_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
        IF    ${next_disabled}    BREAK
        Click    ${PRODUCTS_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
    Should Be True    ${found}    msg=Product "${T51_SAVINGS_PRODUCT_NAME}" not found in the Active Products table

    # 2. Extract current version from the product row
    ${prod_id_text}=    Get Text
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_SAVINGS_PRODUCT_NAME}") td >> nth=0
    ${prod_id_clean}=    Evaluate    '${prod_id_text}'.replace('\\n', '').replace(' ', '')
    ${current_version}=    Evaluate    int('${prod_id_clean}'.split('_')[-1])
    ${expected_version}=   Evaluate    str(${current_version} + 1).zfill(3)
    Log    Target: ${T51_SAVINGS_PRODUCT_NAME} | Version: ${current_version} → Next: _${expected_version}

    # 3. Navigate to the Edit page
    Navigate To Edit Savings Product    ${T51_SAVINGS_PRODUCT_NAME}

    # 4. Update description
    ${timestamp}=    Evaluate    __import__('datetime').datetime.now().strftime('%H%M%S')
    ${new_desc}=     Set Variable    Updated by automation at ${timestamp}
    Fill Text        css=[data-testid="page-products-edit"] textarea >> nth=0    ${new_desc}
    
    # 5. Save
    Wait For Elements State    ${EDIT_PRODUCT_SAVE_BTN}    enabled
    Click                      ${EDIT_PRODUCT_SAVE_BTN}
    Wait For Load Spinner To Disappear

    # 6. Return to list and Verify Version Increment
    ${redirected}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${PRODUCTS_LIST_PAGE}    visible    timeout=5s
    IF    not ${redirected}
        Navigate To Products
    END
    
    # Paginate to find the updated row and verify the new version number
    ${ver_found}=    Set Variable    ${FALSE}
    WHILE    True
        ${ver_exists}=    Run Keyword And Return Status
        ...    Wait For Elements State
        ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_SAVINGS_PRODUCT_NAME}") td:has-text("_${expected_version}")
        ...    visible    timeout=2s
        IF    ${ver_exists}
            ${ver_found}=    Set Variable    ${TRUE}
            BREAK
        END
        ${next_disabled}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${PRODUCTS_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
        IF    ${next_disabled}    BREAK
        Click    ${PRODUCTS_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
    Should Be True    ${ver_found}
    ...    msg=Expected Product ID version "_${expected_version}" not found for "${T51_SAVINGS_PRODUCT_NAME}" after save

t5.1.7 Edit Active Loans Product – Display Prepopulated Form
    [Documentation]    Verify that clicking Edit on a Loans product opens the Edit Product
    ...                Form page with all existing product fields pre-populated and editable.
    [Tags]             products    active    edit    smoke    mvp    type2
    Navigate To Edit Loans Product
    # Verify the Edit Product page is displayed
    Wait For Elements State    ${EDIT_PRODUCT_PAGE}    visible
    # Verify product name field is pre-populated (not empty)
    ${product_name_value}=    Get Property
    ...    css=[data-testid="page-products-edit"] input[type="text"] >> nth=0
    ...    value
    Should Not Be Empty    ${product_name_value}
    ...    msg=Product name field should be pre-populated but was empty
    # Verify Save Changes button is visible
    Wait For Elements State    ${EDIT_PRODUCT_SAVE_BTN}    visible

t5.1.8 Save Updated Loans Product – Record New Values
    [Documentation]    Verify that modifying a field on a Loans product and clicking
    ...                Save Changes persists the update successfully. The Product ID's
    ...                version suffix increments (e.g. _000 → _001) to indicate a new version.
    [Tags]             products    active    edit    smoke    mvp    type2
    # Paginate to find the loans product — skip if not present in this environment
    ${found}=    Set Variable    ${FALSE}
    WHILE    True
        ${exists}=    Run Keyword And Return Status
        ...    Wait For Elements State
        ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_LOANS_PRODUCT_NAME}") >> nth=0
        ...    visible    timeout=2s
        IF    ${exists}
            ${found}=    Set Variable    ${TRUE}
            BREAK
        END
        ${next_disabled}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${PRODUCTS_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
        IF    ${next_disabled}    BREAK
        Click    ${PRODUCTS_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
    Skip If    not ${found}    No "${T51_LOANS_PRODUCT_NAME}" product available in this environment
    # Read the current Product ID and extract version before editing
    ${prod_id_text}=    Get Text
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_LOANS_PRODUCT_NAME}") td >> nth=0
    ${prod_id_clean}=    Evaluate    '${prod_id_text}'.replace('\\n', '').replace(' ', '')
    ${current_version}=    Evaluate    int('${prod_id_clean}'.split('_')[-1])
    ${expected_version}=   Evaluate    str(${current_version} + 1).zfill(3)
    Log    Current version: ${current_version} → expected after save: _${expected_version}
    # Navigate to edit and make a change
    Navigate To Edit Loans Product    ${T51_LOANS_PRODUCT_NAME}
    ${timestamp}=    Evaluate    __import__('datetime').datetime.now().strftime('%H%M%S')
    ${new_desc}=     Set Variable    Updated by automation at ${timestamp}
    Fill Text        css=[data-testid="page-products-edit"] textarea >> nth=0    ${new_desc}
    Wait For Load Spinner To Disappear
    # Save the changes
    Wait For Elements State    ${EDIT_PRODUCT_SAVE_BTN}    enabled
    Click                      ${EDIT_PRODUCT_SAVE_BTN}
    Wait For Load Spinner To Disappear
    # Return to list
    ${redirected}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${PRODUCTS_LIST_PAGE}    visible    timeout=5s
    IF    not ${redirected}
        Navigate To Products
    END
    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE}    visible
    # Paginate to find the updated row and verify the new version number
    ${ver_found}=    Set Variable    ${FALSE}
    WHILE    True
        ${ver_exists}=    Run Keyword And Return Status
        ...    Wait For Elements State
        ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_LOANS_PRODUCT_NAME}") td:has-text("_${expected_version}")
        ...    visible    timeout=2s
        IF    ${ver_exists}
            ${ver_found}=    Set Variable    ${TRUE}
            BREAK
        END
        ${next_disabled}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${PRODUCTS_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
        IF    ${next_disabled}    BREAK
        Click    ${PRODUCTS_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
    Should Be True    ${ver_found}
    ...    msg=Expected Product ID version "_${expected_version}" not found for "${T51_LOANS_PRODUCT_NAME}" after save


# ====================================================================
# EDIT PRODUCT — VALIDATION
# ====================================================================

t5.1.9 Edit Product – Required Field Validation
    [Documentation]    Verify that clearing a required field (e.g. Product Name) on the Edit
    ...                Product Form triggers a validation error and the Save Changes button
    ...                is disabled, preventing the record from being saved.
    [Tags]             products    edit    validation    smoke
    Navigate To Edit Savings Product    ${T51_SAVINGS_PRODUCT_NAME}
    # Clear the product name field (required)
    ${name_input}=    Set Variable
    ...    css=[data-testid="page-products-edit"] input[type="text"] >> nth=0
    Focus    ${name_input}
    Keyboard Key    press    Control+a
    Keyboard Key    press    Backspace
    Wait For Load Spinner To Disappear
    # Verify Save Changes button is disabled after clearing a required field
    Wait For Elements State    ${EDIT_PRODUCT_SAVE_BTN}    disabled    timeout=10s

t5.1.10 Edit Product – Invalid Input Validation
    [Documentation]    Verify that entering invalid values (e.g. letters in a numeric field)
    ...                on the Edit Product Form triggers validation error messages and
    ...                the Save Changes button is disabled/blocked.
    [Tags]             products    edit    validation    regression
    Navigate To Edit Savings Product    ${T51_SAVINGS_PRODUCT_NAME}
    # Enter letters into the first numeric input field (e.g. interest rate)
    ${numeric_input}=    Set Variable
    ...    css=[data-testid="page-products-edit"] .ant-input-number-input >> nth=0
    Focus    ${numeric_input}
    Keyboard Key    press    Control+a
    Fill Text        ${numeric_input}    abc
    Keyboard Key     press    Tab
    Wait For Load Spinner To Disappear
    # Verify Save Changes button is disabled for invalid input
    Wait For Elements State    ${EDIT_PRODUCT_SAVE_BTN}    disabled    timeout=10s

t5.1.11 Edit Product – No Changes Made
    [Documentation]    Verify that the Save Changes button is disabled when no modifications
    ...                have been made on the Edit Product Form, preventing unnecessary saves.
    [Tags]             products    edit    validation    smoke
    Navigate To Edit Savings Product    ${T51_SAVINGS_PRODUCT_NAME}
    # No edits made — Save Changes button must be disabled
    Wait For Elements State    ${EDIT_PRODUCT_SAVE_BTN}    disabled    timeout=10s

t5.1.12 Edit Product – Cancel Edit Without Saving
    [Documentation]    Verify that clicking Back after modifying fields shows a confirmation
    ...                dialog warning the teller that unsaved changes will be lost. Confirming
    ...                discards changes and returns the teller to the previous page.
    [Tags]             products    edit    validation    smoke
    Navigate To Edit Savings Product    ${T51_SAVINGS_PRODUCT_NAME}
    # Make a change to trigger the unsaved-changes guard
    Fill Text    css=[data-testid="page-products-edit"] textarea >> nth=0    unsaved change test
    Wait For Load Spinner To Disappear
    # Click Back to attempt to leave the page
    Click    ${EDIT_PRODUCT_BACK_BTN}
    # Verify the leave-page confirmation dialog appears with the expected message
    Wait For Elements State    ${LEAVE_PAGE_CONFIRM_MODAL}    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    css=.ant-modal-content:has-text("Are you sure you want to leave this page?")
    ...    visible
    # Confirm leaving — changes should be discarded
    Click    ${LEAVE_PAGE_CONFIRM_BTN}
    Wait For Load Spinner To Disappear
    # Verify teller is returned to the Products list (no changes saved)
    Wait For Elements State    ${PRODUCTS_LIST_PAGE}    visible


# ====================================================================
# ARCHIVE PRODUCT
# ====================================================================

t5.1.13 Action: Archive Product – Confirmation Modal Appears
    [Documentation]    Verify that clicking the Archive action on "${T51_ARCHIVE_PRODUCT_NAME}"
    ...                (ID: ${T51_ARCHIVE_PRODUCT_ID}) opens a confirmation modal with the
    ...                correct title ("Archive Product?") and body message.
    [Tags]             products    active    archive    smoke    mvp    type2
    # Paginate through all pages to find the target product by ID
    ${found}=    Set Variable    ${FALSE}
    WHILE    True
        ${exists}=    Run Keyword And Return Status
        ...    Wait For Elements State
        ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_ARCHIVE_PRODUCT_ID}") >> nth=0
        ...    visible    timeout=2s
        IF    ${exists}
            ${found}=    Set Variable    ${TRUE}
            BREAK
        END
        ${next_disabled}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${PRODUCTS_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
        IF    ${next_disabled}    BREAK
        Click    ${PRODUCTS_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
    Skip If    not ${found}    Product "${T51_ARCHIVE_PRODUCT_NAME}" (${T51_ARCHIVE_PRODUCT_ID}) not found in Active Products table
    # Click the Archive button for the target product
    Click
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_ARCHIVE_PRODUCT_ID}") >> nth=0 >> css=[data-testid="btn-products-archive"]
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${PRODUCT_UPDATE_STATUS_MODAL}    visible
    # Verify modal title and body message
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    ${PRODUCT_UPDATE_STATUS_MODAL} >> text=Archive Product?
    ...    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    ${PRODUCT_UPDATE_STATUS_MODAL} >> text=Are you sure you want to archive this product? It will be moved to the archived tab.
    ...    visible
    # Dismiss modal without archiving
    Click    ${ARCHIVE_PRODUCT_CANCEL_BTN}
    Wait For Elements State    ${PRODUCT_UPDATE_STATUS_MODAL}    hidden

t5.1.14 Action: Archive Product – Confirm Archive
    [Documentation]    Verify that confirming the Archive action on "${T51_ARCHIVE_PRODUCT_NAME}"
    ...                (ID: ${T51_ARCHIVE_PRODUCT_ID}) removes it from Active Products and
    ...                moves it to the Archived Products tab.
    [Tags]             products    active    archive    smoke    mvp    type2
    # Paginate through all pages to find the target product by ID
    ${found}=    Set Variable    ${FALSE}
    WHILE    True
        ${exists}=    Run Keyword And Return Status
        ...    Wait For Elements State
        ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_ARCHIVE_PRODUCT_ID}") >> nth=0
        ...    visible    timeout=2s
        IF    ${exists}
            ${found}=    Set Variable    ${TRUE}
            BREAK
        END
        ${next_disabled}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${PRODUCTS_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
        IF    ${next_disabled}    BREAK
        Click    ${PRODUCTS_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
    Skip If    not ${found}    Product "${T51_ARCHIVE_PRODUCT_NAME}" (${T51_ARCHIVE_PRODUCT_ID}) not found in Active Products table
    Log    Archiving product: ${T51_ARCHIVE_PRODUCT_NAME} (${T51_ARCHIVE_PRODUCT_ID})
    # Click the Archive button for the target product
    Click
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_ARCHIVE_PRODUCT_ID}") >> nth=0 >> css=[data-testid="btn-products-archive"]
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${PRODUCT_UPDATE_STATUS_MODAL}    visible
    # Confirm the archive
    Click    ${ARCHIVE_PRODUCT_CONFIRM_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE}    visible
    # Verify the product is no longer in the Active Products table
    Wait For Elements State
    ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_ARCHIVE_PRODUCT_ID}") >> nth=0
    ...    hidden    timeout=10s
    # Switch to Archived tab and verify the product appears there
    Reload
    Wait For Load Spinner To Disappear
    Click    ${ARCHIVED_PRODUCTS_TAB}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${ARCHIVED_PRODUCTS_TABLE}    visible
    Wait For Elements State
    ...    css=[data-testid="table-products-archived"] tbody tr:has-text("${T51_ARCHIVE_PRODUCT_ID}") >> nth=0
    ...    visible    timeout=15s
    ...    message=Product "${T51_ARCHIVE_PRODUCT_NAME}" (${T51_ARCHIVE_PRODUCT_ID}) not found in Archived Products table after archiving
    # Switch back to Active tab and verify the product is no longer there
    Click    ${ACTIVE_PRODUCTS_TAB}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${ACTIVE_PRODUCTS_TABLE}    visible
    ${still_active}=    Set Variable    ${FALSE}
    WHILE    True
        ${exists}=    Run Keyword And Return Status
        ...    Wait For Elements State
        ...    css=[data-testid="table-products-active"] tbody tr:has-text("${T51_ARCHIVE_PRODUCT_ID}") >> nth=0
        ...    visible    timeout=2s
        IF    ${exists}
            ${still_active}=    Set Variable    ${TRUE}
            BREAK
        END
        ${next_disabled}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${PRODUCTS_PAGINATION_NEXT_DISABLED}    visible    timeout=1s
        IF    ${next_disabled}    BREAK
        Click    ${PRODUCTS_PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
    END
    Should Not Be True    ${still_active}
    ...    msg=Product "${T51_ARCHIVE_PRODUCT_NAME}" should not be in the Active Products table after archiving
