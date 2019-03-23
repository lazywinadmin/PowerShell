Function Get-AccountLockedOut
{

<#
.SYNOPSIS
    This function will find the device where the account get lockedout
.DESCRIPTION
    This function will find the device where the account get lockedout.
    It will query directly the PDC for this information

.PARAMETER DomainName
    Specifies the DomainName to query, by default it takes the current domain ($env:USERDOMAIN)
.PARAMETER UserName
    Specifies the DomainName to query, by default it takes the current domain ($env:USERDOMAIN)
.EXAMPLE
    Get-AccountLockedOut -UserName * -StartTime (Get-Date).AddDays(-5) -Credential (Get-Credential)

    This will retrieve the all the users lockedout in the last 5 days using the credential specify by the user.
    It might not retrieve the information very far in the past if the PDC logs are filling up very fast.

.EXAMPLE
    Get-AccountLockedOut -UserName "Francois-Xavier.cat" -StartTime (Get-Date).AddDays(-2)
#>

    #Requires -Version 3.0
    [CmdletBinding()]
    param (
        [string]$DomainName = $env:USERDOMAIN,
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]$UserName = '*',
        [datetime]$StartTime = (Get-Date).AddDays(-1),
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    BEGIN
    {
        TRY
        {
            #Variables
            $TimeDifference = (Get-Date) - $StartTime

            Write-Verbose -Message "[BEGIN] Looking for PDC..."

            function Get-PDCServer
            {
    <#
    .SYNOPSIS
        Retrieve the Domain Controller with the PDC Role in the domain
    #>
                PARAM (
                    $Domain = $env:USERDOMAIN,
                    $Credential = [System.Management.Automation.PSCredential]::Empty
                )

                IF ($PSBoundParameters['Credential'])
                {

                    [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(
                    (New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList 'Domain', $Domain, $($Credential.UserName), $($Credential.GetNetworkCredential().password))
                    ).PdcRoleOwner.name
                }#Credentials
                ELSE
                {
                    [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(
                    (New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain', $Domain))
                    ).PdcRoleOwner.name
                }
            }#function Get-PDCServer

            Write-Verbose -Message "[BEGIN] PDC is $(Get-PDCServer)"
        }#TRY
        CATCH
        {
            Write-Warning -Message "[BEGIN] Something wrong happened"
            Write-Warning -Message $Error[0]
        }

    }#BEGIN
    PROCESS
    {
        TRY
        {
            # Define the parameters
            $Splatting = @{ }

            # Add the credential to the splatting if specified
            IF ($PSBoundParameters['Credential'])
            {
                Write-Verbose -Message "[PROCESS] Credential Specified"
                $Splatting.Credential = $Credential
                $Splatting.ComputerName = $(Get-PDCServer -Domain $DomainName -Credential $Credential)
            }
            ELSE
            {
                $Splatting.ComputerName =$(Get-PDCServer -Domain $DomainName)
            }

            # Query the PDC
            Write-Verbose -Message "[PROCESS] Querying PDC for LockedOut Account in the last Days:$($TimeDifference.days) Hours: $($TimeDifference.Hours) Minutes: $($TimeDifference.Minutes) Seconds: $($TimeDifference.seconds)"
            Invoke-Command @Splatting -ScriptBlock {

                # Query Security Logs
                Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4740; StartTime = $Using:StartTime } |
                Where-Object { $_.Properties[0].Value -like "$Using:UserName" } |
                Select-Object -Property TimeCreated,
                              @{ Label = 'UserName'; Expression = { $_.Properties[0].Value } },
                              @{ Label = 'ClientName'; Expression = { $_.Properties[1].Value } }
            } | Select-Object -Property TimeCreated, UserName, ClientName
        }#TRY
        CATCH
        {

        }
    }#PROCESS
}
