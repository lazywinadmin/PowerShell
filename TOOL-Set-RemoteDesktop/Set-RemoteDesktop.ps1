function Set-RemoteDesktop {
    <#
    .SYNOPSIS
        The function Set-RemoteDesktop allows you to enable or disable RDP remotely using the registry

    .DESCRIPTION
        The function Set-RemoteDesktop allows you to enable or disable RDP remotely using the registry

    .PARAMETER ComputerName
        Specifies the ComputerName

    .EXAMPLE
        PS C:\> Set-RemoteDesktop -enable $true

    .EXAMPLE
        PS C:\> Set-RemoteDesktop -ComputerName "DC01" -enable $false

    .EXAMPLE
        PS C:\> Set-RemoteDesktop -ComputerName "DC01","DC02","DC03" -enable $false

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
#>

    [CmdletBinding()]
    PARAM (
        [String[]]$ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory = $true)]
        [Boolean]$Enable
    )
    PROCESS {
        FOREACH ($Computer in $ComputerName) {
            TRY {
                IF (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                    $regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $Computer)
                    $regKey = $regKey.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Terminal Server", $True)

                    IF ($Enable) { $regkey.SetValue("fDenyTSConnections", 0) }
                    ELSE { $regkey.SetValue("fDenyTSConnections", 1) }
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