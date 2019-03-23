Function Get-SCSMWorkItemChildItem
{
	param (
		[Parameter(Mandatory = $True)]
		$inputPWI_guid
	)
	### Variables to Return
	$childWIs_obj = @()

	### MAIN
	$inputPWI_obj = get-scsmobject -id $inputPWI_guid
	$containsActivity_relclass_id = '2da498be-0485-b2b2-d520-6ebd1698e61b'
	$childWIs_relobj_filter = "RelationshipId -eq '$containsActivity_relclass_id'"
	$childWIs_relobj = Get-SCSMRelationshipObject -BySource $inputPWI_obj | where{ $_.RelationshipId -eq $containsActivity_relclass_id }
	ForEach ($childWI_relobj in $childWIs_relobj)
	{
		if ($childWI_relobj.IsDeleted -ne 'false')
		{

			$childWI_id = $childWI_relobj.TargetObject.id.guid
			$childWI_obj = get-scsmobject -id $childWI_id
			#filter for DynamicReviewerActivity
			If ($childWI_obj.ClassName -eq 'System.WorkItem.Activity.ReviewActivity' -AND $childWI_obj.Title -match 'DynamicReviewerActivity')
			{
				$childWIs_obj += $childWI_obj
			}
		}
	}
	### RETURN DATA
	$childWIs_obj
}