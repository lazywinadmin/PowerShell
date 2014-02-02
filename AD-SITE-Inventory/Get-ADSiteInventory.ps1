function Get-ADSiteInventory {
<#
	.SYNOPSIS
		This function will retrieve information about the Sites and Services of the Active Directory

	.DESCRIPTION
		This function will retrieve information about the Sites and Services of the Active Directory

	.EXAMPLE
		Get-ADSiteInventory
	
	.EXAMPLE
		Get-ADSiteInventory | Export-Csv -Path .\ADSiteInventory.csv

	.OUTPUTS
		PSObject

	.NOTES
		AUTHOR	: Francois-Xavier Cat
		DATE	: 2014/02/02
		
		HISTORY	:
		1.0		2014/02/02	Initial Version
	
#>
	[CmdletBinding()]
    PARAM()
    BEGIN {Write-Verbose -Message "[BEGIN] Starting Script..."}
    PROCESS
    {
		TRY{
	        # Domain and Sites Information
	        $Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
	        $SiteInfo = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites

	        # Forest Context
	        $ForestType = [System.DirectoryServices.ActiveDirectory.DirectoryContexttype]"forest"
	        $ForestContext = New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ForestType,$Forest


	        FOREACH ($item in $SiteInfo){
				
				Write-Verbose -Message "[PROCESS] SITE: $($item.name)"
				
				# Get the Site Links
				Write-Verbose -Message "[PROCESS] SITE: $($item.name) - Getting Site Links"
	            $LinksInfo = ([System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::FindByName($forcntxt,$($item.name))).SiteLinks
				
				# Create PowerShell Object and Output
				Write-Verbose -Message "[PROCESS] SITE: $($item.name) - Preparing Output"
	            New-Object -TypeName PSObject -Property @{
	                Name= $item.Name
	                Subnets = $item.Subnets -join ','
	                SiteLinks = $item.SiteLinks -join ","
	                Servers = $item.Servers -join ","
	                Domains = $item.Domains -join ","
	                Options = $item.options
	                AdjacentSites = $item.AdjacentSites -join ','
	                InterSiteTopologyGenerator = $item.InterSiteTopologyGenerator
	                Location = $item.location
	                SiteLinksInfo = $LinksInfo
	                <#
	                SiteLinksInfo = New-Object -TypeName PSObject -Property @{
	                    SiteLinksCost = $LinksInfo.Cost -join ","
	                    ReplicationInterval = $LinksInfo.ReplicationInterval -join ','
	                    ReciprocalReplicationEnabled = $LinksInfo.ReciprocalReplicationEnabled -join ','
	                    NotificationEnabled = $LinksInfo.NotificationEnabled -join ','
	                    TransportType = $LinksInfo.TransportType -join ','
	                    InterSiteReplicationSchedule = $LinksInfo.InterSiteReplicationSchedule -join ','
	                    DataCompressionEnabled = $LinksInfo.DataCompressionEnabled -join ',' 
	                }
	                #>
	            }#New-Object -TypeName PSoBject
	        }#Foreach ($item in $SiteInfo)
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something Wrong Happened"
			Write-Warning -Message $Error[0]
		}#CATCH
    }#PROCESS
    END
	{
		Write-Verbose -Message "[END] Script Completed!"
	}#END
}#get-ADSiteServicesInfo

#get-ADSiteServicesInfo #| export-csv .\test.csv