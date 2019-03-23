<#
.SYNOPSIS
    This script is monitoring group(s) in Active Directory and send an email when someone is changing the membership.

.DESCRIPTION
    This script is monitoring group(s) in Active Directory and send an email when someone is changing the membership.
    It will also report the Change History made for this/those group(s).

.PARAMETER Group
    Specify the group(s) to query in Active Directory.
    You can also specify the 'DN','GUID','SID' or the 'Name' of your group(s).
    Using 'Domain\Name' will also work.

.PARAMETER SearchRoot
    Specify the DN, GUID or canonical name of the domain or container to search. By default, the script searches the entire sub-tree of which SearchRoot is the topmost object (sub-tree search). This default behavior can be altered by using the SearchScope parameter.

.PARAMETER SearchScope
    Specify one of these parameter values
        'Base' Limits the search to the base (SearchRoot) object.
            The result contains a maximum of one object.
        'OneLevel' Searches the immediate child objects of the base (SearchRoot)
            object, excluding the base object.
        'Subtree'   Searches the whole sub-tree, including the base (SearchRoot)
            object and all its child objects.

.PARAMETER GroupScope
    Specify the group scope of groups you want to find. Acceptable values are: 
        'Global'; 
        'Universal'; 
        'DomainLocal'.

.PARAMETER GroupType
    Specify the group type of groups you want to find. Acceptable values are: 
        'Security';
        'Distribution'.

.PARAMETER File
    Specify the File where the Group are listed. DN, SID, GUID, or Domain\Name of the group are accepted.

.PARAMETER EmailServer
    Specify the Email Server IPAddress/FQDN.

.PARAMETER EmailTo
    Specify the Email Address(es) of the Destination. Example: fxcat@fx.lab

.PARAMETER EmailFrom
    Specify the Email Address of the Sender. Example: Reporting@fx.lab

.PARAMETER EmailEncoding
    Specify the Body and Subject Encoding to use in the Email.
    Default is ASCII.

.PARAMETER Server
    Specify the Domain Controller to use.
    Aliases: DomainController, Service

.PARAMETER HTMLLog
    Specify if you want to save a local copy of the Report.
    It will be saved under the directory "HTML".

.EXAMPLE
    .\AD-GROUP-Monitor_MemberShip.ps1 -Group "FXGroup" -EmailFrom "From@Company.com" -EmailTo "To@Company.com" -EmailServer "mail.company.com"

    This will run the script against the group FXGROUP and send an email to To@Company.com using the address From@Company.com and the server mail.company.com.

.EXAMPLE
    .\AD-GROUP-Monitor_MemberShip.ps1 -Group "FXGroup","FXGroup2","FXGroup3" -EmailFrom "From@Company.com" -Emailto "To@Company.com" -EmailServer "mail.company.com"

    This will run the script against the groups FXGROUP,FXGROUP2 and FXGROUP3  and send an email to To@Company.com using the address From@Company.com and the Server mail.company.com.

.EXAMPLE
    .\AD-GROUP-Monitor_MemberShip.ps1 -Group "FXGroup" -EmailFrom "From@Company.com" -Emailto "To@Company.com" -EmailServer "mail.company.com" -Verbose

    This will run the script against the group FXGROUP and send an email to To@Company.com using the address From@Company.com and the server mail.company.com. Additionally the switch Verbose is activated to show the activities of the script.

.EXAMPLE
    .\AD-GROUP-Monitor_MemberShip.ps1 -Group "FXGroup" -EmailFrom "From@Company.com" -Emailto "Auditor@Company.com","Auditor2@Company.com" -EmailServer "mail.company.com" -Verbose

    This will run the script against the group FXGROUP and send an email to Auditor@Company.com and Auditor2@Company.com using the address From@Company.com and the server mail.company.com. Additionally the switch Verbose is activated to show the activities of the script.

.EXAMPLE
    .\AD-GROUP-Monitor_MemberShip.ps1 -SearchRoot 'FX.LAB/TEST/Groups' -Emailfrom Reporting@fx.lab -Emailto "Catfx@fx.lab" -EmailServer 192.168.1.10 -Verbose

    This will run the script against all the groups present in the CanonicalName 'FX.LAB/TEST/Groups' and send an email to catfx@fx.lab using the address Reporting@fx.lab and the server 192.168.1.10. Additionally the switch Verbose is activated to show the activities of the script.

