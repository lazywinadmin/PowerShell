function Get-SCSMServiceRequestComment
{
<#
	.SYNOPSIS
		Function to retrieve the comments from a Service Request WorkItem

	.DESCRIPTION
		Function to retrieve the comments from a Service Request WorkItem

	.PARAMETER DateTime
		Specifies from when (DateTime) the search need to look

	.PARAMETER GUID
		Specifies the GUID of the Service Request or Incident

	.EXAMPLE
		Get-SCSMServiceRequestComment -DateTime $((Get-Date).AddHours(-15))

	.EXAMPLE
		Get-SCSMServiceRequestComment -DateTime "2016/01/01"

	.EXAMPLE
		Get-SCSMServiceRequestComment -GUID 221dbd07-b480-ee33-fc25-6077406e83ad

	.NOTES
		Francois-Xavier Cat
		www.LazyWinAdmin.com
		@lazywinadm
#>

	PARAM
	(
		[Parameter(ParameterSetName = 'General',
				   Mandatory = $true)]
		$DateTime = $((Get-Date).AddHours(-24)),

		[Parameter(ParameterSetName = 'GUID')]
		$GUID
	)

	IF ($PSBoundParameters['GUID'])
	{
		$Tickets = Get-SCSMObject -id $GUID
	}
	ELSE
	{
		if ($DateTime -is [String]){ $DateTime = Get-Date $DateTime}
		$DateTime = $DateTime.ToString(“yyy-MM-dd HH:mm:ss”)
		$Tickets = Get-SCSMObject -Class (Get-SCSMClass System.WorkItem.servicerequest$) -Filter "CreatedDate -gt '$DateTime'" #| Where-Object { $_.AssignedTo -eq $NULL }
	}

	$Tickets |
	ForEach-Object {
		$CurrentTicket = $_
		$relatedObjects = Get-scsmrelatedobject -SMObject $CurrentTicket
		Foreach ($Comment in ($relatedObjects | Where-Object { $_.classname -eq 'System.WorkItem.TroubleTicket.UserCommentLog' -or $_.classname -eq 'System.WorkItem.TroubleTicket.AnalystCommentLog' -or $_.classname -eq 'System.WorkItem.TroubleTicket.AuditCommentLog'}))
		{
			# Output the information
			[pscustomobject][ordered] @{
				TicketName = $CurrentTicket.Name
				TicketClassName = $CurrentTicket.Classname
				TicketDisplayName = $CurrentTicket.DisplayName
				TicketID = $CurrentTicket.ID
				TicketGUID = $CurrentTicket.get_id()
				TicketSupportGroup = $CurrentTicket.SupportGroup.displayname
				TicketAssignedTo = $CurrentTicket.AssignedTo
				TicketCreatedDate = $CurrentTicket.CreatedDate
				Comment = $Comment.Comment
				CommentEnteredBy = $Comment.EnteredBy
				CommentEnteredDate = $Comment.EnteredDate
				CommentClassName = $Comment.ClassName
			}
		}
	}
}