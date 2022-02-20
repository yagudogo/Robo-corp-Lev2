*** Settings ***
Documentation     Order robots from RobotSpareBin Industries Inc
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.Excel.Files
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Robocorp.Vault

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts
    Close the browser

*** Keywords ***
Open the robot order website
    ${secret}=    Get Secret    credentials
    Open Available Browser    ${secret}[url]

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${f_orders}    Read table from CSV    orders.csv
    [Return]    ${f_orders}

Close the annoying modal
    Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Fill the form
    [Arguments]    ${f_row}
    Select From List By Value    head    ${f_row}[Head]
    Click Element    id-body-${f_row}[Body]
    Input Text    //input[@placeholder='Enter the part number for the legs']    ${f_row}[Legs]
    Input Text    address    ${f_row}[Address]

Preview the robot
    Click Button    preview

Submit the order
    Wait Until Keyword Succeeds    5x    1s    Send order

Send order
    Click Button    order
    Wait Until Page Contains Element    id:order-another

Wait Until Page Contains

Store the receipt as a PDF file
    [Arguments]    ${f_order_number}
    Wait Until Element Is Visible    id:receipt
    ${order_receipt}    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt}    ${OUTPUT_DIR}${/}receipts${/}${f_order_number}.pdf
    [Return]    ${OUTPUT_DIR}${/}receipts${/}${f_order_number}.pdf

Take a screenshot of the robot
    [Arguments]    ${f_order_number}
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}screenshots${/}${f_order_number}.png
    [Return]    ${OUTPUT_DIR}${/}screenshots${/}${f_order_number}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${f_screenshot}    ${f_pdf}
    ${files}    Create List    ${f_pdf}    ${f_screenshot}
    Add Files To PDF    ${files}    ${f_pdf}

Create a ZIP file of the receipts
    ${zip_file_name}    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}receipts
    ...    ${zip_file_name}

Go to order another robot
    Click Element    order-another

Close the browser
    Close Browser
