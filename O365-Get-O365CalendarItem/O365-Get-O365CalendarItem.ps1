function Get-O365CalendarItem
{
<#
	.SYNOPSIS
		Function to gather Calendar Items between two specific dates
	
	.DESCRIPTION
		Function to gather Calendar Items between two specific dates
		It is using the REST API available against Office365
	
	.PARAMETER EmailAddress
		Specifies the mailbox email address to query
        Example: info@lazywinadmin.com
	
	.PARAMETER StartDateTime
		Specifies the Start Date Time
        The UTC date and time when the event starts. (datetimeoffset)
        Default is now.
	
	.PARAMETER EndDateTime
		Specifies the End Date Time
	    The UTC date and time when the event ends. (datetimeoffset)
        Default is next week (7 days).
	
	.PARAMETER Credential
		Specifies alternative credentials
        By default it will use the current user.
	
	.EXAMPLE
		PS C:\> Get-O365CalendarItem -EmailAddress info@lazywinadmin.com -Credential $cred | Select-Object -Property Subject, StartTimeZone, Start, End, @{L="Attendees";E={$psitem.attendees.emailaddress | Select-Object -Property name -Unique|Sort}}
        
        Get the calendar Items Subject, StartTimeZone,Start, End, Attendees for the last 7 days
	.NOTES
		https://msdn.microsoft.com/office/office365/api/calendar-rest-operations
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(Mandatory)]
		[String]$EmailAddress,
		
		[String]$StartDateTime = $((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddThh:mm:ssZ")),
		
		[String]$EndDateTime = $((Get-Date).ToUniversalTime().AddDays(7).ToString("yyyy-MM-ddThh:mm:ssZ")),
		
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
	PROCESS
	{
		$Splatting = @{
			Credential = $Credential
			Uri = "https://outlook.office365.com/api/v1.0/users/$EmailAddress/calendarview?startDateTime=$StartDateTime&endDateTime=$EndDateTime"
		}
		
		Invoke-RestMethod @Splatting | Select-Object -ExpandProperty Value
	}
}

# Subject, StartTimeZone,Start, End, Attendees
Get-O365CalendarItem -Email info@lazywinadmin.com |
Select-Object -Property Subject, StartTimeZone, Start, End, @{ L = "Attendees"; E = { $psitem.attendees.emailaddress | Select-Object -Property name -Unique | Sort } }
