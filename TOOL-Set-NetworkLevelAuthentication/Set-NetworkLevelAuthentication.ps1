function Set-NetworkLevelAuthentication
{
<#
.SYNOPSIS
	This function will set the NLA setting on a local machine or remote machine

.DESCRIPTION
	This function will set the NLA setting on a local machine or remote machine

.PARAMETER  ComputerName
	Specify one or more computers

.PARAMETER EnableNLA
	Specify if the NetworkLevelAuthentication need to be set to $true or $false

.PARAMETER  Credential
	Specify the alternative credential to use. By default it will use the current one.

.EXAMPLE
	Set-NetworkLevelAuthentication -EnableNLA $true

.EXAMPLE
	Set-NetworkLevelAuthentication -EnableNLA $true -computername "SERVER01","SERVER02"

.EXAMPLE
	Set-NetworkLevelAuthentication -EnableNLA $true -computername (Get-Content ServersList.txt)

.NOTES
	DATE	: 2014/04/01
	AUTHOR	: Francois-Xavier Cat
	WWW		: http://lazywinadmin.com
	Twitter	: @lazywinadm

	Article : http://lazywinadmin.com/2014/04/powershell-getset-network-level.html
	GitHub	: https://github.com/lazywinadmin/PowerShell
#>
	#Requires -Version 3.0
	[CmdletBinding()]
	PARAM (
		[Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
		[System.String[]]$ComputerName = $env:ComputerName,

		[Parameter(Mandatory)]
		[System.Boolean]$EnableNLA,

		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)#Param
	BEGIN
	{
		TRY
		{
			IF (-not (Get-Module -Name CimCmdlets))
			{
				Write-Verbose -Message '[BEGIN] Import Module CimCmdlets'
				Import-Module CimCmdlets -ErrorAction 'Stop' -ErrorVariable ErrorBeginCimCmdlets
			}
		}
		CATCH
		{
			IF ($ErrorBeginCimCmdlets)
			{
				Write-Error -Message "[BEGIN] Can't find CimCmdlets Module"
			}
		}
	}#BEGIN

	PROCESS
	{
		FOREACH ($Computer in $ComputerName)
		{
			Write-Verbose -message $Computer
			TRY
			{
				# Building Splatting for CIM Sessions
				Write-Verbose -message "$Computer - CIM/WIM - Building Splatting"
				$CIMSessionParams = @{
					ComputerName = $Computer
					ErrorAction = 'Stop'
					ErrorVariable = 'ProcessError'
				}

				# Add Credential if specified when calling the function
				IF ($PSBoundParameters['Credential'])
				{
					Write-Verbose -message "[PROCESS] $Computer - CIM/WMI - Add Credential Specified"
					$CIMSessionParams.credential = $Credential
				}

				# Connectivity Test
				Write-Verbose -Message "[PROCESS] $Computer - Testing Connection..."
				Test-Connection -ComputerName $Computer -Count 1 -ErrorAction Stop -ErrorVariable ErrorTestConnection | Out-Null

				# CIM/WMI Connection
				#  WsMAN
				IF ((Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue).productversion -match 'Stack: 3.0')
				{
					Write-Verbose -Message "[PROCESS] $Computer - WSMAN is responsive"
					$CimSession = New-CimSession @CIMSessionParams
					$CimProtocol = $CimSession.protocol
					Write-Verbose -message "[PROCESS] $Computer - [$CimProtocol] CIM SESSION - Opened"
				}

				# DCOM
				ELSE
				{
					# Trying with DCOM protocol
					Write-Verbose -Message "[PROCESS] $Computer - Trying to connect via DCOM protocol"
					$CIMSessionParams.SessionOption = New-CimSessionOption -Protocol Dcom
					$CimSession = New-CimSession @CIMSessionParams
					$CimProtocol = $CimSession.protocol
					Write-Verbose -message "[PROCESS] $Computer - [$CimProtocol] CIM SESSION - Opened"
				}

				# Getting the Information on Terminal Settings
				Write-Verbose -message "[PROCESS] $Computer - [$CimProtocol] CIM SESSION - Get the Terminal Services Information"
				$NLAinfo = Get-CimInstance -CimSession $CimSession -ClassName Win32_TSGeneralSetting -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'"
				$NLAinfo | Invoke-CimMethod -MethodName SetUserAuthenticationRequired -Arguments @{ UserAuthenticationRequired = $EnableNLA } -ErrorAction 'Continue' -ErrorVariable ErrorProcessInvokeWmiMethod
			}

			CATCH
			{
				Write-Warning -Message "Error on $Computer"
				Write-Error -Message $_.Exception.Message
				if ($ErrorTestConnection) { Write-Warning -Message "[PROCESS] Error - $ErrorTestConnection" }
				if ($ProcessError) { Write-Warning -Message "[PROCESS] Error - $ProcessError" }
				if ($ErrorProcessInvokeWmiMethod) { Write-Warning -Message "[PROCESS] Error - $ErrorProcessInvokeWmiMethod" }
			}#CATCH
			FINALLY
			{
				if ($CimSession)
				{
					# CLeanup/Close the remaining session
					Write-Verbose -Message "[PROCESS] Finally Close any CIM Session(s)"
					Remove-CimSession -CimSession $CimSession
				}
			}
		} # FOREACH
	}#PROCESS
	END
	{
		Write-Verbose -Message "[END] Script is completed"
	}
}
