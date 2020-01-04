function Send-Email {
    <#
    .SYNOPSIS
        This function allows you to send email

    .DESCRIPTION
        This function allows you to send email using the NET Class System.Net.Mail

    .PARAMETER To
        A description of the To parameter.

    .PARAMETER From
        A description of the From parameter.

    .PARAMETER FromDisplayName
        Specifies the DisplayName to show for the FROM parameter

    .PARAMETER SenderAddress
        A description of the SenderAddress parameter.

    .PARAMETER SenderDisplayName
        Specifies the DisplayName of the Sender

    .PARAMETER CC
        A description of the CC parameter.

    .PARAMETER BCC
        A description of the BCC parameter.

    .PARAMETER ReplyToList
        Specifies the email address(es) that will be use when the recipient(s) reply to the email.

    .PARAMETER Subject
        Specifies the subject of the email.

    .PARAMETER Body
        Specifies the body of the email.

    .PARAMETER BodyIsHTML
        Specifies that the text format of the body is HTML. Default is Plain Text.

    .PARAMETER Priority
        Specifies the priority of the message. Default is Normal.

    .PARAMETER Encoding
        Specifies the text encoding of the title and the body.

    .PARAMETER Attachment
        Specifies if an attachement must be added to the function

    .PARAMETER Credential
        Specifies the credential to use, default will use the current credential.

    .PARAMETER SMTPServer
        Specifies if the SMTP Server IP or FQDN to use

    .PARAMETER Port
        Specifies if the SMTP Server Port to use. Default is 25.

    .PARAMETER EnableSSL
        Specifies if the email must be sent using SSL.

    .PARAMETER DeliveryNotificationOptions
        Specifies the delivey notification options.
        https://msdn.microsoft.com/en-us/library/system.net.mail.deliverynotificationoptions.aspx

    .PARAMETER EmailCC
        Specifies the Carbon Copy recipient

    .PARAMETER EmailBCC
        Specifies the Blind Carbon Copy recipient

    .PARAMETER EmailTo
        Specifies the recipient of the email

    .PARAMETER EmailFrom
        Specifies the sender of the email

    .PARAMETER Sender
        Specifies the Sender Email address. Sender is the Address of the actual sender acting on behalf of the author listed in the From parameter.

    .EXAMPLE
        Send-email `
        -EmailTo "fxcat@contoso.com" `
        -EmailFrom "powershell@contoso.com" `
        -SMTPServer "smtp.sendgrid.net"  `
        -Subject "Test Email" `
        -Body "Test Email"

        This will send an email using the current credential of the current logged user

    .EXAMPLE
        $Cred = [System.Net.NetworkCredential](Get-Credential -Credential testuser)

        Send-email `
        -EmailTo "fxcat@contoso.com" `
        -EmailFrom "powershell@contoso.com" `
        -Credential $cred
        -SMTPServer "smtp.sendgrid.net"  `
        -Subject "Test Email" `
        -Body "Test Email"

        This will send an email using the credentials specified in the $Cred variable

    .EXAMPLE
        Send-email `
        -EmailTo "fxcat@contoso.com","SomeoneElse@contoso.com" `
        -EmailFrom "powershell@contoso.com" `
        -SMTPServer "smtp.sendgrid.net"  `
        -Subject "Test Email" `
        -Body "Test Email"

        This will send an email using the current credential of the current logged user to two
        fxcat@contoso.com and SomeoneElse@contoso.com

    .NOTES
        Francois-Xavier Cat
        fxcat@lazywinadmin.com
        lazywinadmin.com
        @lazywinadmin

        VERSION HISTORY
        1.0 2014/12/25     Initial Version
        1.1 2015/02/04     Adding some error handling and clean up the code a bit
        Add Encoding, CC, BCC, BodyAsHTML
        1.2 2015/04/02    Credential

        TODO
        -Add more Help/Example
        -Add Support for classic Get-Credential
    .LINK
        https://github.com/lazywinadmin/PowerShell
#>

    [CmdletBinding(DefaultParameterSetName = 'Main')]
    param
    (
        [Parameter(ParameterSetName = 'Main',
            Mandatory = $true)]
        [Alias('EmailTo')]
        [String[]]$To,

        [Parameter(ParameterSetName = 'Main',
            Mandatory = $true)]
        [Alias('EmailFrom', 'FromAddress')]
        [String]$From,

        [Parameter(ParameterSetName = 'Main')]
        [ValidateNotNullOrEmpty()]
        [string]$FromDisplayName,

        [Parameter(ParameterSetName = 'Main')]
        [Alias('EmailCC')]
        [String]$CC,

        [Parameter(ParameterSetName = 'Main')]
        [Alias('EmailBCC')]
        [System.String]$BCC,

        [Parameter(ParameterSetName = 'Main')]
        [ValidateNotNullOrEmpty()]
        [Alias('ReplyTo')]
        [System.string[]]$ReplyToList,

        [Parameter(ParameterSetName = 'Main')]
        [System.String]$Subject = "Email from PowerShell",

        [Parameter(ParameterSetName = 'Main')]
        [System.String]$Body = "Hello World",

        [Parameter(ParameterSetName = 'Main')]
        [Switch]$BodyIsHTML = $false,

        [Parameter(ParameterSetName = 'Main')]
        [ValidateNotNullOrEmpty()]
        [System.Net.Mail.MailPriority]$Priority = "Normal",

        [Parameter(ParameterSetName = 'Main')]
        [ValidateSet("Default", "ASCII", "Unicode", "UTF7", "UTF8", "UTF32")]
        [System.String]$Encoding = "Default",

        [Parameter(ParameterSetName = 'Main')]
        [System.String]$Attachment,

        [Parameter(ParameterSetName = 'Main')]
        [pscredential]
        [System.Net.NetworkCredential]$Credential,

        [Parameter(ParameterSetName = 'Main',
            Mandatory = $true)]
        [ValidateScript( {
                # Verify the host is reachable
                Test-Connection -ComputerName $_ -Count 1 -Quiet
            })]
        [Alias("Server")]
        [string]$SMTPServer,

        [Parameter(ParameterSetName = 'Main')]
        [ValidateRange(1, 65535)]
        [Alias("SMTPServerPort")]
        [int]$Port = 25,

        [Parameter(ParameterSetName = 'Main')]
        [Switch]$EnableSSL,

        [Parameter(ParameterSetName = 'Main')]
        [ValidateNotNullOrEmpty()]
        [Alias('EmailSender', 'Sender')]
        [string]$SenderAddress,

        [Parameter(ParameterSetName = 'Main')]
        [ValidateNotNullOrEmpty()]
        [System.String]$SenderDisplayName,

        [Parameter(ParameterSetName = 'Main')]
        [ValidateNotNullOrEmpty()]
        [Alias('DeliveryOptions')]
        [System.Net.Mail.DeliveryNotificationOptions]$DeliveryNotificationOptions
    )

    #PARAM

    PROCESS {
        TRY {
            # Create Mail Message Object
            $SMTPMessage = New-Object -TypeName System.Net.Mail.MailMessage
            $SMTPMessage.From = $From
            FOREACH ($ToAddress in $To) { $SMTPMessage.To.add($ToAddress) }
            $SMTPMessage.Body = $Body
            $SMTPMessage.IsBodyHtml = $BodyIsHTML
            $SMTPMessage.Subject = $Subject
            $SMTPMessage.BodyEncoding = $([System.Text.Encoding]::$Encoding)
            $SMTPMessage.SubjectEncoding = $([System.Text.Encoding]::$Encoding)
            $SMTPMessage.Priority = $Priority
            $SMTPMessage.Sender = $SenderAddress

            # Sender Displayname parameter
            IF ($PSBoundParameters['SenderDisplayName']) {
                $SMTPMessage.Sender.DisplayName = $SenderDisplayName
            }

            # From Displayname parameter
            IF ($PSBoundParameters['FromDisplayName']) {
                $SMTPMessage.From.DisplayName = $FromDisplayName
            }

            # CC Parameter
            IF ($PSBoundParameters['CC']) {
                $SMTPMessage.CC.Add($CC)
            }

            # BCC Parameter
            IF ($PSBoundParameters['BCC']) {
                $SMTPMessage.BCC.Add($BCC)
            }

            # ReplyToList Parameter
            IF ($PSBoundParameters['ReplyToList']) {
                foreach ($ReplyTo in $ReplyToList) {
                    $SMTPMessage.ReplyToList.Add($ReplyTo)
                }
            }

            # Attachement Parameter
            IF ($PSBoundParameters['attachment']) {
                $SMTPattachment = New-Object -TypeName System.Net.Mail.Attachment($attachment)
                $SMTPMessage.Attachments.Add($SMTPattachment)
            }

            # Delivery Options
            IF ($PSBoundParameters['DeliveryNotificationOptions']) {
                $SMTPMessage.DeliveryNotificationOptions = $DeliveryNotificationOptions
            }

            #Create SMTP Client Object
            $SMTPClient = New-Object -TypeName Net.Mail.SmtpClient
            $SMTPClient.Host = $SmtpServer
            $SMTPClient.Port = $Port

            # SSL Parameter
            IF ($PSBoundParameters['EnableSSL']) {
                $SMTPClient.EnableSsl = $true
            }

            # Credential Paramenter
            #IF (($PSBoundParameters['Username']) -and ($PSBoundParameters['Password']))
            IF ($PSBoundParameters['Credential']) {
                <#
                # Create Credential Object
                $Credentials = New-Object -TypeName System.Net.NetworkCredential
                $Credentials.UserName = $username.Split("@")[0]
                $Credentials.Password = $Password
                #>

                # Add the credentials object to the SMTPClient obj
                $SMTPClient.Credentials = $Credential
            }
            IF (-not $PSBoundParameters['Credential']) {
                # Use the current logged user credential
                $SMTPClient.UseDefaultCredentials = $true
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
        Remove-Variable -Name SMTPClient -ErrorAction SilentlyContinue
        Remove-Variable -Name Password -ErrorAction SilentlyContinue
    }#END
} #End Function Send-Email