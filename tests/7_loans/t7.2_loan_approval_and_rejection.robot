*** Settings ***
Documentation       t7.2 Loan Approval and Rejection
...                 Covers the Pending Applications review flow: opening the application
...                 detail modal via Approve/Reject row buttons, finalizing approval and
...                 rejection (with mandatory remarks), navigation behavior of Back
...                 buttons, post-approval visibility in the customer profile, and the
...                 separation-of-duties check that the maker cannot decide on their own
...                 application.

Resource            ../../resources/keywords/common.resource
Resource            ../../resources/keywords/customers.resource
Resource            ../../resources/keywords/loans.resource

Suite Setup         Login As Approver And Navigate To Pending Applications
Suite Teardown      Close Browser
Test Setup          Go To Pending Applications
Test Teardown       Close Loan Modals If Open



*** Keywords ***
Login As Approver And Navigate To Pending Applications
    [Documentation]    Logs in as the approver (different from the loan creator so the
    ...                separation-of-duties check does not block normal Approve/Reject)
    ...                and lands on the Pending Applications page.
    Login To Teller App        ${T72_APPROVER_EMAIL}    ${T72_APPROVER_PASSWORD}
    Navigate To Pending Applications Page
    View Pending Applications List

Go To Pending Applications
    [Documentation]    Navigates back to Pending Applications before each test so a previous
    ...                test's modal/page state doesn't leak into the next.
    Navigate To Pending Applications Page
    View Pending Applications List

Close Loan Modals If Open
    [Documentation]    Closes the rejection remarks modal first (if open), then the loan
    ...                application detail modal, so the next test starts clean.
    ${remarks_open}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LOAN_REJECTION_INPUT}    visible    timeout=1s
    IF    ${remarks_open}
        Click    ${LOAN_REJECTION_BACK_BTN}
        Wait For Elements State    ${LOAN_REJECTION_INPUT}    hidden    timeout=5s
    END
    ${modal_open}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LOAN_APP_MODAL_CUSTOMER_FORM}    visible    timeout=1s
    IF    ${modal_open}
        Click    ${LOAN_DETAILS_CLOSE_BTN}
        Wait For Elements State    ${LOAN_APP_MODAL_CUSTOMER_FORM}    hidden    timeout=5s
    END

Open Approve Modal For First Customer Row
    [Documentation]    Searches by customer name and clicks the Approve button on the first
    ...                matching row to open the application detail modal.
    [Arguments]        ${T26_CUSTOMER_NAME}
    Fill Text                    ${PENDING_APPS_SEARCH_INPUT}    ${T26_CUSTOMER_NAME}
    Click                        ${PENDING_APPS_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State
    ...    ${PENDING_APPS_TABLE} >> tbody tr:has-text("${T26_CUSTOMER_NAME}") >> nth=0    visible    timeout=10s
    Click
    ...    ${PENDING_APPS_TABLE} >> tbody tr:has-text("${T26_CUSTOMER_NAME}") >> ${PENDING_APPS_APPROVE_BTN} >> nth=0
    Wait For Elements State      ${LOAN_APP_MODAL_CUSTOMER_FORM}    visible    timeout=10s

Open Reject Modal For First Customer Row
    [Documentation]    Searches by customer name and clicks the Reject button on the first
    ...                matching row to open the application detail modal.
    [Arguments]        ${T26_CUSTOMER_NAME}
    Fill Text                    ${PENDING_APPS_SEARCH_INPUT}    ${T26_CUSTOMER_NAME}
    Click                        ${PENDING_APPS_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    Wait For Elements State
    ...    ${PENDING_APPS_TABLE} >> tbody tr:has-text("${T26_CUSTOMER_NAME}") >> nth=0    visible    timeout=10s
    Click
    ...    ${PENDING_APPS_TABLE} >> tbody tr:has-text("${T26_CUSTOMER_NAME}") >> ${PENDING_APPS_REJECT_BTN} >> nth=0
    Wait For Elements State      ${LOAN_APP_MODAL_CUSTOMER_FORM}    visible    timeout=10s

Verify Application Detail Modal Content
    [Documentation]    Verifies that the application detail modal shows the expected title,
    ...                Customer Form fields, and Customer Details fields.
    # Modal title contains the product name + "Loan Application"
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=${T26_LOANS_PRODUCT} Loan Application    visible

    # Customer Form (left column) — Loan Details fields
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_MODAL_CUSTOMER_FORM}                  visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Loan amount             visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Interest rate           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Loan term length        visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Loan term unit          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Mode of disbursement    visible

    # Customer Details (right column)
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_MODAL_CUSTOMER_DETAILS}                visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Customer Name          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Customer ID            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Email Address          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Mobile Number          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Gender                 visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Civil Status           visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Date of Birth          visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Country of Birth       visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Nationality            visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=TIN                    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=Complete Address       visible

    # Customer name value appears in the modal
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_DETAIL_MODAL} >> text=${T26_CUSTOMER_NAME}    visible


