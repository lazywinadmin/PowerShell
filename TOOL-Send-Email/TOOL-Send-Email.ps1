Function Send-EMail
{
<#
	.SYNOPSIS
		This function allows you to send email
	
	.DESCRIPTION
		This function allows you to send email using the NET Class System.Net.Mail
	
	.PARAMETER EmailTo
		Specifies the recipient of the email
	
	.PARAMETER EmailFrom
		Specifies the sender of the email
	
	.PARAMETER EmailCC
		Specifies the Carbon Copy recipient
	
	.PARAMETER EmailBCC
		Specifies the Blind Carbon Copy recipient
	
	.PARAMETER Subject
		Specifies the subject of the email.
	
	.PARAMETER Body
		Specifies the body of the email.
	
	.PARAMETER BodyIsHTML
		Specifies that the text format of the body is HTML. Default is Plain Text.
	
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
	
	.NOTES
		Francois-Xavier Cat
		fxcat@lazywinadmin.com
		www.lazywinadmin.com
		@lazywinadm
		
		VERSION HISTORY
		1.0 2014/12/25 	Initial Version
		1.1 2015/02/04 	Adding some error handling and clean up the code a bit
		Add Encoding, CC, BCC, BodyAsHTML
		1.2 2015/04/02	Credential
		
		TODO
		-Add more Help/Example
		-Add Support for classic Get-Credential
#>
	
	[CmdletBinding(DefaultParameterSetName = "Main")]
	PARAM (
		[Parameter(ParameterSetName = "Main")]
		[Parameter(Mandatory = $true)]
		[Alias('To')]
		[String]$EmailTo,
		
		[Parameter(ParameterSetName = "Main")]
		[Parameter(Mandatory = $true)]
		[Alias('From')]
		[String]$EmailFrom,
		
		[Parameter(ParameterSetName = "Main")]
		[String]$EmailCC,
		
		[Parameter(ParameterSetName = "Main")]
		[String]$EmailBCC,
		
		[Parameter(ParameterSetName = "Main")]
		[String]$Subject = "Email from PowerShell",
		
		[Parameter(ParameterSetName = "Main")]
		[String]$Body = "Hello World",
		
		[Parameter(ParameterSetName = "Main")]
		[Switch]$BodyIsHTML = $false,
		
		[Parameter(ParameterSetName = "Main")]
		[ValidateSet("Default","ASCII","Unicode","UTF7","UTF8","UTF32")]
		[System.String]$Encoding = "Default",
		
		[Parameter(ParameterSetName = "Main")]
		[String]$Attachment,
		
		[System.Net.NetworkCredential]$Credential,
		<#
		[Parameter(ParameterSetName = "Main")]
		[Parameter(ParameterSetName = "Credential", Mandatory = $true)]
		[String]$Username,
	
		[Parameter(ParameterSetName = "Main")]
		[Parameter(ParameterSetName = "Credential", Mandatory = $true)]
		[String]$Password,
		#>
		
		[Parameter(ParameterSetName = "Main")]
		[Parameter(Mandatory = $true)]
		[ValidateScript({
			# Verify the host is reachable
			Test-Connection -ComputerName $_ -Count 1 -Quiet})]
		[string]$SMTPServer,
		
		[Parameter(ParameterSetName = "Main")]
		[ValidateRange(1, 65535)]
		[int]$Port = 25,
		
		[Parameter(ParameterSetName = "Main")]
		[Switch]$EnableSSL
	)#PARAM
	
	PROCESS
	{
		TRY
		{
			# Create Mail Message Object
			$SMTPMessage = New-Object System.Net.Mail.MailMessage
			$SMTPMessage.From = $EmailFrom
			$SMTPMessage.To = $EmailTo
			$SMTPMessage.Body = $Body
			$SMTPMessage.Subject = $Subject
			$SMTPMessage.BodyEncoding = $([System.Text.Encoding]::$Encoding)
			$SMTPMessage.SubjectEncoding = $([System.Text.Encoding]::$Encoding)
			
			# CC Parameter
			IF ($PSBoundParameters['EmailCC'])
			{
				$SMTPMessage.CC.Add($EmailCC)
			}
			
			# BCC Parameter
			IF ($PSBoundParameters['EmailBCC'])
			{
				$SMTPMessage.BCC.Add($EmailBCC)
			}
			
			# Attachement Parameter
			IF ($PSBoundParameters['attachment'])
			{
				$SMTPattachment = New-Object -TypeName System.Net.Mail.Attachment($attachment)
				$SMTPMessage.Attachments.Add($STMPattachment)
			}
			
			#Create SMTP Client Object
			$SMTPClient = New-Object -TypeName Net.Mail.SmtpClient
			$SMTPClient.Host = $SmtpServer
			$SMTPClient.Port = $Port
			
			# SSL Parameter
			IF ($PSBoundParameters['EnableSSL'])
			{
				$SMTPClient.EnableSsl = $true
			}
			
			# Credential Paramenter
			#IF (($PSBoundParameters['Username']) -and ($PSBoundParameters['Password']))
			IF ($PSBoundParameters['Credential'])
			{
				<#
				# Create Credential Object
				$Credentials = New-Object -TypeName System.Net.NetworkCredential
				$Credentials.UserName = $username.Split("@")[0]
				$Credentials.Password = $Password
				#>
				
				# Add the credentials object to the SMTPClient obj
				$SMTPClient.Credentials = $Credential
			}
			IF (-not $PSBoundParameters['Credential'])
			{
				# Use the current logged user credential
				$SMTPClient.UseDefaultCredentials = $true
			}
			
			# Send the Email
			$SMTPClient.Send($SMTPMessage)
			
		}#TRY
		CATCH
		{
			Write-Warning -message "[PROCESS] Something wrong happened"
			Write-Warning -Message $Error[0].Exception.Message
		}
	}#Process
	END
	{
		# Remove Variables
		Remove-Variable -Name SMTPClient -ErrorAction SilentlyContinue
		Remove-Variable -Name Password -ErrorAction SilentlyContinue
	}#END
} #End Function Send-EMail