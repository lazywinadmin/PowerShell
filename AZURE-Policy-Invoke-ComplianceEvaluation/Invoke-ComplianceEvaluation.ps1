function Invoke-ComplianceEvaluation {
    <#
    .SYNOPSIS
        Function to trigger compliance evalution for Azure Policies on a specific Resource Group or Subscription
    .description
        The code assume you are already authenticated to azure
    .example
        # Load the function
        . ./invoke-complianceevaluation
        # Trigger Policy Compliance evaluation against current subscription
        Invoke-ComplianceEvaluation
    .example
        # Load the function
        . ./invoke-complianceevaluation
        # Trigger Policy Compliance evaluation against specified subscription
        Invoke-ComplianceEvaluation -subscriptionid <uid>
    .example
        # Load the function
        . ./invoke-complianceevaluation
        # Trigger Policy Compliance evaluation against specified resource group in the current subscription
        Invoke-ComplianceEvaluation -ResourceGroupName MyRg

    .example
        # Load the function
        . ./invoke-complianceevaluation
        # Trigger Policy Compliance evaluation against specified resource group in the specified subscription
        Invoke-ComplianceEvaluation -ResourceGroupName MyRg -subscriptionid <uid>

    #>
    [CmdletBinding()]
    param($resourceGroupName,$subscriptionId)

    if(-not $subscriptionId){
        $subscriptionId = (Get-AzContext).subscription.id
    }
    $uri = "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2018-07-01-preview"

    if ($resourceGroupName){
        $uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2018-07-01-preview"
    }
    
    Write-verbose -message "uri = '$uri'"
    Write-verbose -message "Retrieving Context..."
    $azContext = Get-AzContext
    $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
    $token = $profileClient.AcquireAccessToken($azContext.Tenant.Id)
    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'='Bearer ' + $token.AccessToken
    }
    Write-verbose -message "Invoking TriggerEvaluation..."
    Invoke-RestMethod -Method Post -Uri $uri -UseBasicParsing -Headers $authHeader
}
