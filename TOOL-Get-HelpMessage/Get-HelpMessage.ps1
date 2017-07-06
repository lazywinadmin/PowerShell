function Get-HelpMessage
{
    <#
    .SYNOPSIS
    Function to explain why an error occurred and provides problem-solving information.
    Equivalent of NET HELPMSG
    
    .DESCRIPTION
    Function to explain why an error occurred and provides problem-solving information.
    Equivalent of NET HELPMSG.

    The function also create an alias called HelpMsg, so you can call the function this way:
    HelpMsg 618
    
    .PARAMETER Id
    Specify the ID of the error you want to retrieve.
    Can be decimal, hexadecimal

    .EXAMPLE
    Get-HelpMessage 618

    The specified compression format is unsupported
    
    .EXAMPLE
    Get-HelpMessage 0x80070652

    Another installation is already in progress. Complete that installation before proceeding with this install

    .EXAMPLE
    Get-HelpMessage –2147023278 
    Another installation is already in progress. Complete that installation before proceeding with this install

    .NOTES
    http://www.leeholmes.com/blog/2009/09/15/powershell-equivalent-of-net-helpmsg/
    https://github.com/lazywinadmin/powershell
    #>
    [CmdletBinding()]
    [Alias('HelpMsg')]
    PARAM($Id)
    [ComponentModel.Win32Exception] $id
}