function Clean-MacAddress {
    <#
    .SYNOPSIS
        Function to cleanup a MACAddress string

    .DESCRIPTION
        Function to cleanup a MACAddress string

    .PARAMETER MacAddress
        Specifies the MacAddress

    .PARAMETER Separator
        Specifies the separator every two characters

    .PARAMETER Uppercase
        Specifies the output must be Uppercase

    .PARAMETER Lowercase
        Specifies the output must be LowerCase

    .EXAMPLE
        Clean-MacAddress -MacAddress '00:11:22:33:44:55'

        001122334455
    .EXAMPLE
        Clean-MacAddress -MacAddress '00:11:22:dD:ee:FF' -Uppercase

        001122DDEEFF

    .EXAMPLE
        Clean-MacAddress -MacAddress '00:11:22:dD:ee:FF' -Lowercase

        001122ddeeff

    .EXAMPLE
        Clean-MacAddress -MacAddress '00:11:22:dD:ee:FF' -Lowercase -Separator '-'

        00-11-22-dd-ee-ff

    .EXAMPLE
        Clean-MacAddress -MacAddress '00:11:22:dD:ee:FF' -Lowercase -Separator '.'

        00.11.22.dd.ee.ff

    .EXAMPLE
        Clean-MacAddress -MacAddress '00:11:22:dD:ee:FF' -Lowercase -Separator :

        00:11:22:dd:ee:ff

    .OUTPUTS
        System.String

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
    .Link
        https://github.com/lazywinadmin/PowerShell
#>
    [OutputType([String], ParameterSetName = "Upper")]
    [OutputType([String], ParameterSetName = "Lower")]
    [CmdletBinding(DefaultParameterSetName = 'Upper')]
    param
    (
        [Parameter(ParameterSetName = 'Lower')]
        [Parameter(ParameterSetName = 'Upper')]
        [String]$MacAddress,

        [Parameter(ParameterSetName = 'Lower')]
        [Parameter(ParameterSetName = 'Upper')]
        [ValidateSet(':', 'None', '.', "-")]
        $Separator,

        [Parameter(ParameterSetName = 'Upper')]
        [Switch]$Uppercase,

        [Parameter(ParameterSetName = 'Lower')]
        [Switch]$Lowercase
    )

    BEGIN {
        # Initial Cleanup
        $MacAddress = $MacAddress -replace "-", "" #Replace Dash
        $MacAddress = $MacAddress -replace ":", "" #Replace Colon
        $MacAddress = $MacAddress -replace "/s", "" #Remove whitespace
        $MacAddress = $MacAddress -replace " ", "" #Remove whitespace
        $MacAddress = $MacAddress -replace "\.", "" #Remove dots
        $MacAddress = $MacAddress.trim() #Remove space at the beginning
        $MacAddress = $MacAddress.trimend() #Remove space at the end
    }
    PROCESS {
        IF ($PSBoundParameters['Uppercase']) {
            $MacAddress = $macaddress.toupper()
        }
        IF ($PSBoundParameters['Lowercase']) {
            $MacAddress = $macaddress.tolower()
        }
        IF ($PSBoundParameters['Separator']) {
            IF ($Separator -ne "None") {
                $MacAddress = $MacAddress -replace '(..(?!$))', "`$1$Separator"
            }
        }
    }
    END {
        Write-Output $MacAddress
    }
}
