function Test-IsLocalAdministrator {
    <#
.SYNOPSIS
    Function to verify if the current user is a local Administrator on the current system
.DESCRIPTION
    Function to verify if the current user is a local Administrator on the current system
.EXAMPLE
    Test-IsLocalAdministrator

    True
.NOTES
    Francois-Xavier Cat
    @lazywinadmin
    lazywinadmin.com
    github.com/lazywinadmin
#>
    [CmdletBinding()]
    PARAM()
    try {
        ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}