.EXAMPLE
    .\AD-GROUP-Monitor_MemberShip.ps1 -file .\groupslist.txt -Emailfrom Reporting@fx.lab -Emailto "Catfx@fx.lab" -EmailServer 192.168.1.10 -Verbose

    This will run the script against all the groups present in the file groupslists.txt and send an email to catfx@fx.lab using the address Reporting@fx.lab and the server 192.168.1.10. Additionally the switch Verbose is activated to show the activities of the script.

.EXAMPLE
    .\AD-GROUP-Monitor_MemberShip.ps1 -server DC01.fx.lab -file .\groupslist.txt -Emailfrom Reporting@fx.lab -Emailto "Catfx@fx.lab" -EmailServer 192.168.1.10 -Verbose

    This will run the script against the Domain Controller "DC01.fx.lab" on all the groups present in the file groupslists.txt and send an email to catfx@fx.lab using the address Reporting@fx.lab and the server 192.168.1.10. Additionally the switch Verbose is activated to show the activities of the script.

.EXAMPLE
    .\AD-GROUP-Monitor_MemberShip.ps1 -server DC01.fx.lab:389 -file .\groupslist.txt -Emailfrom Reporting@fx.lab -Emailto "Catfx@fx.lab" -EmailServer 192.168.1.10 -Verbose

    This will run the script against the Domain Controller "DC01.fx.lab" (on port 389) on all the groups present in the file groupslists.txt and send an email to catfx@fx.lab using the address Reporting@fx.lab and the server 192.168.1.10. Additionally the switch Verbose is activated to show the activities of the script.

.EXAMPLE
    .\AD-GROUP-Monitor_MemberShip.ps1 -group "Domain Admins" -Emailfrom Reporting@fx.lab -Emailto "Catfx@fx.lab" -EmailServer 192.168.1.10 -EmailEncoding 'ASCII' -HTMLlog

    This will run the script against the group "Domain Admins" and send an email (using the encoding ASCII) to catfx@fx.lab using the address Reporting@fx.lab and the SMTP server 192.168.1.10. It will also save a local HTML report under the HTML Directory.

.INPUTS
    System.String

.OUTPUTS
    Email Report

.NOTES
    NAME:    AD-GROUP-Monitor_MemberShip.ps1
    AUTHOR:    Francois-Xavier Cat 
    EMAIL:    info@lazywinadmin.com
    WWW:    www.lazywinadmin
    Twitter:@lazywinadm

    REQUIREMENTS:
        -Read Permission in Active Directory on the monitored groups
        -Quest Active Directory PowerShell Snapin
        -A Scheduled Task (in order to check every X seconds/minutes/hours)

    VERSION HISTORY:
    1.0     2012.02.01
        Initial Version

    1.1     2012.03.13
        CHANGE to monitor both Domain Admins and Enterprise Admins

    1.2     2013.09.23
        FIX issue when specifying group with domain 'DOMAIN\Group'
        CHANGE Script Format (BEGIN, PROCESS, END)
        ADD Minimal Error handling. (TRY CATCH)

    1.3     2013.10.05
        CHANGE in the PROCESS BLOCK, the TRY CATCH blocks and placed
         them inside the FOREACH instead of inside the TRY block
        ADD support for Verbose
        CHANGE the output file name "DOMAIN_GROUPNAME-membership.csv"
        ADD a Change History File for each group(s)
         example: "GROUPNAME-ChangesHistory-yyyyMMdd-hhmmss.csv"
        ADD more Error Handling
        ADD a HTML Report instead of plain text
        ADD HTML header
        ADD HTML header for change history

    1.4     2013.10.11
        CHANGE the 'Change History' filename to
         "DOMAIN_GROUPNAME-ChangesHistory-yyyyMMdd-hhmmss.csv"
        UPDATE Comments Based Help
        ADD Some Variable Parameters

    1.5     2013.10.13
        ADD the full Parameter Names for each Cmdlets used in this script
        ADD Alias to the Group ParameterName

    1.6     2013.11.21
        ADD Support for Organizational Unit (SearchRoot parameter)
        ADD Support for file input (File Parameter)
        ADD ParamaterSetNames and parameters GroupType/GroupScope/SearchScope
        REMOVE [mailaddress] type on $Emailfrom and $EmailTo to make the script available to PowerShell 2.0
        ADD Regular expression validation on $Emailfrom and $EmailTo

    1.7     2013.11.23
        ADD ValidateScript on File Parameter
        ADD Additional information about the Group in the Report
        CHANGE the format of the $changes output, it will now include the DateTime Property
        UPDATE Help
        ADD DisplayName Property in the report

    1.8     2013.11.27
        Minor syntax changes
        UPDATE Help

    1.8.1     2013.12.29
        Rename to AD-GROUP-Monitor_MemberShip

    1.8.2     2014.02.17
        Update Notes

    2.0    2014.05.04
        ADD Support for ActiveDirectory module (AD module is use by default)
        ADD failover to Quest AD Cmdlet if AD module is available
        RENAME GetQADGroupParams variable to ADGroupParams

    2.0.1     2015.01.05
        REMOVE the DisplayName property from the email
        ADD more clear details/Comments
        RENAME a couple of Verbose and Warning Messages
        FIX the DN of the group in the Summary
        FIX SearchBase/SearchRoot Parameter which was not working with AD Module
        FIX Some other minor issues
        ADD Check to validate data added to $Group is valid
        ADD Server Parameter to be able to specify a domain controller

    2.0.2    2015.01.14
        FIX an small issue with the $StateFile which did not contains the domain
        ADD the property Name into the final output.
        ADD Support to export the report to a HTML file (-HTMLLog) It will save
            the report under the folder HTML
        ADD Support for alternative Email Encoding: Body and Subject. Default is ASCII.


    TODO:
        -Add Switch to make the Group summary Optional (info: Description,DN,CanonicalName,SID, Scope, Type)
            -Current Member Count, Added Member count, Removed Member Count
        -Switch to Show all the Current Members (Name, Department, Role, EMail)
        -Possibility to Ignore some groups
        -Email Credential
        -Recursive Membership search
        -Switch to save a local copy of the HTML report (maybe put this by default)
