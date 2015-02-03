Function Test-ADCredential {
	Param($username, $password, $domain)
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	$ct = [System.DirectoryServices.AccountManagement.ContextType]::Domain
	$pc = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($ct, $domain)
	New-Object PSObject -Property @{
		UserName = $username;
		IsValid = $pc.ValidateCredentials($username, $password).ToString()
	}
}
