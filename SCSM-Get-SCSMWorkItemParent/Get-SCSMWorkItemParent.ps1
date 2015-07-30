function Get-SCSMWorkItemParent
{
	<#
	.DESCRIPTION
		Function to retrieve the parent of a System Center Service Manager Work Item
	
	.SYNOPSIS
		Function to retrieve the parent of a System Center Service Manager Work Item
	
	.PARAMETER WorkItemGUI
		Specified the GUID of the Work Item
	
	.PARAMETER WorkItemObject
		Specified the Work Item Object
	
	.EXAMPLE
		$RunbookActivity = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.SystemCenter.Orchestrator.RunbookAutomationActivity$) -filter 'ID -eq RB30579'
		$WorkItemGUID = $RunbookActivity.get_id()
	
		Get-SCSMWorkItemParent -WorkItemGUID $WorkItemGUID
	
	.EXAMPLE
		$RunbookActivity = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.SystemCenter.Orchestrator.RunbookAutomationActivity$) -filter 'ID -eq RB30579'
		Get-SCSMWorkItemParent -WorkItemObject $RunbookActivity
	
	.NOTES
		Francois-Xavier.Cat
		@lazywinadm
		www.lazywinadmin.com
	
		1.0 Function based on the work from Prosum and Cireson consultants
	#>
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = 'GUID', Mandatory)]
		$WorkItemGUID = '',
		
		[Parameter(ParameterSetName = 'Object', Mandatory)]
		$WorkItemObject
	)
	BEGIN
	{
		Import-Module -Name smlets -ErrorAction Stop
	}
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['WorkItemGUID'])
			{
				# Retrieve the Activity Object in SCSM
				$ActivityObject = Get-SCSMObject -id $WorkItemGUID
			}
			IF ($PSBoundParameters['WorkItemObject'])
			{
				# Retrieve the Activity Object in SCSM
				$ActivityObject = Get-SCSMObject -id $WorkItemObject.get_id()
			}
			
			# Retrieve Parent
			$ParentRelationshipID = '2da498be-0485-b2b2-d520-6ebd1698e61b'
			$ParentRelatedObject = Get-SCSMRelationshipObject -ByTarget $ActivityObject | Where-Object{ $_.RelationshipId -eq $ParentRelationshipID }
			$ParentObject = $ParentRelatedObject.SourceObject
			
			If ($ParentObject.ClassName -eq 'System.WorkItem.ServiceRequest' -OR $ParentObject.ClassName -eq 'System.WorkItem.ChangeRequest' -OR $ParentObject.ClassName -eq 'System.WorkItem.ReleaseRecord')
			{
				Write-Output $ParentObject
				
				# Could do the following to retrieve all the properties
				# Get-SCSMObject $ParentRelatedObject.SourceObject.id.Guid
			}
			Else
			{
				# Loop to find the highest parent
				Get-SCSMWorkItemParent -WorkItemGUID $ParentObject.id.guid
			}
		}
		CATCH
		{
			Write-Error -Message $Error[0].Exception.Message
		}
	} #PROCESS
	END
	{
		remove-module -Name smlets -ErrorAction SilentlyContinue
		
	}#End
} #Function