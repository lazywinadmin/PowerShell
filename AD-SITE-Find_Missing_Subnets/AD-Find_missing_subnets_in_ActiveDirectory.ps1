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
        NAME:    TOOL-AD-SITE-Report_Missing_Subnets.ps1
        AUTHOR:    Francois-Xavier CAT
        DATE:    2011/10/11
        EMAIL:    info@lazywinadmin.com

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
        1.5.0 2015.03.12
            ADD Search all domains in the forest
            ADD NETLOGON file version detection (from 2012, NETLOGON contains a colomn for ErrorCode)
            ADD some Verbose/Warning message
            ADD Support for SMTP Port (Parameter EmailSMTPPort), default is 25
            UPDATE Logic of the script (now append csv for each DC, and process the CSV files and Build html at the end of the PROCESS block)
            UPDATE Html report to show forest and domain information
            ADD KeepLogs Switch Parameter
            REMOVE the ExportCSV part, it is saved by default
            ADD HTMLReportPath Parameter, Just need to specify the folder. default file name will be: $ForestName-DateFormat-Report.html
            ADD Table CSS
#>

#requires -version 2.0

[CmdletBinding()]
PARAM (
    [Parameter(Mandatory = $true, HelpMessage = "You must specify the Sender Email Address")]
    [ValidatePattern("[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")]
    [String]$EmailFrom,

    [Parameter(Mandatory = $true, HelpMessage = "You must specify the Destination Email Address")]
    [ValidatePattern("[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")]
    [String[]]$EmailTo,

    [Parameter(Mandatory = $true, HelpMessage = "You must specify the Email Server to use (IPAddress or FQDN)")]
    [String]$EmailServer,

    [ValidateRange(0, 65535)]
    [int]$EmailServerPort = 25,

    [String]$EmailSubject = "Report - Active Directory - SITE - Missing Subnets",

    [Int]$LogsLines = "-200",

    [Switch]$KeepLogs,

    [ValidateScript( { Test-Path -Path $_ })]
    [String]$HTMLReportPath

)

BEGIN {
    TRY {
        # PATH Information
        $ScriptPath = (Split-Path -Path ((Get-Variable -Name MyInvocation).Value).MyCommand.Path)
        $ScriptPathOutput = $ScriptPath + "\Output"
        IF (-not (Test-Path -Path $ScriptPathOutput)) {
            Write-Verbose -Message "[BEGIN] Creating the Output Folder : $ScriptPathOutput"
            New-Item -Path $ScriptPathOutput -ItemType Directory -ErrorAction 'Stop' | Out-Null
        }

        # Date and Time Information
        $DateFormat = Get-Date -Format "yyyyMMdd_HHmmss"
        $ReportDateFormat = Get-Date -Format "yyyy\MM\dd HH:mm:ss"

        # HTML Report settings
        $ReportTitle = "<H2>" +
        "Report - Active Directory - SITE - Missing Subnets" +
        "</H2>"
        # HTML Report settings
        $Report = "<p style=`"background-color:white;font-family:consolas;font-size:9pt`">" +
        "<strong>Report Time:</strong> $DateFormat <br>" +
        "<strong>Account:</strong> $env:userdomain\$($env:username.toupper()) on $($env:ComputerName.toUpper())" +
        "</p>"

        $Head = "<style>" +
        "BODY{background-color:white;font-family:consolas;font-size:11pt}" +
        "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse}" +
        "TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:`"#00297A`";font-color:white}" +
        "TD{border-width: 1px;padding-right: 2px;padding-left: 2px;padding-top: 0px;padding-bottom: 0px;border-style: solid;border-color: black;background-color:white}" +
        "</style>" +

        '<style type="text/css">
        table.gridtable {
            font-family: verdana,arial,sans-serif;
            font-size:11px;
            color:#333333;
            border-width: 1px;
            border-color: #666666;
            border-collapse: collapse;
        }
        table.gridtable th {
            border-width: 1px;
            padding: 8px;
            border-style: solid;
            border-color: #666666;
            background-color: #dedede;
        }
        table.gridtable td {
            border-width: 1px;
            padding: 8px;
            border-style: solid;
            border-color: #666666;
            background-color: #ffffff;
        }
        </style>'

        $Head2 = "<style>" +
        "BODY{background-color:white;font-family:consolas;font-size:9pt;}" +
        "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}" +
        "TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:`"#C0C0C0`"}" +
        "TD{border-width: 1px;padding-right: 2px;padding-left: 2px;padding-top: 0px;padding-bottom: 0px;border-style: solid;border-color: black;background-color:white}" +
        "</style>"

        $TableCSS = @"
<style type="text/css">
table.gridtable {
    font-family: verdana,arial,sans-serif;
    font-size:11px;
    color:#333333;
    border-width: 1px;
    border-color: #666666;
    border-collapse: collapse;
}
table.gridtable th {
    border-width: 1px;
    padding: 8px;
    border-style: solid;
    border-color: #666666;
    background-color: #dedede;
}
table.gridtable td {
    border-width: 1px;
    padding: 8px;
    border-style: solid;
    border-color: #666666;
    background-color: #ffffff;
}
</style>
"@

        $PostContent = "<font size=`"1`" color=`"black`"><br><br><i><u>Generated from:</u> $($env:COMPUTERNAME.ToUpper()) <u>on</u> $(Get-Date -Format "yyyy/MM/dd HH:mm:ss")</i></font>"

        # Get the Current Forest Information
        $Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
        $ForestName = $Forest.Name.ToUpper()
        Write-Verbose -Message "[BEGIN] Forest: $ForestName"


    }#TRY
    CATCH {
        Throw $_
    }#CATCH
}#BEGIN

