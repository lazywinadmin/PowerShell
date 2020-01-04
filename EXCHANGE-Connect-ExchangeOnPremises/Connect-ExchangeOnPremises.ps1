function Connect-ExchangeOnPremises {
    <#
    .SYNOPSIS
        Function to Connect to an Exchange OnPremises environment

    .DESCRIPTION
        Function to Connect to an Exchange OnPremises environment

    .PARAMETER ConnectionUri
        Specifies the Connection Uri to use
        Example: http://ExchServer.lazywinadmin.com/powershell

    .PARAMETER Credential
        Specifies the credential to use

    .EXAMPLE
        PS C:\> Connect-ExchangeOnPremises -ConnectionUri http://ExchServer.lazywinadmin.com/powershell

    .EXAMPLE
        PS C:\> Connect-ExchangeOnPremises -ConnectionUri http://ExchServer.lazywinadmin.com/powershell -Credential (Get-Credential)

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
    .LINK
        https://github.com/lazywinadmin/PowerShell
#>
    PARAM (
        [Parameter(Mandatory, HelpMessage = 'http://<ServerFQDN>/powershell')]
        [system.string]$ConnectionUri,

        [Alias('RunAs')]
        [pscredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    try{


        $Splatting = @{
            ConnectionUri     = $ConnectionUri
            ConfigurationName = 'microsoft.exchange'
        }
        IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }

        # Load Exchange cmdlets (Implicit remoting)
        Import-PSSession -Session (New-PSSession @Splatting)
    }catch{
        $PSCmdlet.ThrowTerminatingError($_)
    }
}