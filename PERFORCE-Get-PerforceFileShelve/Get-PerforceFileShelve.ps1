function Get-PerforceFileShelve
{
<#
	.SYNOPSIS
		Function to retrieve the file(s) shelfed for a specific changelist number or a specific User
	
	.DESCRIPTION
		Function to retrieve the file(s) shelfed for a specific changelist number or a specific User
	
	.PARAMETER ChangeListNumber
		A description of the ChangeListNumber parameter.
	
	.PARAMETER UserName
		A description of the UserName parameter.
	
	.OUTPUTS
		psobject, psobject
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding(DefaultParameterSetName = 'ChangeListNumber')]
	[OutputType([psobject], ParameterSetName = 'ChangeListNumber')]
	[OutputType([psobject], ParameterSetName = 'Username')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'ChangeListNumber',
				   Mandatory = $true)]
		[string[]]$ChangeListNumber,
		
		[Parameter(ParameterSetName = 'Username',
				   Mandatory = $true)]
		[string]$UserName
	)
	
	IF ($PSBoundParameters['UserName'])
	{
		$ChangeList = p4 changes -u $UserName -s shelved
		$ChangeListNumber = ($ChangeList -split '\s')[1] | Select-Object -unique
	}
	
	
	foreach ($Change in $ChangeListNumber)
	{
		$ShelvesFiles = p4 describe -S $ChangeListNumber | select-string -Pattern '\.\.\. //'
		
		foreach ($file in $ShelvesFiles)
		{
			$OriginalLine = $file
			$LiteralPath = $file -split "#" -replace '\.\.\. ', ''
			
			[pscustomobject][ordered]@{
				LiteralPath = $LiteralPath[0]
				FileName = ($LiteralPath[0] -split '/')[-1]
				RevisionNumber = ($LiteralPath[1] -split '\s')[0]
				ChangeType = ($LiteralPath[1] -split '\s')[1]
				Line = $OriginalLine
			}
		}
	}
}
