function Get-LocalGroupMember {
    <#
    .SYNOPSIS
        Retrieve a Local Group membership
    .DESCRIPTION
        Retrieve a Local Group membership
    .PARAMETER ComputerName
        Specifies one or computers to query
    .PARAMETER GroupName
        Specifies the Group name
    .EXAMPLE
        Get-LocalGroupMember
    .NOTES
        Francois-Xavier Cat
        @lazywinadmin
        lazywinadmin.com

        To Add:
            Credential param
            Resurce Local and AD using ADSI or ActiveDirectory Module
            OnlyUser param
#>
    [CmdletBinding()]
    PARAM (
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [System.String[]]$ComputerName = $env:COMPUTERNAME,
        [System.String]$GroupName = "Administrators"
    )
    BEGIN {
        TRY {
            Add-Type -AssemblyName System.DirectoryServices.AccountManagement -ErrorAction 'Stop' -ErrorVariable ErrorBeginAddType
            $ctype = [System.DirectoryServices.AccountManagement.ContextType]::Machine
        }
        CATCH {
            Write-Warning -Message "[BEGIN] Something wrong happened"
            IF ($ErrorBeginAddType) { Write-Warning -Message "[BEGIN] Error while loading the Assembly: System.DirectoryServices.AccountManagement" }
            Write-Warning -Message $Error[0].Exception.Message
        }
    }
    PROCESS {
        FOREACH ($Computer in $ComputerName) {
            TRY {
                $context = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $ctype, $computer
                $idtype = [System.DirectoryServices.AccountManagement.IdentityType]::SamAccountName
                $group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($context, $idtype, $GroupName)
                $group.Members | Select-Object *, @{ Label = 'Server'; Expression = { $computer } }, @{ Label = 'Domain'; Expression = { $_.Context.Name } }
            }
            CATCH {
                Write-Warning -Message "[PROCESS] Something wrong happened"
                Write-Warning -Message $Error[0].Exception.Message
            }
        }
    }
}