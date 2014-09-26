function Get-ADGPOReplication
{
	<#
	.SYNOPSIS
		This function retrieve one or all the GPO and report their DSVersions and SysVolVersions (Users and Computers)
	.DESCRIPTION
		This function retrieve one or all the GPO and report their DSVersions and SysVolVersions (Users and Computers)
	.PARAMETER GPOName
		Specify the name of the GPO
	.PARAMETER All
		Specify that you want to retrieve all the GPO (slow if you have a lot of Domain Controllers)
	.EXAMPLE
		Get-ADGPOReplication -GPOName "Default Domain Policy"
	.EXAMPLE
		Get-ADGPOReplication -All
	.NOTES
		Francois-Xavier Cat
		@lazywinadm
		lazywinadmin.com
	
		VERSION HISTORY
		1.0 2014.09.22 Initial version
	#>
	PARAM (
		[parameter(Mandatory = $True,ParameterSetName="One")]
		[String[]]$GPOName,
		[parameter(Mandatory = $True, ParameterSetName = "All")]
		[Switch]$All
	)
	BEGIN
	{
		if (-not (Get-Module -Name ActiveDirectory)) { Import-Module -Name ActiveDirectory -ErrorAction Stop}
		if (-not (Get-Module -Name GroupPolicy)) { Import-Module -Name GroupPolicy -ErrorAction Stop }
	}
	PROCESS
	{
		FOREACH ($DomainController in ((Get-ADDomainController -filter *).hostname))
		{
			TRY
			{
				IF ($psBoundParameters['GPOName'])
				{
                    Foreach ($GPOItem in $GPOName)
                    {
					    $GPO = Get-GPO -Name $GPOItem -Server $DomainController -ErrorAction Stop
					
					    [pscustomobject][ordered] @{
						    GroupPolicyName = $GPOItem
						    DomainController = $DomainController
						    UserVersion = $GPO.User.DSVersion
						    UserSysVolVersion = $GPO.User.SysvolVersion
						    ComputerVersion = $GPO.Computer.DSVersion
						    ComputerSysVolVersion = $GPO.Computer.SysvolVersion
					    }#PSObject
                    }#Foreach ($GPOItem in $GPOName)
				}#IF ($psBoundParameters['GPOName'])
				IF ($psBoundParameters['All'])
				{
					$GPOList = Get-GPO -All -Server $DomainController -ErrorAction Stop
					
					foreach ($GPO in $GPOList)
					{
						[pscustomobject][ordered] @{
							GroupPolicyName = $
							DomainController = $DomainController
							UserVersion = $GPO.User.DSVersion
							UserSysVolVersion = $GPO.User.SysvolVersion
							ComputerVersion = $GPO.Computer.DSVersion
							ComputerSysVolVersion = $GPO.Computer.SysvolVersion
						}#PSObject
					}
				}#IF ($psBoundParameters['All'])
			}#TRY
			CATCH
			{
				Write-Warning -Message "[PROCESS] Something wrong happened"
				Write-Warning -Message $Error[0].exception.message
			}
		}#FOREACH
	}#PROCESS
}