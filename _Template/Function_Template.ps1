Function Get-Something
{
<#
	.SYNOPSIS
		A brief description of the Get-Something function.
	
	.DESCRIPTION
		A detailed description of the Get-Something function.
	
	.PARAMETER ComputerName
		A description of the ComputerName parameter.
	
	.PARAMETER Credential
		A description of the Credential parameter.
	
	.EXAMPLE
		PS C:\> Get-Something -ComputerName $value1 -Credential $value2
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
#>
	PARAM (
		[Alias("CN", "__SERVER", "PSComputerName")]
		[String[]]$ComputerName = $env:COMPUTERNAME,
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)#PARAM
	BEGIN
	{
		# GlobalVariables
		
		# Helper function for Default Verbose/Debug message
		function Get-DefaultMessage
		{
			param ($Message)
			Write-Output "[$(Get-Date -Format 'yyyy/MM/dd-HH:mm:ss:ff')][$((Get-Variable -Scope 1 -Name MyInvocation -ValueOnly).MyCommand.Name)] $Message"
		}#Get-DefaultMessage
		
		# Handlers
		
	}#BEGIN
	PROCESS
	{
		FOREACH ($Computer in $ComputerName)
		{
			Write-Verbose -Message (Get-DefaultMessage -Message $Computer)
			TRY
			{
				IF (Test-Connection -ComputerName $Computer -Count 1 -Quiet)
				{
					IF ($PSBoundParameters['Credential'])
					{
						
					}
					# Some Action here
				}#IF Test-Connection
			}
			CATCH
			{
				
			}#CATCH
			FINALLY
			{
				
			}#FINALLY
		}#FOREACH
	}#PROCESS
	END
	{
		Write-Verbose -Message (Get-DefaultMessage -Message "Script Completed")
	}#END
}#Function