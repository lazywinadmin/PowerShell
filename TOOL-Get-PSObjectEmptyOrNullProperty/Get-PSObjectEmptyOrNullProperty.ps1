function Get-PSObjectEmptyOrNullProperty {
    <#
.SYNOPSIS
    Function to Get all the empty or null properties with empty value in a PowerShell Object

.DESCRIPTION
    Function to Get all the empty or null properties with empty value in a PowerShell Object.
    I used this function in a System Center Orchestrator where I had a runbook that could update most of the important
    properties of a user. Using this function I knew which properties were not be updated.

.PARAMETER PSObject
    Specifies the PowerShell Object

.EXAMPLE
    PS C:\> Get-PSObjectEmptyOrNullProperty -PSObject $UserInfo

.EXAMPLE

    # Create a PowerShell Object with some properties
    $o=''|select FirstName,LastName,nullable
    $o.firstname='Nom'
    $o.lastname=''
    $o.nullable=$null

    # Look for empty or null properties
    Get-PSObjectEmptyOrNullProperty -PSObject $o

    MemberType      : NoteProperty
    IsSettable      : True
    IsGettable      : True
    Value           :
    TypeNameOfValue : System.String
    Name            : LastName
    IsInstance      : True

    MemberType      : NoteProperty
    IsSettable      : True
    IsGettable      : True
    Value           :
    TypeNameOfValue : System.Object
    Name            : nullable
    IsInstance      : True

.NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadmin
.LINK
    https://github.com/lazywinadmin/PowerShell
#>
    PARAM (
        $PSObject)
    PROCESS {
        $PsObject.psobject.Properties |
            Where-Object -FilterScript { -not $_.value }
    }
}
