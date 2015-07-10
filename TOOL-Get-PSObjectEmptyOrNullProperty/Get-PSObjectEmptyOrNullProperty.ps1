function Get-PSObjectEmptyOrNullProperty
{
<#
	.SYNOPSIS
		Function to Get all the empty or null properties with empty value in a PowerShell Object
	
	.DESCRIPTION
		Function to Get all the empty or null properties with empty value in a PowerShell Object
	
	.PARAMETER PSObject
		Specifies the PowerShell Object
	
	.EXAMPLE
		PS C:\> Get-PSObjectEmptyOrNullProperty -PSObject $UserInfo
	
	.NOTES
		Francois-Xavier Cat	
		www.lazywinadmin.com
		@lazywinadm
#>
	PARAM (
		$PSObject)
	PROCESS
	{
		$PsObject.psobject.Properties |
		Where-Object { -not $_.value }
	}
}