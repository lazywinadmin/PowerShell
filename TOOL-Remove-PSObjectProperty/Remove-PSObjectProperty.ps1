function Remove-PSObjectProperty {
<#
.SYNOPSIS
    Function to Remove a specifid property from a PowerShell object

.DESCRIPTION
    Function to Remove a specifid property from a PowerShell object

.PARAMETER PSObject
    Specifies the PowerShell Object

.PARAMETER Property
    Specifies the property to remove

.EXAMPLE
    PS C:\> Remove-PSObjectProperty -PSObject $UserInfo -Property Info

.NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadmin
.LINK
    https://github.com/lazywinadmin/PowerShell
#>
    PARAM (
        $PSObject,

        [String[]]$Property)
    PROCESS {
        Foreach ($item in $Property) {
            $PSObject.psobject.Properties.Remove("$item")
        }
    }
}