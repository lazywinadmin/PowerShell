#Requires -RunAsAdministrator

# Set the Path
Set-Location -Path c:\

#Office 365 Credential
IF((Read-Host -Prompt "Do you want to connect to Office365") -like "*y*"){
	$Office365Cred = Get-Credential -Credential fxaviercat@mtlpug.onmicrosoft.com
	Connect-Msolservice -credential $Office365Cred
}

#Clear Host
Clear-Host

# Show PS Version and date/time
Write-host "PowerShell Version: $($psversiontable.psversion) - ExecutionPolicy: $(Get-ExecutionPolicy)" -for yellow
Write-host "DATE/TIME: $(Get-date -format 'yyyy/MM/dd hh:mm:ss')" -for gray
IF ($Office365Cred) {Write-Host "Connected to Office365 Domain: $((Get-MsolDomain).name)"}

# update the help
Write-host "Updating Help in background (Get-Job)" -for gray
Start-job -script {Update-Help -verbose} | Out-null
Write-host " "

#Learn something today
Get-Command -Module Microsoft*,Cim*,PS*,ISE | Get-Random | Get-Help -ShowWindow
Get-Random -input (Get-Help about*) | Get-Help -ShowWindow

# change the prompt
function prompt {
  #Get-location
  Write-output "PS [LazyWinAdmin.com]> "
}