*** Test Cases ***

t7.2.1 Verify Teller can review full application details for a pending loan
    [Documentation]    Open the application detail modal via the Approve row button and
    ...                verify the modal title, Customer Form fields, Customer Details fields,
    ...                and the Approve this application button are all visible. Closing the
    ...                modal via Back leaves the application in Pending status.
    [Tags]             loans    approval    pending_apps    smoke    mvp    type1

    Open Approve Modal For First Customer Row    ${T26_CUSTOMER_NAME}
    Verify Application Detail Modal Content

    # Approve action button is visible and clickable
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_DETAILS_APPROVE_BTN}    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_DETAILS_APPROVE_BTN}    enabled

    # Close via Back — application should remain pending
    Click                        ${LOAN_DETAILS_CLOSE_BTN}
    Wait For Elements State      ${LOAN_APP_MODAL_CUSTOMER_FORM}    hidden    timeout=5s
    Wait For Elements State      ${PENDING_APPS_PAGE}    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    ${PENDING_APPS_TABLE} >> tbody tr:has-text("${T26_CUSTOMER_NAME}") >> nth=0    visible


t7.2.2 Verify Teller can finalize approval by clicking Approve this application
    [Documentation]    Open the application detail modal, click Approve this application,
    ...                verify the modal closes and a success toast appears, and confirm the
    ...                application is moved to Pending Disbursement.
    [Tags]             loans    approval    pending_apps    smoke    mvp    type1

    Open Approve Modal For First Customer Row    ${T26_CUSTOMER_NAME}

    Click                        ${LOAN_DETAILS_APPROVE_BTN}
    Wait For Elements State      ${LOAN_APP_MODAL_CUSTOMER_FORM}    hidden    timeout=15s

    # Changed from 'visible' to 'attached' to capture fast fade-outs safely
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${SUCCESS_TOAST_APPROVED}    attached    timeout=5s

    # The approved loan should appear in Pending Disbursement
    Navigate To Pending Disbursements Page
    View Pending Disbursements List
    Fill Text                    ${PENDING_DISB_SEARCH_INPUT}    ${T26_CUSTOMER_NAME}
    Click                        ${PENDING_DISB_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    ${PENDING_DISB_TABLE} >> tbody tr:has-text("${T26_CUSTOMER_NAME}") >> nth=0    visible    timeout=10s


t7.2.3 Verify Teller can review application details before rejecting a loan
    [Documentation]    Open the application detail modal via the Reject row button and
    ...                verify the modal title, Customer Form fields, Customer Details fields,
    ...                and the Reject this application button are all visible. Closing the
    ...                modal via Back leaves the application in Pending status.
    [Tags]             loans    rejection    pending_apps    smoke    mvp    type1

    Open Reject Modal For First Customer Row    ${T26_CUSTOMER_NAME}
    Verify Application Detail Modal Content

    # Reject action button is visible and clickable
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_DETAILS_REJECT_BTN}    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_DETAILS_REJECT_BTN}    enabled

    # Close via Back — application should remain pending
    Click                        ${LOAN_DETAILS_CLOSE_BTN}
    Wait For Elements State      ${LOAN_APP_MODAL_CUSTOMER_FORM}    hidden    timeout=5s
    Wait For Elements State      ${PENDING_APPS_PAGE}    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    ${PENDING_APPS_TABLE} >> tbody tr:has-text("${T26_CUSTOMER_NAME}") >> nth=0    visible


