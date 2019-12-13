function Get-ISEShortCut {
    <#
.SYNOPSIS
    List ISE Shortcuts

.DESCRIPTION
    List ISE Shortcuts.
    This won't run in a regular powershell console, only in ISE.

.EXAMPLE
    Get-ISEShortcut

    Will list all the shortcuts available
.EXAMPLE
    Get-Help Get-ISEShortcut -Online

    Will show technet page of ISE Shortcuts
.LINK
    http://technet.microsoft.com/en-us/library/jj984298.aspx

.NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadmin

    VERSION HISTORY
    2015/01/10 Initial Version
#>
    PARAM($Key, $Name)
    BEGIN {
        function Test-IsISE {
            # try...catch accounts for:
            # Set-StrictMode -Version latest
            try {
                $null -ne $psISE
            }
            catch {
                return $false;
            }
        }
    }
    PROCESS {
        if ($(Test-IsISE) -eq $true) {
            # http://www.powershellmagazine.com/2013/01/29/the-complete-list-of-powershell-ise-3-0-keyboard-shortcuts/

            # Reference to the ISE Microsoft.PowerShell.GPowerShell assembly (DLL)
            $gps = $psISE.GetType().Assembly
            $rm = New-Object -TypeName System.Resources.ResourceManager -ArgumentList GuiStrings, $gps
            $rs = $rm.GetResourceSet((Get-Culture), $true, $true)
            $rs | Where-Object -Property Name -match 'Shortcut\d?$|^F\d+Keyboard' |
            Sort-Object -Property Value

    }
}
}