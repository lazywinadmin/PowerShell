function Get-SCSMWorkItemParent {
    <#
    .DESCRIPTION
        Function to retrieve the parent of a System Center Service Manager Work Item

    .SYNOPSIS
        Function to retrieve the parent of a System Center Service Manager Work Item

    .PARAMETER WorkItemGUI
        Specified the GUID of the Work Item

    .PARAMETER WorkItemObject
        Specified the Work Item Object

    .EXAMPLE
        $RunbookActivity = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.SystemCenter.Orchestrator.RunbookAutomationActivity$) -filter 'ID -eq RB30579'
        $WorkItemGUID = $RunbookActivity.get_id()

        Get-SCSMWorkItemParent -WorkItemGUID $WorkItemGUID

    .EXAMPLE
        $RunbookActivity = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.SystemCenter.Orchestrator.RunbookAutomationActivity$) -filter 'ID -eq RB30579'
        Get-SCSMWorkItemParent -WorkItemObject $RunbookActivity

    .NOTES
        Francois-Xavier.Cat
        @lazywinadmin
        lazywinadmin.com

        1.0 Function based on the work from Prosum and Cireson consultants
    .LINK
        https://github.com/lazywinadmin/PowerShell
    #>
    [CmdletBinding()]
    PARAM (
        [Parameter(ParameterSetName = 'GUID', Mandatory)]
        [Alias('ID')]
        $WorkItemGUID,

        [Parameter(ParameterSetName = 'Object', Mandatory)]
        $WorkItemObject
    )
    BEGIN {
        IF (-not (Get-Module -Name Smlets)) {
            TRY {
                Import-Module -Name smlets -ErrorAction Stop
            }
            CATCH {
                Write-Error -Message "[BEGIN] Error importing smlets"
                $Error[0].Exception.Message
            }
        }
        ELSE { Write-Verbose -Message "[BEGIN] Smlets module already loaded" }
    }
    PROCESS {
        TRY {
            IF ($PSBoundParameters['WorkItemGUID']) {
                # Retrieve the Activity Object in SCSM
                Write-Verbose -Message "[PROCESS] Retrieving WorkItem with GUID"
                $ActivityObject = Get-SCSMObject -id $WorkItemGUID
            }
            IF ($PSBoundParameters['WorkItemObject']) {
                # Retrieve the Activity Object in SCSM
                Write-Verbose -Message "[PROCESS] Retrieving WorkItem with SM Object"
                $ActivityObject = Get-SCSMObject -id $WorkItemObject.get_id()
            }

            # Retrieve Parent
            Write-Verbose -Message "[PROCESS] Activity: $($ActivityObject.name)"
            Write-Verbose -Message "[PROCESS] Retrieving WorkItem Parent"
            $ParentRelationshipID = '2da498be-0485-b2b2-d520-6ebd1698e61b'
            $ParentRelatedObject = Get-SCSMRelationshipObject -ByTarget $ActivityObject | Where-Object -FilterScript { $_.RelationshipId -eq $ParentRelationshipID }
            $ParentObject = $ParentRelatedObject.SourceObject

            Write-Verbose -Message "[PROCESS] Activity: $($ActivityObject.name) - Parent: $($ParentObject.name)"


            If ($ParentObject.ClassName -eq 'System.WorkItem.ServiceRequest' -OR $ParentObject.ClassName -eq 'System.WorkItem.ChangeRequest' -OR $ParentObject.ClassName -eq 'System.WorkItem.ReleaseRecord' -OR $ParentObject.ClassName -eq 'System.WorkItem.Incident') {
                Write-Verbose -Message "[PROCESS] This is the top level parent"
                Write-Output $ParentObject

                # Could do the following to retrieve all the properties
                # Get-SCSMObject $ParentRelatedObject.SourceObject.id.Guid
            }
            Else {
                Write-Verbose -Message "[PROCESS] Not the top level parent. Running Get-SCSMWorkItemParent against this object"
                # Loop to find the highest parent
                Get-SCSMWorkItemParent -WorkItemGUID $ParentObject.id.guid
            }
        }
        CATCH {
            Write-Error -Message $Error[0].Exception.Message
        }
    } #PROCESS
    END {
        Remove-Module -Name smlets -ErrorAction SilentlyContinue
    }#End
} #Function