Function Set-SCSMMAStatus
{
    [CmdletBinding()]
    PARAM(
        $ManualActivityID,

        $Status = "Completed"
    )
    BEGIN
    {
        TRY
        {
            if (-not(Get-module -Name smlets))
            {
                # Import the module
                Import-Module -Name smlets
            }
        }
        CATCH
        {
            Write-Warning -Message "[BEGIN] Error while loading the smlets"
            Write-Warning -Message $Error[0].exception.message
        }
    }
    PROCESS
    {
        TRY{
            # Get a specific manual activity
            $ManualActivity = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Activity.ManualActivity$) -filter "ID -eq $ManualActivityID"
            # Change the status of the Manual Activity
            Set-SCSMObject -SMObject $ManualActivity -Property Status -Value $Status
        }
        CATCH
        {
            Write-Warning -Message "[PROCESS] Something wrong happened"
            Write-Warning -Message $Error[0].exception.message
        }
    }
    END{
        Write-Verbose -Message "[END] Set-SCSMMAStatus Done!"
    }
}