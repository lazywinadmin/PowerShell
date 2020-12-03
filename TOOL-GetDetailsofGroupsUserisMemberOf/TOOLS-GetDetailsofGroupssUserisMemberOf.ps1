#Powershell one line script to get details of all groups user memberof 

Get-ADPrincipalGroupMembership ashishanand  |Get-ADGroup -Properties * | select name, managedby, *
