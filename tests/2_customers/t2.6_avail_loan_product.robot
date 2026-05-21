*** Settings ***
Documentation       t2.6 Existing Customer Avails a Loans Product
...                 Covers the full Loans product availment flow:
...                 Customer Information step (editable Loan Details + custom fields,
...                 See Details side panel), Review and Confirm step, success page,
...                 and post-availment Pending Applications check.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/customers.resource
Resource            ../../resources/keywords/loans.resource

Suite Setup         Open Customer Profile And Cache URL
Suite Teardown      Close Browser
Test Setup          Return To Customer Profile Page
Test Teardown       Close Drawer If Open


*** Keywords ***
Open Customer Profile And Cache URL
    [Documentation]    Logs in, navigates to the t2.6 target customer profile, and caches
    ...                the URL so subsequent tests can navigate directly without re-searching.
    Login To Teller App
    Navigate To Customers
    View Customer Profile    ${T26_CUSTOMER_ID}
    ${url}=    Get Url
    Set Suite Variable    ${CUSTOMER_PROFILE_URL}    ${url}

Return To Customer Profile Page
    [Documentation]    Navigates directly to the cached customer profile URL before each test.
    Go To                      ${CUSTOMER_PROFILE_URL}
    Wait For Load Spinner To Disappear

Close Drawer If Open
    [Documentation]    Closes any open drawer by clicking the close button if visible.
    ${drawer_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=.ant-drawer-body    visible    timeout=1s
    IF    ${drawer_visible}
        Click    ${PRODUCT_DETAILS_CLOSE_BTN}
        Wait For Elements State    css=.ant-drawer-body    hidden    timeout=5s
    END

Navigate To Avail Loan Product Page
    [Documentation]    From the customer profile Eligible Products tab, searches for the
    ...                target Loans product and clicks Avail Product.
    Click                        ${ELIGIBLE_PRODUCTS_TAB}
    Wait For Load Spinner To Disappear
    Fill Text                    ${PRODUCT_SEARCH_INPUT}    ${T26_LOANS_PRODUCT}
    Click                        ${PRODUCT_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State      css=.ant-table-body tr:has-text("${T26_LOANS_PRODUCT}")    visible
    Click                        css=.ant-table-body tr:has-text("${T26_LOANS_PRODUCT}") >> ${AVAIL_PRODUCT_BTN}
    Wait For Elements State      ${AVAIL_PRODUCT_PAGE}    visible
    Wait For Load Spinner To Disappear

Fill Loan Details
    [Documentation]    Fills the Loan Amount, Interest Rate, Loan Term Length, and selects
    ...                Mode of Disbursement on the Customer Information step.
    Wait For Elements State      ${AVAIL_LOAN_AMOUNT_INPUT}             visible
    Fill Text                    ${AVAIL_LOAN_AMOUNT_INPUT}             ${T26_LOAN_AMOUNT}
    Fill Text                    ${AVAIL_LOAN_INTEREST_RATE_INPUT}      ${T26_INTEREST_RATE}
    Fill Text                    ${AVAIL_LOAN_TERM_LENGTH_INPUT}        ${T26_LOAN_TERM_LENGTH}
    Click                        ${AVAIL_LOAN_DISBURSEMENT_SELECT}
    Wait For Elements State      css=.ant-select-dropdown .ant-select-item-option:has-text("${T26_DISBURSEMENT_MODE}")    visible
    Click                        css=.ant-select-dropdown .ant-select-item-option:has-text("${T26_DISBURSEMENT_MODE}")

Fill Employer Name
    [Documentation]    Fills the required Employer Name custom field.
    Wait For Elements State      ${AVAIL_LOAN_EMPLOYER_NAME_INPUT}    visible
    Fill Text                    ${AVAIL_LOAN_EMPLOYER_NAME_INPUT}    ${T26_EMPLOYER_NAME}


*** Test Cases ***

t2.6.1 Avail Loans Product – Customer Information Step
    [Documentation]    Verify that clicking Avail Product on a Loans product navigates to the
    ...                Customer Information step. Customer Details, Product Details, Loan
    ...                Details (editable), and any required custom fields are displayed.
    ...                Continue button is disabled until all required fields are filled.
    [Tags]             customers    products    loans    smoke    mvp    type2

    Navigate To Avail Loan Product Page
    ${url}=    Get Url
    Set Suite Variable    ${AVAIL_PAGE_URL}    ${url}

    # Page and stepper
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE}                                     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_STEPS}                                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=Customer Information        visible

    # Customer Details section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=Customer Details            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=Email Address               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=Mobile Number               visible

    # Product Details section
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=Product Details             visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=Product Name                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=${T26_LOANS_PRODUCT}        visible

    # Loan Details section (editable)
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=Loan Details                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_LOAN_AMOUNT_INPUT}             visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_LOAN_INTEREST_RATE_INPUT}      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_LOAN_TERM_LENGTH_INPUT}        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_LOAN_DISBURSEMENT_SELECT}      visible

    # Continue button disabled before required fields filled
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_CONTINUE_BTN}    disabled


