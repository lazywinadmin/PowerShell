function Get-ParentGroup {
    <#
    .SYNOPSIS
        Find all parent groups of an AD object
    .DESCRIPTION
        Find all parent groups of an AD object by walking the memberof attribute
    .PARAMETER Name
        Specify one or more object names (ANR or distinguishedName) to look up parent groups for
    .Example
        Get-ParentGroup -Name TESTUSER

        This will find all parent groups of TESTUSER
    .Example
        Get-ParentGroup -Name TESTGROUP,TESTUSER

        This will find all parent groups of TESTGROUP and TESTUSER
    .Example
        Get-ParentGroup TESTUSER | Group Name | select name, count

        This will find duplicate parent group entries
    .link
        https://github.com/lazywinadmin/PowerShell

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
                            Get-ParentGroup -Name $CurrentObject.DistinguishedName

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
        Write-Verbose -Message "[END] Get-ParentGroup"
    }
}