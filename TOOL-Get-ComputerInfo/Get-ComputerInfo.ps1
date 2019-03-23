#requires -Version 3

function Get-ComputerInfo
{

<#
.SYNOPSIS
   This function query some basic Operating System and Hardware Information from
   a local or remote machine.

.DESCRIPTION
   This function query some basic Operating System and Hardware Information from
   a local or remote machine.
   It requires PowerShell version 3 for the Ordered Hashtable.

   The properties returned are the Computer Name (ComputerName),the Operating 
   System Name (OSName), Operating System Version (OSVersion), Memory Installed 
   on the Computer in GigaBytes (MemoryGB), the Number of 
   Processor(s) (NumberOfProcessors), Number of Socket(s) (NumberOfSockets),
   and Number of Core(s) (NumberOfCores).

   This function as been tested against Windows Server 2000, 2003, 2008 and 2012

.PARAMETER ComputerName
   Specify a ComputerName or IP Address. Default is Localhost.

.PARAMETER ErrorLog
   Specify the full path of the Error log file. Default is .\Errors.log.

.PARAMETER Credential
   Specify the alternative credential to use

.EXAMPLE
   Get-ComputerInfo

   ComputerName       : XAVIER
   OSName             : Microsoft Windows 8 Pro
   OSVersion          : 6.2.9200
   MemoryGB           : 4
   NumberOfProcessors : 1
   NumberOfSockets    : 1
   NumberOfCores      : 4

   This example return information about the localhost. By Default, if you don't
   specify a ComputerName, the function will run against the localhost.

.EXAMPLE
   Get-ComputerInfo -ComputerName SERVER01

   ComputerName       : SERVER01
   OSName             : Microsoft Windows Server 2012
   OSVersion          : 6.2.9200
   MemoryGB           : 4
   NumberOfProcessors : 1
   NumberOfSockets    : 1
   NumberOfCores      : 4

   This example return information about the remote computer SERVER01.

.EXAMPLE
   Get-Content c:\ServersList.txt | Get-ComputerInfo

   ComputerName       : DC
   OSName             : Microsoft Windows Server 2012
   OSVersion          : 6.2.9200
   MemoryGB           : 8
   NumberOfProcessors : 1
   NumberOfSockets    : 1
   NumberOfCores      : 4

   ComputerName       : FILESERVER
   OSName             : Microsoft Windows Server 2008 R2 Standard 
   OSVersion          : 6.1.7601
   MemoryGB           : 2
   NumberOfProcessors : 1
   NumberOfSockets    : 1
   NumberOfCores      : 1

   ComputerName       : SHAREPOINT
   OSName             : Microsoft(R) Windows(R) Server 2003 Standard x64 Edition
   OSVersion          : 5.2.3790
   MemoryGB           : 8
   NumberOfProcessors : 8
   NumberOfSockets    : 8
   NumberOfCores      : 8

   ComputerName       : FTP
   OSName             : Microsoft Windows 2000 Server
   OSVersion          : 5.0.2195
   MemoryGB           : 4
   NumberOfProcessors : 2
   NumberOfSockets    : 2
   NumberOfCores      : 2

   This example show how to use the function Get-ComputerInfo in a Pipeline.
   Get-Content Cmdlet Gather the content of the ServersList.txt and send the
   output to Get-ComputerInfo via the Pipeline.

.EXAMPLE
   Get-ComputerInfo -ComputerName FILESERVER,SHAREPOINT -ErrorLog d:\MyErrors.log.

   ComputerName       : FILESERVER
   OSName             : Microsoft Windows Server 2008 R2 Standard 
   OSVersion          : 6.1.7601
   MemoryGB           : 2
   NumberOfProcessors : 1
   NumberOfSockets    : 1
   NumberOfCores      : 1

   ComputerName       : SHAREPOINT
   OSName             : Microsoft(R) Windows(R) Server 2003 Standard x64 Edition
   OSVersion          : 5.2.3790
   MemoryGB           : 8
   NumberOfProcessors : 8
   NumberOfSockets    : 8
   NumberOfCores      : 8

   This example show how to use the function Get-ComputerInfo against multiple
   Computers. Using the ErrorLog Parameter, we send the potential errors in the
   file d:\Myerrors.log.

.INPUTS
   System.String

.OUTPUTS
   System.Management.Automation.PSCustomObject

.NOTES
   Scripting Games 2013 - Advanced Event #2
#>

 [CmdletBinding()]

    PARAM(
    [Parameter(ValueFromPipeline=$true)]
    [String[]]$ComputerName = "LocalHost",

    [String]$ErrorLog = ".\Errors.log",

    [Alias("RunAs")]
    [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )#PARAM

    BEGIN {}#PROCESS BEGIN

    PROCESS{
        FOREACH ($Computer in $ComputerName) {
            Write-Verbose -Message "PROCESS - Querying $Computer ..."

            TRY{
                $Splatting = @{
                    ComputerName = $Computer
                }

                IF ($PSBoundParameters["Credential"]){
                    $Splatting.Credential = $Credential
                }


                $Everything_is_OK = $true
                Write-Verbose -Message "PROCESS - $Computer - Testing Connection"
                Test-Connection -Count 1 -ComputerName $Computer -ErrorAction Stop -ErrorVariable ProcessError | Out-Null

                # Query WMI class Win32_OperatingSystem
                Write-Verbose -Message "PROCESS - $Computer - WMI:Win32_OperatingSystem"
                $OperatingSystem = Get-WmiObject -Class Win32_OperatingSystem @Splatting -ErrorAction Stop -ErrorVariable ProcessError

                # Query WMI class Win32_ComputerSystem
                Write-Verbose -Message "PROCESS - $Computer - WMI:Win32_ComputerSystem"
                $ComputerSystem = Get-WmiObject -Class win32_ComputerSystem @Splatting -ErrorAction Stop -ErrorVariable ProcessError

                # Query WMI class Win32_Processor
                Write-Verbose -Message "PROCESS - $Computer - WMI:Win32_Processor"
                $Processors = Get-WmiObject -Class win32_Processor @Splatting -ErrorAction Stop -ErrorVariable ProcessError

                # Processors - Determine the number of Socket(s) and core(s)
                # The following code is required for some old Operating System where the
                # property NumberOfCores does not exist.
                Write-Verbose -Message "PROCESS - $Computer - Determine the number of Socket(s)/Core(s)"
                $Cores = 0
                $Sockets = 0
                FOREACH ($Proc in $Processors){
                    IF($Proc.numberofcores -eq $null){
                        IF ($Proc.SocketDesignation -ne $null){$Sockets++}
                        $Cores++
                    }ELSE {
                        $Sockets++
                        $Cores += $proc.numberofcores
                    }#ELSE
                }#FOREACH $Proc in $Processors

            }CATCH{
                $Everything_is_OK = $false
                Write-Warning -Message "Error on $Computer"
                $Computer | Out-file -FilePath $ErrorLog -Append -ErrorAction Continue
                $ProcessError | Out-file -FilePath $ErrorLog -Append -ErrorAction Continue
                Write-Warning -Message "Logged in $ErrorLog"

            }#CATCH


            IF ($Everything_is_OK){
                Write-Verbose -Message "PROCESS - $Computer - Building the Output Information"
                $Info = [ordered]@{
                    "ComputerName" = $OperatingSystem.__Server;
                    "OSName" = $OperatingSystem.Caption;
                    "OSVersion" = $OperatingSystem.version;
                    "MemoryGB" = $ComputerSystem.TotalPhysicalMemory/1GB -as [int];
                    "NumberOfProcessors" = $ComputerSystem.NumberOfProcessors;
                    "NumberOfSockets" = $Sockets;
                    "NumberOfCores" = $Cores}

                $output = New-Object -TypeName PSObject -Property $Info
                $output
            } #end IF Everything_is_OK
        }#end Foreach $Computer in $ComputerName
    }#PROCESS BLOCK
    END{
        # Cleanup
        Write-Verbose -Message "END - Cleanup Variables"
        Remove-Variable -Name output,info,ProcessError,Sockets,Cores,OperatingSystem,ComputerSystem,Processors,
        ComputerName, ComputerName, Computer, Everything_is_OK -ErrorAction SilentlyContinue

        # End
        Write-Verbose -Message "END - Script End !"
    }#END BLOCK
}#function
