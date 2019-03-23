function Connect-ExchangeOnPremises
{
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
        www.lazywinadmin.com
        @lazywinadm
#>
    PARAM (
        [Parameter(Mandatory,HelpMessage= 'http://<ServerFQDN>/powershell')]
        [system.string]$ConnectionUri,
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    $Splatting = @{
        ConnectionUri = $ConnectionUri
        ConfigurationName = 'microsoft.exchange'
    }
    IF ($PSBoundParameters['Credential']){$Splatting.Credential = $Credential}

    # Load Exchange cmdlets (Implicit remoting)
    Import-PSSession -Session (New-pssession @Splatting)
}