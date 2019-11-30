function Get-ADSiteAndSubnet {
    <#
    .SYNOPSIS
        This function will retrieve Site names, subnets names and descriptions.

    .DESCRIPTION
        This function will retrieve Site names, subnets names and descriptions.

    .EXAMPLE
        Get-ADSiteAndSubnet

    .EXAMPLE
        Get-ADSiteAndSubnet | Export-Csv -Path .\ADSiteInventory.csv

    .OUTPUTS
        PSObject

    .NOTES
        AUTHOR    : Francois-Xavier Cat
        DATE    : 2014/02/03

        HISTORY    :

            1.0        2014/02/03    Initial Version


#>
    [CmdletBinding()]
    PARAM()
    BEGIN { Write-Verbose -Message "[BEGIN] Starting Script..." }
    PROCESS {
        TRY {
            # Domain and Sites Information
            $Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
            $SiteInfo = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites

            # Forest Context
            $ForestType = [System.DirectoryServices.ActiveDirectory.DirectoryContexttype]"forest"
            $ForestContext = New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ForestType, $Forest

            # Distinguished Name of the Configuration Partition
            $Configuration = ([ADSI]"LDAP://RootDSE").configurationNamingContext

            # Get the Subnet Container
            $SubnetsContainer = [ADSI]"LDAP://CN=Subnets,CN=Sites,$Configuration"
            $SubnetsContainerchildren = $SubnetsContainer.Children

            FOREACH ($item in $SiteInfo) {

                Write-Verbose -Message "[PROCESS] SITE: $($item.name)"

                $output = @{
                    Name = $item.name
                }
                FOREACH ($i in $item.Subnets.name) {
                    Write-Verbose -message "[PROCESS] SUBNET: $i"
                    $output.Subnet = $i
                    $SubnetAdditionalInfo = $SubnetsContainerchildren.Where( { $_.name -match $i })

                    Write-Verbose -message "[PROCESS] SUBNET: $i - DESCRIPTION: $($SubnetAdditionalInfo.Description)"
                    $output.Description = $($SubnetAdditionalInfo.Description)

                    Write-Verbose -message "[PROCESS] OUTPUT INFO"

                    New-Object -TypeName PSObject -Property $output
                }
            }#Foreach ($item in $SiteInfo)
        }#TRY
        CATCH {
            $PSCmdlet.ThrowTerminatingError($_)
        }#CATCH
    }#PROCESS
    END {
        Write-Verbose -Message "[END] Script Completed!"
    }#END
}#get-ADSiteServicesInfo