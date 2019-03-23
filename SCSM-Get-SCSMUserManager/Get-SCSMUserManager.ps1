Function Get-SCSMUserManager
{
    Param (
        $input_affectedUser_id
    )

    ## Return Variables
    $managerOfAffectedUser_obj = $null

    ## MAIN
    $affectedUser_obj = get-scsmobject -id $input_affectedUser_id
    $userManagesUser_relclass_id = '4a807c65-6a1f-15b2-bdf3-e967e58c254a'
    $managerOfAffectedUser_relobjs = Get-SCSMRelationshipObject -ByTarget $affectedUser_obj | where{ $_.relationshipId -eq $userManagesUser_relclass_id }

    ## Check if Manager User Exists and that the relationship is current.
    ##  get-scsmrelationshipobject tends to keep track of relationship history. It returns old and new
    ##  relationships

    If ($managerOfAffectedUser_relobjs -ne $null)
    {
        ForEach ($managerOfAffectedUser_relobj in $managerOfAffectedUser_relobjs)
        {
            If ($managerOfAffectedUser_relobj.IsDeleted -eq $True)
            {
                #The relationship no longer exists. Returning nothing
                #  which will effectively keep the managerOfAffectedUser_obj the same as before.
            }
            Else
            {
                #The relationship exists, setting managerOfAffectedUser_relExists to true.
                $managerOfAffectedUser_id = $managerofaffecteduser_relobj.SourceObject.Id.Guid
                $managerOfAffectedUser_obj = get-scsmobject -id $managerofaffecteduser_id
            }
        }
    }
    Else
    {
        #No Affected User Exists
        $managerOfAffectedUser_obj = $null
    }
    $managerOfAffectedUser_obj
}