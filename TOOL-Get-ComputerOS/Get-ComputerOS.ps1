function Get-ComputerOS
{
<#
	.SYNOPSIS
		function to retrieve the Operating System of a machine
	
	.DESCRIPTION
		function to retrieve the Operating System of a machine
	
	.PARAMETER ComputerName
		Specifies the ComputerName of the machine to query. Default is localhost.
	
	.PARAMETER Credential
		Specifies the credentials to use. Default is Current credentials
	
	.EXAMPLE
		PS C:\> Get-ComputerOS -ComputerName "SERVER01","SERVER02","SERVER03"
	
	.EXAMPLE
		PS C:\> Get-ComputerOS -ComputerName "SERVER01" -Credential (Get-Credential -cred "FX\SuperAdmin")
	
	.NOTES
		Additional information about the function.
#>
	PARAM (
		[String[]]$ComputerName = $env:ComputerName,
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		[Microsoft.Management.Infrastructure.CimSession]$CimSession
	)
	PROCESS
	{
		FOREACH ($Computer in $ComputerName)
		{
			TRY
			{
				IF (Test-Connection -ComputerName $Computer -Count 1 -Quiet)
				{
					# Define Hashtable to hold our properties
					$Splatting = @{
						class = "Win32_OperatingSystem"
						ErrorAction = Stop
					}
					
					IF ($PSBoundParameters['CimSession'])
					{
						# Using cim session already opened
						$Query = Get-CIMInstance @Splatting -CimSession $CimSession
					}
					ELSE
					{
						# Credential specified
						IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }
						
						# Set the ComputerName into the splatting
						$Splatting.ComputerName = $ComputerName

						$Query = Get-WmiObject @Splatting
					}
					
					$Properties = @{
						ComputerName = $Computer
						OperatingSystem = $Query.Caption
					}
					
					New-Object -TypeName PSObject -Property $Properties
				}
			}
			CATCH
			{
				
			}
		}
	}
}