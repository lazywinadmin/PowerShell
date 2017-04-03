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

.PARAMETER Timezone
    Specify the timezone
    Complete list available here https://technet.microsoft.com/en-us/library/cc749073(v=ws.10).aspx

.PARAMETER Credential
	Specifies alternative credentials
	By default it will use the current user.
	
.PARAMETER PageResult
	Specifies the number of items to return. Max is 50.
	
.EXAMPLE
	PS C:\> Get-O365CalendarEvent
		
	Get the calendar Events of the next coming week for the current user.
	
.EXAMPLE
	PS C:\> Get-O365CalendarEvent -EmailAddress info@lazywinadmin.com -Credential (Get-Credential) | Select-Object -Property Subject, StartTimeZone, Start, End, @{L="Attendees";E={$psitem.attendees.emailaddress | Select-Object -Property name -Unique|Sort}}
		
	Get the calendar Events Subject, StartTimeZone,Start, End, Attendees for the last 7 days
	
.EXAMPLE
	Get-O365CalendarEvent -EmailAddress info@lazywinadmin.com -Credential $cred -StartDateTime $((Get-Date).adddays(-50)) -PageResult 15
	
.NOTES
	Francois-Xavier Cat
	www.lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin
		
	# More about the Calendar operations
	https://msdn.microsoft.com/office/office365/api/calendar-rest-operations
		
	# Filter/Sorting/Top/Order
	https://msdn.microsoft.com/office/office365/APi/complex-types-for-mail-contacts-calendar#UseODataqueryparametersPageresults
    
    VERSION HISTORY
        1.0 | 2015/06/00 | Francois-Xavier Cat (lazywinadmin.com)
            Initial version
        1.1 | 2016/06/21 | Stephane van Gulick - (PowerShellDistrict.com)
            Added Headers Property 'timeZone' to fit the display gap that could happen between an actual event an the current timeZone.
        1.2 | 2017/04/02 | Francois-Xavier Cat (lazywinadmin.com)
            Add all the timezones in the ValidateSet of $TimeZone
			Add TRY/CATCH and Error handler
			Add some Verbose messages
#>
	
	[CmdletBinding()]
	param
	(
		[System.String]$EmailAddress,
		
		[System.datetime]$StartDateTime = (Get-Date),
		
		[System.datetime]$EndDateTime = ((Get-Date).adddays(7)),
		
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[ValidateNotNullOrEmpty()]
		[ValidateRange(1, 50)]
		$PageResult = '10',
		
		[ValidateSet(
			'Afghanistan Standard Time',
			'Alaskan Standard Time',
			'Arab Standard Time',
			'Arabian Standard Time',
			'Arabic Standard Time',
			'Atlantic Standard Time',
			'AUS Central Standard Time',
			'AUS Eastern Standard Time',
			'Azerbaijan Standard Time',
			'Azores Standard Time',
			'Canada Central Standard Time',
			'Cape Verde Standard Time',
			'Caucasus Standard Time',
			'Cen. Australia Standard Time',
			'Central America Standard Time',
			'Central Asia Standard Time',
			'Central Brazilian Standard Time',
			'Central Europe Standard Time',
			'Central European Standard Time',
			'Central Pacific Standard Time',
			'Central Standard Time',
			'Central Standard Time (Mexico)',
			'China Standard Time',
			'Dateline Standard Time',
			'E. Africa Standard Time',
			'E. Australia Standard Time',
			'E. Europe Standard Time',
			'E. South America Standard Time',
			'Eastern Standard Time',
			'Egypt Standard Time',
			'Ekaterinburg Standard Time',
			'Fiji Standard Time', 'FLE Standard Time',
			'Georgian Standard Time',
			'GMT Standard Time',
			'Greenland Standard Time',
			'Greenwich Standard Time',
			'GTB Standard Time',
			'Hawaiian Standard Time',
			'India Standard Time',
			'Iran Standard Time',
			'Israel Standard Time',
			'Korea Standard Time',
			'Mid-Atlantic Standard Time',
			'Mountain Standard Time',
			'Mountain Standard Time (Mexico)',
			'Myanmar Standard Time',
			'N. Central Asia Standard Time',
			'Namibia Standard Time',
			'Nepal Standard Time',
			'New Zealand Standard Time',
			'Newfoundland Standard Time',
			'North Asia East Standard Time',
			'North Asia Standard Time',
			'Pacific SA Standard Time',
			'Pacific Standard Time',
			'Romance Standard Time',
			'Russian Standard Time',
			'SA Eastern Standard Time',
			'SA Pacific Standard Time',
			'SA Western Standard Time',
			'Samoa Standard Time',
			'SE Asia Standard Time',
			'Singapore Standard Time',
			'South Africa Standard Time',
			'Sri Lanka Standard Time',
			'Taipei Standard Time',
			'Tasmania Standard Time',
			'Tokyo Standard Time',
			'Tonga Standard Time',
			'US Eastern Standard Time',
			'US Mountain Standard Time',
			'Vladivostok Standard Time',
			'W. Australia Standard Time',
			'W. Central Africa Standard Time',
			'W. Europe Standard Time',
			'West Asia Standard Time',
			'West Pacific Standard Time',
			'Yakutsk Standard Time'
		)]
		[System.String]$Timezone
	)
	
	PROCESS
	{
		TRY
		{
			$ScriptName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).MyCommand
			
			Write-Verbose -Message "[$ScriptName] Create splatting"
			$Splatting = @{
				Credential = $Credential
				Uri = "https://outlook.office365.com/api/v1.0/users/$EmailAddress/calendarview?startDateTime=$StartDateTime&endDateTime=$($EndDateTime)&`$top=$PageResult"
			}
			
			
			if ($TimeZone)
			{
				Write-Verbose -Message "[$ScriptName] Add TimeZone"
				$headers = New-Object -TypeName 'System.Collections.Generic.Dictionary[[String],[String]]'
				$headers.Add('Prefer', "outlook.timezone=`"$TimeZone`"")
				$Splatting.Add('Headers', $headers)
			}
			if (-not $PSBoundParameters['EmailAddress'])
			{
				Write-Verbose -Message "[$ScriptName] EmailAddress not specified, updating URI"
				#Query the current User
				$Splatting.Uri = "https://outlook.office365.com/api/v1.0/me/calendarview?startDateTime=$StartDateTime&endDateTime=$($EndDateTime)&`$top=$PageResult"
			}
			Write-Verbose -Message "[$ScriptName] URI: $($Splatting.Uri)"
			Invoke-RestMethod @Splatting -ErrorAction Stop | Select-Object -ExpandProperty Value
		}
		CATCH
		{
			$PSCmdlet.ThrowTerminatingError($_)	
		}
	}
}