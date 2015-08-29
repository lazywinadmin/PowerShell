function Get-O365CalendarEvent
{
<#
	.SYNOPSIS
		Function to gather Calendar Events between two specific dates
	
	.DESCRIPTION
		Function to gather Calendar Events between two specific dates
		It is using the REST API available against Office365
	
	.PARAMETER EmailAddress
		Specifies the mailbox email address to query.
		Default is the current user
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
		PS C:\> Get-O365CalendarEvent
	
		Get the calendar Events of the next coming week for the current user.
	
	.EXAMPLE
		PS C:\> Get-O365CalendarEvent -EmailAddress info@lazywinadmin.com -Credential (Get-Credential) | Select-Object -Property Subject, StartTimeZone, Start, End, @{L="Attendees";E={$psitem.attendees.emailaddress | Select-Object -Property name -Unique|Sort}}
        
        Get the calendar Events Subject, StartTimeZone,Start, End, Attendees for the last 7 days
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
		
		https://msdn.microsoft.com/office/office365/api/calendar-rest-operations
#>
	[CmdletBinding()]
	PARAM (
		[String]$EmailAddress,
		
		[datetime]$StartDateTime = (Get-Date),
		
		[datetime]$EndDateTime = ((Get-Date).adddays(7)),
		
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
	PROCESS
	{
		$Splatting = @{
			Credential = $Credential
			Uri = "https://outlook.office365.com/api/v1.0/users/$EmailAddress/calendarview?startDateTime=$StartDateTime&endDateTime=$EndDateTime"
		}
		if (-not $PSBoundParameters['EmailAddress'])
		{
			#Query the current User
			$Splatting.Uri = "https://outlook.office365.com/api/v1.0/me/calendarview?startDateTime=$StartDateTime&endDateTime=$EndDateTime"
		}
		Invoke-RestMethod @Splatting | Select-Object -ExpandProperty Value
	}
}
