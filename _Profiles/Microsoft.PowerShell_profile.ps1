<#	
	.SYNOPSIS
		Profile File
	.DESCRIPTION
		Profile File
	.NOTES
		Francois-Xavier Cat
	
		HISTORY
		2014/12/25 Update
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

#...

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
function Launch-Office365Admin { Invoke-Item "https://portal.office.com" -Credential (Get-Credential) }
function Launch-AzurePortal { Invoke-Item "https://portal.azure.com/" -Credential (Get-Credential) }
function Launch-InternetExplorer { & 'C:\Program Files (x86)\Internet Explorer\iexplore.exe' "about:blank" }
function Launch-ExchangeOnline { Invoke-Item "https://outlook.office365.com/ecp/" }

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

# Get list of Accelerators
function Get-Accelerators
{
	[psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::get
}


# CLX from TommyMaynard.com
#  This will not clear the screen like "cls" I will just scroll to caret and hide previous commands/output
Function clx {
    [System.Console]::SetWindowPosition(0,[System.Console]::CursorTop)
}

# DOT Source External Functions
$currentpath = Get-ScriptDirectory
. (Join-Path -Path $currentpath -ChildPath "\functions\show-object.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\connect-office365.ps1")
. (Join-Path -Path $currentpath -ChildPath "\functions\Test-Port.ps1")

# DatePattern Output
function Test-DatePattern
{
#http://jdhitsolutions.com/blog/2014/10/powershell-dates-times-and-formats/
$patterns = "d","D","g","G","f","F","m","o","r","s", "t","T","u","U","Y","dd","MM","yyyy","yy","hh","mm","ss","yyyyMMdd","yyyyMMddhhmm","yyyyMMddhhmmss"

Write-host "It is now $(Get-Date)" -ForegroundColor Green

foreach ($pattern in $patterns) {

#create an Object
[pscustomobject]@{
 Pattern = $pattern
 Syntax = "Get-Date -format '$pattern'"
 Value = (Get-Date -Format $pattern)
}

} #foreach

Write-Host "Most patterns are case sensitive" -ForegroundColor Green
}

function View-Cats
{
	<#
	.SYNOPSIS
		This will open Internet explorer and show a different cat every 5 seconds
	.DESCRIPTION
	.NOTES
		#http://www.reddit.com/r/PowerShell/comments/2htfog/viewcats/
	#>
    Param(
        [int]$refreshtime=5
    )
    $IE = new-object -ComObject internetexplorer.application
    $IE.visible = $true
    $IE.FullScreen = $true
    $shell = New-Object -ComObject wscript.shell
    $shell.AppActivate("Internet Explorer")

    while($true){
        $request = Invoke-WebRequest -Uri "http://thecatapi.com/api/images/get" -Method get 
        $IE.Navigate($request.BaseResponse.ResponseUri.AbsoluteUri)
        Start-Sleep -Seconds $refreshtime
    }
} 

Function Find-Apartment
{
	<#
	.SYNOPSIS
		Allow you search Appartement in craigslist
	.DESCRIPTION
	.NOTES
		#http://masterrex.com/?p=64
	#>
    param (
        [Parameter(Mandatory=$False)]$MinPrice="0",
        [Parameter(Mandatory=$False)]$MaxPrice="9999",
        [Parameter(Mandatory=$False)]$MaxPages="1",
        [Parameter(Mandatory=$False)]$URL = "http://burlington.craigslist.org"
    )
    $AvailableRooms = @()
    For ($CurrentPage=0;$CurrentPage -le $MaxPages;$CurrentPage++) {
        $WebPage = Invoke-WebRequest "$URL/search/roo?=roo&s=$Start&query=&zoomToPosting=&minAsk=$MinPrice&maxAsk=$MaxPrice&hasPic=1"
        $Results = $WebPage.ParsedHtml.body.innerHTML.Split("`n") | ? { $_ -like "<P class=row*" }
        ForEach ($Item in $Results) { 
            $ItemObject=$ID=$Price=$DatePosted=$Neighborhood=$Link=$Description=$Email=$null
            $ID = ($Item -replace ".*pid\=`"","") -replace "`".*"
            $Price = ($Item -replace ".*class=price>","") -replace "</SPAN>.*"
            $DatePosted = ($Item -replace ".*class=date>","") -replace "</SPAN>.*"
            $Neighborhood = ($Item -replace ".*\<SMALL\>\(","") -replace "\)\</SMALL>.*"
            If ($Neighborhood -like "<*") { $Neighborhood = "N/A" } 
            $Link = $URL + ((($Item -replace ".*\<A href\=`"","") -replace "\<.*") -split('">'))[0]
            $Email = (($(Invoke-WebRequest $Link).ParsedHtml.body.innerHTML.Split("`n") | ? { $_ -like "var displayEmail*" }) -replace "var displayEmail \= `"") -replace "`";"
            $Description = ((($Item -replace ".*\<A href\=`"","") -replace "\<.*") -split('">'))[1]
            $ItemObject = New-Object -TypeName PSObject -Property @{
                'ID' = $ID
                'Price' = $Price
                'DatePosted' = $DatePosted
                'Neighborhood' = $Neighborhood
                'Link' = $Link
                'Description' = $Description
                'E-Mail' = $Email
            }
            #$AvailableRooms += $ItemObject
            $ItemObject
        }
    }
    #Return $AvailableRooms
}

#########
# Other #
#########

# Learn something today (show a random cmdlet help and "about" article
Get-Command -Module Microsoft*,Cim*,PS*,ISE | Get-Random | Get-Help -ShowWindow
Get-Random -input (Get-Help about*) | Get-Help -ShowWindow