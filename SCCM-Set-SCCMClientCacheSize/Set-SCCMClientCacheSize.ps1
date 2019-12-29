function Set-SCCMClientCacheSize {
    <#
        .SYNOPSIS
            Function to set the cache size on a SCCM Client
        .DESCRIPTION
            Function to set the cache size on a SCCM Client
        .PARAMETER ComputerName
            Specifies the name of the client on which the Cache size need to be changed
        .PARAMETER SizeMB
            Specifies the size of the cache in MB.
        .PARAMETER ServiceRestart
            Specifies that you want the SCCM Client service to restart
        .PARAMETER Credential
            Specifies the credential to use against the remote machine
            Only work with the WMI query for now, not the service restart
        .EXAMPLE
            Set-SCCMClientCacheSize -ComputerName Client01 -SizeMB 5000

            This will set the client cache to 5000Mb on the computer Client01
        .NOTES
            Francois-Xavier Cat
            lazywinadmin.com
            @lazywinadmin
        .LINK
            https://github.com/lazywinadmin/PowerShell
    #>
    PARAM(
        [Parameter(Mandatory)]
        [string[]]$ComputerName,

        [int]$SizeMB = 10240,

        [Switch]$ServiceRestart,

        [Alias('RunAs')]
        [PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    FOREACH ($Computer in $ComputerName) {
        Write-Verbose -message "[PROCESS] ComputerName: $Computer"

        # Define Parameters
        $SplattingWMI = @{
            NameSpace = "ROOT\CCM\SoftMgmtAgent"
            Class     = "CacheConfig"
        }
        $SplattingService = @{
            Name = 'ccmexec'
        }

        IF ($PSBoundParameters['ComputerName']) {
            $SplattingWMI.ComputerName = $Computer
            $SplattingService.ComputerName = $Computer
        }
        IF ($PSBoundParameters['Credential']) {
            $SplattingWMI.Credential = $Credential
        }

        TRY {
            # Set the Cache Size
            $Cache = Get-WmiObject @SplattingWMI
            $Cache.Size = $SizeMB
            $Cache.Put()

            # Restart SCCM Client
            IF ($PSBoundParameters['ServiceRestart']) {
                Get-Service @SplattingService | Restart-Service
            }
        }
        CATCH {
            Write-Warning -message "[PROCESS] Something Wrong happened with $Computer"
            $Error[0].execption.message
        }
    }
}
