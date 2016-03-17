function Get-PerforceWorkspace
{
<#
	.SYNOPSIS
		Function to retrieve Perforce all the Workspaces or those owned by a specific user
	
	.DESCRIPTION
		Function to retrieve Perforce all the Workspaces or those owned by a specific user
	
	.PARAMETER UserName
		Specified the Username to query
	
	.OUTPUTS
		psobject
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding(DefaultParameterSetName = 'All')]
	[OutputType([psobject], ParameterSetName = 'UserName')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'UserName')]
		[string]$UserName
	)
	
	if ($PSBoundParameters['UserName'])
	{
		$workspaces = p4 workspaces -u $UserName
	}
	else
	{
		$Workspaces = p4 workspaces
	}
	
	Foreach ($WorkSp in $workspaces)
	{
		$OriginalLine = $WorkSp
		$WorkSp = $WorkSp -split '\s'
		$WorkSpCount = $WorkSp.count
		[pscustomobject][ordered]@{
			Name = $WorkSp[1]
			CreationDate = $WorkSp[2] -as [datetime]
			Root = $WorkSp[4]
			Comment = $WorkSp[5..$WorkSpCount] -as [string]
			Line = $OriginalLine
		}
	}
}
