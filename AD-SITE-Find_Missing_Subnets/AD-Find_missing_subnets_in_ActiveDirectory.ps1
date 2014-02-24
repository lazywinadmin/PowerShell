<#
	.SYNOPSIS
		This script goal is to get all the missing subnets from the 
		NETLOGON.LOG file from each Domain Controllers in the Active Directory.
		It will copy all the NETLOGON.LOG locally and parse them.

	.DESCRIPTION
		This script goal is to get all the missing subnets from the 
		NETLOGON.LOG file from each Domain Controllers in the Active Directory.
		It will copy all the NETLOGON.LOG locally and parse them.

	.PARAMETER EmailServer
		Specifies the Email Server IPAddress/FQDN
	.PARAMETER EmailTo
		Specifies the Email Address(es) of the Destination
	.PARAMETER EmailFrom
		Specifies the Email Address of the Sender
	.PARAMETER EmailSubject
		Specifies the Email Subject
	.PARAMETER LogsLines
		Specifies the number of Lines to check in the NETLOGON.LOG files
		Default is '-200'.
		This number is negative, so the script check the last x lines (newest entry).
		If you put a positive number it will check the first lines (oldest entry).

	.EXAMPLE
		./TOOL-AD-SITE-Report_Missing_Subnets.ps1 -Verbose -EmailServer mail.fx.local -EmailTo "Contact1@fx.local","Contact2@fx.local" -EmailFrom ADREPORT@fx.local -EmailSubject "Report - AD - Missing Subnets"

		This example will query all the Domain Controllers in the Active Directory and get the last 200 lines (Default) of each NETLOGON.log files. It will then send an email report to Contact1@fx.local and Contact2@fx.local.

	.NOTES
		NAME:	TOOL-AD-SITE-Report_Missing_Subnets.ps1
		AUTHOR:	Francois-Xavier CAT 
		DATE:	2011/10/11
		EMAIL:	info@lazywinadmin.com

		REQUIREMENTS:
		-A Task scheduler to execute the script every x weeks
		-Permission to Read \\DC\admin$, a basic account without specific rights will do it
		-Permission to write locally in the Output folder ($ScriptPath\Output)

		VERSION HISTORY:
		1.0 2011.10.11
			Initial Version.
		1.1 2011.11.12
			FIX System.OutOfMemoryException Error when too many logs to process
				Now the script will copy the file locally.
		1.2 2012.09.22
			UPDATE Code to report via CSV/Email
		1.3 2013.10.14
			UPDATE the syntax of the script
		1.4 2013.10.20
			ADD ValidatePattern on Email parameters, instead of [mailaddress] which is only supported on PS v3
        1.4.1 2014.02.24
            FIX issue with sending the email
#>

#requires -version 2.0
  
[CmdletBinding()]
PARAM(
		[Parameter(Mandatory=$true,HelpMessage="You must specify the Sender Email Address")]
		[ValidatePattern("[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")]
        [String]$EmailFrom,
		[Parameter(Mandatory=$true,HelpMessage="You must specify the Destination Email Address")]
		[ValidatePattern("[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")]
        [String[]]$EmailTo,
		[Parameter(Mandatory=$true,HelpMessage="You must specify the Email Server to use (IPAddress or FQDN)")]
        [String]$EmailServer,
		[String]$EmailSubject = "Report - Active Directory - SITE - Missing Subnets",
		[Int]$LogsLines = "-200"
    )

