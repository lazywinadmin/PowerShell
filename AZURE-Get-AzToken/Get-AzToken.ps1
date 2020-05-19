<#
.SYNOPSIS
    Retrieve token of the current Azure Context session
.DESCRIPTION
    Retrieve token of the current Azure Context session
    This is using the Get-AzContext cmdlets from the module Az.Account and assume a session is already opened.

.EXAMPLE
    Get-AzToken

.LINK
    https://github.com/lazywinadmin/PowerShell

#>
[CmdletBinding()]
Param()
try{
    $currentAzureContext = Get-AzContext
    $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile;
    $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId).AccessToken
}catch{
    throw $_
}