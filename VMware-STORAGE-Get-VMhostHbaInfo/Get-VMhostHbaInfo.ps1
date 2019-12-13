Function Get-VMhostHbaInfo {
    <#
.SYNOPSIS
    The function Get-VMHostHBAInfo is gathering HBA cards information using PowerCli cmdlets and SSH connection to get additional details.

.DESCRIPTION
    The function Get-VMHostHBAInfo is gathering HBA cards information using PowerCli cmdlets and SSH connection to get additional details.

.PARAMETER VMHost
    Specify the VMhost to query

.PARAMETER Username
    Specify the Username account to use to connect via putty (plink.exe)

.PARAMETER Password
    Specify the Username account's password to use to connect via putty (plink.exe)

.PARAMETER PlinkPath
    Specify the plink.exe full path. Default is "C:\Program Files (x86)\PuTTY\plink.exe"

.EXAMPLE
    Get-VMhostHbaInfo -VMhost "vmhost01.fx.lab" -Username root -Password Secr3tP@ssword

    HostName           : vmhost01.fx.lab
    HostProduct        : VMware ESXi 5.1.0 build-1157734
    HbaDevice          : vmhba2
    HbaWWN             : 10:00:00:00:c9:a5:44:a8
    HbaDriver          : lpfc820
    HbaModel           : LPe11000 4Gb Fibre Channel Host Adapter
    HbaFirmwareVersion : 2.82X4 (ZS2.82X4)
    HWModel            : ProLiant DL365 G5


    HostName           : vmhost01.fx.lab
    HostProduct        : VMware ESXi 5.1.0 build-1157734
    HbaDevice          : vmhba3
    HbaWWN             : 10:00:00:00:c9:a5:44:a9
    HbaDriver          : lpfc820
    HbaModel           : LPe11000 4Gb Fibre Channel Host Adapter
    HbaFirmwareVersion : 2.82X4 (ZS2.82X4)
    HWModel            : ProLiant DL365 G5


.EXAMPLE
    Get-VMhostHbaInfo -VMhost "vmhost01.fx.lab" -Username root -Password Secr3tP@ssword -PlinkPath "C:\Program Files (x86)\PuTTY\plink.exe"

    HostName           : vmhost01.fx.lab
    HostProduct        : VMware ESXi 5.1.0 build-1157734
    HbaDevice          : vmhba2
    HbaWWN             : 10:00:00:00:c9:a5:44:a8
    HbaDriver          : lpfc820
    HbaModel           : LPe11000 4Gb Fibre Channel Host Adapter
    HbaFirmwareVersion : 2.82X4 (ZS2.82X4)
    HWModel            : ProLiant DL365 G5


    HostName           : vmhost01.fx.lab
    HostProduct        : VMware ESXi 5.1.0 build-1157734
    HbaDevice          : vmhba3
    HbaWWN             : 10:00:00:00:c9:a5:44:a9
    HbaDriver          : lpfc820
    HbaModel           : LPe11000 4Gb Fibre Channel Host Adapter
    HbaFirmwareVersion : 2.82X4 (ZS2.82X4)
    HWModel            : ProLiant DL365 G5

.EXAMPLE
    Get-VMhostHbaInfo -VMhost "vmhost01.fx.lab" -Username root -Password Secr3tP@ssword -Verbose

    VERBOSE: PROCESS - vmhost01.fx.lab - Retrieving General Information ...
    VERBOSE: 6/10/2014 12:38:51 PM Get-View Started execution
    VERBOSE: 6/10/2014 12:38:52 PM Get-View Finished execution
    VERBOSE: PROCESS -  - Status is Powered On
    VERBOSE: PROCESS - vmhost01.fx.lab - Retrieving HBA information ...
    VERBOSE: PROCESS - vmhost01.fx.lab - Retrieving HBA Advance information - checking SSH Service...
    VERBOSE: 6/10/2014 12:38:52 PM Get-View Started execution
    VERBOSE: 6/10/2014 12:38:52 PM Get-View Finished execution
    VERBOSE: PROCESS - vmhost01.fx.lab - Output Result

    HostName           : vmhost01.fx.lab
    HostProduct        : VMware ESXi 5.1.0 build-1157734
    HbaDevice          : vmhba2
    HbaWWN             : 10:00:00:00:c9:a5:44:a8
    HbaDriver          : lpfc820
    HbaModel           : LPe11000 4Gb Fibre Channel Host Adapter
    HbaFirmwareVersion : 2.82X4 (ZS2.82X4)
    HWModel            : ProLiant DL365 G5

    VERBOSE: PROCESS - vmhost01.fx.lab - Retrieving HBA information ...
    VERBOSE: PROCESS - vmhost01.fx.lab - Retrieving HBA Advance information - checking SSH Service...
    VERBOSE: 6/10/2014 12:38:53 PM Get-View Started execution
    VERBOSE: 6/10/2014 12:38:54 PM Get-View Finished execution
    VERBOSE: PROCESS - vmhost01.fx.lab - Output Result

    HostName           : vmhost01.fx.lab
    HostProduct        : VMware ESXi 5.1.0 build-1157734
    HbaDevice          : vmhba3
    HbaWWN             : 10:00:00:00:c9:a5:44:a9
    HbaDriver          : lpfc820
    HbaModel           : LPe11000 4Gb Fibre Channel Host Adapter
    HbaFirmwareVersion : 2.82X4 (ZS2.82X4)
    HWModel            : ProLiant DL365 G5

    VERBOSE: END - End of Get-VMhostHbaInfo

.EXAMPLE
    Get-VMhostHbaInfo -VMhost "vmhost01.fx.lab" -Username root -Password Secr3tP@ssword | Export-CSV HBAInformation.csv

.INPUTS
    System.String

.OUTPUTS
    PSObject

.NOTES
    Twitter: @lazywinadmin
    WWW: lazywinadmin.com

    VERSION HISTORY
    1.0 Original version of this script is from vmdude.fr (http://www.vmdude.fr/en/scripts-en/hba-firmware-version/)
    2.0 Converted to a reusable function
#>


    [CmdletBinding()]
    PARAM (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [String] $VMhost,
        [Parameter()]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [string] $PlinkPath = "C:\Program Files (x86)\PuTTY\plink.exe",
        [Parameter(
            HelpMessage = "Enter the ESXi account used for SSH connection/command.",
            Mandatory = $true)]
        [string] $Username,
        [Parameter(
            HelpMessage = "Enter the ESXi account's password.",
            Mandatory = $true)]
        [string] $Password
    )
    BEGIN {
        TRY {
            # Verify VMware Snapin is loaded
            IF (-not (Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction 'SilentlyContinue')) {
                Write-Verbose -Message "BEGIN - Loading Vmware Snapin VMware.VimAutomation.Core..."
                Add-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction Stop -ErrorVariable ErrorBeginAddPssnapin
            }

            # Verify VMware Snapin is connected to at least one vcenter
            IF (-not ($global:DefaultVIServer.count -gt 0)) {
                Write-Verbose -Message "BEGIN - Currently not connected to a vCenter..."
                Connect-VIServer -Server (Read-Host -Prompt "You are not connected to a VMware vCenter, Please enter the FQDN or IP of the vCenter") -ErrorAction Stop -ErrorVariable ErrorBeginConnectViServer
            }
        }
        CATCH {

            IF ($ErrorBeginAddPssnapin) {
                Write-Warning -Message "BEGIN - VMware Snapin VMware.VimAutomation.Core does not seem to be available"
                $PSCmdlet.ThrowTerminatingError($_)
            }
            IF ($ErrorBeginConnectViServer) {
                Write-Warning -Message "BEGIN - Couldnt connect to the Vcenter"
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
    PROCESS {
        TRY {
            Write-Verbose -Message "PROCESS - $Vmhost - Retrieving General Information ..."
            $hostsview = Get-View -ViewType HostSystem -Property ("runtime", "name", "config", "hardware") -Filter @{ "Name" = "$VMhost" } -ErrorAction Stop -ErrorVariable ErrorProcessGetView

            IF ($hostsview) {
                IF ($hostsview.runtime.PowerState -match "poweredOn") {
                    Write-Verbose -Message "PROCESS - $($hostview.name) - Status is Powered On"
                    $esx = $hostsview | Where-Object -FilterScript { $_.runtime.PowerState -match "poweredOn" }
                    FOREACH ($hba in ($esx.Config.StorageDevice.HostBusAdapter | Where-Object -FilterScript { $_.GetType().Name -eq "HostFibreChannelHba" })) {
                        Write-Verbose -Message "PROCESS - $($esx.name) - Retrieving HBA information ..."
                        $line = "" | Select-Object -Property HostName, HostProduct, HbaDevice, HbaWWN, HbaDriver, HbaModel, HbaFirmwareVersion, HWModel
                        $line.HostName = $esx.name
                        $line.HostProduct = $esx.config.product.fullName
                        $line.HbaDevice = $hba.device
                        $line.HbaWWN = ([regex]::matches("{0:x}" -f $hba.PortWorldWideName, '.{2}') | ForEach-Object -Process { $_.value }) -join ':'
                        $line.HbaDriver = $hba.driver
                        $line.HbaModel = $hba.model
                        $line.HWModel = $esx.hardware.systemInfo.model


                        Write-Verbose -Message "PROCESS - $($esx.name) - Retrieving HBA Advance information - checking SSH Service..."
                        IF (((Get-View -ViewType HostSystem -ErrorAction Stop -ErrorVariable ErrorProcessGetViewTypeService -Filter @{ "Name" = $($ESX.name) }).config.service.service | Where-Object -FilterScript { $_.key -eq 'tsm-ssh' }).running) {
                            if ($hba.driver -match "lpfc") {
                                $remoteCommand = "head -9 /proc/scsi/lpfc*/* | grep -B1 $($line.HbaWWN) | grep -i 'firmware version' | sed 's/Firmware Version:\{0,1\} \(.*\)/\1/'"
                            }
                            elseif ($hba.driver -match "qla") {
                                $remoteCommand = "head -8 /proc/scsi/qla*/* | grep -B2 $($hba.device) | grep -i 'firmware version' | head -1 | sed 's/.*Firmware version \(.*\), Driver version.*/\1/'"
                            }
                            $tmpStr = [string]::Format('& "{0}" {1} "{2}"', $PlinkPath, "-ssh " + $Username + "@" + $esx.Name + " -pw $Password", $remoteCommand + ";exit")

                            #Running plink.exe
                            $line.HbaFirmwareVersion = Invoke-Expression $tmpStr
                        }
                        ELSE {
                            Write-Warning -Message "PROCESS - $($esx.name) - SSH Server is not enabled"
                            $line.HbaFirmwareVersion = ""
                        }

                        Write-Verbose -Message "PROCESS - $($esx.name) - Output Result"
                        Write-Output $line
                    }#FOREACH ($hba in ($esx.Config
                }#IF ($hostsview.runtime.PowerState -match "poweredOn")
                ELSE {
                    Write-Verbose -Message "PROCESS - Host: $($hostview.name) - Powered Off"
                }
            } #IF HOSTVIEW
            ELSE {
                Write-Verbose -Message "PROCESS - Can't find any host"
            }
        }#TRY
        CATCH {
            Write-Warning -Message "PROCESS - Something Wrong happened"
            IF ($ErrorProcessGetView) { Write-Error -Message "PROCESS - Error while getting the host information" }
            IF ($ErrorProcessGetViewTypeService) { Write-Error -Message "PROCESS - Error while getting the host services information" }
            $PSCmdlet.ThrowTerminatingError($_)
        }
    } #PROCESS
    END {
        Write-Verbose -Message "END - End of Get-VMhostHbaInfo"
    }
}