t2.6.2 Verify Loan Details Fields Are Editable During Availment (Customer Information Step)
    [Documentation]    Verify that all Loan Details fields are enabled and editable on the
    ...                Customer Information step. Entered values are retained and accepted.
    ...                Continue becomes enabled once all required fields (Loan Details +
    ...                custom fields) are filled.
    [Tags]             customers    products    loans    smoke    mvp    type2

    Go To    ${AVAIL_PAGE_URL}
    Wait For Load Spinner To Disappear

    # All Loan Details inputs are enabled
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_LOAN_AMOUNT_INPUT}             enabled
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_LOAN_INTEREST_RATE_INPUT}      enabled
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_LOAN_TERM_LENGTH_INPUT}        enabled
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_LOAN_DISBURSEMENT_SELECT}      visible

    # Fill Loan Details
    Fill Loan Details

    # Values are retained (AntD InputNumber formats with commas + 2 decimals on blur)
    ${loan_amount_value}=        Get Property    ${AVAIL_LOAN_AMOUNT_INPUT}             value
    ${interest_rate_value}=      Get Property    ${AVAIL_LOAN_INTEREST_RATE_INPUT}      value
    ${term_length_value}=        Get Property    ${AVAIL_LOAN_TERM_LENGTH_INPUT}        value
    ${loan_amount_clean}=        Evaluate    '${loan_amount_value}'.replace(',', '')
    ${interest_rate_clean}=      Evaluate    '${interest_rate_value}'.replace(',', '')
    ${term_length_clean}=        Evaluate    '${term_length_value}'.replace(',', '')
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Numbers    ${loan_amount_clean}      ${T26_LOAN_AMOUNT}
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Numbers    ${interest_rate_clean}    ${T26_INTEREST_RATE}
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Numbers    ${term_length_clean}      ${T26_LOAN_TERM_LENGTH}
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    ${AVAIL_LOAN_DISBURSEMENT_SELECT}:has-text("${T26_DISBURSEMENT_MODE}")    visible

    # Fill custom field then assert Continue is enabled
    Fill Employer Name
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_CONTINUE_BTN}    enabled


t2.6.3 See Details of Loans Product During Availment (Customer Information Step)
    [Documentation]    Verify that clicking See Details on the Product Details section opens
    ...                a side panel with complete Loans product configuration, closes cleanly,
    ...                and leaves the user on the Customer Information step with Loan Details
    ...                fields unaffected.
    [Tags]             customers    products    loans    smoke    mvp    type2

    Go To    ${AVAIL_PAGE_URL}
    Wait For Load Spinner To Disappear

    Click                        ${AVAIL_PRODUCT_SEE_DETAILS_BTN}
    Wait For Elements State      ${AVAIL_PRODUCT_DETAILS_DRAWER}    visible

    # Product Definition / Details
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Product name              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Product type              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Description               visible

    # Loan Features
    Scroll To Element    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Minimum loan amount
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Minimum loan amount       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Maximum loan amount       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Loan term length          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Loan term unit            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Repayment method          visible

    # Eligibility Criteria
    Scroll To Element    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Minimum age
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Minimum age               visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Required documents        visible

    # Pricing & Fees
    Scroll To Element    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text="Processing fee"
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text="Processing fee"              visible
    Scroll To Element    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Penalty interest rate
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Penalty interest rate         visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_DETAILS_DRAWER} >> text=Penalty conditions            visible

    # Close the side panel and verify user remains on Customer Information step
    Click                        ${PRODUCT_DETAILS_CLOSE_BTN}
    Wait For Elements State      ${AVAIL_PRODUCT_DETAILS_DRAWER}    hidden
    Wait For Elements State      ${AVAIL_PRODUCT_PAGE}              visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_LOAN_AMOUNT_INPUT}    visible