#>

#requires -version 3.0
#Requires -Module ActiveDirectory

[CmdletBinding(DefaultParameterSetName = "Group")]
PARAM (
    [Parameter(ParameterSetName = "Group", Mandatory = $true, HelpMessage = "You must specify at least one Active Directory group")]
    [ValidateNotNull()]
    [Alias('DN', 'DistinguishedName', 'GUID', 'SID', 'Name')]
    [string[]]$Group,

    [Parameter(ParameterSetName = "OU", Mandatory = $true)]
    [Alias('SearchBase')]
    [String[]]$SearchRoot,

    [Parameter(ParameterSetName = "OU")]
    [ValidateSet("Base", "OneLevel", "Subtree")]
    [String]$SearchScope,

    [Parameter(ParameterSetName = "OU")]
    [ValidateSet("Global", "Universal", "DomainLocal")]
    [String]$GroupScope,

    [Parameter(ParameterSetName = "OU")]
    [ValidateSet("Security", "Distribution")]
    [String]$GroupType,

    [Parameter(ParameterSetName = "File", Mandatory = $true)]
    [ValidateScript({ Test-Path -Path $_ })]
    [String[]]$File,

    [Parameter()]
    [Alias('DomainController', 'Service')]
    $Server,

    [Parameter(Mandatory = $true, HelpMessage = "You must specify the Sender Email Address")]
    [ValidatePattern("[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")]
    [String]$Emailfrom,

    [Parameter(Mandatory = $true, HelpMessage = "You must specify the Destination Email Address")]
    [ValidatePattern("[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")]
    [String[]]$Emailto,

    [Parameter(Mandatory = $true, HelpMessage = "You must specify the Email Server to use (IPAddress or FQDN)")]
    [String]$EmailServer,

    [Parameter()]
    [ValidateSet("ASCII", "UTF8", "UTF7", "UTF32", "Unicode", "BigEndianUnicode", "Default")]
    [String]$EmailEncoding="ASCII",

    [Parameter()]
    [Switch]$HTMLLog
)
BEGIN
{
    TRY
    {

        # Set the Paths Variables and create the folders if not present
        $ScriptPath = (Split-Path -Path ((Get-Variable -Name MyInvocation).Value).MyCommand.Path)
        $ScriptPathOutput = $ScriptPath + "\Output"
        IF (!(Test-Path -Path $ScriptPathOutput))
        {
            Write-Verbose -Message "[BEGIN] Creating the Output Folder : $ScriptPathOutput"
            New-Item -Path $ScriptPathOutput -ItemType Directory | Out-Null
        }
        $ScriptPathChangeHistory = $ScriptPath + "\ChangeHistory"
        IF (!(Test-Path -Path $ScriptPathChangeHistory))
        {
            Write-Verbose -Message "[BEGIN] Creating the ChangeHistory Folder : $ScriptPathChangeHistory"
            New-Item -Path $ScriptPathChangeHistory -ItemType Directory | Out-Null
        }

        # Set the Date and Time variables format
        $DateFormat = Get-Date -Format "yyyyMMdd_HHmmss"
        $ReportDateFormat = Get-Date -Format "yyyy\MM\dd HH:mm:ss"


        # Active Directory Module
        IF (Get-Module -Name ActiveDirectory -ListAvailable) #verify ad module is installed
        {
            Write-Verbose -Message "[BEGIN] Active Directory Module"
            # Verify Ad module is loaded
            IF (-not (Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue -ErrorVariable ErrorBEGINGetADModule))
            {
                Write-Verbose -Message "[BEGIN] Active Directory Module - Loading"
                Import-Module -Name ActiveDirectory -ErrorAction SilentlyContinue -ErrorVariable ErrorBEGINAddADModule
                Write-Verbose -Message "[BEGIN] Active Directory Module - Loaded"
                $global:ADModule = $true
            }
            ELSE
            {
                Write-Verbose -Message "[BEGIN] Active Directory module seems loaded"
                $global:ADModule = $true
            }
        }
        ELSE # Else we try to load Quest Ad Cmdlets
        {
            Write-Verbose -Message "[BEGIN] Quest AD Snapin"
            # Verify Quest Active Directory Snapin is loaded
            IF (-not (Get-PSSnapin -Name Quest.ActiveRoles.ADManagement -ErrorAction Stop -ErrorVariable ErrorBEGINGetQuestAD))
            {
                Write-Verbose -Message "[BEGIN] Quest Active Directory - Loading"
                Add-PSSnapin -Name Quest.ActiveRoles.ADManagement -ErrorAction Stop -ErrorVariable ErrorBEGINAddQuestAd
                Write-Verbose -Message "[BEGIN] Quest Active Directory - Loaded"
                $global:QuestADSnappin = $true
            }
            ELSE
            {
                Write-Verbose -Message "[BEGIN] Quest AD Snapin seems loaded"
            }
        }

        Write-Verbose -Message "[BEGIN] Setting HTML Variables"
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
        "</style>"
        $Head2 = "<style>" +
        "BODY{background-color:white;font-family:consolas;font-size:9pt;}" +
        "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}" +
        "TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:`"#C0C0C0`"}" +
        "TD{border-width: 1px;padding-right: 2px;padding-left: 2px;padding-top: 0px;padding-bottom: 0px;border-style: solid;border-color: black;background-color:white}" +
        "</style>"


    }#TRY
    CATCH
    {
        Write-Warning -Message "[BEGIN] Something went wrong"

        #Show last error
        #Write-Warning -Message $_.Exception.Message
        Write-Warning -Message $Error[0]

        # Quest AD Cmdlets Errors
        if ($ErrorBEGINGetQuestAD) { Write-Warning -Message "[BEGIN] Can't Find the Quest Active Directory Snappin" }
        if ($ErrorBEGINAddQuestAD) { Write-Warning -Message "[BEGIN] Can't Load the Quest Active Directory Snappin" }

        # AD module Errors
        if ($ErrorBEGINGetADmodule) { Write-Warning -Message "[BEGIN] Can't find the Active Directory module" }
        if ($ErrorBEGINAddADmodule) { Write-Warning -Message "[BEGIN] Can't load the Active Directory module" }
    }#CATCH
}#BEGIN

