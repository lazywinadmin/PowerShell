function Connect-Office365 {
    <#
.SYNOPSIS
    This function will prompt for credentials, load module MSOLservice,
    load implicit modules for Office 365 Services (AD, Lync, Exchange) using PSSession.
.DESCRIPTION
    This function will prompt for credentials, load module MSOLservice,
    load implicit modules for Office 365 Services (AD, Lync, Exchange) using PSSession.
.EXAMPLE
    Connect-Office365

    This will prompt for your credentials and connect to the Office365 services
.EXAMPLE
    Connect-Office365 -verbose

    This will prompt for your credentials and connect to the Office365 services.
    Additionally you will see verbose messages on the screen to follow what is happening in the background
.NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadmin
.LINK
    https://github.com/lazywinadmin/PowerShell
#>
    [CmdletBinding()]
    PARAM (

    )
    BEGIN {
        TRY {
            #Modules
            IF (-not (Get-Module -Name MSOnline -ListAvailable)) {
                Write-Verbose -Message "BEGIN - Import module Azure Active Directory"
                Import-Module -Name MSOnline -ErrorAction Stop -ErrorVariable ErrorBeginIpmoMSOnline
            }

            IF (-not (Get-Module -Name LyncOnlineConnector -ListAvailable)) {
                Write-Verbose -Message "BEGIN - Import module Lync Online"
                Import-Module -Name LyncOnlineConnector -ErrorAction Stop -ErrorVariable ErrorBeginIpmoLyncOnline
            }
            
            IF (-not (Get-Module -Name ExchangeOnlineManagement -ListAvailable)) {
                Write-Verbose -Message "BEGIN - Import module ExchangeOnlineManagement"
                Import-Module -Name ExchangeOnlineManagement -ErrorAction Stop -ErrorVariable ErrorBeginExchangeOnlineManagement
            }
        }
        CATCH {
            IF ($ErrorBeginIpmoMSOnline) {
                Write-Warning -Message "BEGIN - Error while importing MSOnline module"
            }
            IF ($ErrorBeginIpmoLyncOnline) {
                Write-Warning -Message "BEGIN - Error while importing LyncOnlineConnector module"
            }
            
            IF ($ErrorBeginExchangeOnlineManagement) {
                Write-Warning -Message "BEGIN - Error while importing ExchangeOnlineManagement module"
            }

            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    PROCESS {
        TRY {

            # CREDENTIAL
            Write-Verbose -Message "PROCESS - Ask for Office365 Credential"
            $Credential = Get-Credential -ErrorAction continue -ErrorVariable ErrorCredential -Credential "$env:USERNAME@$env:USERDNSDOMAIN"


            # AZURE ACTIVE DIRECTORY (MSOnline)
            Write-Verbose -Message "PROCESS - Connect to Azure Active Directory"
            Connect-MsolService -Credential $Credential

            # EXCHANGE ONLINE (V2)
            Write-Verbose -Message "PROCESS - Connect to Exchange online"
            Connect-ExchangeOnline -Credential $Credential -ErrorAction Stop -ErrorVariable ErrorConnectExchange

            # LYNC ONLINE (LyncOnlineConnector)
            Write-Verbose -Message "PROCESS - Create session to Lync online"
            $LyncSession = New-CsOnlineSession –Credential $Credential -ErrorAction Stop -ErrorVariable ErrorConnectLync
            Import-PSSession -Session $LyncSession -Prefix LyncCloud

            # SHAREPOINT ONLINE (Implicit Remoting module)
            #Connect-SPOService -Url https://contoso-admin.sharepoint.com –credential $O365cred
        }
        CATCH {
            Write-Warning -Message "PROCESS - Something went wrong!"
            IF ($ErrorCredential) {
                Write-Warning -Message "PROCESS - Error while gathering credential"
            }
            IF ($ErrorConnectMSOL) {
                Write-Warning -Message "PROCESS - Error while connecting to Azure AD"
            }
            IF ($ErrorConnectExchange) {
                Write-Warning -Message "PROCESS - Error while connecting to Exchange Online"
            }
            IF ($ErrorConnectLync) {
                Write-Warning -Message "PROCESS - Error while connecting to Lync Online"
            }

            Write-Warning -Message $error[0].exception.message
        }
    }
}
