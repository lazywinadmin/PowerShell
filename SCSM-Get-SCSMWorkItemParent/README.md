[GetSCSMWorkItemParent01]: https://github.com/lazywinadmin/PowerShell/blob/master/SCSM-Get-SCSMWorkItemParent/images/Get-SCSMWorkItemParent01.jpg
[GetSCSMWorkItemParent02]: https://github.com/lazywinadmin/PowerShell/blob/master/SCSM-Get-SCSMWorkItemParent/images/Get-SCSMWorkItemParent02.jpg
[GetSCSMWorkItemParent03]: https://github.com/lazywinadmin/PowerShell/blob/master/SCSM-Get-SCSMWorkItemParent/images/Get-SCSMWorkItemParent03.jpg
# Get-SCSMWorkItemParent

## Loading the function

```PowerShell
# Load the function in your PS
. .\Get-SCSMWorkItemParent.ps1
```

![alt text][GetSCSMWorkItemParent01]

## Get the Work Item Parent of a Runbook Activity

```PowerShell
# Load the function in your PS
# Get a Runbook Activity
$RunbookActivity = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.SystemCenter.Orchestrator.RunbookAutomationActivity$) -filter 'ID -eq RB12813'

# Get the Runbook Activity's Work Item Parent
Get-SCSMWorkItemParent -WorkItemObject $RunbookActivity
```

![alt text][GetSCSMWorkItemParent02]


## Get the Work Item Parent of a Runbook Activity using a GUID

```PowerShell
# Load the function in your PS
# Get a Runbook Activity GUID
$RunbookActivity.get_id()

# Get the Runbook Activity's Work Item Parent from the RBA guid
Get-SCSMWorkItemParent -WorkItemGuid $RunbookActivity.Get_id()
```

![alt text][GetSCSMWorkItemParent03]
