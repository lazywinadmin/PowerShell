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
        1.0 | 2014.09.22 | Francois-Xavier Cat
            Initial version
            Adding some more Error Handling
            Fix some typo
    #>
    #requires -version 3
    [CmdletBinding()]
    PARAM (
        [parameter(Mandatory = $True, ParameterSetName = "One")]
        [String[]]$GPOName,
        [parameter(Mandatory = $True, ParameterSetName = "All")]
        [Switch]$All
    )
    BEGIN
    {
        TRY
        {
            if (-not (Get-Module -Name ActiveDirectory)) { Import-Module -Name ActiveDirectory -ErrorAction Stop -ErrorVariable ErrorBeginIpmoAD }
            if (-not (Get-Module -Name GroupPolicy)) { Import-Module -Name GroupPolicy -ErrorAction Stop -ErrorVariable ErrorBeginIpmoGP }
        }
        CATCH
        {
            Write-Warning -Message "[BEGIN] Something wrong happened"
            IF ($ErrorBeginIpmoAD) { Write-Warning -Message "[BEGIN] Error while Importing the module Active Directory" }
            IF ($ErrorBeginIpmoGP) { Write-Warning -Message "[BEGIN] Error while Importing the module Group Policy" }
            Write-Warning -Message "[BEGIN] $($Error[0].exception.message)"
        }
    }
    PROCESS
    {
        FOREACH ($DomainController in ((Get-ADDomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetDC -filter *).hostname))
        {
            TRY
            {
                IF ($psBoundParameters['GPOName'])
                {
                    Foreach ($GPOItem in $GPOName)
                    {
                        $GPO = Get-GPO -Name $GPOItem -Server $DomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetGPO

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
                    $GPOList = Get-GPO -All -Server $DomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetGPOAll

                    foreach ($GPO in $GPOList)
                    {
                        [pscustomobject][ordered] @{
                            GroupPolicyName = $GPO.DisplayName
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
                IF ($ErrorProcessGetDC) { Write-Warning -Message "[PROCESS] Error while running retrieving Domain Controllers with Get-ADDomainController" }
                IF ($ErrorProcessGetGPO) { Write-Warning -Message "[PROCESS] Error while running Get-GPO" }
                IF ($ErrorProcessGetGPOAll) { Write-Warning -Message "[PROCESS] Error while running Get-GPO -All" }
                Write-Warning -Message "[PROCESS] $($Error[0].exception.message)"
            }
        }#FOREACH
    }#PROCESS
}
