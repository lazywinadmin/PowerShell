Function Get-HashTableNotEmptyOrNullValue {
    <#
.SYNOPSIS
    This function will get the values that are not empty or Null in a hashtable object
.DESCRIPTION
    This function will get the values that are not empty or Null in a hashtable object
.PARAMETER Hashtable
    Specifies the hashtable that will be showed
.EXAMPLE
    Get-HashTableNotEmptyOrNullValue -HashTable $SplattingVariable
.NOTES
    Francois-Xavier Cat
    @lazywinadmin
    lazywinadmin.com
#>
    PARAM([System.Collections.Hashtable]$HashTable)

    $HashTable.GetEnumerator().name |
        ForEach-Object -Process {
            if ($HashTable[$_] -ne "") {
                Write-Output $_
            }
        }
}
