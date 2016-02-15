Function Check-PerforceUserExist
{
	PARAM ($UserName)
	PROCESS
	{
		$CheckAccount = p4 users $UserName
		if ($CheckAccount -like "*accessed*")
		{
			$CheckAccount = $CheckAccount -split '\s'
			
			$Properties = @{
				"UserName" = $CheckAccount[0]
				"Email" = $CheckAccount[1] -replace "<|>", ""
				"PerforceAccount" = $CheckAccount[2] -replace "\(|\)", ""
			}
			New-Object -TypeName PSObject -Property $Properties
		} #IF
	}
}