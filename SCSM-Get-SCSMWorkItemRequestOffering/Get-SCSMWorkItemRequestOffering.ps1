function Get-SCSMWorkItemRequestOffering {
    <#
    .SYNOPSIS
        Function to retrieve the RequestOffering used to create a specific work item.

    .DESCRIPTION
        Function to retrieve the RequestOffering used to create a specific work item.
        It will output the full object and add the work item Name and GUID to the output

    .EXAMPLE
        $SR = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.ServiceRequest$) -Filter "ID -eq 'SR55000'"
        Get-SCSMWorkItemRequestOffering -SMObject $SR

    .EXAMPLE
        Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.ServiceRequest$) -Filter "ID -eq 'SR55000'" | Get-SCSMWorkItemRequestOffering

    .EXAMPLE
        $SR = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.ServiceRequest$) -Filter "ID -eq 'SR55000'"
        $IR = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.IncidentRequest$) -Filter "ID -eq 'IR99000'"
        Get-SCSMWorkItemRequestOffering -SMObject $SR,IR

    .NOTES
        Francois-Xavier Cat
        @lazywinadmin
        lazywinadmin.com
    .LINK
        https://github.com/lazywinadmin/PowerShell

    #>
    PARAM (
        [Parameter(ValueFromPipeline)]
        $SMObject
    )
    BEGIN { Import-Module -Name SMLets -ErrorAction Stop }
    PROCESS {
        foreach ($Item in $SMObject) {
            (Get-SCSMRelationshipObject -BySource $Item | Where-Object -FilterScript { $_.RelationshipID -eq "2730587f-3d88-a4e4-42d8-08cf94535a6e" }).TargetObject |
                Select-Object -property @{ Label = "WorkItemName"; Expression = { $Item.Name } }, @{ Label = "WorkItemGUID"; Expression = { $Item.get_id() } }, *

        }
    }#PROCESS
    END { Remove-Module -Name Smlets -ErrorAction SilentlyContinue }
}