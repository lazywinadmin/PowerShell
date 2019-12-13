function Get-ParentGroup {
    <#
    .SYNOPSIS
        Find all Nested members of a group
    .DESCRIPTION
        Find all Nested members of a group
    .PARAMETER Name
        Specify one or more GroupName to audit
    .Example
        Get-NestedMember -GroupName TESTGROUP

        This will find all the indirect members of TESTGROUP
    .Example
        Get-NestedMember -GroupName TESTGROUP,TESTGROUP2

        This will find all the indirect members of TESTGROUP and TESTGROUP2
    .Example
        Get-NestedMember TESTGROUP | Group Name | select name, count

        This will find duplicate

#>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory = $true)]
        [String[]]$Name
    )
    BEGIN {
        TRY {
            if (-not(Get-Module Activedirectory -ErrorAction Stop)) {
                Write-Verbose -Message "[BEGIN] Loading ActiveDirectory Module"
                Import-Module -Name ActiveDirectory -ErrorAction Stop
            }
        }
        CATCH {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    PROCESS {
        TRY {
            FOREACH ($Obj in $Name) {
                # Make an Ambiguous Name Resolution
                $ADObject = Get-ADObject -LDAPFilter "(|(anr=$obj)(distinguishedname=$obj))" -Properties memberof -ErrorAction Stop
                IF ($ADObject) {
                    # Show a warning if more than 1 object is found
                    if ($ADObject.count -gt 1) { Write-Warning -Message "More than one object found with the $obj request" }

                    FOREACH ($Account in $ADObject) {
                        Write-Verbose -Message "[PROCESS] $($Account.name)"
                        $Account | Select-Object -ExpandProperty memberof | ForEach-Object -Process {

                            $CurrentObject = Get-Adobject -LDAPFilter "(|(anr=$_)(distinguishedname=$_))" -Properties Samaccountname


                            Write-Output $CurrentObject | Select-Object Name, SamAccountName, ObjectClass, @{L = "Child"; E = { $Account.samaccountname } }

                            Write-Verbose -Message "Inception - $($CurrentObject.distinguishedname)"
                            Get-ParentGroup -OutBuffer $CurrentObject.distinguishedname

                        }#$Account | Select-Object
                    }#FOREACH ($Account in $ADObject){
                }#IF($ADObject)
                ELSE {
                    #Write-Warning -Message "[PROCESS] Can't find the object $Obj"
                }#ELSE
            }#FOREACH ($Obj in $Object)
        }#TRY
        CATCH {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }#PROCESS
    END {
        Write-Verbose -Message "[END] Get-NestedMember"
    }
}