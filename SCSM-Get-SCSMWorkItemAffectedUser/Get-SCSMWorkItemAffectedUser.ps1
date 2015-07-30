Function Get-WorkItemAffectedUser
{
<#
	.SYNOPSIS
		Function to retrieve the Affected User of a Work Item
	
	.DESCRIPTION
		Function to retrieve the Affected User of a Work Item
	
	.PARAMETER WorkItem
		Specifies the object to query
	
	.EXAMPLE
		PS C:\> Get-WorkItemAffectedUser -WorkItem $SR,IR
	
	.EXAMPLE
		PS C:\> $SR,IR | Get-WorkItemAffectedUser
	
	.NOTES
		Francois-Xavier Cat
		@lazywinadm
		www.lazywinadmin.com
	
		1.0 Based on Cireson's consultants Script
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(ValueFromPipeline)]
		$WorkItem
	)
	BEGIN
	{
		$wiAffectedUser_obj = $null
		Import-Module -Name SMLets -ErrorAction Stop	
	}
	PROCESS
	{
		foreach ($Item in $WorkItem)
		{
			Write-Verbose -Message "[PROCESS] Working on $($Item.Name)"
			# AffectedUser RelationshipClass
			$RelationshipClass_AffectedUser = 'dff9be66-38b0-b6d6-6144-a412a3ebd4ce'
			$RelationshipClass_AffectedUser_Object = Get-SCSMRelationshipClass -id $RelationshipClass_AffectedUser
			
			Get-ScsmRelatedObject -SMObject $Item -Relationship $wiAffectedUser_relclass_obj |
			Select-Object -Property @{ Label = "WorkItemName"; Expression = { $Item.Name } },
						  @{ Label = "WorkItemName"; Expression = { $Item.get_id() } },*
		}
	}
}
