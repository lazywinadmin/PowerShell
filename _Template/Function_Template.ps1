Function Get-Something
{
<#
.SYNOPSIS
    A brief description of the Get-Something function.

.DESCRIPTION
    A detailed description of the Get-Something function.

.PARAMETER ComputerName
    A description of the ComputerName parameter.

.PARAMETER Credential
    A description of the Credential parameter.

.EXAMPLE
    Get-Something -ComputerName $value1 -Credential $value2

.NOTES
    Francois-Xavier Cat
    lazywinadmin.github.io
    www.lazywinadmin.com
    @lazywinadm

    1.0 | 2016/00/00 | Francois-Xavier Cat
        Initial Version
#>
    PARAM (
        [Alias("CN", "__SERVER", "PSComputerName")]
        [String[]]$ComputerName = $env:COMPUTERNAME,

        [Alias("RunAs")]
        [System.Management.Automation.Credential()]
        [pscredential]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )#PARAM
    TRY
    {
        $FunctionName = $MyInvocation.MyCommand.Name


        $Splatting = @{
            ComputerName = $ComputerName
        }

        IF ($PSBoundParameters['Credential'])
        {
            Write-Verbose -Message "[$FunctionName] Appending Credential"
            $Splatting.Credential = $Credential
        }

        # MAIN CODE HERE
        Write-Verbose -Message "[$FunctionName] Connect to..."

    }
    CATCH
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }#CATCH
    FINALLY
    {
        #Some Cleanup tasks
    }#FINALLY
}#Function