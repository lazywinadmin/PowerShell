function ConvertTo-Base64 {
    <#
    .SYNOPSIS
        Function to convert an image to Base64

    .DESCRIPTION
        Function to convert an image to Base64

    .PARAMETER Path
        Specifies the path of the file

    .EXAMPLE
        ConvertTo-Base64 -Path "C:\images\PowerShellLogo.png"

    .NOTES
        Francois-Xavier Cat
        @lazywinadmin
        lazywinadmin.com
        github.com/lazywinadmin
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [ValidateScript( { Test-Path -Path $_ })]
        [String]$Path
    )
    Write-Verbose -Message "[ConvertTo-Base64] Converting image to Base64 $Path"
    [System.convert]::ToBase64String((Get-Content -Path $path -Encoding Byte))
}