PROCESS
{
    TRY
    {

        # # # # # # # # # # # # # # # # #
        # SEARCHROOT parameter specified#
        # # # # # # # # # # # # # # # # #

        IF ($PSBoundParameters['SearchRoot'])
        {
            Write-Verbose -Message "[PROCESS] SearchRoot specified"
            FOREACH ($item in $SearchRoot)
            {
                # ADGroup Splatting
                $ADGroupParams = @{ }


                # ActiveDirectory Module
                IF ($ADModule)
                {
                    $ADGroupParams.SearchBase = $item

                    # Server Specified
                    IF ($PSBoundParameters['Server']) { $ADGroupParams.Server = $Server}
                }
                IF ($QuestADSnappin)
                {
                    $ADGroupParams.SearchRoot = $item

                    # Server Specified
                    IF ($PSBoundParameters['Server']) { $ADGroupParams.Service = $Server }
                }


                # # # # # # # # # # # # # # # # # #
                # SEARCHSCOPE Parameter specified #
                # # # # # # # # # # # # # # # # # #
                IF ($PSBoundParameters['SearchScope'])
                {
                    Write-Verbose -Message "[PROCESS] SearchScope specified"
                    $ADGroupParams.SearchScope = $SearchScope
                }


                # # # # # # # # # # # # # # # # #
                # GROUPSCOPE Parameter specified#
                # # # # # # # # # # # # # # # # #
                IF ($PSBoundParameters['GroupScope'])
                {
                    Write-Verbose -Message "[PROCESS] GroupScope specified"
                    # ActiveDirectory Module Parameter
                    IF ($ADModule) { $ADGroupParams.Filter = "GroupScope -eq `'$GroupScope`'" }
                    # Quest ActiveDirectory Snapin Parameter
                    ELSE { $ADGroupParams.GroupScope = $GroupScope }
                }


                # # # # # # # # # # # # # # # # #
                # GROUPTYPE Parameter specified #
                # # # # # # # # # # # # # # # # #
                IF ($PSBoundParameters['GroupType'])
                {
                    Write-Verbose -Message "[PROCESS] GroupType specified"
                    # ActiveDirectory Module
                    IF ($ADModule)
                    {
                        # ActiveDirectory Module Parameter
                        IF ($ADGroupParams.Filter)
                        {
                            $ADGroupParams.Filter = "$($ADGroupParams.Filter) -and GroupCategory -eq `'$GroupType`'"
                        }
                        ELSE
                        {
                            $ADGroupParams.Filter = "GroupCategory -eq '$GroupType'"
                        }
                    }
                    # Quest ActiveDirectory Snapin
                    ELSE
                    {
                        $ADGroupParams.GroupType = $GroupType
                    }
                }#IF ($PSBoundParameters['GroupType'])



                IF ($ADModule)
                {
                    IF (-not($ADGroupParams.filter)){$ADGroupParams.Filter = "*"}

                    Write-Verbose -Message "[PROCESS] AD Module - Querying..."

                    # Add the groups to the variable $Group
                    $GroupSearch = Get-ADGroup @ADGroupParams

                    if ($GroupSearch){
                        $group += $GroupSearch.Distinguishedname
                        Write-Verbose -Message "[PROCESS] OU: $item"
                    }
                }

                IF ($QuestADSnappin)
                {
                    Write-Verbose -Message "[PROCESS] Quest AD Snapin - Querying..."
                    # Add the groups to the variable $Group
                    $GroupSearchQuest = Get-QADGroup @ADGroupParams
                    if ($GroupSearchQuest){
                        $group += $GroupSearchQuest.DN
                        Write-Verbose -Message "[PROCESS] OU: $item"
                    }
                }

            }#FOREACH ($item in $OU)
        }#IF ($PSBoundParameters['SearchRoot'])




        # # # # # # # # # # # # # # #
        # FILE parameter specified  #
        # # # # # # # # # # # # # # #

        IF ($PSBoundParameters['File'])
        {
            Write-Verbose -Message "[PROCESS] File"
            FOREACH ($item in $File)
            {
                Write-Verbose -Message "[PROCESS] Loading File: $item"

                $FileContent = Get-Content -Path $File

                if ($FileContent)
                {
                    # Add the groups to the variable $Group
                    $Group += Get-Content -Path $File
                }



            }#FOREACH ($item in $File)
        }#IF ($PSBoundParameters['File'])



        # # # # # # # # # # # # # # # # # # # # # # # # # # #
        # GROUP or SEARCHROOT or FILE parameters specified  #
        # # # # # # # # # # # # # # # # # # # # # # # # # # #

        # This will run for any parameter set name ParameterSetName = OU, Group or File
        FOREACH ($item in $Group)
        {
            TRY
            {

                Write-Verbose -Message "[PROCESS] GROUP: $item... "

                # Splatting for the AD Group Request
                $GroupSplatting = @{ }
                $GroupSplatting.Identity = $item

                # Group Information
                if ($ADModule)
                {
                    Write-Verbose -Message "[PROCESS] ActiveDirectory module"

                    # Add the Server if specified
                    IF ($PSBoundParameters['Server']) { $GroupSplatting.Server = $Server }

                    # Look for Group
                    $GroupName = Get-ADGroup @GroupSplatting -Properties * -ErrorAction Continue -ErrorVariable ErrorProcessGetADGroup
                    $DomainName = ($GroupName.canonicalname -split '/')[0]
                    $RealGroupName = $GroupName.name
                }
                if ($QuestADSnappin)
                {
                    Write-Verbose -Message "[PROCESS] Quest ActiveDirectory Snapin"

                    # Add the Server if specified
                    IF ($PSBoundParameters['Server']) { $GroupSplatting.Service = $Server }

                    # Look for Group
                    $GroupName = Get-QADgroup @GroupSplatting -ErrorAction Continue -ErrorVariable ErrorProcessGetQADGroup
                    $DomainName = $($GroupName.domain.name)
                    $RealGroupName = $GroupName.name
                }

                # GroupName Found
                IF ($GroupName)
                {

                    # Splatting for the AD Group Members Request
                    $GroupMemberSplatting = @{ }
                    $GroupMemberSplatting.Identity = $GroupName


                    # Get GroupName Membership
                    if ($ADModule)
                    {
                        Write-Verbose -Message "[PROCESS] GROUP: $item - Querying Membership (AD Module)"

                        # Add the Server if specified
                        IF ($PSBoundParameters['Server']) { $GroupMemberSplatting.Server = $Server }

                        # Look for Members
                        $Members = Get-ADGroupMember @GroupMemberSplatting -Recursive -ErrorAction Stop -ErrorVariable ErrorProcessGetADGroupMember | Select-Object -Property *,@{ Name = 'DN'; Expression = { $_.DistinguishedName } }
                    }
                    if ($QuestADSnappin)
                    {
                        Write-Verbose -Message "[PROCESS] GROUP: $item - Querying Membership (Quest AD Snapin)"

                        # Add the Server if specified
                        IF ($PSBoundParameters['Server']) { $GroupMemberSplatting.Service = $Server }

                        $Members = Get-QADGroupMember @GroupMemberSplatting -Indirect -ErrorAction Stop -ErrorVariable ErrorProcessGetQADGroupMember #| Select-Object -Property *,@{ Name = 'DistinguishedName'; Expression = { $_.dn } }
                    }
                    # NO MEMBERS, Add some info in $members to avoid the $null
                    # If the value is $null the compare-object won't work
                    IF (-not ($Members))
                    {
                        Write-Verbose -Message "[PROCESS] GROUP: $item is empty"
                        $Members = New-Object -TypeName PSObject -Property @{
                            Name = "No User or Group"
                            SamAccountName = "No User or Group"
                        }
                    }


                    # GroupName Membership File
                    # If the file doesn't exist, assume we don't have a record to refer to
                    $StateFile = "$($DomainName)_$($RealGroupName)-membership.csv"
                    IF (!(Test-Path -Path (Join-Path -Path $ScriptPathOutput -ChildPath $StateFile)))
                    {
                        Write-Verbose -Message "[PROCESS] $item - The following file did not exist: $StateFile"
                        Write-Verbose -Message "[PROCESS] $item - Exporting the current membership information into the file: $StateFile"
                        $Members | Export-csv -Path (Join-Path -Path $ScriptPathOutput -ChildPath $StateFile) -NoTypeInformation
                    }
                    ELSE
                    {
                        Write-Verbose -Message "[PROCESS] $item - The following file Exists: $StateFile"
                    }


                    # GroupName Membership File is compared with the current GroupName Membership
                    Write-Verbose -Message "[PROCESS] $item - Comparing Current and Before"
                    $ImportCSV = Import-Csv -Path (Join-Path -path $ScriptPathOutput -childpath $StateFile) -ErrorAction Stop -ErrorVariable ErrorProcessImportCSV
                    $Changes = Compare-Object -DifferenceObject $ImportCSV -ReferenceObject $Members -ErrorAction stop -ErrorVariable ErrorProcessCompareObject -Property Name, SamAccountName, DN |
                    Select-Object @{ Name = "DateTime"; Expression = { Get-Date -Format "yyyyMMdd-hh:mm:ss" } }, @{
                        n = 'State'; e = {
                            IF ($_.SideIndicator -eq "=>") { "Removed" }
                            ELSE { "Added" }
                        }
                    }, DisplayName, Name, SamAccountName, DN | Where-Object { $_.name -notlike "*no user or group*" }
                    Write-Verbose -Message "[PROCESS] $item - Compare Block Done !"

                    <# Troubleshooting
                    Write-Verbose -Message "IMPORTCSV var"
                    $ImportCSV | fl -Property Name, SamAccountName, DN

                    Write-Verbose -Message "MEMBER"
                    $Members | fl -Property Name, SamAccountName, DN
                    Write-Verbose -Message "CHANGE"
                    $Changes
                    #>

                    # CHANGES FOUND !
                    If ($Changes)
                    {
                        Write-Verbose -Message "[PROCESS] $item - Some changes found"
                        $changes | Select-Object -Property DateTime, State, Name, SamAccountName, DN

                        # CHANGE HISTORY
                        #  Get the Past Changes History
                        Write-Verbose -Message "[PROCESS] $item - Get the change history for this group"
                        $ChangesHistoryFiles = Get-ChildItem -Path $ScriptPathChangeHistory\$($DomainName)_$($RealGroupName)-ChangeHistory.csv -ErrorAction 'SilentlyContinue'
                        Write-Verbose -Message "[PROCESS] $item - Change history files: $(($ChangesHistoryFiles|Measure-Object).Count)"

                        # Process each history changes
                        IF ($ChangesHistoryFiles)
                        {
                            $infoChangeHistory = @()
                            FOREACH ($file in $ChangesHistoryFiles.FullName)
                            {
                                Write-Verbose -Message "[PROCESS] $item - Change history files - Loading $file"
                                # Import the file and show the $file creation time and its content
                                $ImportedFile = Import-Csv -Path $file -ErrorAction Stop -ErrorVariable ErrorProcessImportCSVChangeHistory
                                FOREACH ($obj in $ImportedFile)
                                {
                                    $Output = "" | Select-Object -Property DateTime, State, DisplayName,Name, SamAccountName, DN
                                    #$Output.DateTime = $file.CreationTime.GetDateTimeFormats("u") | Out-String
                                    $Output.DateTime = $obj.DateTime
                                    $Output.State = $obj.State
                                    $Output.DisplayName = $obj.DisplayName
                                    $Output.Name = $obj.Name
                                    $Output.SamAccountName = $obj.SamAccountName
                                    $Output.DN = $obj.DN
                                    $infoChangeHistory = $infoChangeHistory + $Output
                                }#FOREACH $obj in Import-csv $file
                            }#FOREACH $file in $ChangeHistoryFiles
                            Write-Verbose -Message "[PROCESS] $item - Change history process completed"
                        }#IF($ChangeHistoryFiles)

                        # CHANGE(S) EXPORT TO CSV
                        Write-Verbose -Message "[PROCESS] $item - Save changes to a ChangesHistory file"

                        IF (-not (Test-Path -path (Join-Path -Path $ScriptPathChangeHistory -ChildPath "$($DomainName)_$($RealGroupName)-ChangeHistory.csv")))
                        {
                            $Changes | Export-Csv -Path (Join-Path -Path $ScriptPathChangeHistory -ChildPath "$($DomainName)_$($RealGroupName)-ChangeHistory.csv") -NoTypeInformation
                        }
                        ELSE
                        {
                            #$Changes | Export-Csv -Path (Join-Path -Path $ScriptPathChangeHistory -ChildPath "$DomainName_$RealGroupName-ChangeHistory-$DateFormat.csv") -NoTypeInformation
                            $Changes | Export-Csv -Path (Join-Path -Path $ScriptPathChangeHistory -ChildPath "$($DomainName)_$($RealGroupName)-ChangeHistory.csv") -NoTypeInformation -Append
                        }


                        # EMAIL
                        Write-Verbose -Message "[PROCESS] $item - Preparing the notification email..."

                        $EmailSubject = "PS MONITORING - $($GroupName.SamAccountName) Membership Change"

                        #  Preparing the body of the Email
                        $body = "<h2>Group: $($GroupName.SamAccountName)</h2>"
                        $body += "<p style=`"background-color:white;font-family:consolas;font-size:8pt`">"
                        $body += "<u>Group Description:</u> $($GroupName.Description)<br>"
                        $body += "<u>Group DistinguishedName:</u> $($GroupName.DistinguishedName)<br>"
                        $body += "<u>Group CanonicalName:</u> $($GroupName.CanonicalName)<br>"
                        $body += "<u>Group SID:</u> $($GroupName.Sid.value)<br>"
                        $body += "<u>Group Scope/Type:</u> $($GroupName.GroupScope) / $($GroupName.GroupType)<br>"
                        $body += "</p>"

                        $body += "<h3> Membership Change"
                        $body += "</h3>"
                        $body += "<i>The membership of this group changed. See the following Added or Removed members.</i>"

                        # Removing the old DisplayName Property
                        $Changes = $changes | Select-Object -Property DateTime, State,Name, SamAccountName, DN

                        $body += $changes | ConvertTo-Html -head $head | Out-String
                        $body += "<br><br><br>"
                        IF ($ChangesHistoryFiles)
                        {
                            # Removing the old DisplayName Property
                            $infoChangeHistory = $infoChangeHistory | Select-Object -Property DateTime, State, Name, SamAccountName, DN

                            $body += "<h3>Change History</h3>"
                            $body += "<i>List of the previous changes on this group observed by the script</i>"
                            $body += $infoChangeHistory | Sort-Object -Property DateTime -Descending | ConvertTo-Html -Fragment -PreContent $Head2 | Out-String
                        }
                        $body = $body -replace "Added", "<font color=`"blue`"><b>Added</b></font>"
                        $body = $body -replace "Removed", "<font color=`"red`"><b>Removed</b></font>"
                        $body += $Report

                        #  Preparing the Email properties
                        $SmtpClient = New-Object -TypeName system.net.mail.smtpClient
                        $SmtpClient.host = $EmailServer
                        $MailMessage = New-Object -TypeName system.net.mail.mailmessage
                        #$MailMessage.from = $EmailFrom.Address
                        $MailMessage.from = $EmailFrom
                        #FOREACH ($To in $Emailto){$MailMessage.To.add($($To.Address))}
                        FOREACH ($To in $Emailto) { $MailMessage.To.add($($To)) }
                        $MailMessage.IsBodyHtml = 1
                        $MailMessage.Subject = $EmailSubject
                        $MailMessage.Body = $Body

                        #  Encoding
                        $MailMessage.BodyEncoding = [System.Text.Encoding]::$EmailEncoding
                        $MailMessage.SubjectEncoding = [System.Text.Encoding]::$EmailEncoding


                        #  Sending the Email
                        $SmtpClient.Send($MailMessage)
                        Write-Verbose -Message "[PROCESS] $item - Email Sent."


                        # GroupName Membership export to CSV
                        Write-Verbose -Message "[PROCESS] $item - Exporting the current membership to $StateFile"
                        $Members | Export-csv -Path (Join-Path -Path $ScriptPathOutput -ChildPath $StateFile) -NoTypeInformation -Encoding Unicode

                        # Export HTML File
                        IF ($PSBoundParameters['HTMLLog'])
                        {
                            # Create HTML Directory if it does not exist
                            $ScriptPathHTML = $ScriptPath + "\HTML"
                            IF (!(Test-Path -Path $ScriptPathHTML))
                            {
                                Write-Verbose -Message "[PROCESS] Creating the HTML Folder : $ScriptPathHTML"
                                New-Item -Path $ScriptPathHTML -ItemType Directory | Out-Null
                            }

                            # Define HTML File Name
                            $HTMLFileName = "$($DomainName)_$($RealGroupName)-$(Get-Date -Format 'yyyyMMdd_HHmmss').html"

                            # Save HTML File
                            $Body | Out-File -FilePath (Join-Path -Path $ScriptPathHTML -ChildPath $HTMLFileName)
                        }


                    }#IF $Change
                    ELSE { Write-Verbose -Message "[PROCESS] $item - No Change" }

                }#IF ($GroupName)
                ELSE
                {
                    Write-Verbose -message "[PROCESS] $item - Group can't be found"
                    #IF (Get-ChildItem (Join-Path $ScriptPathOutput "*$item*-membership.csv" -ErrorAction Continue) -or (Get-ChildItem (Join-Path $ScriptPathChangeHistory "*$item*.csv" -ErrorAction Continue)))
                    #{
                    #    Write-Warning "$item - Looks like a file contains the name of this group, this group was possibly deleted from Active Directory"
                    #}

                }#ELSE $GroupName
            }#TRY
            CATCH
            {
                Write-Warning -Message "[PROCESS] Something went wrong"
                #Write-Warning -Message $_.Exception.Message
                Write-Warning -Message $Error[0]

                #Quest Snappin Errors
                if ($ErrorProcessGetQADGroup) { Write-warning -Message "[PROCESS] QUEST AD - Error When querying the group $item in Active Directory" }
                if ($ErrorProcessGetQADGroupMember) { Write-warning -Message "[PROCESS] QUEST AD - Error When querying the group $item members in Active Directory" }

                #ActiveDirectory Module Errors
                if ($ErrorProcessGetADGroup) { Write-warning -Message "[PROCESS] AD MODULE - Error When querying the group $item in Active Directory" }
                if ($ErrorProcessGetADGroupMember) { Write-warning -Message "[PROCESS] AD MODULE - Error When querying the group $item members in Active Directory" }

                # Import CSV Errors
                if ($ErrorProcessImportCSV) { Write-warning -Message "[PROCESS] Error Importing $StateFile" }
                if ($ErrorProcessCompareObject) { Write-warning -Message "[PROCESS] Error when comparing" }
                if ($ErrorProcessImportCSVChangeHistory) { Write-warning -Message "[PROCESS] Error Importing $file" }

                Write-Warning -Message $error[0].exception.Message
            }#CATCH
        }#FOREACH
    }#TRY
    CATCH
    {
        Write-Warning -Message "[PROCESS] Something wrong happened"
        #Write-Warning -Message $error[0].exception.message
        Write-Warning -Message $error[0]
    }

}#PROCESS
END
{
    Write-Verbose -message "[END] Script Completed"
}
