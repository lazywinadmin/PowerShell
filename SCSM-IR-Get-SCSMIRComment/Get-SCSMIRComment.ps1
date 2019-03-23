function Get-SCSMIRComment
{
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
		www.lazywinadmin.com
		@lazywinadm
#>
	[CmdletBinding()]
	PARAM
	(
		[System.WorkItem.Incident[]]$Incident
	)
	PROCESS
	{
		FOREACH ($IR in $Incident)
		{
			TRY
			{
				# Retrieve Comments
				$FilteredIncidents = $IR.AppliesToTroubleTicket | Where-Object {
					$_.ClassName -eq "System.WorkItem.TroubleTicket.UserCommentLog" -OR $_.ClassName -eq "System.WorkItem.TroubleTicket.AnalystCommentLog"
				}

				IF ($FilteredIncidents.count -gt 0)
				{
					FOREACH ($Comment in $FilteredIncidents)
					{
						$Properties = @{
							IncidentID = $IR.ID
							EnteredDate = $Comment.EnteredDate
							EnteredBy = $Comment.EnteredBy
							Comment = $Comment.Comment
							ClassName = $Comment.ClassName
							IsPrivate = $Comment.IsPrivate
						}

						New-Object -TypeName PSObject -Property $Properties
					} # FOREACH
				} #IF Incident found
			}
			CATCH
			{
				$Error[0]	
			}
		} #FOREACH ($IR in $Incident)

	} #Process
} #Function