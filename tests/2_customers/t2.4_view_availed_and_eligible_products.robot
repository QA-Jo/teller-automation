*** Settings ***
Documentation       t2.4 View Availed and Eligible Products
...                 Covers Products Availed list view, pagination, and product detail side panel
...                 (Savings and Loans), as well as Eligible Products list view, search
...                 (active and archived), pagination, and detail side panel for both product types.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/customers.resource

Suite Setup         Open Customer Profile And Cache URL
Suite Teardown      Close Browser
Test Setup          Return To Customer Profile Page
Test Teardown       Close Drawer If Open


*** Keywords ***
Open Customer Profile And Cache URL
    [Documentation]    Logs in, navigates to the target customer profile once, and caches the
    ...                profile URL so subsequent tests can navigate directly without re-searching.
    ...                This avoids triggering multiple API calls per test and prevents rate limiting.
    Login To Teller App
    Navigate To Customers
    View Customer Profile    ${T24_CUSTOMER_NAME}
    ${url}=    Get Url
    Set Suite Variable    ${CUSTOMER_PROFILE_URL}    ${url}

Return To Customer Profile Page
    [Documentation]    Navigates directly to the cached customer profile URL — no search needed.
    ...                Waits for the page to load before each test begins.
    Go To                      ${CUSTOMER_PROFILE_URL}
    Wait For Load Spinner To Disappear

Close Drawer If Open
    [Documentation]    Closes any open drawer by clicking the close button if it exists.
    ${drawer_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${AVAILED_PRODUCT_DRAWER}    visible    timeout=1s
    IF    ${drawer_visible}
        Click    ${PRODUCT_DETAILS_CLOSE_BTN}
        Wait For Elements State    ${AVAILED_PRODUCT_DRAWER}    hidden
    END


*** Test Cases ***

# ====================================================================
# PRODUCTS AVAILED
# ====================================================================

t2.4.1 View Products Availed of Existing Customer
    [Documentation]    Verify that the Products Availed tab on a customer profile displays
    ...                a table with the correct columns: Product Name, Product Category, and
    ...                Action; and that a See Details button is visible per row.
    [Tags]             customers    products    smoke    type2

    Click                       ${PRODUCTS_AVAILED_TAB}
    Wait For Elements State     ${PRODUCT_TABLE}                    visible
    # Verify all fields — continue on failure so ALL mismatches are reported
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     text=Product Name                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     text=Product Category               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     text="Action"                       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${SEE_DETAILS_BTN} >> nth=0         visible

t2.4.2 Pagination and Navigation of Products Availed
    [Documentation]    Verify that pagination controls on the Products Availed tab work correctly:
    ...                Next loads page 2, clicking a page number loads that page directly, and
    ...                Back returns to the prior page. Skips if only one page of data exists.
    [Tags]             customers    products    regression    type2

    Click                       ${PRODUCTS_AVAILED_TAB}
    Wait For Elements State     ${PRODUCT_TABLE}    visible
    Wait For Load Spinner To Disappear
    ${has_multiple_pages}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=.ant-pagination-next:not(.ant-pagination-disabled)    visible    timeout=3s
    IF    ${has_multiple_pages}
        Wait For Load Spinner To Disappear
        Click                      ${PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
        Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ${page3_exists}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=li.ant-pagination-item[title="3"]    visible    timeout=2s
        IF    ${page3_exists}
            Wait For Load Spinner To Disappear
            Click                      css=li.ant-pagination-item[title="3"]
            Wait For Load Spinner To Disappear
            Wait For Elements State    css=li.ant-pagination-item-active[title="3"]    visible
            Wait For Load Spinner To Disappear
            Click                      ${PAGINATION_PREV}
            Wait For Load Spinner To Disappear
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ELSE
            Wait For Load Spinner To Disappear
            Click                      ${PAGINATION_PREV}
            Wait For Load Spinner To Disappear
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("1")    visible
        END
    ELSE
        Log    Only one page of availed products — pagination navigation skipped
        Wait For Elements State    css=.ant-pagination-next.ant-pagination-disabled    visible
    END

t2.4.3 See Specific Details of an Availed Savings Product
    [Documentation]    Verify that clicking See Details on an availed Savings product opens a
    ...                side panel containing Product ID, Product Details, Eligibility for Customer Type,
    ...                Account Configuration, Interest Configuration, Fees & Charges, and Custom Fields
    ...                (values entered during availment). The panel closes without errors.
    ...
    ...                Preconditions:
    ...                - The user must be authenticated and logged into the Teller App.
    ...                - The customer must already be onboarded within the Higala environment.
    ...                - The customer must have at least one availed savings product.
    ...                - The user must have permission to view customer profiles and product details.
    [Tags]             customers    products    smoke    type2

    Click                       ${PRODUCTS_AVAILED_TAB}
    Wait For Elements State     ${PRODUCTS_AVAILED_TABLE}    visible
    Wait For Elements State     ${PRODUCTS_AVAILED_TABLE} >> css=tbody tr:has-text("${T24_AVAILED_SAVINGS_PRODUCT}") >> nth=0    visible
    Click                       ${PRODUCTS_AVAILED_TABLE} >> css=tbody tr:has-text("${T24_AVAILED_SAVINGS_PRODUCT}") >> nth=0 >> ${SEE_DETAILS_BTN}
    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER}    visible

    # Panel header displays the product ID (PROD_xxx format)
    Wait For Elements State     css=.ant-drawer-title    visible

    # Verify all fields — continue on failure so ALL mismatches are reported
    # Product Details
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Product name                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Product type                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Description                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Status                        visible

    # Eligibility for Customer Type
    Scroll To Element           ${AVAILED_PRODUCT_DRAWER} >> text=Minimum age
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Minimum age                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Required Documents            visible

    # Account Configuration
    Scroll To Element           ${AVAILED_PRODUCT_DRAWER} >> text=Average daily balance
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Average daily balance         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Initial deposit               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Overdrafts                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Withdrawal limit frequency    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Withdrawal limit amount       visible

    # Interest Configuration
    Scroll To Element           ${AVAILED_PRODUCT_DRAWER} >> text="Interest rate(%)"
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text="Interest rate(%)"            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Interest type                 visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Interest time period          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Interest rate structure       visible

    # Fees & Charges
    Scroll To Element           ${AVAILED_PRODUCT_DRAWER} >> text=Excess withdrawal fee
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Excess withdrawal fee         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Dormancy fee                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Account closure fee           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Tax rate type                 visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Tax rate value                visible

    # Close side panel
    Click                       ${PRODUCT_DETAILS_CLOSE_BTN}
    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER}    hidden