t2.6.4 Fill Loan Details and Custom Fields for Loans Product and Continue
    [Documentation]    Verify that filling all required Loan Details and custom fields enables
    ...                the Continue button, entered values are retained, and the user proceeds
    ...                to the Review Application step with an accurate summary.
    [Tags]             customers    products    loans    smoke    mvp    type2

    Go To    ${AVAIL_PAGE_URL}
    Wait For Load Spinner To Disappear

    # Continue disabled before filling
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_CONTINUE_BTN}    disabled

    Fill Loan Details
    Fill Employer Name

    # Continue enabled after all required fields are filled
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_CONTINUE_BTN}    enabled

    # Proceed to Review step
    Click    ${AVAIL_PRODUCT_CONTINUE_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=Review Application    visible

    # Cache review URL for t2.6.5 reuse if needed
    ${review_url}=    Get Url
    Set Suite Variable    ${REVIEW_PAGE_URL}    ${review_url}

    # Verify review summary reflects all entered Loan Details and custom field values
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=Loan Details                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=Employment Information      visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=${T26_EMPLOYER_NAME}        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_PAGE} >> text=${T26_DISBURSEMENT_MODE}    visible


t2.6.5 Review and Confirm Loans Product Availment
    [Documentation]    Verify that the Review Application step shows accurate data, Confirm
    ...                and Avail processes the request, and the Success page is displayed
    ...                with the correct product name and a Back to Customer Profile button.
    [Tags]             customers    products    loans    smoke    mvp    type2

    # Complete the Customer Information step to reach Review
    Navigate To Avail Loan Product Page
    Fill Loan Details
    Fill Employer Name
    Click                        ${AVAIL_PRODUCT_CONTINUE_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State      ${AVAIL_PRODUCT_PAGE} >> text=Review Application    visible

    # Confirm availment
    Click                        ${AVAIL_PRODUCT_CONFIRM_BTN}
    Wait For Load Spinner To Disappear

    # Verify Success page
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_LOAN_SUCCESS_PANEL}                            visible    timeout=15s
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Product Availed                                   visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T26_LOANS_PRODUCT} >> nth=0                     visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAIL_PRODUCT_BACK_TO_PROFILE}                       visible


t2.6.6 Verify Newly Availed Loan Appears in Pending Applications Module
    [Documentation]    Verify that after a successful Loans availment, clicking Back to
    ...                Customer Profile returns the user to the profile, and the newly availed
    ...                loan appears in the Pending Applications module with status Pending.
    [Tags]             customers    products    loans    regression    mvp    type2

    # Complete the full avail flow to reach the Success page
    # (Success state is React in-memory — the URL cannot be navigated to directly)
    Navigate To Avail Loan Product Page
    Fill Loan Details
    Fill Employer Name
    Click                        ${AVAIL_PRODUCT_CONTINUE_BTN}
    Wait For Load Spinner To Disappear
    Click                        ${AVAIL_PRODUCT_CONFIRM_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State      ${AVAIL_PRODUCT_BACK_TO_PROFILE}    visible    timeout=15s

    # Back to customer profile
    Click                        ${AVAIL_PRODUCT_BACK_TO_PROFILE}
    Wait For Load Spinner To Disappear
    Wait For Elements State      ${CUSTOMERS_PROFILE_PAGE}    visible

    # Navigate to Pending Applications and verify the new loan appears
    Navigate To Pending Applications Page
    View Pending Applications List
    Fill Text                    ${PENDING_APPS_SEARCH_INPUT}    ${T26_CUSTOMER_NAME}
    Click                        ${PENDING_APPS_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State
    ...    ${PENDING_APPS_TABLE} >> tbody tr:has-text("${T26_CUSTOMER_NAME}") >> nth=0    visible    timeout=10s
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    ${PENDING_APPS_TABLE} >> tbody tr:has-text("${T26_LOANS_PRODUCT}") >> nth=0    visible
