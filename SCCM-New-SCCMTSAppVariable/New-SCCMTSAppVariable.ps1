Function New-SCCMTSAppVariable
{
	<#
	.SYNOPSIS
		Function to create a SCCM Task Sequence Application Variable during the OSD
	
	.PARAMETER BaseVariableName
		Specifies the "Base Variable Name" present in the task "Install Application" of the Task Sequence.
		(In the 'Install application according to dynamic variable list' section)
	
	.PARAMETER ApplicationList
		Specifies the list of application to install.
		Those must match the SCCM Application name to install
	
	.EXAMPLE
		New-SCCMTSVariable -BaseVariableName "FX" -ApplicationList "Photoshop","AutoCad"
	
	.EXAMPLE
		New-SCCMTSVariable -BaseVariableName "FX" -ApplicationList $Variable
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
	#>
	
	PARAM ([String]$BaseVariableName,
		
		[String[]]$ApplicationList
	)
	
	BEGIN
	{
		$TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
	}
	PROCESS
	{
		
		$ApplicationCount = $ApplicationList.Count
		$Counter = 1
		
		$ApplicationList | ForEach-Object {
			$Variable = "$BaseVariableName{0:00}" -f $Counter
			$TSEnv.value("$Variable") = "$_"
			
			$Counter++| Out-Null	
		}
	}
}