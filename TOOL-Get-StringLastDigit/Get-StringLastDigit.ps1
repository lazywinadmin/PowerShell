function Get-StringLastDigit {
<#
.SYNOPSIS
    Get the last digit of a string
.DESCRIPTION
    Get the last digit of a string using Regular Expression
.PARAMETER String
    Specifies the String to check
.EXAMPLE
    PS C:\> Get-StringLastDigit -String "Francois-Xavier.cat5"

    5
.EXAMPLE
    PS C:\> Get-StringLastDigit -String "Francois-Xavier.cat"

    <no output>
.EXAMPLE
    PS C:\> Get-StringLastDigit -String "Francois-Xavier.cat" -Verbose

    <no output>
    VERBOSE: The following string does not finish by a digit: Francois-Xavier.cat
.NOTES
    Francois-Xavier Cat
    @lazywinadmin
    lazywinadmin.com
.LINK
    https://github.com/lazywinadmin/PowerShell
#>
    [CmdletBinding()]
    PARAM($String)
    try {
        #Check if finish by Digit
        if ($String -match "^.*\d$") {
            # Output the last digit
            $String.Substring(($String.ToCharArray().count) - 1)
        }
        else { Write-Verbose -Message "The following string does not finish by a digit: $String" }
    }
    catch { $PSCmdlet.ThrowTerminatingError($_) }
}