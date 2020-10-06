<#
.Synopsis
Verify Active Directory credentials
.DESCRIPTION
This function takes a user name and a password as input and will verify if the combination is correct. The function returns a boolean based on the result.
.NOTES   
Name: Test-ADCredential
Version: 1.0
.PARAMETER UserName
The samaccountname of the Active Directory user account
.PARAMETER Password
The password of the Active Directory user account
.EXAMPLE
Test-ADCredential -username username1 -password Password1!
Description:
Verifies if the username and password provided are correct, returning either true or false based on the result
#>
function Test-ADCredential {
    [CmdletBinding()]
    Param
    (
        [string]$UserName,
        [string]$Password
    )
    if (!($UserName) -or !($Password)) {
        Write-Warning 'Test-ADCredential: Please specify both user name and password'
    } else {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
        $DS.ValidateCredentials($UserName, $Password)
    }
}
