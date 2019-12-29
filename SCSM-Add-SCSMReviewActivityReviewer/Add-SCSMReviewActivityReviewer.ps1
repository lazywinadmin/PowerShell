function Add-SCSMReviewActivityReviewer {
    <#
    .SYNOPSIS
        Function to add a reviewer to a Review Activity item

    .DESCRIPTION
        Function to add a reviewer to a Review Activity item

    .PARAMETER UserName
        Specifies the UserName to add

    .PARAMETER Veto
        Specifies the Veto. Default is False.

    .PARAMETER MustVote
        Specifies if the Vote is required. Default is False.

    .PARAMETER WorkItemID
        Specifies the WorkItem ID of the Review Activity

    .EXAMPLE
        PS C:\> Add-SCSMReviewActivityReviewer -UserName 'francois-xavier' -veto $true -WorkItemID '2aa822b0-b144-3acf-bee3-9a11714c5de0'

    .NOTES
        Francois-Xavier Cat
        @lazywinadmin
        lazywinadmin.com

        1.0 Based on Cireson's consultant function
    .LINK
        https://github.com/lazywinadmin/PowerShell
#>
    [CmdletBinding()]
    PARAM
    (
        [System.String]$UserName,

        [Boolean]$veto = $false,

        [Boolean]$mustvote = $false,

        $WorkItemID
    )

    BEGIN { Import-Module -Name SMLets -ErrorAction Stop }
    PROCESS {
        # Retrieve the Active Directory User Class
        $ADUserClassID = '10a7f898-e672-ccf3-8881-360bfb6a8f9a'
        $ADUserClassObject = Get-ScsmClass -Id $ADUserClassID

        $ScsmUser = Get-ScsmObject -class $ADUserClassObject -filter "Username -eq $UserName"

        if ($ScsmUser) {
            # Direct Reviewer add SCSM user by guid
            $RelationShipClass_HasReviewer = Get-SCSMRelationshipClass -name "System.ReviewActivityHasReviewer"
            $RelationShipClass_ReviewerIsUser = Get-SCSMRelationshipClass -name "System.ReviewerIsUser"
            $Class_ReviewerClass = Get-SCSMClass -name "System.Reviewer$"

            # Hashtable for reviewer arguments
            $ReviewerArgs = @{ ReviewerID = "{0}"; Mustvote = $mustvote; Veto = $veto }

            $Reviewer = new-scsmobject -class $class_ReviewerClass -propertyhashtable $ReviewerArgs -nocommit

            $WorkItem = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Activity.ReviewActivity$) -filter "ID -eq '$WorkItemID'"

            $reviewerStep1 = New-SCSMRelationshipObject -nocommit -Relationship $RelationShipClass_HasReviewer -Source $WorkItem -Target $Reviewer
            $reviewerStep2 = New-SCSMRelationshipObject -nocommit -Relationship $RelationShipClass_ReviewerIsUser -Source $Reviewer -Target $ScsmUser
            $reviewerStep1.Commit()
            $reviewerStep2.Commit()
        }
    }
}
