Function Add-ADSubnet{
<#
    .SYNOPSIS
        This function allow you to add a subnet object in your active directory using ADSI

    .DESCRIPTION
        This function allow you to add a subnet object in your active directory using ADSI

    .PARAMETER  Subnet
        Specifies the Name of the subnet to add

    .PARAMETER  SiteName
        Specifies the Name of the Site where the subnet will be created

    .PARAMETER  Description
        Specifies the Description of the subnet

    .PARAMETER  Location
        Specifies the Location of the subnet

    .EXAMPLE
        Add-ADSubnet -Subnet "192.168.10.0/24" -SiteName MTL1

    This will create the subnet "192.168.10.0/24" and assign it to the site "MTL1".

    .EXAMPLE
        Add-ADSubnet -Subnet "192.168.10.0/24" -SiteName MTL1 -Description "Workstations VLAN 110" -Location "Montreal, Canada" -verbose

    This will create the subnet "192.168.10.0/24" and assign it to the site "MTL1" with the description "Workstations VLAN 110" and the location "Montreal, Canada"
    Using the parameter -Verbose, the script will show the progression of the subnet creation.


    .NOTES
        NAME:    FUNCT-AD-SITE-Add-ADSubnet_using_ADSI.ps1
        AUTHOR:    Francois-Xavier CAT 
        DATE:    2013/11/07
        EMAIL:    info@lazywinadmin.com
        WWW:    www.lazywinadmin.com
        TWITTER:@lazywinadm

        http://www.lazywinadmin.com/2013/11/powershell-add-ad-site-subnet.html

        VERSION HISTORY:
        1.0 2013.11.07
            Initial Version

#>
    [CmdletBinding()]
    PARAM(
        [Parameter(
            Mandatory=$true,
            Position=1,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Subnet name to create")]
        [Alias("Name")]
        [String]$Subnet,
        [Parameter(
            Mandatory=$true,
            Position=2,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Site to which the subnet will be applied")]
        [Alias("Site")]
        [String]$SiteName,
        [Parameter(
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Description of the Subnet")]
        [String]$Description,
        [Parameter(
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Location of the Subnet")]
        [String]$location
    )
    PROCESS{
            TRY{
                $ErrorActionPreference = 'Stop'

                # Distinguished Name of the Configuration Partition
                $Configuration = ([ADSI]"LDAP://RootDSE").configurationNamingContext

                # Get the Subnet Container
                $SubnetsContainer = [ADSI]"LDAP://CN=Subnets,CN=Sites,$Configuration"

                # Create the Subnet object
                Write-Verbose -Message "$subnet - Creating the subnet object..."
                $SubnetObject = $SubnetsContainer.Create('subnet', "cn=$Subnet")

                # Assign the subnet to a site
                $SubnetObject.put("siteObject","cn=$SiteName,CN=Sites,$Configuration")

                # Adding the Description information if specified by the user
                IF ($PSBoundParameters['Description']){
                    $SubnetObject.Put("description",$Description)
                }

                # Adding the Location information if specified by the user
                IF ($PSBoundParameters['Location']){
                    $SubnetObject.Put("location",$Location)
                }
                $SubnetObject.setinfo()
                Write-Verbose -Message "$subnet - Subnet added."
            }#TRY
            CATCH{
                Write-Warning -Message "An error happened while creating the subnet: $subnet"
                $error[0].Exception
            }#CATCH
    }#PROCESS Block
    END{
        Write-Verbose -Message "Script Completed"
    }#END Block
}#Function Add-ADSubnet