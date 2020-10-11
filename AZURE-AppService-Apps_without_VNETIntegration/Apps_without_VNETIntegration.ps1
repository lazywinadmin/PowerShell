<#
.SYNOPSIS
Retrieve Apps using a App Service Plan without VNET Integration in the current Tenant

.DESCRIPTION
This script will do the following steps:

-Retrieve App Service Plan accross the Tenant
-Check if they have a VNET Integration present
-If Not, retrieve the WebApp using the App Service Plan
-Output the result
.EXAMPLE
    ./Apps_without_VNETIntegration.ps1

    Output the Apps using a App Service Plan without VNET Integration
.EXAMPLE
    ./Apps_without_VNETIntegration.ps1|
    Export-Csv report.csv

    Send the output to an excel report
.LINK
        https://github.com/lazywinadmin/PowerShell
.NOTES

# TODO
-Support for retries

# Resources
* List VnetIntegration in a particular RG for a App Service Plan
az appservice vnet-integration list -g <resource group name> --plan <app Service plan name>
* Creating VNET Integration
https://stackoverflow.com/questions/59976040/how-do-you-associate-an-azure-web-app-with-a-vnet-using-powershell-az

#>
[CmdletBinding()]
PARAM()
try{
    # Load Module
    $Dependencies=@("Az.ResourceGraph", "Az.Accounts")
    if(-not(Get-Module -Name $Dependencies)){$Dependencies| import-Module}
    # Functions
    function Get-AzToken{
    <#
    .SYNOPSIS
        Retrieve token of the current Azure Context session
    .DESCRIPTION
        Retrieve token of the current Azure Context session
        This is using the Get-AzContext cmdlets from the module Az.Account and assume a session is already opened.
    .EXAMPLE
        $token=Get-AzToken
        $uri = "https://management.azure.com/tenants?api-version=2019-11-01"
        invoke-restmethod -method get -uri $uri -Headers @{Authorization="Bearer $token";'Content-Type'='application/json'}
        This leverate the token of the current session to query the Azure Management
        API and retrieves all the tenants information
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
    }
    # Connect to Azure
    if(-not(Get-AzContext)){Connect-AzAccount}

    # Retrieve All the App Service Plan (ServerFarms) using Resource Graph
    $servicePlans=Search-AzGraph -Query "Resources | where type == 'microsoft.web/serverfarms'" -First 1000

    # Get Current token
    $token = Get-AzToken

    foreach ($sp in $serviceplans){
        Write-Verbose -Message "Service Plan: '$($sp.name)' - VNET Integration - Retrieving..."
        $uri = "https://management.azure.com/subscriptions/$($sp.subscriptionId)/resourceGroups/$($sp.resourcegroup)/providers/Microsoft.Web/serverfarms/$($sp.name)/virtualNetworkConnections?api-version=2019-08-01"
        $Result = invoke-restmethod -method get -uri $uri -Headers @{Authorization="Bearer $token";'Content-Type'='application/json'} -verbose:$false

        if(-not$result){
            Write-Verbose -Message "Service Plan: '$($sp.name)' - VNET Integration - Not present..."
            Write-Verbose -Message "Service Plan: '$($sp.name)' - Retrieving Apps using this App Service Plan..."
            $Apps = Search-AzGraph -Query "Resources |where properties.serverFarmId contains '$($sp.id)'" -first 1000

            foreach ($app in $apps)
            {
                [pscustomobject]@{
                    AppServicePlanName = $sp.name
                    AppServicePlanResourceId = $sp.id
                    AppName = $app.name
                    AppResourceId = $app.id
                    AppResourceType = $app.type
                }

            }
        }
    }
}catch{
    throw $_
}