PROCESS {
    TRY {
        FOREACH ($Domain in $Forest.Domains) {
            $DomainName = $Domain.Name.ToUpper()

            # Get the names of all the Domain Contollers in $domain
            Write-Verbose -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - Getting all Domain Controllers from ..."
            $DomainControllers = $domain | ForEach-Object -Process { $_.DomainControllers } | Select-Object -Property Name

            # Gathering the NETLOGON.LOG for each Domain Controller
            Write-Verbose -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - Gathering Logs from Domain controllers"
            FOREACH ($dc in $DomainControllers) {
                $DCName = $($dc.Name).toUpper()
                TRY {

                    #######################
                    # COPY NETLOGON Files #
                    #######################

                    # Get the Current Domain Controller in the Loop
                    Write-Verbose -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - $DCName - Gathering Logs"

                    # NETLOGON.LOG path for the current Domain Controller
                    $path = "\\$DCName\admin`$\debug\netlogon.log"

                    # Testing the $path
                    IF ((Test-Path -Path $path) -and ($null -ne (Get-Item -Path $path).Length)) {
                        IF ((Get-Content -Path $path | Measure-Object -Line).lines -gt 0) {
                            #Copy the NETLOGON.log locally for the current DC
                            Write-Verbose -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - $DCName - NETLOGON.LOG - Copying..."
                            Copy-Item -Path $path -Destination $ScriptPathOutput\$DomainName-$DCName-$DateFormat-netlogon.log

                            #Export the $LogsLines last lines of the NETLOGON.log and send it to a file
                            ((Get-Content -Path $ScriptPathOutput\$DomainName-$DCName-$DateFormat-netlogon.log -ErrorAction Continue)[$LogsLines .. -1]) |
                                Out-File -FilePath "$ScriptPathOutput\$DomainName-$DCName.txt" -ErrorAction 'Continue' -ErrorVariable ErrorOutFileNetLogon
                            Write-Verbose -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - $DCName - NETLOGON.LOG - Copied"
                        }#IF
                        ELSE { Write-Verbose -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - $DCName - NETLOGON File Empty !!" }
                    }
                    ELSE { Write-Warning -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - $DCName - NETLOGON.log is not reachable" }



                    ###########################
                    # FILE PROCESS (PART 1/2) #
                    ###########################
                    # Combine results
                    $FilesToCombine = Get-Content -Path $ScriptPathOutput\*.txt -ErrorAction SilentlyContinue
                    IF ($FilesToCombine) {

                        # Detect version of the netlogon file
                        # Windows Server 2012
                        IF ($FilesToCombine[0] -match "\[\d{1,5}\]") {
                            Write-Verbose -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - Importing exported data to a CSV format..."
                            Write-Verbose -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - NETLOGON format: 2012"
                            $ImportString = $FilesToCombine | ConvertFrom-Csv -Delimiter ' ' -Header Date, Time, Code, Domain, Error, Name, IPAddress
                        }

                        # Windows Server Pre-2012 (2003/2008)
                        IF ($FilesToCombine[0] -notmatch "\[\d{1,5}\]") {
                            Write-Verbose -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - Importing exported data to a CSV format..."
                            Write-Verbose -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - NETLOGON format: 2008 and Previous versions"
                            $ImportString = $FilesToCombine | ConvertFrom-Csv -Delimiter ' ' -Header Date, Time, Domain, Error, Name, IPAddress, Code
                        }

                        # Convert the TXT file to a CSV format
                        Write-Verbose -Message "[PROCESS] FOREST: $ForestName DOMAIN: $domainName - Importing exported data to a CSV format..."
                        $ImportString = $FilesToCombine | ConvertFrom-Csv -Delimiter ' ' -Header Date, Time, Code, Domain, Error, Name, IPAddress

                        # Append Missing Subnet File
                        $importString | Where-Object -FilterScript { $_.Error -like "*NO_CLIENT_SITE*" } | Export-Csv -LiteralPath $scriptpathOutput\$ForestName-$dateformat-NOCLIENTSITE.csv -Append
                        # Append Other Error File
                        $importString | Where-Object -FilterScript { $_.Error -notlike "*NO_CLIENT_SITE*" } | Export-Csv -LiteralPath $scriptpathOutput\$ForestName-$dateformat-OTHERERRORS.csv -Append

                    }#IF File to Combine
                    ELSE { Write-Verbose -Message "[PROCESS] Nothing to process" }

                }#TRY
                CATCH {
                    Write-Warning -Message "$ForestName - $domainName - $DCName - Something wrong happened"
                    if ($ErrorOutFileNetLogon) { Write-Warning -Message "$ForestName - $domainName - $DCName - Error with Out-File" }
                }#CATCH
            }#FOREACH
        }#FOREACH Domains in Forest


        ###########################
        # FILE PROCESS (PART 2/2) #
        ###########################
        $MissingSubnets = Import-Csv -LiteralPath $scriptpathOutput\$ForestName-$dateformat-NOCLIENTSITE.csv
        $OtherErrors = Import-Csv -LiteralPath $scriptpathOutput\$ForestName-$dateformat-OTHERERRORS.csv



        ############################
        # BUILDING THE HTML REPORT #
        ############################
        Write-Verbose -Message "[PROCESS] $ForestName - Building the HTML Report"

        # MISSING SUBNETS
        $EmailBody += "<h1><u>Forest:</u> $($ForestName.ToUpper())</h1>"
        $EmailBody += "<h2><u>Domain</u>: $($DomainName.ToUpper())</h2>"
        $EmailBody += "<h3>Missing Subnet(s) for $($DomainName.ToUpper())</h3>"
        IF ($MissingSubnets) {
            $EmailBody += "<i>List of Active Directory client that can not find their site.<br> You need to add those subnets into the console Active Directory Sites And Services</i>"
            $EmailBody += $MissingSubnets | Sort-Object IPAddress -Unique | ConvertTo-Html -property IPAddress, Name, Date, Domain, Code, Error -Fragment #|out-string
        }
        ELSE { $EmailBody += "<i>No Missing Subnet(s) detected</i>" }

        #  OTHER ERRORS
        $EmailBody += "<h2>Other Error(s)</h2>"
        IF ($OtherErrors) {
            $EmailBody += "<br><font size=`"1`" color=`"red`">"
            # Retrieve Each txt generated from the NETLOGON files
            Get-ChildItem $scriptpathoutput\$DomainName-*.txt -Exclude "*All_Export*" |
                ForEach-Object -Process {
                    # Get the Other Errors (not Missing subnets)
                    $CurrentFile = Get-Content $_ | Where-Object -FilterScript { $_ -notlike "*NO_CLIENT_SITE*" }
                    IF ($CurrentFile) {
                        # Write the name of the log, this will help sysadmin to find which side report the error
                        $EmailBody += "<font size=`"2`"><b>$($_.basename)</b><br></font>"
                        $EmailBody += "<br><font size=`"1`" color=`"red`">"
                        FOREACH ($Line in $CurrentFile) {
                            $EmailBody += "$line<br>"
                        }#FOREACH
                        # Close the FONT block
                        $EmailBody += "</font>"
                    }#IF
                }#foreach-object
        }
        ELSE { $EmailBody += "<i>No Other Error detected</i>" }

    }#TRY
    CATCH {
        Throw $_
    }#CATCH
    FINALLY {


        ##############
        # SEND EMAIL #
        ##############

        # Add PostContent to email
        $EmailBody += $PostContent

        $EmailBody = $EmailBody -replace "<table>", '<table class="gridtable">'
        $FinalEmailBody = ConvertTo-Html -Head $Head -PostContent $EmailBody

        # EMAIL
        Write-Verbose -Message "[PROCESS] Preparing the final Email"
        $SmtpClient = New-Object -TypeName system.net.mail.smtpClient
        $SmtpClient.host = $EmailServer
        $SmtpClient.Port = $EmailServerPort
        $MailMessage = New-Object -TypeName system.net.mail.mailmessage
        $MailMessage.from = $EmailFrom
        #FOREACH ($To in $Emailto){$MailMessage.To.add($($To.Address))}
        FOREACH ($To in $Emailto) { $MailMessage.To.add($($To)) }
        $MailMessage.IsBodyHtml = $true
        $MailMessage.Subject = $EmailSubject
        $MailMessage.Body = $FinalEmailBody
        $SmtpClient.Send($MailMessage)
        Write-Verbose -Message "[PROCESS] Email Sent!"


        ###############
        # SAVE REPORT #
        ###############

        if ($PSBoundParameters['HTMLReportPath']) {
            $FinalEmailBody | Out-File -LiteralPath (Join-Path -Path $HTMLReportPath -ChildPath "$ForestName-$dateformat-Report.html")
        }
    }

}#PROCESS
END {
    IF (-not $KeepLogs) {
        Write-Verbose -Message "Cleanup txt and log files..."
        Remove-Item -Path $ScriptpathOutput\*.txt -force
        Remove-Item -Path $ScriptPathOutput\*.log -force
        Write-Verbose -Message "Script Completed"
    }
}#END