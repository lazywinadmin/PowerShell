function Get-ScriptDirectory
{
<#
.SYNOPSIS
   This function retrieve the current folder path
.DESCRIPTION
   This function retrieve the current folder path
#>
    if($hostinvocation -ne $null)
    {
        Split-Path $hostinvocation.MyCommand.path
    }
    else
    {
        Split-Path $script:MyInvocation.MyCommand.Path
    }
}
