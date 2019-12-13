function Get-LocalAdministratorBuiltin {
    <#
    .SYNOPSIS
        function to retrieve the local Administrator account

    .DESCRIPTION
        function to retrieve the local Administrator account

    .PARAMETER ComputerName
        Specifies the computername

    .EXAMPLE
        PS C:\> Get-LocalAdministratorBuiltin

    .EXAMPLE
        PS C:\> Get-LocalAdministratorBuiltin -ComputerName SERVER01

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin

    #function to get the BUILTIN LocalAdministrator
    #http://blog.simonw.se/powershell-find-builtin-local-administrator-account/
#>

    [CmdletBinding()]
    param (
        [Parameter()]
        $ComputerName = $env:computername
    )
    Process {
        Foreach ($Computer in $ComputerName) {
            Try {
                Add-Type -AssemblyName System.DirectoryServices.AccountManagement
                $PrincipalContext = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine, $Computer)
                $UserPrincipal = New-Object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal($PrincipalContext)
                $Searcher = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalSearcher
                $Searcher.QueryFilter = $UserPrincipal
                $Searcher.FindAll() | Where-Object -FilterScript { $_.Sid -Like "*-500" }
            }
            Catch {
                Write-Warning -Message "$($_.Exception.Message)"
            }
        }
    }
}