function New-PerforceUser
{
<#
.SYNOPSIS
    Create a user in perforce based on tmp file which contains the User, Email and FullName
.DESCRIPTION
    Create a user in perforce based on tmp file which contains the User, Email and FullName
#>
	[CmdletBinding()]
	PARAM ($UserTemplate)
	PROCESS
	{
		# Create perforce user based on template
		Get-Content $UserTemplate | p4 user -f -i
	}
}