function Get-BatteryStatus {
    <#
    .SYNOPSIS
    Retrieve battery information

    .DESCRIPTION
    Retrieve battery information

    .EXAMPLE
    Get-BatteryStatus

    .NOTES
        http://www.powershellmagazine.com/2012/10/18/pstip-get-system-power-information/
    #>
    PARAM()
    try {
        Add-Type -Assembly System.Windows.Forms
        [System.Windows.Forms.SystemInformation]::PowerStatus
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}
