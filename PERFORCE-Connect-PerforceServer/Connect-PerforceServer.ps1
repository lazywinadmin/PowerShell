function Connect-PerforceServer
{
<#
.SYNOPSIS
    Connect to a Perforce Server
.DESCRIPTION
    Connect to a Perforce Server
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(Mandatory = $True)]
		$Server,
		
		[Parameter(Mandatory = $True)]
		$Port,
		
		[Parameter(Mandatory = $True)]
		$UserName,
		
		[Parameter(Mandatory = $True)]
		$Password
	)
	BEGIN
	{
		#Check if p4.exe is present
	}
	PROCESS
	{
		TRY
		{
			IF (Test-Connection -ComputerName $Server -Count 1 -Quiet -ErrorAction SilentlyContinue)
			{
				# Set the Environment Variables
				$env:p4port = "$($Server):$($Port)"
				$env:p4user = $UserName
				
				# Connect to p4 as Admin
				#  The environment variables previously set will be used by p4
				$Password | p4 login
			}
			ELSE
			{
				Write-Warning -Message "[PROCESS] Can't ping to $Server on port: $port"
			}
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Issue while connecting to perforce server: $Server on port: $port"
		}
	}
}
