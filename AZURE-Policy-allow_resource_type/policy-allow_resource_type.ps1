<#
.SYNOPSIS
    Retrieve Resource Provider Types, create an assignment
    for the policy definition 'Allowed resource types' and
    pass the resourcetypes as parameter (-listOfResourceTypesAllowed)
.DESCRIPTION
    Retrieve Resource Provider Types, create an assignment
    for the policy definition 'Allowed resource types' and
    pass the resourcetypes as parameter (-listOfResourceTypesAllowed)


    Script built with the help from a few resources:
    - https://stackoverflow.com/questions/49861955/list-of-all-azure-resource-types-in-azure
    - https://docs.microsoft.com/en-us/rest/api/resources/providers/list
    - https://docs.microsoft.com/en-us/rest/api/resources/providers/listattenantscope
    - https://docs.microsoft.com/en-us/azure/templates/microsoft.devices/iothub-allversions

.PARAMETER SubscriptionId
    Specify the subscriptionId to use
.PARAMETER PolicyDefinitionId
    Specify the PolicyDefinitionId to use
.PARAMETER PolicyAssignmentScope
    Specify on which resource the Policy Assignment need to apply
.PARAMETER AllowedNamespace
    Specify the

.EXAMPLE
    .\policy-allowed_resource_type.ps1 `
        -SubscriptionId '8f3a8176-f66f-420c-8fce-a797ac7cde89' `
        -PolicyDefinitionId '/subscriptions/8f3a8176-f66f-420c-8fce-a797ac7cde89/providers/Microsoft.Authorization/policyDefinitions/8c2f213e-decf-4016-a59e-5e7ce9903075' `
        -PolicyAssignmentScope '/subscriptions/8f3a8176-f66f-420c-8fce-a797ac7cde89/resourceGroups/LogicApp/' `
        -AllowedNamespace 'Microsoft.Compute','Microsoft.Storage','Microsoft.Network'

