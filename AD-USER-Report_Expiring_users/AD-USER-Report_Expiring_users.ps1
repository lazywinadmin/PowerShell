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
	www.lazywinadmin.com
	@lazywinadm

	VERSION HISTORY
	1.0 2015/02/03	Initial Version
	
	TODO
		Send-Mailmessage in begin
		
	
#>
[CmdletBinding()]
PARAM (
	[Alias("ExpirationDays")]
	[Int]$Days = '10',
	
	[String]$SearchBase = "",
	
	[mailaddress]$EmailFrom = "ScriptServer@Contoso.com",
	
	[mailaddress[]]$EmailTo = "IT@Contoso.com",
	
	[String]$EmailSMTPServer = "smtp.contoso.com"
)
BEGIN
{
	# Add Active Directory Module	
	
	# Define Email Subject
	[String]$EmailSubject = "PS Report-ActiveDirectory-Expiring Users (in the next $days days)"
	[String]$NoteLine = "Generated from $($env:Computername.ToUpper()) on $(Get-Date -format 'yyyy/MM/dd HH:mm:ss')"
}
PROCESS
{
	TRY
	{
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
		IF (-not ($accounts))
		{
			$body = "No user account expiring in the next $days days to report <br>$PostContent"
		}
		ELSE
		{
			$body = $Accounts |
			ConvertTo-Html -head $Css -PostContent $PostContent -PreContent $PreContent
		}
		
		# Send an Email
		#  Preparing the Email properties
		$SmtpClient = New-Object -TypeName system.net.mail.smtpClient
		$SmtpClient.host = $EmailSMTPServer
		$MailMessage = New-Object -TypeName system.net.mail.mailmessage
		
		#$MailMessage.from = $EmailFrom.Address
		$MailMessage.from = $EmailFrom.Address
		FOREACH ($To in $Emailto) { $MailMessage.To.add($($To.Address)) }
		
		#FOREACH ($To in $Emailto) { $MailMessage.To.add($($To)) }
		$MailMessage.IsBodyHtml = 1
		$MailMessage.Subject = $EmailSubject
		$MailMessage.Body = $Body
		
		#$MailMessage.Attachments.Add((Join-Path $MonthlyReportLocation $MonthlyReportName))
		
		$SmtpClient.Send($MailMessage)
	}#TRY
	CATCH
	{
		
	}
}#PROCESS
END
{
	
}