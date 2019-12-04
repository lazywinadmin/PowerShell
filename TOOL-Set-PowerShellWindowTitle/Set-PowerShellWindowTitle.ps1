function Set-PowerShellWindowTitle {
    <#
    .SYNOPSIS
        Function to set the title of the PowerShell Window

    .DESCRIPTION
        Function to set the title of the PowerShell Window

    .PARAMETER Title
        Specifies the Title of the PowerShell Window

    .EXAMPLE
        PS C:\> Set-PowerShellWindowTitle -Title LazyWinAdmin.com

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
#>
    [CmdletBinding()]
    PARAM($Title)
    try {
        $Host.UI.RawUI.WindowTitle = $Title
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

