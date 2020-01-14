
<#PSScriptInfo

.VERSION 1.0

.GUID f2d5adaf-ed37-4dcc-96d5-2ac72b770cf8

.AUTHOR Francois-Xavier Cat

.COMPANYNAME

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI
    https://github.com/lazywinadmin/PowerShell

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>

<#
.SYNOPSIS
    Retrieve Azure Policy Compliance Data for a specific Assignment under a specific ManagementGroupName
.DESCRIPTION
    Retrieve Azure Policy Compliance Data for a specific Assignment under a specific ManagementGroupName
    This will also retrieve the subscription name

    This script assume you are already connected and authenticated to Azure.

.PARAMETER ManagementGroupName
    Specify the ManagementGroupName

.PARAMETER AssignmentID
    Specify the AssignmentID

.EXAMPLE
    Get-PolicyComplianceData.ps1 -ManagementGroupName <id> -AssignmentID <id>

.LINK
    https://github.com/lazywinadmin/PowerShell

#>
[CmdletBinding()]
Param(
    $ManagementGroupName,
    $AssignmentID
)
try{
    # Retrieve the Compliance data
    $State = Get-AzPolicyState -ManagementGroupName $ManagementGroupName -Filter "(AssignmentID eq $AssignmentID)"

    $SubscriptionNames = $State | Group-Object -Property SubscriptionId | ForEach-Object -Process {
        Get-AzSubscription -SubscriptionId $_.Name
    }

    $State | Select-Object -Property *,@{
        Label='SubscriptionName';
        Expression=@{
            #keep current state in var
            $CurrentState=$_
            # retrieve sub name
            ($SubscriptionNames | Where-Object -Filter {$_.id -eq $currentState.subscriptionid}).name
        }
    }
}catch{
    throw $_
}