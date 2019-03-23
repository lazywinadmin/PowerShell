function New-CimSmartSession
{
<# 
.SYNOPSIS 
    Function to create a CimSession to remote computer using either WSMAN or DCOM protocol.

.DESCRIPTION 
    Function to create a CimSession to remote computer using either WSMAN or DCOM protocol.
	This function requires at least PowerShell v3.

.PARAMETER ComputerName 
    Specifies the ComputerName 

.PARAMETER Credential 
    Specifies alternative credentials

.EXAMPLE 
    New-CimSmartSession -ComputerName DC01,DC02

.EXAMPLE 
    $Session = New-CimSmartSession -ComputerName DC01 -Credential (Get-Credential -Credential "FX\SuperAdmin")
	New-CimInstance -CimSession $Session -Class Win32_Bios

.NOTES 
    Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
#>
	#Requires -Version 3.0
	[CmdletBinding()]
	PARAM (
		[Parameter(ValueFromPipeline = $true)]
		[string[]]$ComputerName = $env:COMPUTERNAME,

		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)

	BEGIN
	{
		# Default Verbose/Debug message
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

		# Create a containter (hashtable) for the properties (Splatting)
		$CIMSessionSplatting = @{ }

		# Credential specified
		IF ($PSBoundParameters['Credential']) { $CIMSessionSplatting.Credential = $Credential }

		# CIMSession Option for DCOM (Default is WSMAN)
		$CIMSessionOption =	New-CimSessionOption -Protocol Dcom
	}

	PROCESS
	{
		FOREACH ($Computer in $ComputerName)
		{
			Write-Verbose -Message (Get-DefaultMessage -Message "$Computer - Test-Connection")
			IF (Test-Connection -ComputerName $Computer -Count 1 -Quiet)
			{
				$CIMSessionSplatting.ComputerName = $Computer


				# WSMAN Protocol
				IF ((Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue).productversion -match 'Stack: ([3-9]|[1-9][0-9]+)\.[0-9]+')
				{
					TRY
					{
						#WSMAN (Default when using New-CimSession)
						Write-Verbose -Message (Get-DefaultMessage -Message "$Computer - Connecting using WSMAN protocol (Default, requires at least PowerShell v3.0)")
						New-CimSession @CIMSessionSplatting -errorVariable ErrorProcessNewCimSessionWSMAN
					}
					CATCH
					{
						IF ($ErrorProcessNewCimSessionWSMAN) { Write-Warning -Message (Get-DefaultMessage -Message "$Computer - Can't Connect using WSMAN protocol") }
						Write-Warning -Message (Get-DefaultMessage -Message $Error.Exception.Message)
					}
				}

				ELSE
				{
					# DCOM Protocol
					$CIMSessionSplatting.SessionOption = $CIMSessionOption

					TRY
					{
						Write-Verbose -Message (Get-DefaultMessage -Message "$Computer - Connecting using DCOM protocol")
						New-CimSession @SessionParams -errorVariable ErrorProcessNewCimSessionDCOM
					}
					CATCH
					{
						IF ($ErrorProcessNewCimSessionDCOM) { Write-Warning -Message (Get-DefaultMessage -Message "$Computer - Can't connect using DCOM protocol either") }
						Write-Warning -Message (Get-DefaultMessage -Message $Error.Exception.Message)
					}
					FINALLY
					{
						# Remove the CimSessionOption for the DCOM protocol for the next computer
						$CIMSessionSplatting.Remove('CIMSessionOption')
					}
				}#ELSE
			}#Test-Connection
		}#FOREACH
	}#PROCESS
}#Function