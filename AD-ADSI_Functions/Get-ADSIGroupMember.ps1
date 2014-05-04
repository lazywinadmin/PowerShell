Function Get-ADSIGroupMember
{
    <#
        .SYNOPSIS
            Return a collection of users in an ActiveDirectory group.
    #>
	[CmdletBinding()]
	Param
	(
		[parameter(Mandatory)]
		[String[]]$GroupName,
		[ADSI]$Domain
	)
	
	Begin
	{
		IF (-not ($Domain)) { $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry([ADSI]"") }
		ELSE { New-Object System.DirectoryServices.DirectoryEntry($Domain) }
		
		$DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
	}
	
	Process
	{
		foreach ($Item in ($DirectorySearcher.FindAll()))
		{
			
			$LDAPFilter = "(&(objectCategory=Group)(name=$GroupName))"
			
			$DirectorySearcher.SearchRoot = $DirectoryEntry
			$DirectorySearcher.PageSize = 1000
			$DirectorySearcher.Filter = $LDAPFilter
			$DirectorySearcher.SearchScope = "Subtree"
			
			$Group = $Item.GetDirectoryEntry()
			$Members = $Group.member
			
			If ($Members -ne $Null)
			{
				foreach ($User in $Members)
				{
					$UserObject = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$($User)")
					If ($UserObject.objectCategory.Value.Contains("Group"))
					{
					}
					Else
					{
						$ThisUser = New-Object -TypeName PSObject -Property @{
							cn = $UserObject.cn
							distinguishedName = $UserObject.distinguishedName
							name = $UserObject.name
							nTSecurityDescriptor = $UserObject.nTSecurityDescriptor
							objectCategory = $UserObject.objectCategory
							objectClass = $UserObject.objectClass
							objectGUID = $UserObject.objectGUID
							objectSID = $UserObject.objectSID
							showInAdvancedViewOnly = $UserObject.showInAdvancedViewOnly
						}
					}
					$UserAccounts += $ThisUser
				}
			}
		}
	}
	
	End
	{
		Return $UserAccounts
	}
}