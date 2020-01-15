function Get-AzureIPRangesAndServiceTags {
<#
.SYNOPSIS

Retrieve the Ip address ranges and Service Tags ranges for Azure (Public, USgov, Germnay or China)
The function return a Json. This can be passed to '|Converfrom-json' if you wish
to get a PowerShell object.

This information is pulled from Microsoft Download pages.

'Public' = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519'
'USGov' = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=57063'
'China' = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=57062'
'Germany' = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=57064'

.DESCRIPTION

This file contains the IP address ranges for Public Azure as a whole, each
Azure region within Public, and ranges for several Azure Services (Service Tags)
such as Storage, SQL and AzureTrafficManager in Public. This file currently
includes only IPv4 address ranges but a schema extension in the near future
will enable us to support IPv6 address ranges as well. Service Tags are each
expressed as one set of cloud-wide ranges and broken out by region within that
cloud.  This file is updated weekly. New ranges appearing in the file will not
be used in Azure for at least one week. Please download the new json file every
week and perform the necessary changes at your site to correctly identify
services running in Azure. These service tags can also be used to simplify
the Network Security Group rules for your Azure deployments though some
service tags might not be available in all clouds and regions.
For more information please visit http://aka.ms/servicetags

.PARAMETER Cloud
    Specify the type of cloud.
    Default is 'Public'

    Accepted Values: 'Public','USGov','Germany','China'
.EXAMPLE
Get-AzureIPRangesAndServiceTags

Retrieve the IP Ranges and Service Tags Ranges for Public Cloud
This will output the Json File

.EXAMPLE
Get-AzureIPRangesAndServiceTags | ConvertFrom-Json

Retrieve the IP Ranges and Service Tags Ranges for Public Cloud
The Json is converted to a PowerShell Object

.EXAMPLE
Get-AzureIPRangesAndServiceTags -Cloud China

Retrieve the IP Ranges and Service Tags Ranges for China
This will output the Json File

.NOTES
Version History
1.0 | 2020/01/14 | Francois-Xavier Cat
    Initial version
.LINK
https://github.com/lazywinadmin/PowerShell

#>
[CmdletBinding()]
param(
    [ValidateSet('Public','USGov','Germany','China')]
    [system.string]
    $Cloud = "Public"
)
try{
    switch($Cloud){
        'USGov' {$downloadUri = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=57063'}
        'China' {$downloadUri = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=57062'}
        'Germany' {$downloadUri = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=57064'}
        default {$downloadUri = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519'}
    }

    Write-Verbose -Message "Retrieving Download link..."
    $downloadPage = Invoke-WebRequest -Uri $downloadUri
    $jsonFileUri = ($downloadPage.RawContent.Split('"') -like "https://*ServiceTags*")[0]

    if($jsonFileUri){
        Write-Verbose -Message "Downloading '$jsonFileUri'..."
        $TempFile = New-TemporaryFile
        Invoke-WebRequest -Uri $jsonFileUri -outfile $TempFile

        Get-Content -Path $TempFile -Raw
    }else{
        Write-Error -Message "Failed to find the download link in the page '$downloadUri'"
    }
}catch{
    $PSCmdlet.ThrowTerminatingError($_)
}
}
