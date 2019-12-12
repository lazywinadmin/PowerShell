function New-RandomPassword {
    <#
.SYNOPSIS
    Function to generate a complex and random password
.DESCRIPTION
    Function to generate a complex and random password

    This is using the GeneratePassword method from the
    system.web.security.membership NET Class.

    https://msdn.microsoft.com/en-us/library/system.web.security.membership.generatepassword(v=vs.100).aspx

.PARAMETER Length
    The number of characters in the generated password. The length must be between 1 and 128 characters.
    Default is 12.

.PARAMETER NumberOfNonAlphanumericCharacters
    The minimum number of non-alphanumeric characters (such as @, #, !, %, &, and so on) in the generated password.
    Default is 5.

.PARAMETER Count
    Specifies how many password you want. Default is 1

.EXAMPLE
    New-RandomPassword
        []sHX@]W#w-{
.EXAMPLE
    New-RandomPassword -Length 8 -NumberOfNonAlphanumericCharacters 2
        v@Warq_6
.EXAMPLE
    New-RandomPassword -Count 5
        *&$6&d1[f8zF
        Ns$@[lRH{;f4
        ;G$Su^M$bS+W
        mgZ/{y8}I@-t
        **W.)60kY4$V
.NOTES
    francois-xavier.cat
    lazywinadmin.com
    @lazywinadmin
    github.com/lazywinadmin
#>
    PARAM (
        [Int32]$Length = 12,

        [Int32]$NumberOfNonAlphanumericCharacters = 5,

        [Int32]$Count = 1
    )

    BEGIN {
        Add-Type -AssemblyName System.web;
    }

    PROCESS {
        1..$Count | ForEach-Object -Process {
            [System.Web.Security.Membership]::GeneratePassword($Length, $NumberOfNonAlphanumericCharacters)
        }
    }
}