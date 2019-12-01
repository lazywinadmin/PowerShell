function Get-SCSMReviewActivityReviewer {
    <#
    .SYNOPSIS
    Function to retrieve the reviewers of a Review Activity

    .DESCRIPTION
    Function to retrieve the reviewers of a Review Activity

    .PARAMETER ActivityObject
    Specifies the Service Manager Object

    .PARAMETER ActivityName
    Specifies the Name of the Ticket (Example RA1000)

    .PARAMETER ActivityGUID
    Specifies the GUID of the Activity

    .EXAMPLE
    Get-SCSMReviewActivityReviewer -ActivityObject $RA

    .EXAMPLE
    Get-SCSMReviewActivityReviewer -ActivityGUID '04ddd0a1-993a-13dc-68a8-c434270df5a2'

    .EXAMPLE
    Get-SCSMReviewActivityReviewer -ActivityName 'RA1234'

    .NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadmin
    #>

    [CmdletBinding(DefaultParameterSetName = 'Object')]
    param
    (
        [Parameter(ParameterSetName = 'Object',
            Mandatory = $true,
            ValueFromPipeline = $true)]
        $ActivityObject,

        [Parameter(ParameterSetName = 'Name',
            Mandatory = $true)]
        $ActivityName,

        [Parameter(ParameterSetName = 'GUID',
            Mandatory = $true)]
        $ActivityGUID
    )

    BEGIN { Import-Module -Name SMLets -ErrorAction Stop }
    PROCESS {
        IF ($PSBoundParameters['ActivityGUID']) {
            $RA = Get-SCSMObject -Id $ActivityGUID
        }
        IF ($PSBoundParameters['ActivityName']) {
            $RA = Get-SCSMObject (Get-SCSMClass System.WorkItem.Activity.ReviewActivity$) -Filter Id -eq $ActivityName
        }
        IF ($PSBoundParameters['ActivityObject']) {
            $RA = $ActivityObject
        }


        $RelationshipClassHasReviewer = Get-SCSMRelationshipClass System.ReviewActivityHasReviewer$
        $RelationshipClassReviewerIsUser = Get-SCSMRelationshipClass System.ReviewerIsUser$
        foreach ($Reviewer in (Get-SCSMRelatedObject -SMObject $RA -Relationship $RelationshipClassHasReviewer)) {
            Get-SCSMRelatedObject -SMObject $Reviewer -Relationship $RelationshipClassReviewerIsUser
        }
    }
}