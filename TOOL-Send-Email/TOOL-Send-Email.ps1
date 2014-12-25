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
	
	#>
	
	[CmdletBinding()]
	PARAM (
		[Parameter()]
		[Alias('To')]
		[String]$EmailTo,
	
		[String]$Subject,
		
		[String]$Body,
	
		[Parameter()]
		[Alias('From')]
		[Parameter(Mandatory = $true)]
		[String]$EmailFrom,
	
		[String]$Attachment,
		
		[String]$Username,
		
		[String]$Password,
	
		[Parameter(Mandatory = $true)]
		[ValidateScript({
			# Verify the host is reachable
			Test-Connection -ComputerName $_ -Count 1 -Quiet
		})]
		[string]$SMTPServer,
		[ValidateRange(1,65535)]
		[int]$Port = 587
	)
	
	$SMTPServer = $server
	$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body)
	if ($PSBoundParameters['attachment'])
	{
		$SMTPattachment = New-Object System.Net.Mail.Attachment($attachment)
		$SMTPMessage.Attachments.Add($STMPattachment)
	}
	$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $port)
	$SMTPClient.EnableSsl = $true
	$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($username.Split("@")[0], $Password);
	#$SMTPClient.Credentials = $SendgridCred
	$SMTPClient.Send($SMTPMessage)
	Remove-Variable -Name SMTPClient
	Remove-Variable -Name Password
	
} #End Function Send-EMail