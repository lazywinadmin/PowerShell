Function Set-SCSMMAStatus {
    <#
    .SYNOPSIS
        Set the status of a Manual Activity
    .DESCRIPTION
        Set the status of a Manual Activity
    .PARAMETER ManualActivityID
        Specify the ID of the Manual Activity
    .PARAMETER Status
        Specify the status of the Manual activity

        Status possible:
        In Progress
        Cancelled
        Completed
        Failed
        On Hold
        Pending
        Rerun
        Skipped
    .EXAMPLE
        Set-SCSMMAStatus -ManualActivityID MA123456 -Status 'Cancelled'
    #>
    [CmdletBinding()]
    PARAM(
        $ManualActivityID,

        $Status = "Completed"
    )
    BEGIN {
        TRY {
            if (-not(Get-Module -Name smlets)) {
                # Import the module
                Import-Module -Name smlets
            }
        }
        CATCH {
            Write-Warning -Message "[BEGIN] Error while loading the smlets"
            Write-Warning -Message $Error[0].exception.message
        }
    }
    PROCESS {
        TRY {
            # Get a specific manual activity
            $ManualActivity = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Activity.ManualActivity$) -filter "ID -eq $ManualActivityID"
            # Change the status of the Manual Activity
            Set-SCSMObject -SMObject $ManualActivity -Property Status -Value $Status
        }
        CATCH {
            Write-Warning -Message "[PROCESS] Something wrong happened"
            Write-Warning -Message $Error[0].exception.message
        }
    }
    END {
        Write-Verbose -Message "[END] Set-SCSMMAStatus Done!"
    }
}