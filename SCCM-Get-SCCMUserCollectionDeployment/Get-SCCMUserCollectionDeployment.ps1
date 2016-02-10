function Get-SCCMUserCollectionDeployment
{
<#
	.SYNOPSIS
		Function to retrieve an User's collection deployments
	
	.DESCRIPTION
		Function to retrieve an User's collection deployments
		The function will first retrieve all the collections where the user is member of and
		find deployments advertised on those.
		
		The final output will include user, collection and deployment information.
	
	.PARAMETER Username
		Specifies the SamAccountName of the user.
		The user must be present in the SCCM database.
	
	.PARAMETER SiteCode
		Specifies the SCCM SiteCode
	
	.PARAMETER ComputerName
		Specifies the SCCM Server to query (Most likely the Management Server)
	
	.PARAMETER Credential
		Specifies the credential to use to query the SCCM Server.
		Default will take the current user credentials
	
	.PARAMETER Purpose
		Specifies a specific deployment intent.
		Possible value: Available or Required.
		Default is Null (get all)
	
	.PARAMETER ApplicationName
		Specifies the exact name of the application to return
	
	.EXAMPLE
		Get-SCCMUserCollectionDeployment -UserName francois-xavier.cat -SiteCode S01 -ComputerName SERVER01 -ApplicationName "Microsoft Visual C++ Redistributable 2005 x64" 
	
	.EXAMPLE
		Get-SCCMUserCollectionDeployment -UserName TestUser -Credential $cred -Purpose Required
	
	.NOTES
		Francois-Xavier cat
		www.lazywinadmin.com
		@lazywinadm
		
		SMS_R_User: https://msdn.microsoft.com/en-us/library/hh949577.aspx
		SMS_Collection: https://msdn.microsoft.com/en-us/library/hh948939.aspx
		SMS_DeploymentInfo: https://msdn.microsoft.com/en-us/library/hh948268.aspx
#>
	
	[CmdletBinding()]
	[OutputType([System.Management.Automation.PSCustomObject])]
	param
	(
		[Parameter(Mandatory = $true)]
		[Alias('SamAccountName')]
		[String]$UserName,
		
		[Parameter(Mandatory = $true)]
		[String]$SiteCode,
		
		[Parameter(Mandatory = $true)]
		[String]$ComputerName,
		
		[System.Management.Automation.Credential()]
		[Alias('RunAs')]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[ValidateSet('Required', 'Available')]
		[String]$Purpose,
		
		[String]$ApplicationName
	)
	
	BEGIN
	{
		# Verify if the username contains the domain name and remove it
		# Example: "FX\TestUser" will become "TestUser"
		if ($UserName -like '*\*') { $UserName = ($UserName -split '\\')[1] }
		
		# Define default properties
		$Splatting = @{
			ComputerName = $ComputerName
			NameSpace = "root\SMS\Site_$SiteCode"
		}
		
		# Credential
		IF ($PSBoundParameters['Credential'])
		{
			$Splatting.Credential = $Credential
		}
		
		Switch ($Purpose)
		{
			"Required" { $DeploymentIntent = 0 }
			"Available" { $DeploymentIntent = 2 }
			default { $DeploymentIntent = "NA" }
		}
		
		Function Get-SCCMDeploymentIntentName
		{
			PARAM (
				[Parameter(Mandatory)]
				$DeploymentIntent
			)
			PROCESS
			{
				if ($DeploymentIntent = 0) { Write-Output "Required" }
				if ($DeploymentIntent = 2) { Write-Output "Available" }
				if ($DeploymentIntent -ne 0 -and $DeploymentIntent -ne 2) { Write-Output "NA" }
			}
		} #Function Get-SCCMDeploymentIntentName
		
		
	}
	PROCESS
	{
		# Find the User in SCCM CMDB
		$User = Get-WMIObject @Splatting -Query "Select * From SMS_R_User WHERE UserName='$UserName'"
		
		# Find the collections where the user is member of		
		Get-WmiObject -Class sms_fullcollectionmembership @splatting -Filter "ResourceID = '$($user.resourceid)'" |
		ForEach-Object -Process {
			
			# Retrieve the collection of the user
			$Collections = Get-WmiObject @splatting -Query "Select * From SMS_Collection WHERE CollectionID='$($_.Collectionid)'"
			
			
			# Retrieve the deployments (advertisement) of each collections
			Foreach ($Collection in $collections)
			{
				
				switch ($DeploymentIntent)
				{
					'NA'{
						$Query = "Select * From SMS_DeploymentInfo WHERE CollectionID='$($Collection.CollectionID)'"
						if ($PSBoundParameters['ApplicationName'])
						{
							$Query = "Select * From SMS_DeploymentInfo WHERE CollectionID='$($Collection.CollectionID)' AND TargetName='$ApplicationName'"
						}
					}
					
					default
					{
						$Query = "Select * From SMS_DeploymentInfo WHERE CollectionID='$($Collection.CollectionID)' AND DeploymentIntent='$DeploymentIntent'"
						if ($PSBoundParameters['ApplicationName'])
						{
							$Query = "Select * From SMS_DeploymentInfo WHERE CollectionID='$($Collection.CollectionID)' AND DeploymentIntent='$DeploymentIntent' AND TargetName='$ApplicationName'"
						}
					}
				}
				
				$Deployments = Get-WmiObject @splatting -Query $Query
				
				
				Foreach ($Deploy in $Deployments)
				{
					
					# Prepare Output
					$Properties = @{
						UserName = $UserName
						ComputerName = $ComputerName
						CollectionName = $Deploy.CollectionName
						CollectionID = $Deploy.CollectionID
						DeploymentID = $Deploy.DeploymentID
						DeploymentName = $Deploy.DeploymentName
						DeploymentIntent = $deploy.DeploymentIntent
						DeploymentIntentName = (Get-SCCMDeploymentIntentName -DeploymentIntent $deploy.DeploymentIntent)
						TargetName = $Deploy.TargetName
						TargetSubName = $Deploy.TargetSubname
						
					}
					
					# Output the current Object
					New-Object -TypeName PSObject -prop $Properties
				} #Foreach ($Deploy in $Deployments)
			} #Foreach ($Collection in $collections)
		} #ForEach-Object {
	} #PROCESS
} #function Get-SCCMUserCollectionDeployment