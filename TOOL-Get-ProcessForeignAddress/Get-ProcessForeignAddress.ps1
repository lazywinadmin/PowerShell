function Get-ProcessForeignAddress
{
<#
.SYNOPSIS
	Get all foreignIPAddress for all or specific processname

.DESCRIPTION
	Get all foreignIPAddress for all or specific processname

.PARAMETER ProcessName
	Specifies the ProcessName to filter on

.EXAMPLE
	Get-ProcessForeignAddress

	Retrieve all the foreign addresses

.EXAMPLE
	Get-ProcessForeignAddress chrome

	Show all the foreign address(es) for the process chrome

.EXAMPLE
	Get-ProcessForeignAddress chrome | select ForeignAddress -Unique

	Show all the foreign address(es) for the process chrome and show only the ForeignAddress(es) once

.NOTES
	Author	: Francois-Xavier Cat
	Website	: www.lazywinadmin.com
	Github	: github.com/lazywinadmin
	Twitter	: @lazywinadm
#>
	PARAM ($ProcessName)
	$netstat = netstat -no

	$Result = $netstat[4..$netstat.count] |
	ForEach-Object {
		$current = $_.trim() -split '\s+'

		New-Object -TypeName PSobject -Property @{
			ProcessName = (Get-Process -id $current[4]).processname
			ForeignAddressIP = ($current[2] -split ":")[0] #-as [ipaddress]
			ForeignAddressPort = ($current[2] -split ":")[1]
			State = $current[3]
		}
	}

	if ($ProcessName)
	{
		$result | Where-Object { $_.processname -like "$processname" }
	}
	else { $Result }
}