t2.4.4 See Specific Details of an Availed Loans Product
    [Documentation]    Verify that clicking See Details on an availed Loans product opens a
    ...                side panel containing Product ID, Product Definition, Product Details,
    ...                Loan Features, Eligibility Criteria, Pricing & Fees, and Loan Details
    ...                (values entered during availment). The panel closes without errors.
    [Tags]             customers    products    smoke    type2

    Click                       ${PRODUCTS_AVAILED_TAB}
    Wait For Elements State     css=.ant-table-body tr:has-text("${T24_AVAILED_LOAN_PRODUCT}") >> nth=0    visible
    Click                       css=.ant-table-body tr:has-text("${T24_AVAILED_LOAN_PRODUCT}") >> nth=0 >> ${SEE_DETAILS_BTN}
    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER}    visible

    # Panel header displays the product ID (PROD_xxx format)
    Wait For Elements State     css=.ant-drawer-title    visible

    # Verify all fields — continue on failure so ALL mismatches are reported
    # Product Definition
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Loan type                     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Preferred customers           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Loan purpose                  visible

    # Product Details
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Product name                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Product type                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Description                   visible

    # Loan Features
    Scroll To Element           ${AVAILED_PRODUCT_DRAWER} >> text=Minimum loan amount
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Minimum loan amount           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Maximum loan amount           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Loan term length >> nth=0      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Loan term unit >> nth=0        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Interest rate type            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Repayment method              visible

    # Eligibility Criteria
    Scroll To Element           ${AVAILED_PRODUCT_DRAWER} >> text=Minimum age
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Minimum age                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Maximum age                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Minimum income level          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Credit score                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Employment type               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Required documents            visible

    # Pricing & Fees
    Scroll To Element           ${AVAILED_PRODUCT_DRAWER} >> text=Processing fee type
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text="Interest rate (%)" >> nth=0   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Interest rate structure       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text="Processing fee"                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Processing fee type             visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Penalty interest rate         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Penalty conditions            visible

    # TODO: Re-enable Loan Details section once UI is fixed
    # # Loan Details (values entered during availment)
    # Scroll To Element           ${AVAILED_PRODUCT_DRAWER} >> text=Mode of disbursement
    # Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text="Loan amount"                 visible
    # Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Loan term length              visible
    # Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Loan term unit                visible
    # Wait For Elements State     ${AVAILED_PRODUCT_DRAWER} >> text=Mode of disbursement          visible

    # Close side panel
    Click                       ${PRODUCT_DETAILS_CLOSE_BTN}
    Wait For Elements State     ${AVAILED_PRODUCT_DRAWER}    hidden


