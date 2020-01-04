function Get-ScriptDirectory {
    <#
.SYNOPSIS
   This function retrieve the current folder path
.DESCRIPTION
   This function retrieve the current folder path
.EXAMPLE
    Get-ScriptDirectory
.LINK
    https://github.com/lazywinadmin/PowerShell
#>
    if ($null -eq $hostinvocation) {
        Split-Path -Path $hostinvocation.MyCommand.path
    }
    else {
        Split-Path -Path $script:MyInvocation.MyCommand.Path
    }
}
