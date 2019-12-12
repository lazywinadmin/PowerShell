
function Get-DistributionGroupMemberRecursive {
    <#
.SYNOPSIS
    This script will list all the members (recursively) of a DistributionGroup
.EXAMPLE
    Get-DistributionGroupMemberRecursive -Group TestDG  -Verbose
.NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadmin
#>
    [CmdletBinding()]
    PARAM ($Group)
    BEGIN {
        TRY {
            # Retrieve Group information
            Write-Verbose -Message "[BEGIN] Retrieving members of $Group"
            $GroupMembers = Get-DistributionGroupMember -Identity $Group -ErrorAction Stop -ErrorVariable ErrorBeginGetDistribMembers |
                Select-Object -Property Name, PrimarySMTPAddress, @{ Label = "Group"; Expression = { $Group } }, RecipientType

        }
        CATCH {
            if ($ErrorBeginGetDistribMembers) { Write-Warning -Message "[BEGIN] Issue while retrieving members of $Group" }
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    PROCESS {
        FOREACH ($Member in $GroupMembers) {
            TRY {
                Write-Verbose -Message "[PROCESS] Member: $($member.name)"

                SWITCH ($Member.RecipientType) {
                    "MailUniversalDistributionGroup" {
                        # Member's type is Distribution Group, we need to find members of this object
                        Get-DistributionGroupMemberRecursive -Group $($Member.name) |
                            Select-Object -Property Name, PrimarySMTPAddress, @{ Label = "Group"; Expression = { $($Member.name) } }, RecipientType
                        Write-Verbose -Message "[PROCESS] $($Member.name)"
                    }
                    "UserMailbox" {
                        # Member's type is User, let's just output the data
                        $Member | Select-Object -Property Name, PrimarySMTPAddress, @{ Label = "Group"; Expression = { $Group } }
                    }
                }
            }
            CATCH {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
    END {
        Write-Verbose -message "[END] Done"
    }
}
