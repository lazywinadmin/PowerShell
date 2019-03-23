function Remove-PSObjectEmptyOrNullProperty
{
<#
	.SYNOPSIS
		Function to Remove all the empty or null properties with empty value in a PowerShell Object

	.DESCRIPTION
		Function to Remove all the empty or null properties with empty value in a PowerShell Object

	.PARAMETER PSObject
		Specifies the PowerShell Object

	.EXAMPLE
		PS C:\> Remove-PSObjectEmptyOrNullProperty -PSObject $UserInfo

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
		Where-Object { -not $_.value } |
		ForEach-Object {
			$PsObject.psobject.Properties.Remove($_.name)
		}
	}
}