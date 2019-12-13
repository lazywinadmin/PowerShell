$UserSam = "TestAccount"

$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
$Search.Filter = "(&((objectclass=user)(samaccountname=$UserSam)))"
$Search.FindAll() | ForEach-Object -Process {
    $Account = $_
    $AccountGetDirectory = $Account.GetDirectoryEntry();

    # Add the properties tokenGroups
    $AccountGetDirectory.GetInfoEx(@("tokenGroups"), 0)


    $($AccountGetDirectory.Get("tokenGroups")) |
        ForEach-Object -Process {
            # Create SecurityIdentifier to translate into group name
            $Principal = New-Object -TypeName System.Security.Principal.SecurityIdentifier($_, 0)
            $domainName = [adsi]"LDAP://$($Principal.AccountDomainSid)"

            <#
                           TypeName: System.Security.Principal.SecurityIdentifier

                        Name              MemberType Definition
                        ----              ---------- ----------
                        CompareTo         Method     int CompareTo(System.Security.Principal.SecurityIdentifier sid), int IComparable[SecurityIdentifier].CompareTo(System.Security.Principal.Security...
                        Equals            Method     bool Equals(System.Object o), bool Equals(System.Security.Principal.SecurityIdentifier sid)
                        GetBinaryForm     Method     void GetBinaryForm(byte[] binaryForm, int offset)
                        GetHashCode       Method     int GetHashCode()
                        GetType           Method     type GetType()
                        IsAccountSid      Method     bool IsAccountSid()
                        IsEqualDomainSid  Method     bool IsEqualDomainSid(System.Security.Principal.SecurityIdentifier sid)
                        IsValidTargetType Method     bool IsValidTargetType(type targetType)
                        IsWellKnown       Method     bool IsWellKnown(System.Security.Principal.WellKnownSidType type)
                        ToString          Method     string ToString()
                        Translate         Method     System.Security.Principal.IdentityReference Translate(type targetType)
                        AccountDomainSid  Property   System.Security.Principal.SecurityIdentifier AccountDomainSid {get;}
                        BinaryLength      Property   int BinaryLength {get;}
                        Value             Property   string Value {get;}
                        #>
            # Prepare Output
            $Properties = @{
                SamAccountName = $Account.properties.samaccountname -as [string]
                GroupName      = $principal.Translate([System.Security.Principal.NTAccount])
            }
            # Output Information
            New-Object -TypeName PSObject -Property $Properties
        }
}