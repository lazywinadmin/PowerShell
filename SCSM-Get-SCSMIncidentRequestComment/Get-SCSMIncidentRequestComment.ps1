function Get-SCSMIncidentRequestComment {
    <#
    .SYNOPSIS
        Function to retrieve the comments from a Incident Request WorkItem

    .DESCRIPTION
        Function to retrieve the comments from a Incident Request WorkItem

    .PARAMETER DateTime
        Specifies from when (DateTime) the search need to look

    .PARAMETER GUID
        Specifies the GUID of the Incident Request

    .EXAMPLE
        Get-SCSMServiceRequestComment -DateTime $((Get-Date).AddHours(-15))

    .EXAMPLE
        Get-SCSMServiceRequestComment -DateTime "2016/01/01"

    .EXAMPLE
        Get-SCSMServiceRequestComment -GUID 221dbd07-b480-ee33-fc25-6077406e83ad

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
    .LINK
        https://github.com/lazywinadmin/PowerShell
#>

    PARAM
    (
        [Parameter(ParameterSetName = 'General',
            Mandatory = $false)]
        $DateTime = $((Get-Date).AddHours(-24)),

        [Parameter(ParameterSetName = 'GUID')]
        $GUID
    )
    BEGIN {
        $AssignedUserClassRelation = Get-SCSMRelationshipClass -Id 15e577a3-6bf9-6713-4eac-ba5a5b7c4722
    }
    PROCESS {

        IF ($PSBoundParameters['GUID']) {
            $Tickets = Get-SCSMObject -id $GUID
        }
        ELSE {
            if ($DateTime -is [String]) { $DateTime = Get-Date $DateTime }
            $DateTime = $DateTime.ToString(“yyy-MM-dd HH:mm:ss”)
            $Tickets = Get-SCSMObject -Class (Get-SCSMClass System.WorkItem.incident$) -Filter "CreatedDate -gt '$DateTime'" #| Where-Object { $_.AssignedTo -eq $NULL }
        }

        $Tickets |
            ForEach-Object -Process {
                $CurrentTicket = $_
                $relatedObjects = Get-scsmrelatedobject -SMObject $CurrentTicket
                $AssignedTo = (Get-SCSMRelatedObject -SMObject $CurrentTicket -Relationship $AssignedUserClassRelation)

                $Objects = $relatedObjects |
                    Where-Object -FilterScript {
                        $_.classname -eq 'System.WorkItem.TroubleTicket.UserCommentLog' -or
                        $_.classname -eq 'System.WorkItem.TroubleTicket.AnalystCommentLog' -or
                        $_.classname -eq 'System.WorkItem.TroubleTicket.AuditCommentLog' }

                Foreach ($Comment in $Objects) {
                    # Output the information
                    [pscustomobject][ordered] @{
                        TicketName         = $CurrentTicket.Name
                        TicketClassName    = $CurrentTicket.Classname
                        TicketDisplayName  = $CurrentTicket.DisplayName
                        TicketID           = $CurrentTicket.ID
                        TicketGUID         = $CurrentTicket.get_id()
                        TicketTierQueue    = $CurrentTicket.TierQueue.displayname
                        TicketAssignedTo   = $AssignedTo.DisplayName
                        TicketCreatedDate  = $CurrentTicket.CreatedDate
                        Comment            = $Comment.Comment
                        CommentEnteredBy   = $Comment.EnteredBy
                        CommentEnteredDate = $Comment.EnteredDate
                        CommentClassName   = $Comment.ClassName
                    }
                }
            }

    }
}