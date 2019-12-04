function Set-RDPEnable {
    <#
    .SYNOPSIS
        The function Set-RDPEnable enable RDP remotely using the registry

    .DESCRIPTION
        The function Set-RDPEnable enable RDP remotely using the registry

    .PARAMETER ComputerName
        Specifies the ComputerName

    .EXAMPLE
        PS C:\> Set-RDPEnable

    .EXAMPLE
        PS C:\> Set-RDPEnable -ComputerName "DC01"

    .EXAMPLE
        PS C:\> Set-RDPEnable -ComputerName "DC01","DC02","DC03"

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
#>

    [CmdletBinding()]
    PARAM (
        [String[]]$ComputerName = $env:COMPUTERNAME
    )
    PROCESS {
        FOREACH ($Computer in $ComputerName) {
            TRY {
                IF (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                    $regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $Computer)
                    $regKey = $regKey.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Terminal Server", $True)
                    $regkey.SetValue("fDenyTSConnections", 0)
                    $regKey.flush()
                    $regKey.Close()
                } #IF Test-Connection
            } #Try
            CATCH {
                $PSCmdlet.ThrowTerminatingError($_)
            } #Catch
        } #FOREACH
    } #Process
}