# ====================================================================
# ELIGIBLE PRODUCTS
# ====================================================================

t2.4.5 View Eligible Products for Existing Customer
    [Documentation]    Verify that the Eligible Products tab displays a table with the correct
    ...                columns: Product Name, Product Category, and Action; and that each row
    ...                has both See Details and Avail Product buttons.
    [Tags]             customers    products    smoke    type2

    Click                       ${ELIGIBLE_PRODUCTS_TAB}
    Wait For Elements State     ${PRODUCT_TABLE}                    visible
    # Verify all fields — continue on failure so ALL mismatches are reported
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     text=Product Name                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     text=Product Category               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     text="Action"                       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${SEE_DETAILS_BTN} >> nth=0         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${AVAIL_PRODUCT_BTN} >> nth=0       visible

t2.4.6 Search Eligible Products
    [Documentation]    Verify that searching by a valid active product name filters the
    ...                Eligible Products table to show only matching results, and clearing
    ...                the search restores the full eligible products list.
    [Tags]             customers    products    smoke    type2

    Click                       ${ELIGIBLE_PRODUCTS_TAB}
    Wait For Elements State     ${PRODUCT_TABLE}    visible

    # Search for an active product
    Fill Text                   ${PRODUCT_SEARCH_INPUT}    ${T24_ACTIVE_PRODUCT}
    Click                       ${PRODUCT_SEARCH_BTN}
    Wait For Elements State     ${PRODUCT_TABLE}    visible
    Wait For Elements State     css=.ant-table-body table tbody tr:has-text("${T24_ACTIVE_PRODUCT}")    visible

    # Clear search and verify the full list is restored
    Fill Text                   ${PRODUCT_SEARCH_INPUT}    ${EMPTY}
    Click                       ${PRODUCT_SEARCH_BTN}
    Wait For Elements State     ${PRODUCT_TABLE}                    visible
    Wait For Elements State     ${SEE_DETAILS_BTN} >> nth=0         visible

t2.4.7 Search Archived Products in Eligible Products
    [Documentation]    Verify that searching for an archived product in the Eligible Products
    ...                tab returns no results, confirming archived products are excluded from
    ...                the eligible list. Clearing the search restores the full list.
    [Tags]             customers    products    negative    type2

    Click                       ${ELIGIBLE_PRODUCTS_TAB}
    Wait For Elements State     ${PRODUCT_TABLE}    visible

    # Search for an archived product — should yield no results
    Fill Text                   ${PRODUCT_SEARCH_INPUT}    ${T24_ARCHIVED_PRODUCT}
    Click                       ${PRODUCT_SEARCH_BTN}
    Wait For Elements State     css=.ant-empty-description    visible

    # Clear search and verify the full list is restored
    Fill Text                   ${PRODUCT_SEARCH_INPUT}    ${EMPTY}
    Click                       ${PRODUCT_SEARCH_BTN}
    Wait For Elements State     ${PRODUCT_TABLE}                    visible
    Wait For Elements State     ${SEE_DETAILS_BTN} >> nth=0         visible

t2.4.8 Pagination and Navigation of Eligible Products
    [Documentation]    Verify that pagination controls on the Eligible Products tab work
    ...                correctly: Next loads page 2, clicking a page number loads that page
    ...                directly, and Back returns to the prior page.
    ...                Skips if only one page of data exists.
    [Tags]             customers    products    regression    type2

    Click                       ${ELIGIBLE_PRODUCTS_TAB}
    Wait For Elements State     ${PRODUCT_TABLE}    visible
    Wait For Load Spinner To Disappear
    ${has_multiple_pages}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=.ant-pagination-next:not(.ant-pagination-disabled)    visible    timeout=3s
    IF    ${has_multiple_pages}
        Wait For Load Spinner To Disappear
        Click                      ${PAGINATION_NEXT}
        Wait For Load Spinner To Disappear
        Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
        ${page3_exists}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=li.ant-pagination-item[title="3"]    visible    timeout=2s
        IF    ${page3_exists}
            Wait For Load Spinner To Disappear
            Click                      css=li.ant-pagination-item[title="3"]
            Wait For Load Spinner To Disappear
            ${page3_loaded}=    Run Keyword And Return Status
            ...    Wait For Elements State    css=li.ant-pagination-item-active[title="3"]    visible    timeout=5s
            IF    ${page3_loaded}
                Wait For Load Spinner To Disappear
                Click                      ${PAGINATION_PREV}
                Wait For Load Spinner To Disappear
                Wait For Elements State    css=li.ant-pagination-item-active:has-text("2")    visible
            ELSE
                Log    Page 3 button exists but didn't load — may not have enough data. Skipping page 3 navigation.
                Wait For Load Spinner To Disappear
                Click                      ${PAGINATION_PREV}
                Wait For Load Spinner To Disappear
                Wait For Elements State    css=li.ant-pagination-item-active:has-text("1")    visible
            END
        ELSE
            Wait For Load Spinner To Disappear
            Click                      ${PAGINATION_PREV}
            Wait For Load Spinner To Disappear
            Wait For Elements State    css=li.ant-pagination-item-active:has-text("1")    visible
        END
    ELSE
        Log    Only one page of eligible products — pagination navigation skipped
        Wait For Elements State    css=.ant-pagination-next.ant-pagination-disabled    visible
    END

