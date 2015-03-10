function Disable-RemoteDesktop
{
<#
	.SYNOPSIS
		The function Disable-RemoteDesktop will disable RemoteDesktop on a local or remote machine.
	
	.DESCRIPTION
		The function Disable-RemoteDesktop will disable RemoteDesktop on a local or remote machine.
	
	.PARAMETER ComputerName
		Specifies the computername
	
	.PARAMETER Credential
		Specifies the credential to use
	
	.PARAMETER CimSession
		Specifies an existing CIM Session to use
	
	.EXAMPLE
		PS C:\> Disable-RemoteDesktop -ComputerName DC01
	
	.EXAMPLE
		PS C:\> Disable-RemoteDesktop -ComputerName DC01 -Credential (Get-Credential -cred "FX\SuperAdmin")
	
	.EXAMPLE
		PS C:\> Disable-RemoteDesktop -CimSession $Session
	
	.NOTES
		Francois-Xavier Cat
		@lazywinadm
		www.lazywinadmin.com
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(
				   ParameterSetName = "Main",
				   ValueFromPipeline = $True,
				   ValueFromPipelineByPropertyName = $True)]
		[Alias("CN", "__SERVER", "PSComputerName")]
		[String[]]$ComputerName,
		
		[Parameter(ParameterSetName = "Main")]
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Parameter(ParameterSetName = "CimSession")]
		[Microsoft.Management.Infrastructure.CimSession]$CimSession
	)
	BEGIN
	{
		# Helper Function
		function Get-DefaultMessage
		{
	<#
	.SYNOPSIS
		Helper Function to show default message used in VERBOSE/DEBUG/WARNING
	.DESCRIPTION
		Helper Function to show default message used in VERBOSE/DEBUG/WARNING.
		Typically called inside another function in the BEGIN Block
	#>
			PARAM ($Message)
			Write-Output "[$(Get-Date -Format 'yyyy/MM/dd-HH:mm:ss:ff')][$((Get-Variable -Scope 1 -Name MyInvocation -ValueOnly).MyCommand.Name)] $Message"
		}#Get-DefaultMessage
	}
	PROCESS
	{
		FOREACH ($Computer in $ComputerName)
		{
			TRY
			{
				Write-Verbose -Message (Get-DefaultMessage -Message "$Computer - Test-Connection")
				IF (Test-Connection -Computer $Computer -count 1 -quiet)
				{
					$Splatting = @{
						Class = "Win32_TerminalServiceSetting"
						NameSpace = "root\cimv2\terminalservices"
					}
					
					IF (-not $PSBoundParameters['CimSession'])
					{
						$Splatting.ComputerName = $Computer
						
						IF ($PSBoundParameters['Credential'])
						{
							$Splatting.credential = $Credential
						}
						
						# Disable Remote Desktop
						Write-Verbose -Message (Get-DefaultMessage -Message "$Computer - Get-WmiObject - Disable Remote Desktop")
						(Get-WmiObject @Splatting).SetAllowTsConnections(0, 0) | Out-Null
						
						# Disable requirement that user must be authenticated
						#(Get-WmiObject -Class Win32_TSGeneralSetting @Splatting -Filter TerminalName='RDP-tcp').SetUserAuthenticationRequired(0)  Out-Null
					}
					IF ($PSBoundParameters['CimSession'])
					{
						$Splatting.CimSession = $CimSession
						Write-Verbose -Message (Get-DefaultMessage -Message "$Computer - CIMSession - Disable Remote Desktop (and Modify Firewall Exception")
						Get-CimInstance @Splatting | Invoke-CimMethod -MethodName SetAllowTSConnections -Arguments @{
							AllowTSConnections = 0;
							ModifyFirewallException = 0
						}
					}
				}
			}
			CATCH
			{
				Write-Warning -Message (Get-DefaultMessage -Message "$Computer - Something wrong happened")
				Write-Warning -MEssage $Error[0].Exception.Message
			}
			FINALLY
			{
				$Splatting.Clear()
			}
		}#FOREACH
		
	}#PROCESS
}#Function