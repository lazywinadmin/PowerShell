function Get-SCSMWorkItemAffectedUser {
    <#
    .SYNOPSIS
        Function to retrieve the Affected User of a Work Item

    .DESCRIPTION
        Function to retrieve the Affected User of a Work Item

    .PARAMETER SMObject
        Specifies the SMObject(s) on which the affected need to be retrieve.

    .PARAMETER Guid
        Specifies the GUID of the SMObject on which the affected need to be retrieve.

    .EXAMPLE
        Get-SCSMWorkItemAffectedUser -SMObject $SR,$IR

    .EXAMPLE
        $SR,$IR | Get-SCSMWorkItemAffectedUser

    .EXAMPLE
        Get-SCSMWorkItemAffectedUser -GUID 5bd5e783-c8a1-0217-9e19-f82823ef4f87

    .NOTES
        Francois-Xavier Cat
        @lazywinadmin
        lazywinadmin.com
#>

    [CmdletBinding(DefaultParameterSetName = 'GUID')]
    param
    (
        [Parameter(ParameterSetName = 'SMObject',
            Mandatory = $true,
            ValueFromPipeline = $true)]
        $SMObject,

        [Parameter(ParameterSetName = 'GUID',
            Mandatory = $true)]
        $Guid
    )

    BEGIN {
        Import-Module -Name SMLets -ErrorAction Stop

        # AffectedUser RelationshipClass
        $RelationshipClass_AffectedUser = 'dff9be66-38b0-b6d6-6144-a412a3ebd4ce'
        $RelationshipClass_AffectedUser_Object = Get-SCSMRelationshipClass -id $RelationshipClass_AffectedUser
    }
    PROCESS {
        IF ($PSBoundParameters['GUID']) {
            foreach ($Item in $GUID) {
                $SMObject = Get-SCSMObject -id $item
                Write-Verbose -Message "[PROCESS] Working on $($Item.Name)"
                Get-ScsmRelatedObject -SMObject $SMObject -Relationship $RelationshipClass_AffectedUser_Object |
                    Select-Object -Property @{ Label = "WorkItemName"; Expression = { $SMObject.Name } },
                    @{ Label = "WorkItemGUID"; Expression = { $SMObject.get_id() } }, *
            }
        }

        IF ($PSBoundParameters['SMobject']) {
            foreach ($Item in $SMObject) {
                Write-Verbose -Message "[PROCESS] Working on $($Item.Name)"
                Get-ScsmRelatedObject -SMObject $Item -Relationship $RelationshipClass_AffectedUser_Object |
                    Select-Object -Property @{ Label = "WorkItemName"; Expression = { $Item.Name } },
                    @{ Label = "WorkItemGUID"; Expression = { $Item.get_id() } }, *
            }
        }
    }
}
