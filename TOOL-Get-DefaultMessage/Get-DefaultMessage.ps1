function Get-DefaultMessage
{
<#
.SYNOPSIS
	Helper Function to show default message used in VERBOSE/DEBUG/WARNING
.DESCRIPTION
	Helper Function to show default message used in VERBOSE/DEBUG/WARNING
	and... HOST in some case.
	This is helpful to standardize the output messages
	
.PARAMETER Message
	Specifies the message to show
.NOTES
	Francois-Xavier Cat
	www.lazywinadmin.com
	@lazywinadm
#>
	PARAM ($Message)
	$DateFormat = Get-Date -Format 'yyyy/MM/dd-HH:mm:ss:ff'
	$FunctionName = (Get-Variable -Scope 1 -Name MyInvocation -ValueOnly).MyCommand.Name
	Write-Output "[$DateFormat][$FunctionName] $Message"
}#Get-DefaultMessage