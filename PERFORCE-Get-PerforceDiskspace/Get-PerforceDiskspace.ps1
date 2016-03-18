function Get-PerforceDiskspace
{
<#
	.SYNOPSIS
		Function to retrieve all the depot(s) diskspace information in Perforce
	
	.DESCRIPTION
		Function to retrieve all the depot(s) diskspace information in Perforce
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	[OutputType([psobject])]
	param ()
	
	$DiskSpaceOutput = p4 diskspace
	
	foreach ($DiskSpace in $DiskSpaceOutput)
	{
		$DiskSpaceSplit = $DiskSpace -split '\s'
		
		[pscustomobject][ordered]@{
			Depot = $DiskSpaceSplit[0]
			FileSystemType = $DiskSpaceSplit[2] -replace '[()]', '' -as [string]
			FreeSpace = $DiskSpaceSplit[4]
			UsedSpace = $DiskSpaceSplit[6]
			TotalSpace = $DiskSpaceSplit[8]
			PercentUsedSpace = $DiskSpaceSplit[-1]
			Line = $DiskSpaceSplit
		}
	}
}
