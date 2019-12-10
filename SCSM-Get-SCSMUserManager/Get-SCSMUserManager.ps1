Function Get-SCSMUserManager {
    <#
    .SYNOPSIS
        Function to retrieve the manager of a user
    .DESCRIPTION
        Function to retrieve the manager of a user
    .PARAMETER UserID
        Specify the User ID
    .EXAMPLE
        Get-SCSMUserManager -UserID $UserID
    #>
    [CmdletBinding()]
    Param (
        [Alias('input_affectedUser_id')]
        [String]$UserID
    )
    try {
        ## Return Variables
        $managerOfAffectedUser_obj = $null

        ## MAIN
        $affectedUser_obj = get-scsmobject -id $UserID
        $userManagesUser_relclass_id = '4a807c65-6a1f-15b2-bdf3-e967e58c254a'
        $managerOfAffectedUser_relobjs = Get-SCSMRelationshipObject -ByTarget $affectedUser_obj |
            Where-Object -FilterScript {
                $_.relationshipId -eq $userManagesUser_relclass_id
            }

        ## Check if Manager User Exists and that the relationship is current.
        ##  get-scsmrelationshipobject tends to keep track of relationship history. It returns old and new
        ##  relationships

        If ($null -ne $managerOfAffectedUser_relobjs) {
            ForEach ($managerOfAffectedUser_relobj in $managerOfAffectedUser_relobjs) {
                If ($managerOfAffectedUser_relobj.IsDeleted -eq $True) {
                    #The relationship no longer exists. Returning nothing
                    #  which will effectively keep the managerOfAffectedUser_obj the same as before.
                }
                Else {
                    #The relationship exists, setting managerOfAffectedUser_relExists to true.
                    get-scsmobject -id ($managerofaffecteduser_relobj.SourceObject.Id.Guid)
                }
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}