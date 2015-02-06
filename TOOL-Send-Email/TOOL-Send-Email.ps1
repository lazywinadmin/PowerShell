Function Send-EMail
{
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
		www.lazywinadmin.com
		@lazywinadm
	
		VERSION HISTORY
		1.0 2014/12/25 	Initial Version
		1.1 2015/02/04 	Adding some error handling and clean up the code a bit
						Add Encoding, CC, BCC, BodyAsHTML
	
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
		[System.Text.Encoding]$Encoding = "Default",
		
		[Parameter(ParameterSetName = "Main")]
		[String]$Attachment,
		
		[Parameter(ParameterSetName = "Main")]
		[Parameter(ParameterSetName = "Credential", Mandatory = $true)]
		[String]$Username,
	
		[Parameter(ParameterSetName = "Main")]
		[Parameter(ParameterSetName = "Credential", Mandatory = $true)]
		[String]$Password,
		
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
			$SMTPMessage.CC = $EmailCC
			$SMTPMessage.Bcc = $EmailBCC
			$SMTPMessage.IsBodyHtml = $BodyIsHtml
			$SMTPMessage.BodyEncoding = $([System.Text.Encoding]::$Encoding)
			$SMTPMessage.SubjectEncoding = $([System.Text.Encoding]::$Encoding)
			
			# Attachement Parameter
			IF ($PSBoundParameters['attachment'])
			{
				$SMTPattachment = New-Object -TypeName System.Net.Mail.Attachment($attachment)
				$SMTPMessage.Attachments.Add($STMPattachment)
			}
			
			# Create SMTP Client Object
			$SMTPClient = New-Object 
			$SMTPClient.Host = $SmtpServer
			$SMTPClient.Port = $Port
			
			# SSL Parameter
			IF ($PSBoundParameters['EnableSSL'])
			{
				$SMTPClient.EnableSsl = $true
			}
			
			# Credential Paramenter
			IF (($PSBoundParameters['Username']) -and ($PSBoundParameters['Password']))
			{
				# Create Credential Object
				$Credentials = New-Object -TypeName System.Net.NetworkCredential
				$Credentials.UserName = $username.Split("@")[0]
				$Credentials.Password = $Password
				
				# Add the credentials object to the SMTPClient obj
				$SMTPClient.Credentials = $Credentials
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
		Remove-Variable -Name SMTPClient
		Remove-Variable -Name Password
	}#END
} #End Function Send-EMail