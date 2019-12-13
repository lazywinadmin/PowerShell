<#
.SYNOPSIS
    Script to report expiring user account
.DESCRIPTION
    Script to report expiring user account
.PARAMETER Days
    Specifies the number of days to look up
.PARAMETER SearchBase
    Specifies the DistinguishedName
.PARAMETER EmailFrom
    Specifies the email origin
.PARAMETER EmailTo
    Specifies the email destination
.PARAMETER EmailSMTPServer
    Specifies the SMTP Server to use
.EXAMPLE
    .\AD-USER-Report_Expiring_Users.ps1 -days 5 -EmailFrom "ScriptBox@lazywinadmin.com" -EmailSMTPServer smtp.lazywinadmin.com -EmailTo fxcat@lazywinadmin.com
.NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadmin

    VERSION HISTORY
    1.0 2015/02/03    Initial Version

    TODO
        Send-Mailmessage in begin


#>
[CmdletBinding()]
PARAM (
    [Alias("ExpirationDays")]
    [Int]$Days = '10',

    [String]$SearchBase = "",

    [string]$EmailFrom = "ScriptServer@Contoso.com",

    [string]$EmailTo = "IT@Contoso.com",

    [String]$EmailSMTPServer = "smtp.contoso.com"
)
BEGIN {
    # Add Active Directory Module

    # Define Email Subject
    [String]$EmailSubject = "PS Report-ActiveDirectory-Expiring Users (in the next $days days)"
    [String]$NoteLine = "Generated from $($env:Computername.ToUpper()) on $(Get-Date -format 'yyyy/MM/dd HH:mm:ss')"

    # Functions helper
    #  Send from
    Function Send-Email {
        <#
    .SYNOPSIS
        This function allows you to send email
    .DESCRIPTION
        This function allows you to send email
    .EXAMPLE
        Send-email `
            -EmailTo "fxcat@contoso.com" `
            -EmailFrom "powershell@contoso.com" `
            -Username "Account" `
            -Password "SecretP@ssword" `
            -SMTPServer "smtp.sendgrid.net"  `
            -Subject "Test Email" `
            -Body "Test Email"
    .NOTES
        Francois-Xavier Cat
        fxcat@lazywinadmin.com
        lazywinadmin.com
        @lazywinadmin

        VERSION HISTORY
        1.0 2014/12/25     Initial Version
        1.1 2015/02/04     Adding some error handling and clean up the code a bit
                        Add Encoding, CC, BCC, BodyAsHTML

        TODO
        -Add more Help/Example
        -Add Support for classic Get-Credential

    #>

        [CmdletBinding()]
        PARAM (
            [Parameter(Mandatory = $true)]
            [Alias('To')]
            [String]$EmailTo,

            [Parameter(Mandatory = $true)]
            [Alias('From')]
            [String]$EmailFrom,

            [String]$EmailCC,

            [String]$EmailBCC,

            [String]$Subject = "Email from PowerShell",

            [String]$Body = "Hello World",

            [Switch]$BodyIsHTML = $false,

            [ValidateSet("Default", "ASCII", "Unicode", "UTF7", "UTF8", "UTF32")]
            [System.Text.Encoding]$Encoding = "Default",

            [String]$Attachment,

            #[Parameter(ParameterSetName = "Credential", Mandatory = $true)]
            #[String]$Username,

            #[Parameter(ParameterSetName = "Credential", Mandatory = $true)]
            #[String]$Password,

            [pscredential]$Credential,

            [Parameter(Mandatory = $true)]
            [ValidateScript( {
                    # Verify the host is reachable
                    Test-Connection -ComputerName $_ -Count 1 -Quiet
                })]
            [string]$SMTPServer,

            [ValidateRange(1, 65535)]
            [int]$Port,

            [Switch]$EnableSSL
        )#PARAM

        PROCESS {
            TRY {
                # Create Mail Message Object
                $SMTPMessage = New-Object -TypeName System.Net.Mail.MailMessage
                $SMTPMessage.From = $EmailFrom
                $SMTPMessage.To = $EmailTo
                $SMTPMessage.Body = $Body
                $SMTPMessage.Subject = $Subject
                $SMTPMessage.CC = $EmailCC
                $SMTPMessage.Bcc = $EmailBCC
                $SMTPMessage.IsBodyHtml = $BodyIsHtml
                $SMTPMessage.BodyEncoding = $Encoding
                $SMTPMessage.SubjectEncoding = $Encoding

                # Attachement Parameter
                IF ($PSBoundParameters['attachment']) {
                    $SMTPattachment = New-Object -TypeName System.Net.Mail.Attachment -ArgumentList $attachment
                    $SMTPMessage.Attachments.Add($SMTPattachment)
                }

                # Create SMTP Client Object
                $SMTPClient = New-Object -TypeName Net.Mail.SmtpClient
                $SMTPClient.Host = $SmtpServer
                $SMTPClient.Port = $Port

                # SSL Parameter
                IF ($PSBoundParameters['EnableSSL']) {
                    $SMTPClient.EnableSsl = $true
                }

                # Credential Paramenter
                #IF (($PSBoundParameters['Username']) -and ($PSBoundParameters['Password'])) {
                IF ($PSBoundParameters['Credential']) {
                    # Create Credential Object
                    #$Credential = New-Object -TypeName System.Net.NetworkCredential
                    #$Credential.UserName = $username.Split("@")[0]
                    #$Credential.Password = $Password

                    # Add the credentials object to the SMTPClient obj
                    $SMTPClient.Credentials = $Credential
                }

                # Send the Email
                $SMTPClient.Send($SMTPMessage)

            }#TRY
            CATCH {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }#Process
        END {
            # Remove Variables
            Remove-Variable -Name SMTPClient
            Remove-Variable -Name Password
        }#END
    } #End Function Send-EMail

}
PROCESS {
    TRY {
        $Accounts = Search-ADAccount -AccountExpiring -SearchBase $SearchBase -TimeSpan "$($days).00:00:00" |
            Select-Object -Property AccountExpirationDate, Name, Samaccountname, @{ Label = "Manager"; E = { (Get-Aduser(Get-aduser $_ -property manager).manager).Name } }, DistinguishedName

        $Css = @"
<style>
table {
    font-family: verdana,arial,sans-serif;
    font-size:11px;
    color:#333333;
    border-width: 1px;
    border-color: #666666;
    border-collapse: collapse;
}

th {
    border-width: 1px;
    padding: 8px;
    border-style: solid;
    border-color: #666666;
    background-color: #dedede;
}

td {
    border-width: 1px;
    padding: 8px;
    border-style: solid;
    border-color: #666666;
    background-color: #ffffff;
}
</style>
"@

        $PreContent = "<Title>Active Directory - Expiring Users (next $days days)</Title>"
        $PostContent = "<br><p><font size='2'><i>$NoteLine</i></font>"


        # Prepare Body
        # If No account to report
        IF (-not ($accounts)) {
            $body = "No user account expiring in the next $days days to report <br>$PostContent"
        }
        ELSE {
            $body = $Accounts |
                ConvertTo-Html -head $Css -PostContent $PostContent -PreContent $PreContent
        }

        # Sending email
        Send-Email -SMTPServer $EmailSMTPServer -From $EmailFrom -To $Emailto -BodyIsHTML `
            -Subject $EmailSubject -Body $body

    }#TRY
    CATCH {
        Throw $_
    }
}#PROCESS
END {

}