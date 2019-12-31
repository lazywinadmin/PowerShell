function ConvertTo-StringList {
    <#
    .SYNOPSIS
        Function to convert an array into a string list with a delimiter.

    .DESCRIPTION
        Function to convert an array into a string list with a delimiter.

    .PARAMETER Array
        Specifies the array to process.

    .PARAMETER Delimiter
        Separator between value, default is ","

    .EXAMPLE
        $Computers = "Computer1","Computer2"
        ConvertTo-StringList -Array $Computers

        Output:
        Computer1,Computer2

    .EXAMPLE
        $Computers = "Computer1","Computer2"
        ConvertTo-StringList -Array $Computers -Delimiter "__"

        Output:
        Computer1__Computer2

    .EXAMPLE
        $Computers = "Computer1"
        ConvertTo-StringList -Array $Computers -Delimiter "__"

        Output:
        Computer1

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin

        I used this function in System Center Orchestrator (SCORCH).
        This is sometime easier to pass data between activities
    .LINK
        https://github.com/lazywinadmin/PowerShell
#>

    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [System.Array]$Array,

        [system.string]$Delimiter = ","
    )

    BEGIN { $StringList = "" }
    PROCESS {
        Write-Verbose -Message "Array: $Array"
        foreach ($item in $Array) {
            # Adding the current object to the list
            $StringList += "$item$Delimiter"
        }
        Write-Verbose -Message "StringList: $StringList"
    }
    END {
        TRY {
            IF ($StringList) {
                $lenght = $StringList.Length
                Write-Verbose -Message "StringList Lenght: $lenght"

                # Output Info without the last delimiter
                $StringList.Substring(0, ($lenght - $($Delimiter.length)))
            }
        }# TRY
        CATCH {
            Write-Warning -Message "[END] Something wrong happening when output the result"
            $Error[0].Exception.Message
        }
        FINALLY {
            # Reset Variable
            $StringList = ""
        }
    }
}