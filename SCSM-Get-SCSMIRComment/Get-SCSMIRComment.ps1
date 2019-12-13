function Get-SCSMIRComment {
    <#
    .SYNOPSIS
        Function to retrieve all the comment of a Incident Request

    .DESCRIPTION
        Function to retrieve all the comment of a Incident Request

    .PARAMETER Incident
        Specifies the Incident Request Object.

    .EXAMPLE
        PS C:\> Get-SCSMIRComment -Incident (get-scsmincident -ID 'IR55444')

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
#>
    [CmdletBinding()]
    PARAM
    (
        #[System.WorkItem.Incident[]]
        [object[]]$Incident
    )
    PROCESS {
        FOREACH ($IR in $Incident) {
            TRY {
                # Retrieve Comments
                $FilteredIncidents = $IR.AppliesToTroubleTicket | Where-Object -FilterScript {
                    $_.ClassName -eq "System.WorkItem.TroubleTicket.UserCommentLog" -OR $_.ClassName -eq "System.WorkItem.TroubleTicket.AnalystCommentLog"
                }

                IF ($FilteredIncidents.count -gt 0) {
                    FOREACH ($Comment in $FilteredIncidents) {
                        $Properties = @{
                            IncidentID  = $IR.ID
                            EnteredDate = $Comment.EnteredDate
                            EnteredBy   = $Comment.EnteredBy
                            Comment     = $Comment.Comment
                            ClassName   = $Comment.ClassName
                            IsPrivate   = $Comment.IsPrivate
                        }

                        New-Object -TypeName PSObject -Property $Properties
                    } # FOREACH
                } #IF Incident found
            }
            CATCH {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        } #FOREACH ($IR in $Incident)
    } #Process
} #Function