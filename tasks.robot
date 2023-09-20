*** Settings ***
Library             RPA.Browser.Playwright
Library             String
Library             RPA.Excel.Files
Library             DateTime
Library             Collections

Suite Teardown      Close Browser


*** Tasks ***
Web Scraper example
    ${url}=    Get the date and create the URL
    Navigate to the website    ${url}
    Extract the data to an Excel file


*** Keywords ***
Get the date and create the URL
    ${current_date}=    Get Current Date    result_format=%Y-%m-%d
    ${url}=    Set Variable
    ...    https://star.dk/soeg/?q=*&ManualDateFrom=2023-01-01&ManualDateTo=${current_date}&maxResults=1000
    RETURN    ${url}

Navigate to the website
    [Arguments]    ${url}
    New Browser    headless=${False}
    New Page    ${url}
    Click    //button[@id='cc-b-acceptall']

Extract the data to an Excel file
    ${result_elements}=    Get Elements    //ul[@id='SearchResultArea']/li
    Create Workbook    results.xlsx
    FOR    ${result_element}    IN    @{result_elements}
        ${title}=
        ...    Get Text
        ...    ${result_element} >> a >> h2
        ${url}=
        ...    Get Attribute
        ...    ${result_element} >> a
        ...    href
        ${additional_text}=
        ...    Get Text
        ...    ${result_element} >> span.search-module__result-tags
        ${category}=    Get Regexp Matches    ${additional_text}    ^[^\/]*(?= \/ )
        ${sub_category}=    Get Regexp Matches    ${additional_text}    (?<= \/ ).*(?= \/ )
        ${row}=
        ...    Create Dictionary
        ...    Title=${title}
        ...    URL=${url}
        ...    Category=${category}[0]
        ...    SubCategory=${sub_category}
        Append Rows To Worksheet    ${row}    header=${True}
    END
    Save Workbook
