function Get-PerforceTicket
{
<#
	.SYNOPSIS
		Function to display all tickets granted to a user by p4 login.
	
	.DESCRIPTION
		Function to display all tickets granted to a user by p4 login.
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	param ()
	
	$Ticket = p4 tickets
	
	foreach ($Tick in $Ticket)
	{
		$TicketSplit = $Tick -split '\s'
		
		[pscustomobject][ordered]@{
			Server = ($TicketSplit[0] -split ':')[0]
			Port = ($TicketSplit[0] -split ':')[1]
			Username = $TicketSplit[1] -replace '[()]', ''
			ID = $TicketSplit[2]
		}
	}
}
