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

		This will save all the site inventory to csv file
		
	.OUTPUTS
		PSObject

	.NOTES
		AUTHOR	: Francois-Xavier Cat
		DATE	: 2014/02/02
		VERSION HISTORY	:
			1.0 | 2014/02/02 | Francois-Xavier Cat
				Initial Version
			1.1 | 2014/02/02 | Francois-Xavier Cat
				Update some verbose messages
	
#>
	[CmdletBinding()]
    PARAM()
    PROCESS
    {
		TRY{
			# Get Script name
			$ScriptName = (Get-Variable -name MyInvocation -Scope 0 -ValueOnly).Mycommand

	        # Domain and Sites Information
			Write-Verbose -message "[$ScriptName][PROCESS] Retrieve current Forest"
	        $Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
			Write-Verbose -message "[$ScriptName][PROCESS] Retrieve current Forest sites"
	        $SiteInfo = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites

	        # Forest Context
			Write-Verbose -message "[$ScriptName][PROCESS] Create forest context"
	        $ForestType = [System.DirectoryServices.ActiveDirectory.DirectoryContexttype]"forest"
	        $ForestContext = New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ForestType,$Forest
            
            # Distinguished Name of the Configuration Partition
			Write-Verbose -message "[$ScriptName][PROCESS] Retrieve RootDSE Configuration Naming Context"
            $Configuration = ([ADSI]"LDAP://RootDSE").configurationNamingContext

            # Get the Subnet Container
			Write-Verbose -message "[$ScriptName][PROCESS] Get the Subnet Container"
            $SubnetsContainer = [ADSI]"LDAP://CN=Subnets,CN=Sites,$Configuration"

	        FOREACH ($item in $SiteInfo){
				
				Write-Verbose -Message "[$ScriptName][PROCESS] SITE: $($item.name)"
				
				# Get the Site Links
				Write-Verbose -Message "[$ScriptName][PROCESS] SITE: $($item.name) - Getting Site Links"
	            $LinksInfo = ([System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::FindByName($ForestContext,$($item.name))).SiteLinks
				
				# Create PowerShell Object and Output
				Write-Verbose -Message "[$ScriptName][PROCESS] SITE: $($item.name) - Preparing Output"

	            New-Object -TypeName PSObject -Property @{
	                Name= $item.Name
                    SiteLinks = $item.SiteLinks -join ","
	                Servers = $item.Servers -join ","
	                Domains = $item.Domains -join ","
	                Options = $item.options
	                AdjacentSites = $item.AdjacentSites -join ','
	                InterSiteTopologyGenerator = $item.InterSiteTopologyGenerator
	                Location = $item.location
                    Subnets = ( $info = Foreach ($i in $item.Subnets.name){
                        $SubnetAdditionalInfo = $SubnetsContainer.Children | Where-Object {$_.name -like "*$i*"}
                        "$i -- $($SubnetAdditionalInfo.Description)" }) -join ","
	                #SiteLinksInfo = $LinksInfo | fl *
	                
	                #SiteLinksInfo = New-Object -TypeName PSObject -Property @{
	                    SiteLinksCost = $LinksInfo.Cost -join ","
	                    ReplicationInterval = $LinksInfo.ReplicationInterval -join ','
	                    ReciprocalReplicationEnabled = $LinksInfo.ReciprocalReplicationEnabled -join ','
	                    NotificationEnabled = $LinksInfo.NotificationEnabled -join ','
	                    TransportType = $LinksInfo.TransportType -join ','
	                    InterSiteReplicationSchedule = $LinksInfo.InterSiteReplicationSchedule -join ','
	                    DataCompressionEnabled = $LinksInfo.DataCompressionEnabled -join ',' 
	                #}
	                #>
	            }#New-Object -TypeName PSoBject
	        }#Foreach ($item in $SiteInfo)
		}#TRY
		CATCH
		{
			# Return the last error
			$PSCmdlet.ThrowTerminatingError($_)
		}#CATCH
    }#PROCESS
    END
	{
		Write-Verbose -Message "[$ScriptName][END] Script Completed!"
	}#END
}#get-ADSiteServicesInfo

#get-ADSiteServicesInfo #| export-csv .\test.csv
Get-ADSiteInventory
