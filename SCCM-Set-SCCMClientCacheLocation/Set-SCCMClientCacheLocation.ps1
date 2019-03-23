function Set-SCCMClientCacheLocation
{
    <#
        .SYNOPSYS
            Function to set the cache location on a SCCM Client
        .DESCRIPTION
            Function to set the cache location on a SCCM Client
        .PARAMETER ComputerName
            Specifies the name of the client on which the Cache location need to be changed
        .PARAMETER Location
            Specifies the location of the cache.
        .PARAMETER ServiceRestart
            Specifies that you want the SCCM Client service to restart
        .PARAMETER Credential
            Specifies the credential to use against the remote machine
            Only work with the WMI query for now, not the service restart
        .EXAMPLE
            Set-SCCMClientCacheLocation -ComputerName Client01 -Location "C:\temp\ccmcache"

            This will set the client cache location "C:\temp\ccmcache" on the computer Client01
    #>
    PARAM(
        [string[]]$ComputerName=".",

        [parameter(Mandatory)]
        [int]$Location,

        [Switch]$ServiceRestart,

        [Alias('RunAs')]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    FOREACH ($Computer in $ComputerName)
    {
        Write-Verbose -message "[PROCESS] ComputerName: $Computer"

        # Define Parameters
        $SplattingWMI = @{
            NameSpace = "ROOT\CCM\SoftMgmtAgent"
            Class = "CacheConfig"
        }
        $SplattingService = @{
            Name = 'ccmexec'
        }

        IF ($PSBoundParameters['ComputerName'])
        {
            $SplattingWMI.ComputerName = $Computer
            $SplattingService.ComputerName = $Computer
        }
        IF ($PSBoundParameters['Credential'])
        {
            $SplattingWMI.Credential = $Credential
        }

        TRY
        {
            # Set the Cache Size
            $Cache = Get-WmiObject @SplattingWMI
            $Cache.location = $Location
            $Cache.Put()

            # Restart SCCM Client
            IF($PSBoundParameters['ServiceRestart'])
            {
                Get-Service @SplattingService | Restart-Service
            }
        }
        CATCH
        {
            Write-Warning -message "[PROCESS] Something Wrong happened with $Computer"
            $Error[0].execption.message
        }
    }
}