.EXAMPLE
    .\policy-allowed_resource_type.ps1 `
        -SubscriptionId '8f3a8176-f66f-420c-8fce-a797ac7cde89' `
        -PolicyDefinitionId '/subscriptions/8f3a8176-f66f-420c-8fce-a797ac7cde89/providers/Microsoft.Authorization/policyDefinitions/8c2f213e-decf-4016-a59e-5e7ce9903075' `
        -PolicyAssignmentScope '/subscriptions/8f3a8176-f66f-420c-8fce-a797ac7cde89/resourceGroups/LogicApp/'
.NOTES
Version history
1.0.0 | 2020/05/15 | Francois-Xavier Cat (github.com/lazywinadmin)
  initial version

TODO:
- Still missing a few resource types
    - Microsoft.Devices
        - IotHubs/certificates
    - Microsoft.Network
        - virtualNetworks/taggedTrafficConsumers
    - Microsoft.OperationalInsight
        - workspaces/views
    - Microsoft.Web
        - a bunch
        - hostingenvironments/metricdefinitions
        - hostingenvironments/metrics

    - Maybe investigate:
        - https://management.azure.com/providers/Microsoft.Authorization/providerOperations?api-version=2018-01-01-preview&$expand=resourceTypes#
#>

[CmdletBinding()]
param(
    [parameter(Mandatory)]
    $SubscriptionId,
    [parameter(Mandatory)]
    $PolicyDefinitionId,
    [parameter(Mandatory)]
    $PolicyAssignmentScope,
    [String[]]$AllowedNamespace
)
try{

    # Select Subscription context
    Write-Verbose -Message "Context - Set Context to Subscription id '$SubscriptionId'"
    Set-AzContext -Subscription $SubscriptionId

    # Resource Types from Resource Provider (on subscription level)
    if($AllowedNamespace){
        $SubProviders = $AllowedNamespace |
            ForEach-Object{
                Write-Verbose -Message "ResourceProvider - Namespace '$($_)' - Retrieving ..."
                Get-AzResourceProvider -ProviderNamespace $_
            }
    }else{
        # Retrieve Providers
        Write-Verbose -Message "ResourceProvider - All namespaces - Retrieving ..."
        $SubProviders = Get-AzResourceProvider -ListAvailable
    }

    # Resource Types from Policy Aliases (on subscription level)
    if($AllowedNamespace){
        $AllAliases = $AllowedNamespace |
            ForEach-Object{
                Write-Verbose -Message "PolicyAliases - Namespace '$($_)' - Retrieving ..."
                Get-AzPolicyAlias -Namespace $_
            }

    }else{
        Write-Verbose -Message "PolicyAliases - All namespaces - Retrieving ..."
        $AllAliases = Get-AzPolicyAlias -ListAvailable
    }


    # Process output from ResourceProvider and PolicyAliases
    Write-Verbose -Message "ResourceProvider/PolicyAliases - Processing output..."
    $SubResourceTypes = $SubProviders |
        Sort-Object -property ProviderNamespace |
        ForEach-Object {
            #Capture current namespace
            $CurrentNamespace = $_.ProviderNamespace

            # Output Resource type from resource providers
            $_.ResourceTypes |
                ForEach-Object{"$CurrentNamespace/$($_.ResourceTypeName)"}

            # Output Resource type from policy aliases
            $AllAliases|
                Where-Object{$_.Namespace -eq $CurrentNamespace}|
                ForEach-Object{"$($_.Namespace)/$($_.ResourceType)"}
    }


    # Retrieve ResourceTypes on Tenant level
    Write-Verbose -Message "ResourceProvider (Tenant scope) - Retrieving current access token..."
    $currentAzureContext = Get-AzContext
    $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile;
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile);
    $token=$profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId).AccessToken;

    # Build Invoke-RestMethod header
    $authHeader = @{
        'Content-type' = 'application/json'
        'Authorization'="Bearer $token"
        #'ExpiresOn'=$accessToken.expires_in
    }

    # Providers - Tenant level
    #  https://docs.microsoft.com/en-us/rest/api/resources/providers/listattenantscope

    if($AllowedNamespace){
        $TenantResourceTypes = $AllowedNamespace |
            ForEach-Object {
                $ResourceProvider = $_
                Write-Verbose -Message "ResourceProvider (Tenant scope) - Retrieving for Namespace '$ResourceProvider'..."

                $uri = "https://management.azure.com/providers/$($ResourceProvider)?api-version=2019-10-01"
                $result = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeader
                $result.resourceTypes.resourceType |
                    ForEach-Object {"$ResourceProvider/$($_)"}
            }
    }else{
        Write-Verbose -Message "ResourceProvider (Tenant scope) - Retrieving all Namespaces ..."
        $uri = "https://management.azure.com/providers?`$expand=resourceTypes/aliases&api-version=2019-10-01"
        $result = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeader
        $TenantResourceTypes = $result.value |
            ForEach-Object {
                $ResourceProvider = $_.namespace
                $_.resourceTypes|
                    ForEach-Object{"$ResourceProvider/$($_.resourceType)"}
            }
    }

    Write-Verbose -Message "Processing final list..."
    $finalList = ($TenantResourceTypes + $SubResourceTypes)|
        Select-Object -Unique

    # $finalList=$finalList | %{
    #     $splitted=$_ -split '\/'
    #     if($splitted.count -gt 2){
    #         "$($splitted[0..1] -join '/')/*"
    #     }
    #     else{$splitted -join '/'}
    # }|select -Unique

    # Retrieve Policy Definition
    Write-Verbose -Message "Policy - Retrieving Definition '$PolicyDefinitionId'..."
    $def = Get-AzPolicyDefinition -Id $PolicyDefinitionId

    # Create Policy Assignment
    Write-Verbose -Message "Policy - Creating assignment ..."
    New-AzPolicyAssignment `
        -Name 'testing-allowed-resource' `
        -Scope $PolicyAssignmentScope `
        -listOfResourceTypesAllowed $finalList `
        -PolicyDefinition $def `
        -OutVariable NewAssign

    #Remove-AzPolicyAssignment -Id $NewAssign

}catch{
    throw $_
}