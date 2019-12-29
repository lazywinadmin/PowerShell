function Get-ADDirectReports {
    <#
    .SYNOPSIS
        This function retrieve the directreports property from the IdentitySpecified.
        Optionally you can specify the Recurse parameter to find all the indirect
        users reporting to the specify account (Identity).

    .DESCRIPTION
        This function retrieve the directreports property from the IdentitySpecified.
        Optionally you can specify the Recurse parameter to find all the indirect
        users reporting to the specify account (Identity).

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin

        Blog post: https://lazywinadmin.com/2014/10/powershell-who-reports-to-whom-active.html

        VERSION HISTORY
        1.0 2014/10/05 Initial Version

    .PARAMETER Identity
        Specify the account to inspect

    .PARAMETER Recurse
        Specify that you want to retrieve all the indirect users under the account

    .EXAMPLE
        Get-ADDirectReports -Identity Test_director

Name                SamAccountName      Mail                Manager
----                --------------      ----                -------
test_managerB       test_managerB       test_managerB@la... test_director
test_managerA       test_managerA       test_managerA@la... test_director

    .EXAMPLE
        Get-ADDirectReports -Identity Test_director -Recurse

Name                SamAccountName      Mail                Manager
----                --------------      ----                -------
test_managerB       test_managerB       test_managerB@la... test_director
test_userB1         test_userB1         test_userB1@lazy... test_managerB
test_userB2         test_userB2         test_userB2@lazy... test_managerB
test_managerA       test_managerA       test_managerA@la... test_director
test_userA2         test_userA2         test_userA2@lazy... test_managerA
test_userA1         test_userA1         test_userA1@lazy... test_managerA
    .LINK
        https://github.com/lazywinadmin/PowerShell
    #>
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory)]
        [String[]]$Identity,
        [Switch]$Recurse
    )
    BEGIN {
        TRY {
            IF (-not (Get-Module -Name ActiveDirectory)) { Import-Module -Name ActiveDirectory -ErrorAction 'Stop' -Verbose:$false }
        }
        CATCH {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    PROCESS {
        foreach ($Account in $Identity) {
            TRY {
                IF ($PSBoundParameters['Recurse']) {
                    # Get the DirectReports
                    Write-Verbose -Message "[PROCESS] Account: $Account (Recursive)"
                    Get-Aduser -identity $Account -Properties directreports |
                        ForEach-Object -Process {
                            $_.directreports | ForEach-Object -Process {
                                # Output the current object with the properties Name, SamAccountName, Mail and Manager
                                Get-ADUser -Identity $PSItem -Properties * | Select-Object -Property *, @{ Name = "ManagerAccount"; Expression = { (Get-Aduser -identity $psitem.manager).samaccountname } }
                                # Gather DirectReports under the current object and so on...
                                Get-ADDirectReports -Identity $PSItem -Recurse
                            }
                        }
                }#IF($PSBoundParameters['Recurse'])
                IF (-not ($PSBoundParameters['Recurse'])) {
                    Write-Verbose -Message "[PROCESS] Account: $Account"
                    # Get the DirectReports
                    Get-Aduser -identity $Account -Properties directreports | Select-Object -ExpandProperty directReports |
                    Get-ADUser -Properties * | Select-Object -Property *, @{ Name = "ManagerAccount"; Expression = { (Get-Aduser -identity $psitem.manager).samaccountname } }
            }#IF (-not($PSBoundParameters['Recurse']))
        }#TRY
        CATCH {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}
END {
    Remove-Module -Name ActiveDirectory -ErrorAction 'SilentlyContinue' -Verbose:$false | Out-Null
}
}
