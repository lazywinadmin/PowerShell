# Mail enable all public folders inside a path. 

Get-PublicFolder -Identity '<Public Folder Path>' -GetChildren |Enable-MailPublicFolder
