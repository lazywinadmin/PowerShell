<#
https://lazywinadmin.com/2014/03/powershell-read-excel-file-using-com.html
#>
[cmdletbinding()]
PARAM (
    [Parameter(Mandatory,
        HelpMessage = "You must specify the full path of the file")]
    [ValidateScript( { Test-Path -Path $_ })]
    $Path,
    [Parameter(Mandatory,
        HelpMessage = "You must specify the SheetName of the Excel file")]
    $Sheet)

#Specify the path of the excel file
$FilePath = $path

#Specify the Sheet name
$SheetName = $Sheet

# Create an Object Excel.Application using Com interface
$objExcel = New-Object -ComObject Excel.Application
# Disable the 'visible' property so the document won't open in excel
$objExcel.Visible = $false
# Open the Excel file and save it in $WorkBook
$WorkBook = $objExcel.Workbooks.Open($FilePath)
# Load the WorkSheet 'BuildSpecs'
$WorkSheet = $WorkBook.sheets.item($SheetName)

[pscustomobject][ordered]@{
    ComputerName      = $WorkSheet.Range("C3").Text
    Project           = $WorkSheet.Range("C4").Text
    Ticket            = $WorkSheet.Range("C5").Text
    Role              = $WorkSheet.Range("C8").Text
    RoleType          = $WorkSheet.Range("C9").Text
    Environment       = $WorkSheet.Range("C10").Text
    Manufacturer      = $WorkSheet.Range("C12").Text
    SiteCode          = $WorkSheet.Range("C15").Text
    isDMZ             = $WorkSheet.Range("C16").Text
    OperatingSystem   = $WorkSheet.Range("C18").Text
    ServicePack       = $WorkSheet.Range("C19").Text
    OSKey             = $WorkSheet.Range("C20").Text
    Owner             = $WorkSheet.Range("C22").Text
    MaintenanceWindow = $WorkSheet.Range("C23").Text
    NbOfProcessor     = $WorkSheet.Range("C26").Text
    NbOfCores         = $WorkSheet.Range("C27").Text
    MemoryGB          = $WorkSheet.Range("C29").Text
}