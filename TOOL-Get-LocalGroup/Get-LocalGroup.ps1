function Get-LocalGroup
{

<#
	.SYNOPSIS
		This script can be list all of local group account.

	.DESCRIPTION
		This script can be list all of local group account.
		The function is using WMI to connect to the remote machine

	.PARAMETER ComputerName
		Specifies the computers on which the command . The default is the local computer.

	.PARAMETER Credential
		A description of the Credential parameter.


	.EXAMPLE
		Get-LocalGroup

		This example shows how to list all the local groups on local computer.

	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
#>

	PARAM
	(
		[Alias('cn')]
		[String[]]$ComputerName = $Env:COMPUTERNAME,

		[String]$AccountName,

		[System.Management.Automation.PsCredential]$Credential
	)

	$Splatting = @{
		Class = "Win32_Group"
		Namespace = "root\cimv2"
		Filter = "LocalAccount='$True'"
	}

	#Credentials
	If ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }

	Foreach ($Computer in $ComputerName)
	{
		TRY
		{
			Write-Verbose -Message "[PROCESS] ComputerName: $Computer"
			Get-WmiObject @Splatting -ComputerName $Computer | Select-Object -Property Name, Caption, Status, SID, SIDType, Domain, Description
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Issue connecting to $Computer"
		}
	}
}