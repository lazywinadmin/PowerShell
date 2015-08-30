function Get-LocalAdministratorBuiltin
{
	#function to get the BUILTIN LocalAdministrator
	#http://blog.simonw.se/powershell-find-builtin-local-administrator-account/
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$ComputerName
	)
	Process
	{
		Foreach ($Computer in $ComputerName)
		{
			Try
			{
				Add-Type -AssemblyName System.DirectoryServices.AccountManagement
				$PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine, $Computer)
				$UserPrincipal = New-Object System.DirectoryServices.AccountManagement.UserPrincipal($PrincipalContext)
				$Searcher = New-Object System.DirectoryServices.AccountManagement.PrincipalSearcher
				$Searcher.QueryFilter = $UserPrincipal
				$Searcher.FindAll() | Where-Object { $_.Sid -Like "*-500" }
			}
			Catch
			{
				Write-Warning -Message "$($_.Exception.Message)"
			}
		}
	}
}