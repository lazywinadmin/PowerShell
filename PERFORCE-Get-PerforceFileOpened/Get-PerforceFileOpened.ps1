function Get-PerforceFileOpened
{
<#
	.SYNOPSIS
		Function to retrieve the file(s) opened for a user or in a workspace
	
	.DESCRIPTION
		Function to retrieve the file(s) opened for a user or in a workspace
	
	.PARAMETER UserName
		Specifies the User
	
	.PARAMETER WorkSpace
		Specifies the Workspace
	
	.OUTPUTS
		Psobject, Psobject
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding(DefaultParameterSetName = 'All')]
	[OutputType([Psobject], ParameterSetName = 'WorkSpace')]
	[OutputType([Psobject], ParameterSetName = 'UserName')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'UserName',
				   Mandatory = $true)]
		$UserName,
		
		[Parameter(ParameterSetName = 'WorkSpace',
				   Mandatory = $true)]
		$WorkSpace
	)
	
	if ($PSBoundParameters['UserName'])
	{
		$OpenedFiles = p4 opened -u $UserName
	}
	elseif ($PSBoundParameters['Workspace'])
	{
		$OpenedFiles = p4 opened -C $WorkSpace
	}
	else
	{
		$openedFiles = p4 opened -a
	}
	
	Foreach ($File in $OpenedFiles)
	{
		$OriginalLine = $file
		$LiteralPath = $File -split '#'
		$RevisionNumber = ($LiteralPath[1] -split ' - ')[0]
		$FullComment = (($literalpath[1] -split ' - ')[1] -split 'by')
		$ChangeNumber = (($FullComment[0] -split 'change ')[1] -split ' \(')[0]
		#if($ChangeNumber -is [int]){$ChangeNumber} else {$ChangeNumber=""}
		
		[pscustomobject][ordered]@{
			LiteralPath = $LiteralPath[0]
			FileName = ($LiteralPath[0] -split '/')[-1]
			RevisionNumber = $RevisionNumber
			Comment = $FullComment[0]
			ChangeListNumber = $ChangeNumber -as [int]
			Username = ($FullComment[1].trim() -split '@')[0]
			Workspace = ($FullComment[1].trim() -split '@')[1]
			Line = $OriginalLine
		}
	}
}