t7.2.4 Verify mandatory remarks modal appears when rejecting an application
    [Documentation]    Click Reject this application, verify the Add remarks modal opens
    ...                with a remarks textarea, and confirm the Submit & reject button is
    ...                disabled while remarks are empty.
    [Tags]             loans    rejection    validation    type1

    Open Reject Modal For First Customer Row    ${T26_CUSTOMER_NAME}
    Click                        ${LOAN_DETAILS_REJECT_BTN}

    # Add remarks modal opens
    Wait For Elements State      ${LOAN_REJECTION_INPUT}    visible    timeout=10s
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Add remarks for rejection    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Add remarks                  visible

    # Submit button is disabled while remarks are empty
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_REJECTION_SUBMIT_BTN}    disabled


t7.2.5 Verify final rejection and success toast message
    [Documentation]    Enter a valid rejection reason, click Submit & reject, and verify
    ...                the modal closes, a success toast appears, and the record is moved
    ...                to Rejected Applications.
    [Tags]             loans    rejection    pending_apps    smoke    mvp    type1

    Open Reject Modal For First Customer Row    ${T26_CUSTOMER_NAME}
    Click                        ${LOAN_DETAILS_REJECT_BTN}
    Wait For Elements State      ${LOAN_REJECTION_INPUT}    visible    timeout=10s

    Fill Text                    ${LOAN_REJECTION_INPUT}    ${T72_REJECTION_REMARKS}
    Wait For Elements State      ${LOAN_REJECTION_SUBMIT_BTN}    enabled    timeout=5s
    Click                        ${LOAN_REJECTION_SUBMIT_BTN}
    Wait For Elements State      ${LOAN_REJECTION_INPUT}    hidden    timeout=15s

    # Success toast
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${SUCCESS_TOAST_REJECTED}    attached    timeout=5s


    # The rejected loan should appear in Rejected Applications
    Navigate To Rejected Loans Page
    View Rejected Loans List
    Fill Text                    ${REJECTED_APPS_SEARCH_INPUT}    ${T26_CUSTOMER_NAME}
    Click                        ${REJECTED_APPS_SEARCH_BTN}
    Wait For Load Spinner To Disappear
    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    ${REJECTED_APPS_TABLE} >> tbody tr:has-text("${T26_CUSTOMER_NAME}") >> nth=0    visible    timeout=10s


t7.2.6 Verify Rejected Applications page layout and columns
    [Documentation]    Navigate to the Rejected Applications page and verify the search bar
    ...                and the required columns (Customer ID, Customer Name, Loan Name,
    ...                Loan Category, Total Loan Amount, Rejected by, Rejection Remarks)
    ...                are visible.
    [Tags]             loans    rejected_loans    smoke    mvp    type1

    Navigate To Rejected Loans Page
    View Rejected Loans List

    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${REJECTED_APPS_SEARCH_INPUT}    visible
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Customer ID         visible    timeout=3s
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Customer Name       visible    timeout=3s
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Loan Name           visible    timeout=3s
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Loan Category       visible    timeout=3s
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Total Loan Amount   visible    timeout=3s
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Rejected by         visible    timeout=3s
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    text=Rejection Remarks   visible    timeout=3s


t7.2.7 Verify navigation when clicking the Back button in loan modals
    [Documentation]    Verify that Back on the application detail modal returns to Pending
    ...                Applications and that Back on the Add remarks modal returns to the
    ...                previous application detail modal.
    [Tags]             loans    pending_apps    regression    type2

    # 1. Back on application detail modal returns to Pending Applications
    Open Approve Modal For First Customer Row    ${T26_CUSTOMER_NAME}
    Click                        ${LOAN_DETAILS_CLOSE_BTN}
    Wait For Elements State      ${LOAN_APP_MODAL_CUSTOMER_FORM}    hidden    timeout=5s
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${PENDING_APPS_PAGE}    visible

    # 2. Back on Add remarks modal returns to the application detail modal
    Open Reject Modal For First Customer Row    ${T26_CUSTOMER_NAME}
    Click                        ${LOAN_DETAILS_REJECT_BTN}
    Wait For Elements State      ${LOAN_REJECTION_INPUT}    visible    timeout=10s
    Click                        ${LOAN_REJECTION_BACK_BTN}
    Wait For Elements State      ${LOAN_REJECTION_INPUT}    hidden    timeout=5s
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${LOAN_APP_MODAL_CUSTOMER_FORM}    visible


