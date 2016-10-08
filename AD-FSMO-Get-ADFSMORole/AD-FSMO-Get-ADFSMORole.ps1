function Get-ADFSMORole
{
	<#
	.SYNOPSIS
		Retrieve the FSMO Role in the Forest/Domain.
	.DESCRIPTION
		Retrieve the FSMO Role in the Forest/Domain.
	.EXAMPLE
		Get-ADFSMORole
    .EXAMPLE
		Get-ADFSMORole -Credential (Get-Credential -Credential "CONTOSO\SuperAdmin")
    .NOTES
        Francois-Xavier Cat
        www.lazywinadmin.com
        @lazywinadm
		github.com/lazywinadmin
	#>
	[CmdletBinding()]
	PARAM (
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)#PARAM
	BEGIN
	{
		TRY
		{
			# Load ActiveDirectory Module if not already loaded.
			IF (-not (Get-Module -Name ActiveDirectory)) { Import-Module -Name ActiveDirectory -ErrorAction 'Stop' -Verbose:$false }
		}
		CATCH
		{
			Write-Warning -Message "[BEGIN] Something wrong happened"
			Write-Warning -Message $Error[0]
		}
	}
	PROCESS
	{
		TRY
		{
            
			IF ($PSBoundParameters['Credential'])
			{
                # Query with the credentials specified
				$ForestRoles = Get-ADForest -Credential $Credential -ErrorAction 'Stop' -ErrorVariable ErrorGetADForest
				$DomainRoles = Get-ADDomain -Credential $Credential -ErrorAction 'Stop' -ErrorVariable ErrorGetADDomain
			}
			ELSE
			{
                # Query with the current credentials
				$ForestRoles = Get-ADForest
				$DomainRoles = Get-ADDomain
			}
			
            # Define Properties
			$Properties = @{
				SchemaMaster = $ForestRoles.SchemaMaster
				DomainNamingMaster = $ForestRoles.DomainNamingMaster
				InfraStructureMaster = $DomainRoles.InfraStructureMaster
				RIDMaster = $DomainRoles.RIDMaster
				PDCEmulator = $DomainRoles.PDCEmulator
			}
			
			New-Object -TypeName PSObject -Property $Properties
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened"
			IF ($ErrorGetADForest) { Write-Warning -Message "[PROCESS] Error While retrieving Forest information"}
			IF ($ErrorGetADDomain) { Write-Warning -Message "[PROCESS] Error While retrieving Domain information"}
			Write-Warning -Message $Error[0]
		}
	}#PROCESS
}