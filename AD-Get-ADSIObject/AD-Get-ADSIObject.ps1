function Get-ADSIObject
{
<#
	.SYNOPSIS
		PowerShell function to retrieve ADSI Properties of an object

	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		
		HISTORY
		1.0 2014/05/04 First Draft
		
		TODO
		Need to convert the Generalized-Time to DateTime
	
		Check info from http://mow001.blogspot.ca/2006/07/powershell-and-active-directory-part-3.html and
			http://www.lazywinadmin.com/2013/10/powershell-get-domainuser.html
#>

	
	[CmdletBinding()]
	PARAM (
		[parameter(mandatory)]
		[validateset('User', 'Computer', 'Contact', 'Group')] 
		[String]$ObjectCategory,
		[String]$Identity = "Admin"
	)
	
	$searcher = [adsisearcher]"(&(objectcategory=$ObjectCategory)(|(name=*$Identity*)(objectguid=*$Identity*)(distinguishedname=*$Identity*)(objectsid=*$Identity*)))"
	
	FOREACH ($obj in ($searcher.FindAll()))
	{
		Write-Verbose -Message "$($obj.properties.name -as [string])"
		New-Object -TypeName PSObject -Property @{
			Name = $obj.properties.name -as [string]
			SamAccountName = $obj.properties.samaccountname -as [string]
			DistinguishedName = $obj.properties.distinguishedname -as [string]
			ObjectSID = $obj.properties.objectsid
			ObjectGUID = $obj.properties.objectguid
			ObjectCategory = $obj.properties.objectcategory -as [string]
			ObjectClass = $obj.properties.objectclass -as [string]
			Description = $obj.properties.description -as [string]
			GroupType = $obj.properties.grouptype -as [string]
			WhenCreated = $obj.properties.whencreated
			WhenChanged = $obj.properties.whenchanged
			adspath = $obj.properties.adspath
			usncreated = $obj.properties.usncreated
			admincount = $obj.properties.admincount -as [int]
			systemflags = $obj.properties.systemflags
		}
	}
}

Get-ADSIObject -ObjectType 'Computer' -Identity 'test'