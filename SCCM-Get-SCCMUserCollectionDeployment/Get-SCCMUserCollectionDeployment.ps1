function Get-SCCMUserCollectionDeployment {
    <#
    .SYNOPSIS
        Function to retrieve a User's collection deployment

    .DESCRIPTION
        Function to retrieve a User's collection deployment
        The function will first retrieve all the collection where the user is member of and
        find deployments advertised on those.

        The final output will include user, collection and deployment information.

    .PARAMETER Username
        Specifies the SamAccountName of the user.
        The user must be present in the SCCM CMDB

    .PARAMETER SiteCode
        Specifies the SCCM SiteCode

    .PARAMETER ComputerName
        Specifies the SCCM Server to query

    .PARAMETER Credential
        Specifies the credential to use to query the SCCM Server.
        Default will take the current user credentials

    .PARAMETER Purpose
        Specifies a specific deployment intent.
        Possible value: Available or Required.
        Default is Null (get all)

    .EXAMPLE
        Get-SCCMUserCollectionDeployment -UserName TestUser -Credential $cred -Purpose Required

    .NOTES
        Francois-Xavier cat
        lazywinadmin.com
        @lazywinadmin

        SMS_R_User: https://msdn.microsoft.com/en-us/library/hh949577.aspx
        SMS_Collection: https://msdn.microsoft.com/en-us/library/hh948939.aspx
        SMS_DeploymentInfo: https://msdn.microsoft.com/en-us/library/hh948268.aspx
    .LINK
        https://github.com/lazywinadmin/PowerShell
#>

    [CmdletBinding()]
    PARAM
    (
        [Parameter(Mandatory)]
        [Alias('SamAccountName')]
        $UserName,

        [Parameter(Mandatory)]
        $SiteCode,

        [Parameter(Mandatory)]
        $ComputerName,

        [Alias('RunAs')]
        [pscredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [ValidateSet('Required', 'Available')]
        $Purpose
    )

    BEGIN {
        # Verify if the username contains the domain name
        #  If it does... remove the domain name
        # Example: "FX\TestUser" will become "TestUser"
        if ($UserName -like '*\*') { $UserName = ($UserName -split '\\')[1] }

        # Define default properties
        $Splatting = @{
            ComputerName = $ComputerName
            NameSpace    = "root\SMS\Site_$SiteCode"
        }

        IF ($PSBoundParameters['Credential']) {
            $Splatting.Credential = $Credential
        }

        Switch ($Purpose) {
            "Required" { $DeploymentIntent = 0 }
            "Available" { $DeploymentIntent = 2 }
            default { $DeploymentIntent = "NA" }
        }

        Function Get-DeploymentIntentName {
            PARAM(
                [Parameter(Mandatory)]
                $DeploymentIntent
            )
            PROCESS {
                if ($DeploymentIntent -eq 0) { Write-Output "Required" }
                if ($DeploymentIntent -eq 2) { Write-Output "Available" }
                if ($DeploymentIntent -ne 0 -and $DeploymentIntent -ne 2) { Write-Output "NA" }
            }
        }#Function Get-DeploymentIntentName


    }
    PROCESS {
        # Find the User in SCCM CMDB
        $User = Get-WMIObject @Splatting -Query "Select * From SMS_R_User WHERE UserName='$UserName'"

        # Find the collections where the user is member of
        Get-WmiObject -Class sms_fullcollectionmembership @splatting -Filter "ResourceID = '$($user.resourceid)'" |
            ForEach-Object -Process {

                # Retrieve the collection of the user
                $Collections = Get-WmiObject @splatting -Query "Select * From SMS_Collection WHERE CollectionID='$($_.Collectionid)'"


                # Retrieve the deployments (advertisement) of each collections
                Foreach ($Collection in $collections) {
                    IF ($DeploymentIntent -eq 'NA') {
                        # Find the Deployment on one collection
                        $Deployments = (Get-WmiObject @splatting -Query "Select * From SMS_DeploymentInfo WHERE CollectionID='$($Collection.CollectionID)'")
                    }
                    ELSE {
                        $Deployments = (Get-WmiObject @splatting -Query "Select * From SMS_DeploymentInfo WHERE CollectionID='$($Collection.CollectionID)' AND DeploymentIntent='$DeploymentIntent'")
                    }

                    Foreach ($Deploy in $Deployments) {

                        # Prepare Output
                        $Properties = @{
                            UserName             = $UserName
                            ComputerName         = $ComputerName
                            CollectionName       = $Deploy.CollectionName
                            CollectionID         = $Deploy.CollectionID
                            DeploymentID         = $Deploy.DeploymentID
                            DeploymentName       = $Deploy.DeploymentName
                            DeploymentIntent     = $deploy.DeploymentIntent
                            DeploymentIntentName = (Get-DeploymentIntentName -DeploymentIntent $deploy.DeploymentIntent)
                            TargetName           = $Deploy.TargetName
                            TargetSubName        = $Deploy.TargetSubname

                        }

                        # Output the current Object
                        New-Object -TypeName PSObject -prop $Properties
                    }
                }
            }
    }
}
