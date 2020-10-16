function get-ImmutableIDfromUPN
{ 

    <#
    .SYNOPSIS
        Converts AD User Object GUID to Office 365 Immutable ID

    .DESCRIPTION
        This function will convert an AD Object GUID to an Office 365 User ImmutableID

    .EXAMPLE
        get-ImmutableIDfromADObject -UserPrincipalname myuser@contoso.com

    .OUTPUTS
        String

    .link
        https://github.com/lazywinadmin/PowerShell
#>


    [CmdletBinding()] Param( 
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]$UserPrincipalname)  
   process{  
        $ADObject =   Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalname'"
        if (!$ADObject.objectguid){$ADObject = get-adobject $AdObject -properties objectGuid} 
        [system.convert]::ToBase64String($ADObject.objectguid.tobytearray()) 
    } 
} 
