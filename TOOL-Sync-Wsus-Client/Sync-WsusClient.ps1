function sync-WsusClient {
    <#
.SYNOPSIS
    Function to force the given computer(s) to check for updates and check in with the WSUS server
.DESCRIPTION
    Connects to computer list over WinRM (PsSession) and forces it to check for updates and report to its WSUS server
    Default if no computers listed is to use localhost
    Meant to run against many computers and get quick results
.PARAMETER ComputerName
    A string list of computer names against which to run this sync command
.PARAMETER Credential
    A "pscredential" that will be used to connect to the remote computer(s)
.EXAMPLE
    Sync-WsusClient
    "localhost - Done!"
.EXAMPLE
    Sync-WsusClient server1, server2, server3, server4
    "server2 - Done!"
    "server1 - Done!"
    "server4 - Done!"
    "server3 - Done!"
.EXAMPLE
    Sync-WsusClient server1, server2 -Credential admin
    (enter your credential and then...)
    "server2 - Done!"
    "server1 - Done!"
.NOTES
    Here's one place where it came from: http://pleasework.robbievance.net/howto-force-really-wsus-clients-to-check-in-on-demand/
    Roger P Seekell, (2019), 9-13-2019
#>
Param(
    [Parameter(ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName = 'localhost',
    [pscredential]$Credential = $null
)
process {
    #this script block will run on each computer
    $scriptBlock = {
        try {
        $updateSession = New-Object -com "Microsoft.Update.Session"
        $null = $updateSession.CreateUpdateSearcher().Search($criteria).UPdates #I don't want to see them
        wuauclt /reportnow
        "$env:computername - Done!"
        }
        catch {
            Write-Error "Sync unsuccessful on $env:computername : $_"
        }
    }#end script block

    $splat = @{"ComputerName" = $ComputerName; "ScriptBlock" = $scriptBlock}

    if ($Credential -ne $null) {
        $splat += @{"Credential" = $Credential}
    }

    Invoke-Command @splat #run with the two or three parameters above
}#end process

}#end function
