Function Add-SCCMUserDeviceAffinity {
    <#
    .SYNOPSIS
        Function to add a primary user on a device

    .DESCRIPTION
        Function to add a primary user on a device

    .PARAMETER SiteCode
        Specifies the SCCM SiteCode

    .PARAMETER SiteServer
        Specifies the SCCM Management Server

    .PARAMETER DeviceName
        Specifies the DeviceName on which the Primary User will be added

    .PARAMETER DeviceID
        Specifies the ResourceID of the Device

    .PARAMETER UserName
        Specifies the UserName that will be added as a Primary User on the Device

    .PARAMETER Credential
        Specifies alternative credentials to use

    .EXAMPLE
        Add-SCCMUserDeviceAffinity -DeviceName WORKSTATION01 -UserName "DOMAIN/UserAccount"

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
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

        [Parameter(Mandatory = $True, HelpMessage = "Please Enter User Name")]
        $UserName,

        [Alias("RunAs")]
        [System.Management.Automation.Credential()]
        [pscredential]
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

    Invoke-WmiMethod @Splatting -Class "SMS_UserMachineRelationship" -Name "CreateRelationship" -ArgumentList @($ResourceID, $AffinityType, 1, $UserName)
}