t7.2.8 Verify Teller can view approved loan details in the Customer Profile
    [Documentation]    Verify that an approved loan appears in the customer's Products
    ...                Availed tab with status Active. Relies on at least one previously
    ...                approved loan for ${T26_CUSTOMER_NAME}.
    [Tags]             customers    loans    approval    regression    mvp    type2

    Navigate To Customers
    View Customer Profile        ${T26_CUSTOMER_ID}
    Wait For Load Spinner To Disappear

    Click                        ${PRODUCTS_AVAILED_TAB}
    Wait For Load Spinner To Disappear

    Run Keyword And Continue On Failure
    ...    Wait For Elements State
    ...    css=.ant-table-body tr:has-text("${T26_LOANS_PRODUCT}") >> nth=0    visible    timeout=10s

    # Open See Details for the first matching loan row
    Click
    ...    css=.ant-table-body tr:has-text("${T26_LOANS_PRODUCT}") >> ${SEE_DETAILS_BTN} >> nth=0
    Wait For Elements State      ${AVAILED_PRODUCT_DRAWER}    visible

    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${AVAILED_PRODUCT_DRAWER} >> text=${T26_LOANS_PRODUCT}    visible


    Click                        ${PRODUCT_DETAILS_CLOSE_BTN}
    Wait For Elements State      ${AVAILED_PRODUCT_DRAWER}    hidden


t7.2.9 Verify Separation of Duties – Same Teller Cannot Approve Own Application
    [Documentation]    Log out, log in as the loan creator, attempt to approve a pending
    ...                application for the same customer, and verify the server-side error
    ...                blocks the approval.
    [Tags]             loans    separation_of_duties    negative    regression    type2

    # 1. Cleanly terminate the default Approver session
    Click                        text=Log out
    Wait For Elements State      ${LOGIN_BUTTON}    visible    timeout=10s

    # 2. Authenticate using default teller credentials (no arguments passed)
    Login To Teller App

    Navigate To Pending Applications Page
    View Pending Applications List
    Open Approve Modal For First Customer Row    ${T26_CUSTOMER_NAME}
    Click                        ${LOAN_DETAILS_APPROVE_BTN}

    # FIX: Checked for 'attached' state and removed the broken 'text=' prefix wrapper
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${T72_APPROVE_SAME_USER_ERROR}    attached    timeout=10s

    # FIX: Close the modal manually so the next test case can see the sidebar/header controls
    Click                        ${LOAN_DETAILS_CLOSE_BTN}
    Wait For Elements State      ${LOAN_APP_MODAL_CUSTOMER_FORM}    hidden    timeout=5s


t7.2.10 Verify Separation of Duties – Same Teller Cannot Reject Own Application
    [Documentation]    Forces a fresh page reload to ensure a clean state, authenticates 
    ...                using the default teller credentials configuration, attempts to reject 
    ...                a pending application for the same customer, and verifies the 
    ...                same-user rejection error blocks the action.
    [Tags]             loans    separation_of_duties    negative    regression    type2

    # 1. FIX: Instead of a risky 'Click text=Log out' which can get intercepted, 
    # go directly to the login page link to force a clean, unauthenticated container view.
    Go To                        ${BASE_URL}
    
    # 2. Authenticate cleanly using default teller credentials (no arguments passed)
    Login To Teller App

    # 3. Route to destination targets now that the dashboard is mounted
    Navigate To Pending Applications Page
    View Pending Applications List
    
    # 4. Execute Negative Workflow Action Review
    Open Reject Modal For First Customer Row    ${T26_CUSTOMER_NAME}
    Click                        ${LOAN_DETAILS_REJECT_BTN}
    Wait For Elements State      ${LOAN_REJECTION_INPUT}    visible    timeout=10s

    Fill Text                    ${LOAN_REJECTION_INPUT}    ${T72_REJECTION_REMARKS}
    Wait For Elements State      ${LOAN_REJECTION_SUBMIT_BTN}    enabled    timeout=5s
    Click                        ${LOAN_REJECTION_SUBMIT_BTN}

    # 5. Assert that the server-side validation error displays safely
    Run Keyword And Continue On Failure
    ...    Wait For Elements State    ${T72_REJECT_SAME_USER_ERROR}    attached    timeout=10s

    # 6. Clear modal state on exit so subsequent runs start clean
    [Teardown]    Run Keywords    Click    ${LOAN_DETAILS_CLOSE_BTN}    AND
    ...                           Wait For Elements State    ${LOAN_APP_MODAL_CUSTOMER_FORM}    hidden    timeout=5s