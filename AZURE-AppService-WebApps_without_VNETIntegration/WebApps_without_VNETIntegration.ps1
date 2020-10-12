<#
.SYNOPSIS
Retrieve WebApps without VNET Integration in the current Tenant

.DESCRIPTION
This script will do the following steps:

-Using Resource Graph API:  Retrieve WebApp accross the tenant
-Using Management API:      Check if they have a VNET Integration present
-If Not, Output the WebApp information
.EXAMPLE
    ./WebApps_without_VNETIntegration.ps1

    Output the Apps using a App Service Plan without VNET Integration
.EXAMPLE
    ./WebApps_without_VNETIntegration.ps1|
    Export-Csv report.csv

    Send the output to an excel report
.LINK
        https://github.com/lazywinadmin/PowerShell
.NOTES

# TODO
-Support for retries
-Use Parallel call if v7.0+

# RESOURCES
* List VnetIntegration in a particular RG for a webapp
az webapp vnet-integration list
https://docs.microsoft.com/en-us/cli/azure/webapp/vnet-integration?view=azure-cli-latest
* WebApp integration with VNET
https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet#automation
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
    #$servicePlans=Search-AzGraph -Query "Resources | where type == 'microsoft.web/serverfarms'" -First 1000

    # Get Current token
    $token = Get-AzToken

    # Retrieve all the WebApp
    Write-Verbose -Message "WebApp - Retrieving WebApps in Tenant..."
    $Apps = Search-AzGraph -Query "Resources |where type == 'microsoft.web/sites' and kind contains 'app'"

    # Retrieve VNET Integration information for each
    $Apps | ForEach-Object -Process {
        $App = $_
        Write-Verbose -Message "WebApp - '$($App.Name)' - Retrieving VNET Integration..."
        $Uri="https://management.azure.com/subscriptions/$($app.subscriptionId)/resourceGroups/$($App.ResourceGroup)/providers/Microsoft.Web/sites/$($App.name)/virtualNetworkConnections?api-version=2019-08-01"
        Write-Verbose -Message "WebApp - '$($App.Name)' - Uri '$Uri'"
        $Result = invoke-restmethod -method get -uri $uri -Headers @{Authorization="Bearer $token";'Content-Type'='application/json'} -verbose:$false

        if(-not$result){
            Write-Verbose -Message "WebApp - '$($App.Name)' - DOT NOT HAVE VNET INTEGRATION"
            $App
        }
    }
}catch{
    throw $_
}