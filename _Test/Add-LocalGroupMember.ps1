Function Add-LocalGroupMember
{
	<#
	.SYNOPSIS
	.DESCRIPTION
	.PARAMETER
	.EXAMPLE
	.NOTES
		Add support for local user/group and ad user/group

	 New-ADGroup -Name "AdmServer$env:COMPUTERNAME" -GroupScope Global -GroupCategory Security -Path $ouPath
    $fqdn = $_.DNSRoot
    ([adsi]"WinNT://./Administrators,group").Add("WinNT://$fqdn/AdmServer$env:COMPUTERNAME")

	#>
	[cmdletBinding()]
	Param (
		[Parameter(Mandatory = $True)]
		[string[]]$ComputerName,
		[Parameter(Mandatory = $True)]
		[string]$GroupName,
		[Parameter(Mandatory = $True)]
		[string]$Domain,
		[Parameter(Mandatory = $True)]
		[string]$Account
	)
	BEGIN
	{
		#Check in AD for SamAccountName
		$ADCheck = ([adsisearcher]"(samaccountname=$Account)").findone().properties['samaccountname']
		if ($SamAccountName -notmatch '\\')
		{
			$ADResolved = (Resolve-SamAccount -SamAccount $SamAccountName -Exit:$true)
			$SamAccountName = 'WinNT://', "$env:userdomain", '/', $ADResolved -join ''
		}
		else
		{
			$ADResolved = ($SamAccountName -split '\\')[1]
			$DomainResolved = ($SamAccountName -split '\\')[0]
			$SamAccountName = 'WinNT://', $DomainResolved, '/', $ADResolved -join ''
		}

	}
	PROCESS
	{
		$de = [ADSI]"WinNT://$computer/$Group,group"
		$de.psbase.Invoke("Add", ([ADSI]"WinNT://$domain/$user").path)
	}
	END
	{

	}
}