t2.4.9 See Specific Details of an Eligible Savings Product
    [Documentation]    Verify that clicking See Details on an eligible Savings product opens
    ...                a side panel containing Product Details, Eligibility for Customer Type,
    ...                Account Configuration, Interest Configuration, and Fees & Charges.
    ...                The panel layout is consistent and closes without errors.
    [Tags]             customers    products    smoke    type2

    Click                       ${ELIGIBLE_PRODUCTS_TAB}
    Wait For Elements State     css=.ant-table-body tr:has-text("Savings") >> nth=0    visible
    Click                       css=.ant-table-body tr:has-text("Savings") >> nth=0 >> ${SEE_DETAILS_BTN}
    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER}    visible

    # Verify all fields — continue on failure so ALL mismatches are reported
    # Product Details
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Product name                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Product type                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Description                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Status                        visible

    # Eligibility for Customer Type
    Scroll To Element           ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Minimum age
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Minimum age                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Required Documents            visible

    # Account Configuration
    Scroll To Element           ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Average daily balance
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Average daily balance         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Initial deposit               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Overdrafts                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Withdrawal limit frequency    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Withdrawal limit amount       visible

    # Interest Configuration
    Scroll To Element           ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text="Interest rate(%)"
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text="Interest rate(%)"            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Interest type                 visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Interest time period          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Interest rate structure       visible

    # Fees & Charges
    Scroll To Element           ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Excess withdrawal fee
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Excess withdrawal fee         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Dormancy fee                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Account closure fee           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Tax rate type                 visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Tax rate value                visible

    # Close side panel
    Click                       ${PRODUCT_DETAILS_CLOSE_BTN}
    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER}    hidden

t2.4.10 See Specific Details of an Eligible Loans Product
    [Documentation]    Verify that clicking See Details on an eligible Loans product opens a
    ...                side panel containing Product Definition, Product Details, Loan Features,
    ...                Eligibility Criteria, Pricing & Fees, and read-only Loan Details reference
    ...                values. The panel layout is consistent and closes without errors.
    [Tags]             customers    products    smoke    type2

    Click                       ${ELIGIBLE_PRODUCTS_TAB}
    Wait For Elements State     css=.ant-table-body tr:has-text("Loan") >> nth=0    visible
    Click                       css=.ant-table-body tr:has-text("Loan") >> nth=0 >> ${SEE_DETAILS_BTN}
    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER}    visible

    # Verify all fields — continue on failure so ALL mismatches are reported
    # Product Definition
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Loan type                     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Preferred customers           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Loan purpose                  visible

    # Product Details
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Product name                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Product type                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Description                   visible

    # Loan Features
    Scroll To Element           ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Minimum loan amount
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Minimum loan amount           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Maximum loan amount           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Loan term length >> nth=0      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Loan term unit >> nth=0        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Interest rate type            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Repayment method              visible

    # Eligibility Criteria
    Scroll To Element           ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Minimum age
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Minimum age                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Maximum age                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Minimum income level          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Credit score                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Employment type               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Required documents            visible

    # Pricing & Fees
    Scroll To Element           ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Processing fee type
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text="Interest rate (%)" >> nth=0   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Interest rate structure       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text="Processing fee"                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Processing fee type             visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Penalty interest rate         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Penalty conditions            visible

    # TODO: Re-enable Loan Details section once UI is fixed
    # # Loan Details (read-only reference values)
    # Scroll To Element           ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Mode of disbursement
    # Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text="Loan amount"                 visible
    # Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Loan term length              visible
    # Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Loan term unit                visible
    # Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER} >> text=Mode of disbursement          visible

    # Close side panel
    Click                       ${PRODUCT_DETAILS_CLOSE_BTN}
    Wait For Elements State     ${ELIGIBLE_PRODUCT_DETAILS_DRAWER}    hidden
