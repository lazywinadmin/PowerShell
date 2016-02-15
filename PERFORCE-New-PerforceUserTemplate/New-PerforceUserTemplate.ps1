function New-PerforceUserTemplate
{
<#
.SYNOPSIS
    Create a tmp file which contains the User, Email and FullName
.DESCRIPTION
    Create a tmp file which contains the User, Email and FullName
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(Mandatory = $True)]
		$UserName,
		
		[Parameter(Mandatory = $True)]
		$EmailAddress,
		
		[Parameter(Mandatory = $True)]
		$FullName,
		
		$TempDirectory = "c:\"
	)
	PROCESS
	{
		# Create Temp file
		$p4TemplateFile = join-path -path $TempDirectory -childpath "NewPerforceUser_$($UserName)_$(Get-Date -Format 'yyyyMMdd_HHmmss').tmp"
		
		# Define user information
		$tempp4NewUserName = "User:" + $UserName
		$tempp4NewUserEmail = "email:" + $EmailAddress
		$tempp4NewUserFullName = "fullname:" + $FullName
		
		# Add the information to a template file
		$tempp4NewUserName | Out-File -FilePath $p4TemplateFile | Out-Null
		$tempp4NewUserEmail | Out-File -FilePath $p4TemplateFile -Append | Out-Null
		$tempp4NewUserFullName | Out-File -FilePath $p4TemplateFile -Append | Out-Null
	}
	END
	{
		#Output FilePath
		Write-Output $p4TemplateFile
	}
}