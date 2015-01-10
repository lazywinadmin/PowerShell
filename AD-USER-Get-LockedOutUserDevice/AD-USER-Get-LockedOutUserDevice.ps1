Function Get-LockedOutUserDevice
{
#Requires -Version 3.0
[CmdletBinding()]
param (
	[string]$DomainName = $env:USERDOMAIN,
	[string]$UserName = "*",
	[datetime]$StartTime = (Get-Date).AddDays(-1),
    $Credential
)
BEGIN{
    function Get-PDCServer {
        <#
        .SYNOPSIS
            Retrieve the Domain Controller with the PDC Role in the domain
        #>
        [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(
            (New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain', $DomainName))
        ).PdcRoleOwner.name
    
    }

}#BEGIN
PROCESS{
    $Splatting = @{
        ComputerName = $(Get-PDCServer)
    }

    IF($PSBoundParameters['Credential']){$Splatting.Credential = $Credential}
    Invoke-Command @Splatting -ScriptBlock {
            #
	        Get-WinEvent -FilterHashtable @{
                LogName = 'Security';
                Id = 4740;
                StartTime = $Using:StartTime} |
	        Where-Object { $_.Properties[0].Value -like "$Using:UserName" } |
	        Select-Object -Property TimeCreated,
				          @{ Label = 'UserName'; Expression = { $_.Properties[0].Value } },
				          @{ Label = 'ClientName'; Expression = { $_.Properties[1].Value } }
    } | Select-Object -Property TimeCreated, UserName, ClientName

}#PROCESS
}