function Get-ComputerOS {
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
    .LINK
        https://github.com/lazywinadmin/PowerShell
#>
    [CmdletBinding()]
    PARAM (
        [Parameter(ParameterSetName = "Main")]
        [Alias("CN", "__SERVER", "PSComputerName")]
        [String[]]$ComputerName = $env:ComputerName,

        [Parameter(ParameterSetName = "Main")]
        [Alias("RunAs")]
        [pscredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(ParameterSetName = "CimSession")]
        [Microsoft.Management.Infrastructure.CimSession]$CimSession
    )
    BEGIN {
        # Default Verbose/Debug message
        function Get-DefaultMessage {
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
    PROCESS {
        FOREACH ($Computer in $ComputerName) {
            TRY {
                Write-Verbose -Message (Get-DefaultMessage -Message $Computer)
                IF (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                    # Define Hashtable to hold our properties
                    $Splatting = @{
                        class       = "Win32_OperatingSystem"
                        ErrorAction = Stop
                    }

                    IF ($PSBoundParameters['CimSession']) {
                        Write-Verbose -Message (Get-DefaultMessage -Message "$Computer - CimSession")
                        # Using cim session already opened
                        $Query = Get-CIMInstance @Splatting -CimSession $CimSession
                    }
                    ELSE {
                        # Credential specified
                        IF ($PSBoundParameters['Credential']) {
                            Write-Warning -Message (Get-DefaultMessage -Message "$Computer - Credential specified $($Credential.username)")
                            $Splatting.Credential = $Credential
                        }

                        # Set the ComputerName into the splatting
                        $Splatting.ComputerName = $ComputerName
                        Write-Verbose -Message (Get-DefaultMessage -Message "$Computer - Get-WmiObject")
                        $Query = Get-WmiObject @Splatting
                    }

                    # Prepare output
                    $Properties = @{
                        ComputerName    = $Computer
                        OperatingSystem = $Query.Caption
                    }

                    # Output
                    New-Object -TypeName PSObject -Property $Properties
                }
            }
            CATCH {
                Write-Warning -Message (Get-DefaultMessage -Message "$Computer - Issue to connect")
                Write-Verbose -Message $Error[0].Exception.Message
            }#CATCH
            FINALLY {
                $Splatting.Clear()
            }
        }#FOREACH
    }#PROCESS
    END {
        Write-Warning -Message (Get-DefaultMessage -Message "Script completed")
    }
}#Function