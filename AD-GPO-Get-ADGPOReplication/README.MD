# Function Get-ADGPOReplication

(LazyWinAdmin Article)[]

Get-ADGPOReplication is retrieving the GPO version and Sysvol version accross the domain for one or more Group Policy objects. This can especially helps you troubleshooting replication issues.

This small function is taking advantage of the module ActiveDirectory to retrieve the list of all Domain Controllers and the module GroupPolicy to query one or more Group Policy objects.

For each GPO, It will then retrieve the version of the User/Computer configurations and the Sysvol Version.

Getting the list of Domain Controllers
$DomainControllers = ((Get-ADDomainController -filter *).hostname)

Processing each Group Policy Object, against each Domain controllers
Foreach ($GPOItem in $GPOName)
{
    $GPO = Get-GPO -Name $GPOItem -Server $DomainController -ErrorAction Stop
    
    [pscustomobject][ordered] @{
        GroupPolicyName = $GPOItem
        DomainController = $DomainController
        UserVersion = $GPO.User.DSVersion
        UserSysVolVersion = $GPO.User.SysvolVersion
        ComputerVersion = $GPO.Computer.DSVersion
        ComputerSysVolVersion = $GPO.Computer.SysvolVersion
    }#PSObject
}#Foreach ($GPOItem in $GPOName)