BEGIN {
    TRY{
        # PATH Information 
        $ScriptPath = (Split-Path -Path ((Get-Variable -Name MyInvocation).Value).MyCommand.Path)
        $ScriptPathOutput = $ScriptPath + "\Output"
        IF (-not(Test-Path -Path $ScriptPathOutput))
        {
            Write-Verbose -Message "Creating the Output Folder : $ScriptPathOutput"
            New-Item -Path $ScriptPathOutput -ItemType Directory | Out-Null
        }
		
		# Date and Time Information
        $DateFormat = Get-Date -Format "yyyyMMdd_HHmmss"
        $ReportDateFormat = Get-Date -Format "yyyy\MM\dd HH:mm:ss"

        # HTML Report settings
		$ReportTitle 		= 	"<H2>"+
									"Report - Active Directory - SITE - Missing Subnets"+
								"</H2>"
        # HTML Report settings
        $Report				= 	"<p style=`"background-color:white;font-family:consolas;font-size:9pt`">"+
									"<strong>Report Time:</strong> $DateFormat <br>"+
									"<strong>Account:</strong> $env:userdomain\$($env:username.toupper()) on $($env:ComputerName.toUpper())"+
								"</p>"

		$Head				= 	"<style>"+
									"BODY{background-color:white;font-family:consolas;font-size:11pt}"+
									"TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse}"+
									"TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:`"#00297A`";font-color:white}"+
									"TD{border-width: 1px;padding-right: 2px;padding-left: 2px;padding-top: 0px;padding-bottom: 0px;border-style: solid;border-color: black;background-color:white}"+
								"</style>"
		$Head2				= 	"<style>"+
									"BODY{background-color:white;font-family:consolas;font-size:9pt;}"+
									"TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"+
									"TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:`"#C0C0C0`"}"+
									"TD{border-width: 1px;padding-right: 2px;padding-left: 2px;padding-top: 0px;padding-bottom: 0px;border-style: solid;border-color: black;background-color:white}"+
								"</style>"
		
		# Get the Current Domain Information
		$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
		Write-Verbose -Message "Domain: $domain"

    }#TRY
    CATCH{
        Write-Warning -Message "BEGIN BLOCK - Something went wrong"
    }#CATCH
}#BEGIN

