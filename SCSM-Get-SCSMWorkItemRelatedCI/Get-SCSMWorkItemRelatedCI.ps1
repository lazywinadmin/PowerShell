function Get-SCSMWorkItemRelatedCI {
    <#
    .SYNOPSIS
        Function to retrieve the related configuration item of a System Center Service Manager Work Item

    .DESCRIPTION
        Function to retrieve the related configuration item of a System Center Service Manager Work Item

    .PARAMETER GUID
        Specifies the GUID of the WorkItem

    .EXAMPLE
        PS C:\> Get-SCSMWorkItemRelatedCI -GUID "69c5dfc9-9acb-0afb-9210-190d3054901e"

    .NOTES
        Francois-Xavier.Cat
        @lazywinadmin
        lazywinadmin.com
#>
    PARAM (
        [parameter()]
        [Alias()]
        $GUID
    )
    PROCESS {
        # Find the Ticket Object
        $WorkItemObject = Get-SCSMObject -id $GUID

        # Find the Related Configuration Items
        Get-SCSMRelationshipObject -BySource $WorkItemObject |
            Where-Object -FilterScript { $_.relationshipid -eq 'd96c8b59-8554-6e77-0aa7-f51448868b43' }
    }
}