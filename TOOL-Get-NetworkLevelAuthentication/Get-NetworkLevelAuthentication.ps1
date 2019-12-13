function Get-NetworkLevelAuthentication {
    <#
.SYNOPSIS
    This function will get the NLA setting on a local machine or remote machine

.DESCRIPTION
    This function will get the NLA setting on a local machine or remote machine

.PARAMETER  ComputerName
    Specify one or more computer to query

.PARAMETER  Credential
    Specify the alternative credential to use. By default it will use the current one.

.EXAMPLE
    Get-NetworkLevelAuthentication

    This will get the NLA setting on the localhost

    ComputerName     : XAVIERDESKTOP
    NLAEnabled       : True
    TerminalName     : RDP-Tcp
    TerminalProtocol : Microsoft RDP 8.0
    Transport        : tcp

.EXAMPLE
    Get-NetworkLevelAuthentication -ComputerName DC01

    This will get the NLA setting on the server DC01

    ComputerName     : DC01
    NLAEnabled       : True
    TerminalName     : RDP-Tcp
    TerminalProtocol : Microsoft RDP 8.0
    Transport        : tcp

.EXAMPLE
    Get-NetworkLevelAuthentication -ComputerName DC01, SERVER01 -verbose

    This will get the NLA setting on the servers DC01 and the SERVER01

.EXAMPLE
    Get-Content .\Computers.txt | Get-NetworkLevelAuthentication -verbose

    This will get the NLA setting for all the computers listed in the file Computers.txt

.EXAMPLE
    Get-NetworkLevelAuthentication -ComputerName (Get-Content -Path .\Computers.txt)

    This will get the NLA setting for all the computers listed in the file Computers.txt

.NOTES
    DATE        : 2014/04/01
    AUTHOR      : Francois-Xavier Cat
    WWW         : http://lazywinadmin.com
    Twitter     : @lazywinadmin

    Article : http://lazywinadmin.com/2014/04/powershell-getset-network-level.html
    GitHub    : https://github.com/lazywinadmin/PowerShell
#>
    #Requires -Version 3.0
    [CmdletBinding()]
    PARAM (
        [Parameter(ValueFromPipeline)]
        [String[]]$ComputerName = $env:ComputerName,

        [Alias("RunAs")]
        [pscredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )#Param
    BEGIN {
        TRY {
            IF (-not (Get-Module -Name CimCmdlets)) {
                Write-Verbose -Message 'BEGIN - Import Module CimCmdlets'
                Import-Module -Name CimCmdlets -ErrorAction 'Stop' -ErrorVariable ErrorBeginCimCmdlets
            }
        }
        CATCH {
            IF ($ErrorBeginCimCmdlets) {
                Write-Error -Message "BEGIN - Can't find CimCmdlets Module"
            }
        }
    }#BEGIN

    PROCESS {
        FOREACH ($Computer in $ComputerName) {
            TRY {
                # Building Splatting for CIM Sessions
                $CIMSessionParams = @{
                    ComputerName  = $Computer
                    ErrorAction   = 'Stop'
                    ErrorVariable = 'ProcessError'
                }

                # Add Credential if specified when calling the function
                IF ($PSBoundParameters['Credential']) {
                    $CIMSessionParams.credential = $Credential
                }

                # Connectivity Test
                Write-Verbose -Message "PROCESS - $Computer - Testing Connection..."
                Test-Connection -ComputerName $Computer -count 1 -ErrorAction Stop -ErrorVariable ErrorTestConnection | Out-Null

                # CIM/WMI Connection
                #  WsMAN
                IF ((Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue).productversion -match 'Stack: 3.0') {
                    Write-Verbose -Message "PROCESS - $Computer - WSMAN is responsive"
                    $CimSession = New-CimSession @CIMSessionParams
                    $CimProtocol = $CimSession.protocol
                    Write-Verbose -message "PROCESS - $Computer - [$CimProtocol] CIM SESSION - Opened"
                }

                # DCOM
                ELSE {
                    # Trying with DCOM protocol
                    Write-Verbose -Message "PROCESS - $Computer - Trying to connect via DCOM protocol"
                    $CIMSessionParams.SessionOption = New-CimSessionOption -Protocol Dcom
                    $CimSession = New-CimSession @CIMSessionParams
                    $CimProtocol = $CimSession.protocol
                    Write-Verbose -message "PROCESS - $Computer - [$CimProtocol] CIM SESSION - Opened"
                }

                # Getting the Information on Terminal Settings
                Write-Verbose -message "PROCESS - $Computer - [$CimProtocol] CIM SESSION - Get the Terminal Services Information"
                $NLAinfo = Get-CimInstance -CimSession $CimSession -ClassName Win32_TSGeneralSetting -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'"
                [pscustomobject][ordered]@{
                    'ComputerName'     = $NLAinfo.PSComputerName
                    'NLAEnabled'       = $NLAinfo.UserAuthenticationRequired -as [bool]
                    'TerminalName'     = $NLAinfo.TerminalName
                    'TerminalProtocol' = $NLAinfo.TerminalProtocol
                    'Transport'        = $NLAinfo.transport
                }
            }

            CATCH {
                Write-Warning -Message "PROCESS - Error on $Computer"
                $_.Exception.Message
                if ($ErrorTestConnection) { Write-Warning -Message "PROCESS Error - $ErrorTestConnection" }
                if ($ProcessError) { Write-Warning -Message "PROCESS Error - $ProcessError" }
            }#CATCH
        } # FOREACH
    }#PROCESS
    END {

        if ($CimSession) {
            Write-Verbose -Message "END - Close CIM Session(s)"
            Remove-CimSession $CimSession
        }
        Write-Verbose -Message "END - Script is completed"
    }
}