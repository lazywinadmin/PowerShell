function Get-SCSMObjectPrefix
{
<#
	.SYNOPSIS
		Function to retrieve the Prefix used for the different WorkItem, Activities or Knowledge Article

	.DESCRIPTION
		Function to retrieve the Prefix used for the different WorkItem, Activities or Knowledge Article

	.PARAMETER ClassName
		Specified the ClassName you want to query

	.EXAMPLE
		Get-SCSMObjectPrefix

		DependentActivity         : DA
		ManualActivity            : MA
		ParallelActivity          : PA
		ReviewActivity            : RA
		RunbookAutomationActivity : RB
		SequentialActivity        : SA
		IncidentRequest           : IR
		ServiceRequest            : SR
		Change                    : CR
		Knowledge                 : KA
		Problem                   : PR
		Release                   : RR

	.EXAMPLE
		Get-SCSMObjectPrefix -ClassName Change

		CR

	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin
		@lazywinadm
		github.com/lazywinadmin
#>

	[OutputType([psobject])]
	param
	(
		[ValidateSet(
			   'DependentActivity',
			   'ManualActivity',
			   'ParallelActivity',
			   'ReviewActivity',
			   'RunbookAutomationActivity',
			   'SequentialActivity',
			   'IncidentRequest',
			   'ServiceRequest',
			   'Change',
			   'Knowledge',
			   'Problem',
			   'Release'
	)]
		[string]$ClassName
	)

	BEGIN
	{
		Import-Module -Name Smlets

		$ActivitySettingsObj = Get-SCSMObject -Class (Get-SCSMClass -Name "System.GlobalSetting.ActivitySettings")
		$ChangeSettingsObj = Get-SCSMObject -Class (Get-SCSMClass -Name "System.GlobalSetting.ChangeSettings")
		$KnowledgedSettingsObj = Get-SCSMObject -Class (Get-SCSMClass -Name "System.GlobalSetting.KnowledgeSettings")
		$ProblemSettingsObj = Get-SCSMObject -Class (Get-SCSMClass -Name "System.GlobalSetting.ProblemSettings")
		$ReleaseSettingsObj = Get-SCSMObject -Class (Get-SCSMClass -Name "System.GlobalSetting.ReleaseSettings")
		$ServiceRequestSettingsObj = Get-SCSMObject -Class (Get-SCSMClass -Name "System.GlobalSetting.ServiceRequestSettings")
		$IncidentRequestSettingsObj = Get-SCSMObject -Class (Get-SCSMClass -Name "System.WorkItem.Incident.GeneralSetting")
	}
	PROCESS
	{
		Switch ($ClassName)
		{
			"DependentActivity" { $ActivitySettingsObj.SystemWorkItemActivityDependentActivityIdPrefix }
			"ManualActivity" { $ActivitySettingsObj.SystemWorkItemActivityManualActivityIdPrefix }
			"ParallelActivity" { $ActivitySettingsObj.SystemWorkItemActivityParallelActivityIdPrefix }
			"ReviewActivity" { $ActivitySettingsObj.SystemWorkItemActivityReviewActivityIdPrefix }
			"RunbookAutomationActivity" { $ActivitySettingsObj.MicrosoftSystemCenterOrchestratorRunbookAutomationActivityBaseIdPrefix }
			"SequentialActivity" { $ActivitySettingsObj.SystemWorkItemActivitySequentialActivityIdPrefix }
			"IncidentRequest" { $IncidentRequestSettingsObj.PrefixForId }
			"ServiceRequest" { $ServiceRequestSettingsObj.ServiceRequestPrefix }
			"Change" { $ChangeSettingsObj.SystemWorkItemChangeRequestIdPrefix }
			"Knowledge" { $KnowledgedSettingsObj.SystemKnowledgeArticleIdPrefix }
			"Problem" { $ProblemSettingsObj.ProblemIdPrefix }
			"Release" { $ReleaseSettingsObj.SystemWorkItemReleaseRecordIdPrefix }
			default
			{
				[pscustomobject][ordered]@{
					"DependentActivity" = $ActivitySettingsObj.SystemWorkItemActivityDependentActivityIdPrefix
					"ManualActivity" = $ActivitySettingsObj.SystemWorkItemActivityManualActivityIdPrefix
					"ParallelActivity" = $ActivitySettingsObj.SystemWorkItemActivityParallelActivityIdPrefix
					"ReviewActivity" = $ActivitySettingsObj.SystemWorkItemActivityReviewActivityIdPrefix
					"RunbookAutomationActivity" = $ActivitySettingsObj.MicrosoftSystemCenterOrchestratorRunbookAutomationActivityBaseIdPrefix
					"SequentialActivity" = $ActivitySettingsObj.SystemWorkItemActivitySequentialActivityIdPrefix
					"IncidentRequest" = $IncidentRequestSettingsObj.PrefixForId
					"ServiceRequest" = $ServiceRequestSettingsObj.ServiceRequestPrefix
					"Change" = $ChangeSettingsObj.SystemWorkItemChangeRequestIdPrefix
					"Knowledge" = $KnowledgedSettingsObj.SystemKnowledgeArticleIdPrefix
					"Problem" = $ProblemSettingsObj.ProblemIdPrefix
					"Release" = $ReleaseSettingsObj.SystemWorkItemReleaseRecordIdPrefix
				}
			}
		}
	}
}
