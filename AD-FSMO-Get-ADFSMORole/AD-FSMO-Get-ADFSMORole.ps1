function Get-ADFSMORole
{
<#
.SYNOPSIS
    Retrieve the FSMO Role in the Forest/Domain.
.DESCRIPTION
    Retrieve the FSMO Role in the Forest/Domain.
.PARAMETER Credential
    Specify the alternative credential to use
.EXAMPLE
    Get-ADFSMORole
.EXAMPLE
    Get-ADFSMORole -Credential (Get-Credential -Credential "CONTOSO\SuperAdmin")
.NOTES
    Francois-Xavier Cat
    www.lazywinadmin.com
    @lazywinadm
    github.com/lazywinadmin

    1.0 | 2016/00/00 | Francois-Xavier Cat
        Initial Version
    1.1 | 2017/11/01 | Francois-Xavier Cat
        Update Error handling
        Update logic
        Remove warning messages
        Replace tabs with spaces
#>
    [CmdletBinding()]
    PARAM (
        [Alias("RunAs")]
        [System.Management.Automation.Credential()]
        [pscredential]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )#PARAM
    TRY
    {
        # Load ActiveDirectory Module if not already loaded.
        IF (-not (Get-Module -Name ActiveDirectory)) { Import-Module -Name ActiveDirectory -ErrorAction 'Stop' -Verbose:$false }

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
        $PSCmdlet.ThrowTerminatingError($_)
    }
}