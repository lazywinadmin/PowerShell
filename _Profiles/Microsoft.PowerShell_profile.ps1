<#	
	.SYNOPSIS
		Profile File
	.DESCRIPTION
		Profile File
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
#>

#########################
# Window, Path and Help #
#########################
# Set the Path
Set-Location -Path c:\lazywinadmin
# Refresh Help
Start-Job -Name "UpdateHelp" -ScriptBlock { Update-Help -Force } | Out-null
Write-Host "Updating Help in background (Get-Help to check)" -ForegroundColor 'DarkGray'
# Show PS Version and date/time
Write-host "PowerShell Version: $($psversiontable.psversion) - ExecutionPolicy: $(Get-ExecutionPolicy)" -for yellow

<#
# Check Admin Elevation
$WindowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$WindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($WindowsIdentity)
$Administrator = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$IsAdmin = $WindowsPrincipal.IsInRole($Administrator)

# Custom Window
#  Set Window Title
if ($isAdmin)
{
	$host.UI.RawUI.WindowTitle = "Administrator: $ENV:USERNAME@$ENV:COMPUTERNAME - $env:userdomain"
}
else
{
	$host.UI.RawUI.WindowTitle = "$ENV:USERNAME@$ENV:COMPUTERNAME - $env:userdomain"
}
#>

###############
# Credentials #
###############



##########
# Module #
##########
#  PSReadLine
Import-Module -Name PSReadline

#########
# Alias #
#########
Set-Alias -Name npp -Value notepad++.exe
Set-Alias -Name np -Value notepad.exe
if (Test-Path $env:USERPROFILE\OneDrive){$OneDriveRoot = "$env:USERPROFILE\OneDrive"}

#############
# Functions #
#############

<#

# This will change the prompt
function prompt
{
	#Get-location
	Write-output "PS [LazyWinAdmin.com]> "
}
#>

# Get the current script directory
function Get-ScriptDirectory
{
	if ($hostinvocation -ne $null)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}


# DOT Source External Functions
$currentpath = Get-ScriptDirectory
. (Join-Path -Path $currentpath -ChildPath "\functions\Show-Object.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\Connect-Office365.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\Test-Port.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\Get-NetAccelerator.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\Clx.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\Test-DatePattern.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\View-Cats.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\Find-Apartment.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\Launch-AzurePortal.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\Launch-ExchangeOnline.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\Launch-InternetExplorer.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\Launch-Office365Admin.ps1")


#########
# Other #
#########

# Learn something today (show a random cmdlet help and "about" article
Get-Command -Module Microsoft*,Cim*,PS*,ISE | Get-Random | Get-Help -ShowWindow
Get-Random -input (Get-Help about*) | Get-Help -ShowWindow