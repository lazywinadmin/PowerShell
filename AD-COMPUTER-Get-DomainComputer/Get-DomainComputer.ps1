﻿Function Get-DomainComputer {
<#
.SYNOPSIS
    The Get-DomainComputer function allows you to get information from an Active Directory Computer object using ADSI.

.DESCRIPTION
    The Get-DomainComputer function allows you to get information from an Active Directory Computer object using ADSI.
    You can specify: how many result you want to see, which credentials to use and/or which domain to query.

.PARAMETER ComputerName
    Specifies the name(s) of the Computer(s) to query

.PARAMETER SizeLimit
    Specifies the number of objects to output. Default is 100.

.PARAMETER DomainDN
    Specifies the path of the Domain to query.
    Examples:     "FX.LAB"
                "DC=FX,DC=LAB"
                "Ldap://FX.LAB"
                "Ldap://DC=FX,DC=LAB"

.PARAMETER Credential
    Specifies the alternate credentials to use.

.EXAMPLE
    Get-DomainComputer

    This will show all the computers in the current domain

.EXAMPLE
    Get-DomainComputer -ComputerName "Workstation001"

    This will query information for the computer Workstation001.

.EXAMPLE
    Get-DomainComputer -ComputerName "Workstation001","Workstation002"

    This will query information for the computers Workstation001 and Workstation002.

.EXAMPLE
    Get-Content -Path c:\WorkstationsList.txt | Get-DomainComputer

    This will query information for all the workstations listed inside the WorkstationsList.txt file.

.EXAMPLE
    Get-DomainComputer -ComputerName "Workstation0*" -SizeLimit 10 -Verbose

    This will query information for computers starting with 'Workstation0', but only show 10 results max.
    The Verbose parameter allow you to track the progression of the script.

.EXAMPLE
    Get-DomainComputer -ComputerName "Workstation0*" -SizeLimit 10 -Verbose -DomainDN "DC=FX,DC=LAB" -Credential (Get-Credential -Credential FX\Administrator)

    This will query information for computers starting with 'Workstation0' from the domain FX.LAB with the account FX\Administrator.
    Only show 10 results max and the Verbose parameter allows you to track the progression of the script.

.NOTES
    NAME:    FUNCT-AD-COMPUTER-Get-DomainComputer.ps1
    AUTHOR:    Francois-Xavier CAT
    DATE:    2013/10/26
    WWW:    www.lazywinadmin.com
    TWITTER: @lazywinadmin

    VERSION HISTORY:
    1.0 2013.10.26
        Initial Version
#>

    [CmdletBinding()]
    PARAM(
        [Parameter(
            ValueFromPipelineByPropertyName=$true,
            ValueFromPipeline=$true)]
        [Alias("Computer")]
        [String[]]$ComputerName,

        [Alias("ResultLimit","Limit")]
        [int]$SizeLimit='100',

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias("Domain")]
        [String]$DomainDN=$(([adsisearcher]"").Searchroot.path),

        [Alias("RunAs")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty

    )#PARAM

    PROCESS{
        IF ($ComputerName){
            Write-Verbose -Message "One or more ComputerName specified"
            FOREACH ($item in $ComputerName){
                TRY{
                    # Building the basic search object with some parameters
                    Write-Verbose -Message "COMPUTERNAME: $item"
                    $Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectSearcher
                    $Searcher.Filter = "(&(objectCategory=Computer)(name=$item))"
                    $Searcher.SizeLimit = $SizeLimit
                    $Searcher.SearchRoot = $DomainDN

                    # Specify a different domain to query
                    IF ($PSBoundParameters['DomainDN']){
                        IF ($DomainDN -notlike "LDAP://*") {$DomainDN = "LDAP://$DomainDN"}#IF
                        Write-Verbose -Message "Different Domain specified: $DomainDN"
                        $Searcher.SearchRoot = $DomainDN}#IF ($PSBoundParameters['DomainDN'])

                    # Alternate Credentials
                    IF ($PSBoundParameters['Credential']) {
                        Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
                        $Domain = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN,$($Credential.UserName),$($Credential.GetNetworkCredential().password) -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCred
                        $Searcher.SearchRoot = $Domain}#IF ($PSBoundParameters['Credential'])

                    # Querying the Active Directory
                    Write-Verbose -Message "Starting the ADSI Search..."
                    FOREACH ($Computer in $($Searcher.FindAll())){
                        Write-Verbose -Message "$($Computer.properties.name)"
                        New-Object -TypeName PSObject -ErrorAction 'Continue' -ErrorVariable ErrProcessNewObjectOutput -Property @{
                            "Name" = $($Computer.properties.name)
                            "DNShostName"    = $($Computer.properties.dnshostname)
                            "Description" = $($Computer.properties.description)
                            "OperatingSystem"=$($Computer.Properties.operatingsystem)
                            "WhenCreated" = $($Computer.properties.whencreated)
                            "DistinguishedName" = $($Computer.properties.distinguishedname)}#New-Object
                    }#FOREACH $Computer

                    Write-Verbose -Message "ADSI Search completed"
                }#TRY
                CATCH{
                    Write-Warning -Message ('{0}: {1}' -f $item, $_.Exception.Message)
                    IF ($ErrProcessNewObjectSearcher){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object"}
                    IF ($ErrProcessNewObjectCred){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object"}
                    IF ($ErrProcessNewObjectOutput){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object"}
                }#CATCH
            }#FOREACH $item


        }#IF $ComputerName
        ELSE {
            Write-Verbose -Message "No ComputerName specified"
            TRY{
                # Building the basic search object with some parameters
                Write-Verbose -Message "List All object"
                $Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectSearcherALL
                $Searcher.Filter = "(objectCategory=Computer)"
                $Searcher.SizeLimit = $SizeLimit

                # Specify a different domain to query
                IF ($PSBoundParameters['DomainDN']){
                    $DomainDN = "LDAP://$DomainDN"
                    Write-Verbose -Message "Different Domain specified: $DomainDN"
                    $Searcher.SearchRoot = $DomainDN}#IF ($PSBoundParameters['DomainDN'])

                # Alternate Credentials
                IF ($PSBoundParameters['Credential']) {
                    Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
                    $DomainDN = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $Credential.UserName,$Credential.GetNetworkCredential().password -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCredALL
                    $Searcher.SearchRoot = $DomainDN}#IF ($PSBoundParameters['Credential'])

                # Querying the Active Directory
                Write-Verbose -Message "Starting the ADSI Search..."
                FOREACH ($Computer in $($Searcher.FindAll())){
                    TRY{
                        Write-Verbose -Message "$($Computer.properties.name)"
                        New-Object -TypeName PSObject -ErrorAction 'Continue' -ErrorVariable ErrProcessNewObjectOutputALL -Property @{
                            "Name" = $($Computer.properties.name)
                            "DNShostName"    = $($Computer.properties.dnshostname)
                            "Description" = $($Computer.properties.description)
                            "OperatingSystem"=$($Computer.Properties.operatingsystem)
                            "WhenCreated" = $($Computer.properties.whencreated)
                            "DistinguishedName" = $($Computer.properties.distinguishedname)}#New-Object
                    }#TRY
                    CATCH{
                        Write-Warning -Message ('{0}: {1}' -f $Computer, $_.Exception.Message)
                        IF ($ErrProcessNewObjectOutputALL){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object"}
                    }
                }#FOREACH $Computer

                Write-Verbose -Message "ADSI Search completed"

            }#TRY

            CATCH{
                Write-Warning -Message "Something Wrong happened"
                IF ($ErrProcessNewObjectSearcherALL){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object"}
                IF ($ErrProcessNewObjectCredALL){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object"}

            }#CATCH
        }#ELSE
    }#PROCESS
    END{Write-Verbose -Message "Script Completed"}
}#function

#Get-Domaincomputer
#Get-Domaincomputer -ComputerName "LAB1*" -SizeLimit 5
#Get-Domaincomputer -Verbose -DomainDN 'DC=FX,DC=LAB' -ComputerName LAB1* -Credential (Get-Credential -Credential "FX.LAB\Administrator")
#Get-Domaincomputer -Verbose -DomainDN 'FX.LAB' -ComputerName LAB1* -Credential (Get-Credential -Credential "FX.LAB\FXtest")
#Get-Domaincomputer -DomainDN 'FX.LAB' -ComputerName LAB1* -Credential (Get-Credential -Credential "FX.LAB\Administrator")
#Get-Domaincomputer -DomainDN 'FX.LAB' -ComputerName LAB1*
#Get-Domaincomputer -DomainDN 'LDAP://FX.LAB' -ComputerName LAB1*
#Get-Domaincomputer -DomainDN 'LDAP://DC=FX,DC=LAB' -ComputerName LAB1*