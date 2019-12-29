Function Add-SCCMGroupDeviceAffinity {
    <#
    .SYNOPSIS
        Function to add a group as primary user on a device

    .DESCRIPTION
        Function to add a group as primary user on a device

    .PARAMETER SiteCode
        Specifies the SCCM SiteCode

    .PARAMETER SiteServer
        Specifies the SCCM Management Server

    .PARAMETER DeviceName
        Specifies the DeviceName on which the Primary User will be added

    .PARAMETER DeviceID
        Specifies the ResourceID of the Device

    .PARAMETER GroupName
        Specifies the Active Directory Group to add as a Primary User on a device

    .PARAMETER Credential
        Specifies alternative credentials to use

    .PARAMETER UserName
        Specifies the UserName that will be added as a Primary User on the Device

    .EXAMPLE
        Add-SCCMGroupDeviceAffinity -DeviceName WORKSTATION01 -GroupName "DOMAIN/GROUP01"

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
    .LINK
        https://github.com/lazywinadmin/PowerShell
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, HelpMessage = "Please Enter Site Server Site code")]
        $SiteCode,

        [Parameter(Mandatory = $True, HelpMessage = "Please Enter Site Server Name")]
        $SiteServer,

        [Parameter(Mandatory = $True, HelpMessage = "Please Enter Device Name")]
        $DeviceName,

        [Parameter()]
        $DeviceID,

        [Parameter(Mandatory = $True, HelpMessage = "Please Enter Group Name")]
        $GroupName,

        [Alias("RunAs")]
        [pscredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    $Splatting = @{
        NameSpace    = "root\sms\site_$SiteCode"
        ComputerName = $SiteServer
    }

    IF ($PSBoundParameters['Credential']) {
        $Splatting.Credential = $Credential
    }


    $AffinityType = 2 # Administrator defined

    IF ($PSBoundParameters['DeviceName']) {
        $ResourceID = (Get-WmiObject @Splatting -Class "SMS_CombinedDeviceResources" -Filter "Name='$DeviceName'" -ErrorAction STOP).resourceID
    }
    IF ($PSBoundParameters['DeviceID']) {
        $ResourceID = $DeviceID
    }

    Invoke-WmiMethod @Splatting -Class "SMS_UserMachineRelationship" -Name "CreateRelationship" -ArgumentList @($ResourceID, $AffinityType, 1, $GroupName)
}