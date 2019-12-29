function Remove-SCCMUserDeviceAffinity {
    <#
    .SYNOPSIS
        Function to remove the primary user(s) or group(s) from a device in SCCM

    .DESCRIPTION
        Function to remove the primary user(s) or group(s) from a device in SCCM

    .PARAMETER SiteCode
        Specifies the SCCM Site Code

    .PARAMETER SiteServer
        Specifies the SCCM Management Server

    .PARAMETER DeviceName
        Specifies the Resource Name on which the Primary Users need to be removed

    .PARAMETER DeviceID
        Specifies the Resource ID on which the Primary Users need to be removed

    .PARAMETER Credential
        Specifies alternative credentials to use

    .EXAMPLE
        $Params = @{
            SiteCode    = 'FXC'
            SiteServer  = 'SCCMServer1'
            DeviceID    = 'FXC00045'
            Credential  = (Get-Credential 'FX/SccmGuru')
        }
        Remove-SCCMUserDeviceAffinity @Params

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
    .LINK
        https://github.com/lazywinadmin/PowerShell
#>

    [CmdletBinding(DefaultParameterSetName = 'ResourceName')]
    param
    (
        [Parameter(ParameterSetName = 'ResourceName')]
        [Parameter(ParameterSetName = 'ResourceID')]
        $SiteCode,

        [Parameter(ParameterSetName = 'ResourceName',
            Mandatory = $true)]
        [Parameter(ParameterSetName = 'ResourceID')]
        $SiteServer,

        [Parameter(ParameterSetName = 'ResourceName')]
        [Alias('Name', 'ResourceName')]
        $DeviceName,

        [Parameter(ParameterSetName = 'ResourceID')]
        [Alias('ResourceID')]
        $DeviceID,

        [Parameter(ParameterSetName = 'ResourceName')]
        [Parameter(ParameterSetName = 'ResourceID')]
        [Alias('RunAs')]
        [pscredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    $CIMsessionSplatting = @{
        ComputerName = $SiteServer
    }


    # Credential Specified
    IF ($PSBoundParameters['Credential']) {
        $CIMsessionSplatting.Credential = $Credential
    }

    # Create a CIM session
    $CIMSession = New-CimSession @CIMsessionSplatting

    # Splatting for CIM cmlets
    $CIMSplatting = @{
        CimSession = $CIMSession
        NameSpace  = "root\sms\site_$SiteCode"
        ClassName  = "SMS_UserMachineRelationship"
    }

    # Device Name Specified
    IF ($PSBoundParameters['DeviceName']) {
        $CIMSplatting.Filter = "ResourceName='$DeviceName' AND isActive=1 AND TYPES NOT NULL"
    }

    # Device ID Specified
    IF ($PSBoundParameters['DeviceID']) {
        $CIMSplatting.Filter = "ResourceID='$DeviceID' AND isActive=1 AND TYPES NOT NULL"
    }

    Get-CimInstance @CIMSplatting | Remove-CimInstance
}