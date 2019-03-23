function Write-Log
{
<#
.SYNOPSIS
    Function to create or append a log file

#>
[CmdletBinding()]
    Param (
        [Parameter()]
        $Path="",
        $LogName = "$(Get-Date -f 'yyyyMMdd').log",

        [Parameter(Mandatory=$true)]
        $Message = "",

        [Parameter()]
        [ValidateSet('INFORMATIVE','WARNING','ERROR')]
        $Type = "INFORMATIVE",
        $Category
    )
    BEGIN {
        # Verify if the log already exists, else create it
        IF (-not(Test-Path -Path $(Join-Path -Path $Path -ChildPath $LogName))){
            New-Item -Path $(Join-Path -Path $Path -ChildPath $LogName) -ItemType file
        }

    }
    PROCESS{
        TRY{
            "$(Get-Date -Format yyyyMMdd:HHmmss) [$TYPE] [$category] $Message" | Out-File -FilePath (Join-Path -Path $Path -ChildPath $LogName) -Append
        }
        CATCH{
            Write-Error -Message "Could not write into $(Join-Path -Path $Path -ChildPath $LogName)"
            Write-Error -Message "Last Error:$($error[0].exception.message)"
        }
    }

}