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
.EXAMPLE
	Get-DefaultMessage -message "Connected"
	
	if the function is just called from the prompt you will get the following output
	[2015/03/14 17:32:53:62] Connected
	
.EXAMPLE
	Get-DefaultMessage -message "Connected to $Computer"
	
	If the function is called from inside another function,
	It will show the name of the function.
	[2015/03/14 17:32:53:62][Get-Something] Connected
	
.NOTES
	Francois-Xavier Cat
	www.lazywinadmin.com
	@lazywinadm
#>
	PARAM ($Message)
	PROCESS
	{
		$DateFormat = Get-Date -Format 'yyyy\/MM\/dd HH:mm:ss:ff'
		$MyCommand = (Get-Variable -Scope 1 -Name MyInvocation -ValueOnly).MyCommand.Name
		IF ($MyCommand)
		{
			Write-Output "[$DateFormat][$MyCommand] $Message"
		} #IF
		ELSE
		{
			Write-Output "[$DateFormat] $Message"
		} #Else
	} #Process
}#Get-DefaultMessage