<#
.SYNOPSIS
Script to update or overwrite App Service IP Rules Restriction based on a CSV file provided
.DESCRIPTION
Script to update or overwrite App Service IP Rules Restriction based on a CSV file provided

The script only validate the IPAddress property to defined if an IP Rule is already present.
It does not check the other properties such as Priority, Name, Description, ...

The script will output the IPRules present on the App Service in the output.

.PARAMETER SubscriptionId
Specify the SubscriptionID

.PARAMETER ResourceGroupName
Specify the Resource Group Name where the App Service is located

.PARAMETER AppServiceName
Specify the App Service Name

.PARAMETER Path
Specify the Path to the CSV File.

.PARAMETER Overwrite
Specify if you want to overwrite all the ip rules

.EXAMPLE
/AppService-Update_RestrictionIP.ps1 -ResourceGroupName "MyRG" -AppServiceName "MyApp" -SubscriptionId '<GUID>' -Path ./source.csv -verbose

Append ip rules not already present. The script only checks if the IP/CIDR is present, it does not check the other properties

.EXAMPLE
/AppService-Update_RestrictionIP.ps1 -ResourceGroupName "MyRG" -AppServiceName "MyApp" -SubscriptionId '<GUID>' -Path ./source.csv -overwrite -verbose

Erase all existing rules and append the one specified in the CSV file

.NOTES

VERSION HISTORY
1.0 | 2020/06/11 | Francois-Xavier Cat (lazywinadmin.com)
    initial version
#>
[cmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string] $AppServiceName,
    [Parameter(Mandatory = $true)]
    [string] $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string] $Path,
    [Switch]$Overwrite
)
try {
    $ErrorActionPreference = "Stop"

    # Load dependencies
    Write-Verbose -Message "Loading modules..."
    Import-Module Az.Accounts -verbose:$false
    Import-Module Az.Resources -verbose:$false

    # Load CSV
    Write-Verbose -Message "Loading CSV File '$Path'..."
    $FileContent = Import-Csv -path $Path
    if($null -eq $FileContent){
        Write-Error -Message "CSV file is empty or not able to import"
    }

    # Establish connection to Azure if not already connected
    Write-Verbose -Message "Checking connection to Azure..."
    $GetContext = Get-AzContext
    if($Null -eq $GetContext){
        Connect-AzAccount
    }

    # Set Context
    if($GetContext.Subscription.id -ne $SubscriptionId){
        Write-Verbose -Message "Switching context to subscription '$SubscriptionId'..."
        Set-AzContext -Subscription $SubscriptionId
    }else{
        Write-Verbose -Message "Context already on subscription '$SubscriptionId'"
    }

    # API Version
    Write-Verbose -Message "Retrieving API Version..."
    $APIVersion = ((Get-AzResourceProvider -ProviderNamespace Microsoft.Web).ResourceTypes | Where-Object ResourceTypeName -eq sites).ApiVersions[0]

    # Get App Service
    Write-Verbose -Message "Retrieving App Service information..."
    $WebAppConfig = Get-AzResource -ResourceName $AppServiceName -ResourceType Microsoft.Web/sites/config -ResourceGroupName $ResourceGroupName -ApiVersion $APIVersion

    if($Overwrite){
        Write-Verbose -Message "Erasing all the current IP Rules (not applied yet)"
        $WebAppConfig.Properties.ipSecurityRestrictions = @()
        $Changes = $true
    }

    foreach ($NewIpRule in $FileContent) {
        if($NewIpRule.IPAddress -notin $WebAppConfig.Properties.ipSecurityRestrictions.IPAddress){
            Write-Verbose -Message "Adding $($NewIPRule.IPAddress) (not applied yet) ..."
            $WebAppConfig.Properties.ipSecurityRestrictions += $NewIpRule

            $Changes = $true
        }
        else{Write-Verbose -Message "Skip $($NewIPRule.IPAddress). IPAddress already in the rules."}
    }

    if($Changes){
        Write-Verbose -Message "Applying changes..."
        (Set-AzResource -ResourceId $WebAppConfig.ResourceId -Properties $WebAppConfig.Properties -ApiVersion $APIVersion).Properties.ipSecurityRestrictions
    }else{
        Write-Verbose -Message "No Change to apply."
        $WebAppConfig.Properties.ipSecurityRestrictions
    }
}catch{
    Throw $_
}