PROCESS{
	TRY {
		# Get the names of all the Domain Contollers in $domain
		Write-Verbose -Message "Getting all Domain Controllers from $domain ..."
		$DomainControllers = $domain | ForEach-Object -Process { $_.DomainControllers } | Select-Object -Property Name

		# Gathering the NETLOGON.LOG for each Domain Controller
		Write-Verbose "Gathering Logs from Domain controllers"
		FOREACH ($dc in $DomainControllers)
		{
			$DCName = $($dc.Name)
			TRY{
		        # Get the Current Domain Controller in the Loop
				Write-Verbose -Message "Gathering Logs from DC: $DCName"
		        
		        # NETLOGON.LOG path for the current Domain Controller
		        $path = "\\$DCName\admin`$\debug\netlogon.log"
		        
		        # Testing the $path
		        IF ((Test-Path -Path $path) -and ((Get-Item -Path $path).Length -ne $null))
				{
                    IF ((Get-Content -Path $path | Measure-Object -Line).lines -gt 0){
		                #Copy the NETLOGON.log locally for the current DC
		                Write-Verbose -Message "$DCName - NETLOGON.LOG - Copying..."
		                Copy-Item -Path $path -Destination $ScriptPathOutput\$($dc.Name)-$DateFormat-netlogon.log 
		                
		                #Export the $LogsLines last lines of the NETLOGON.log and send it to a file
		                ((Get-Content -Path $ScriptPathOutput\$DCName-$DateFormat-netlogon.log -ErrorAction Continue)[$LogsLines .. -1]) | 
						    Out-File -FilePath "$ScriptPathOutput\$DCName.txt" -ErrorAction 'Continue' -ErrorVariable ErrorOutFileNetLogon
				        Write-Verbose -Message "$DCName - NETLOGON.LOG - Copied"
                    }#IF
                    ELSE {Write-Verbose -Message "File Empty"}
		        }ELSE{Write-Warning -Message "$DCName NETLOGON.log is not reachable"}
			}#TRY
			CATCH{
				Write-Warning -Message "Something wrong happened with $DCName"
				if ($ErrorOutFileNetLogon){Write-Warning -Message "$DCName - Error with Out-File"}
			}#CATCH
		}#FOREACH

		# Combine all the TXT file in one
        $FilesToCombine = Get-Content -Path $ScriptPathOutput\*.txt -ErrorAction SilentlyContinue
        if ($FilesToCombine){
		    $FilesToCombine| Out-File -FilePath $ScriptPathOutput\$dateformat-All_Export.txt

		    # Convert the TXT file to a CSV format
		    Write-Verbose -Message "Importing exported data to a CSV format..."
		    $importString = Import-Csv -Path $scriptpathOutput\$dateformat-All_Export.txt -Delimiter ' ' -Header Date,Time,Domain,Error,Name,IPAddress
            
            #  Get Only the entries for the Missing Subnets
            $MissingSubnets = $importString | Where-Object {$_.Error -like "*NO_CLIENT_SITE*"}
			Write-Verbose -Message "Missing Subnet(s) Found: $($MissingSubnets.count)"
            #  Get the other errors from the log
			$OtherErrors    = Get-Content $scriptpathOutput\$dateformat-All_Export.txt | Where-Object {$_ -notlike "*NO_CLIENT_SITE*"} | Sort-Object -Unique
			Write-Verbose -Message "Other Error(s) Found: $($OtherErrors.count)"

			# BUILDING THE HTML REPORT
			Write-Verbose -Message "Building the HTML Report"
            #  Missing Subnets
            $EmailBody += "<h2>Missing Subnet(s)</h2>"
			IF ($MissingSubnets){
            	$EmailBody += "<i>List of Active Directory client that can not find their site.<br> You need to add those subnets into the console Active Directory Sites And Services</i>"
            	$EmailBody += $MissingSubnets | Sort-Object IPAddress -Unique | ConvertTo-Html `
							            -property Date, Name, IPAddress, Domain, Error `
							            -head $Head	|Out-String
			}ELSE {$EmailBody += "<i>No Missing Subnet(s) detected</i>"}
			
			#  Other Errors
			$EmailBody += "<h2>Other Error(s)</h2>" 
			IF ($OtherErrors){
	            $EmailBody += "<br><font size=`"1`" color=`"red`">"
				# Retrieve Each txt generated from the NETLOGON files
				Get-ChildItem $scriptpathoutput\*.txt -Exclude "*All_Export*" | 
					ForEach-Object{
						# Get the Other Errors (not Missing subnets)
						$CurrentFile = Get-Content $_ | Where-Object {$_ -notlike "*NO_CLIENT_SITE*"}
						IF($CurrentFile){
							# Write the name of the log, this will help sysadmin to find which side report the error
							$EmailBody +="<font size=`"2`"><b>$($_.basename)</b><br></font>"
							$EmailBody += "<br><font size=`"1`" color=`"red`">"
							FOREACH ($Line in $CurrentFile){
								$EmailBody += "$line<br>"	
							}#FOREACH
							# Close the FONT block	
							$EmailBody += "</font>"
						}#IF
					}#foreach-object
			}ELSE{$EmailBody += "<i>No Other Error detected</i>"}
			
		    # Export to a CSV File
		    Write-Verbose -Message "CSV file (backup) - Exporting..."
		    $importString | Select-Object -Property Date, Name, IPAddress, Domain, Error | 
		        Sort-Object -Property IPAddress -Unique | 
		        Export-Csv -Path $scriptPathOutput\$DateFormat-AD-SITE-MissingSubnets.csv
		    
			Write-Verbose -Message "CSV file (backup) - Exported to: $DateFormat-AD-SITE-MissingSubnets.csv"
			
			# EMAIL
			Write-Verbose -Message "Preparing the Email"
			$SmtpClient = New-Object -TypeName system.net.mail.smtpClient
			$SmtpClient.host = $EmailServer  
			$MailMessage = New-Object -TypeName system.net.mail.mailmessage
			$MailMessage.from = $EmailFrom 
            #FOREACH ($To in $Emailto){$MailMessage.To.add($($To.Address))}
            FOREACH ($To in $Emailto){$MailMessage.To.add($($To))}
			$MailMessage.IsBodyHtml = $true
			$MailMessage.Subject = $EmailSubject
			$MailMessage.Body = $EmailBody
			$SmtpClient.Send($MailMessage)
		    Write-Verbose -Message "Email Sent!"
        }#IF File to Combine
        ELSE{Write-Verbose -Message "Nothing to process"}
	}#TRY
	CATCH{
		
	}#CATCH

}#PROCESS
END{
	Write-Verbose "Cleanup txt and log files..."
	Remove-item -Path $ScriptpathOutput\*.txt -force
	Remove-Item -Path $ScriptPathOutput\*.log -force
	Write-Verbose -Message "Script Completed"
}#END