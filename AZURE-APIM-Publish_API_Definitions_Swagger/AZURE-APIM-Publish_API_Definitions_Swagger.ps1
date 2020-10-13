<#
.SYNOPSIS
Script to publish API definitions to Azure APIM via OpenAPI Swagger URL.
.DESCRIPTION
Script to publish API definitions to Azure APIM via OpenAPI Swagger URL, with a healthcheck endpoint for liveness check.

The script works for those who are using Swagger as a API documentation (see more https://swagger.io/)

Please ensure that this script will run after web server has been updated accordingly.

Please ensure that web server SSL certificate is trusted.

.PARAMETER ApiId
Specify the ID of the API to publish.

.PARAMETER ApiPath
Specify a web API path as the last part of the API's public URL.

.PARAMETER SwaggerUrl
Specify the Swagger OpenAPI JSON or YAML file (e.g. https://example.com/v2/api-docs)

.PARAMETER ResourceGroup
Specify the Resource Group of desired APIM.

.PARAMETER ApimServiceName
Specify APIM name.

.EXAMPLE
/AZURE-APIM-Publish_API_Definitions_Swagger.ps1 -ResourceGroup "MyRG" -ApiId "MyApp" -ApiPath "swagger" -SwaggerUrl "https://example.com/v2/api-docs" -ApimServiceName "MyApim"

.NOTES

VERSION HISTORY
1.0 | 2020/10/113 | Raksit Mantanacharu (raksit.m@ku.th)
    initial version
#>
[cmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string] $ApiId,
    [Parameter(Mandatory = $true)]
    [string] $ApiPath,
    [Parameter(Mandatory = $true)]
    [string] $SwaggerUrl,
    [Parameter(Mandatory = $true)]
    [string] $ResourceGroup,
    [Parameter(Mandatory = $true)]
    [string] $ApimServiceName,
)
$ApiMgmtContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroup -ServiceName $ApimServiceName
Import-AzApiManagementApi -Context $ApiMgmtContext -SpecificationFormat "Swagger" -SpecificationUrl $SwaggerUrl -Path $ApiPath -ApiId $ApiId

New-AzApiManagementOperation -Context $ApiMgmtContext -ApiId $ApiId -OperationId "getHealthUsingGET" -Name "health probe" -Method "GET" -UrlTemplate "/healthz/liveness" -Description "Use this operation to get liveness status"
