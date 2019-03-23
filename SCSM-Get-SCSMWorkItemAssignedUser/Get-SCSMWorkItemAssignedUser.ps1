function Get-SCSMWorkItemAssignedUser
{
<#
	.SYNOPSIS
		Function to retrieve the Assigned User of a Work Item

	.DESCRIPTION
		Function to retrieve the Assigned User of a Work Item

	.PARAMETER SMObject
		Specifies the SMObject(s) on which the Assigned need to be retrieve.

	.PARAMETER Guid
		Specifies the GUID of the SMObject on which the Assigned need to be retrieve.

	.EXAMPLE
		Get-SCSMWorkItemAssignedUser -SMObject $SR,IR

	.EXAMPLE
		$SR,IR | Get-SCSMWorkItemAssignedUser

	.EXAMPLE
		Get-SCSMWorkItemAssignedUser -GUID 5bd5e783-c8a1-0217-9e19-f82823ef4f87

	.NOTES
		Francois-Xavier Cat
		@lazywinadm
		www.lazywinadmin.com
#>

	[CmdletBinding(DefaultParameterSetName = 'GUID')]
	param
	(
		[Parameter(ParameterSetName = 'SMObject',
				   Mandatory = $true,
				   ValueFromPipeline = $true)]
		$SMObject,

		[Parameter(ParameterSetName = 'GUID',
				   Mandatory = $true)]
		$Guid
	)

	BEGIN
	{
		Import-Module -Name SMLets -ErrorAction Stop

		# AssignedUser RelationshipClass
		$RelationshipClass_AssignedUser_Object = Get-SCSMRelationshipClass -Name System.WorkItemAssignedToUser$
	}
	PROCESS
	{
		IF ($PSBoundParameters['GUID'])
		{
			foreach ($Item in $GUID)
			{
				$SMObject = Get-SCSMObject -id $item
				Write-Verbose -Message "[PROCESS] Working on $($Item.Name)"
				Get-ScsmRelatedObject -SMObject $SMObject -Relationship $RelationshipClass_AssignedUser_Object |
				Select-Object -Property @{ Label = "WorkItemName"; Expression = { $SMObject.Name } },
							  @{ Label = "WorkItemGUID"; Expression = { $SMObject.get_id() } }, *
			}
		}

		IF ($PSBoundParameters['SMobject'])
		{
			foreach ($Item in $SMObject)
			{
				Write-Verbose -Message "[PROCESS] Working on $($Item.Name)"
				Get-ScsmRelatedObject -SMObject $Item -Relationship $RelationshipClass_AssignedUser_Object |
				Select-Object -Property @{ Label = "WorkItemName"; Expression = { $Item.Name } },
							  @{ Label = "WorkItemGUID"; Expression = { $Item.get_id() } }, *
			}
		}
	}
}