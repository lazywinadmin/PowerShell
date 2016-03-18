function Get-PerforceUser
{
<#
	.SYNOPSIS
		Function to retrieve all the users in Perforce
	
	.DESCRIPTION
		Function to retrieve all the users in Perforce
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	[OutputType([psobject])]
	param ()
	
	foreach ($user in (p4 users))
	{
		$UserSplit = $user.trim() -split ' '
		
		[pscustomobject][ordered]@{
			SamaccountName = $UserSplit[0]
			Email = $UserSplit[1] -replace '<', '' -replace '>', ''
			DisplayName = $UserSplit[2..$(($UserSplit.count) - 3)] -replace '[()]', '' -as [string]
			LastAccess = $UserSplit[-1] -as [datetime]
			Line = $user
		}
	}
}
