Function Remove-HashTableEmptyValue {
    <#
.SYNOPSIS
    This function will remove the empty or Null entry of a hashtable object
.DESCRIPTION
    This function will remove the empty or Null entry of a hashtable object
.PARAMETER Hashtable
    Specifies the hashtable that will be cleaned up.
.EXAMPLE
    Remove-HashTableEmptyValue -HashTable $SplattingVariable
.NOTES
    Francois-Xavier Cat
    @lazywinadmin
    lazywinadmin.com
    github.com/lazywinadmin
.LINK
    https://github.com/lazywinadmin/PowerShell
#>
    [CmdletBinding()]
    PARAM([System.Collections.Hashtable]$HashTable)

    $HashTable.GetEnumerator().name |
        ForEach-Object -Process {
            if ($HashTable[$_] -eq "" -or $null -eq $HashTable[$_]) {
                Write-Verbose -Message "[Remove-HashTableEmptyValue][PROCESS] - Property: $_ removing..."
                [void]$HashTable.Remove($_)
                Write-Verbose -Message "[Remove-HashTableEmptyValue][PROCESS] - Property: $_ removed"
            }
        }
}