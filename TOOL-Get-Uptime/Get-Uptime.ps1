function Get-Uptime {
    <#
    .SYNOPSIS
        The function Get-Uptime will get uptime of a local or remote machine.

    .DESCRIPTION
        The function Get-Uptime will get uptime of a local or remote machine.
        This function is compatible with CIM sessions and alternative credentials.

    .PARAMETER ComputerName
        Specifies the computername

    .PARAMETER Credential
        Specifies the credential to use

    .PARAMETER CimSession
        Specifies one or more existing CIM Session(s) to use

    .EXAMPLE
        PS C:\> Get-Uptime -ComputerName DC01

    .EXAMPLE
        PS C:\> Get-Uptime -ComputerName DC01 -Credential (Get-Credential -cred "FX\SuperAdmin")

    .EXAMPLE
        PS C:\> Get-Uptime -CimSession $Session

    .EXAMPLE
        PS C:\> Get-Uptime -CimSession $Session1,$session2,$session3

    .NOTES
        Francois-Xavier Cat
        @lazywinadmin
        lazywinadmin.com
#>
    [CmdletBinding()]
    PARAM (
        [Parameter(
            ParameterSetName = "Main",
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True)]
        [Alias("CN", "__SERVER", "PSComputerName")]
        [String[]]$ComputerName = $env:COMPUTERNAME,

        [Parameter(ParameterSetName = "Main")]
        [Alias("RunAs")]
        [PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(ParameterSetName = "CimSession")]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )
    BEGIN {
        # Helper Function
        function Get-DefaultMessage {
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
    lazywinadmin.com
    @lazywinadmin
#>
            PARAM ($Message)
            $DateFormat = Get-Date -Format 'yyyy/MM/dd-HH:mm:ss:ff'
            $FunctionName = (Get-Variable -Scope 1 -Name MyInvocation -ValueOnly).MyCommand.Name
            Write-Output "[$DateFormat][$FunctionName] $Message"
        }#Get-DefaultMessage
    }
    PROCESS {
        IF ($PSBoundParameters['CimSession']) {
            FOREACH ($Cim in $CimSession) {
                $CIMComputer = $($Cim.ComputerName).ToUpper()

                TRY {
                    # Parameters for Get-CimInstance
                    $CIMSplatting = @{
                        Class         = "Win32_OperatingSystem"
                        CimSession    = $Cim
                        ErrorAction   = 'Stop'
                        ErrorVariable = "ErrorProcessGetCimInstance"
                    }


                    Write-Verbose -Message (Get-DefaultMessage -Message "$CIMComputer - Get-Uptime")
                    $CimResult = Get-CimInstance @CIMSplatting

                    # Prepare output
                    $Uptime = New-TimeSpan -Start $($CimResult.lastbootuptime) -End (Get-Date)

                    $Properties = @{
                        ComputerName   = $CIMComputer
                        Days           = $Uptime.days
                        Hours          = $Uptime.hours
                        Minutes        = $Uptime.minutes
                        Seconds        = $Uptime.seconds
                        LastBootUpTime = $CimResult.lastbootuptime
                    }

                    # Output the information
                    New-Object -TypeName PSObject -Property $Properties

                }
                CATCH {
                    Write-Warning -Message (Get-DefaultMessage -Message "$CIMComputer - Something wrong happened")
                    IF ($ErrorProcessGetCimInstance) { Write-Warning -Message (Get-DefaultMessage -Message "$CIMComputer - Issue with Get-CimInstance") }
                    Write-Warning -Message $Error[0].Exception.Message
                } #CATCH
                FINALLY {
                    $CIMSplatting.Clear() | Out-Null
                }
            } #FOREACH ($Cim in $CimSessions)
        } #IF ($PSBoundParameters['CimSession'])
        ELSE {
            FOREACH ($Computer in $ComputerName) {
                $Computer = $Computer.ToUpper()

                TRY {
                    Write-Verbose -Message (Get-DefaultMessage -Message "$Computer - Test-Connection")
                    IF (Test-Connection -Computer $Computer -count 1 -quiet) {
                        $Splatting = @{
                            Class         = "Win32_OperatingSystem"
                            ComputerName  = $Computer
                            ErrorAction   = 'Stop'
                            ErrorVariable = 'ErrorProcessGetWmi'
                        }

                        IF ($PSBoundParameters['Credential']) {
                            $Splatting.credential = $Credential
                        }

                        Write-Verbose -Message (Get-DefaultMessage -Message "$Computer - Getting Uptime")
                        $result = Get-WmiObject @Splatting


                        # Prepare output
                        $HumanTimeFormat = $Result.ConvertToDateTime($Result.Lastbootuptime)
                        $Uptime = New-TimeSpan -Start $HumanTimeFormat -End $(Get-Date)

                        $Properties = @{
                            ComputerName   = $Computer
                            Days           = $Uptime.days
                            Hours          = $Uptime.hours
                            Minutes        = $Uptime.minutes
                            Seconds        = $Uptime.seconds
                            LastBootUpTime = $CimResult.lastbootuptime
                        }
                        # Output the information
                        New-Object -TypeName PSObject -Property $Properties
                    }
                }
                CATCH {
                    Write-Warning -Message (Get-DefaultMessage -Message "$$Computer - Something wrong happened")
                    IF ($ErrorProcessGetWmi) { Write-Warning -Message (Get-DefaultMessage -Message "$Computer - Issue with Get-WmiObject") }
                    Write-Warning -MEssage $Error[0].Exception.Message
                }
                FINALLY {
                    $Splatting.Clear()
                }
            }#FOREACH
        } #ELSE (Not CIM)
    }#PROCESS
}#Function