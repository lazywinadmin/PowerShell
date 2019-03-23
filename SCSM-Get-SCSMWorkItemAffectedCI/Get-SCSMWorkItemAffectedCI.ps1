function Get-SCSMWorkItemAffectedCI
{
<#
	.SYNOPSIS
		Function to retrieve the affected configuration item of a System Center Service Manager Work Item

	.DESCRIPTION
		Function to retrieve the affected configuration item of a System Center Service Manager Work Item

	.PARAMETER GUID
		Specifies the GUID of the WorkItem

	.EXAMPLE
		PS C:\> Get-SCSMWorkItemAffectedCI -GUID "69c5dfc9-9acb-0afb-9210-190d3054901e"

	.NOTES
		Francois-Xavier.Cat
		@lazywinadm
		www.lazywinadmin.com
#>
	PARAM (
		[parameter()]
		[Alias()]
		$GUID
	)
	PROCESS
	{
		# Find the Ticket Object 
		$WorkItemObject = Get-SCSMObject -id $GUID

		# Find the Affected Configuration Items
		Get-SCSMRelationshipObject -BySource $WorkItemObject |
		Where-Object { $_.relationshipid -eq 'b73a6094-c64c-b0ff-9706-1822df5c2e82' }
	}
}