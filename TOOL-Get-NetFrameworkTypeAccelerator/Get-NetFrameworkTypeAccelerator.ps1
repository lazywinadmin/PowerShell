function Get-NetFrameworkTypeAccelerator
{
<#
.SYNOPSIS 
	Function to retrieve the list of Type Accelerator available
.EXAMPLE
	Get-NetFrameworkTypeAccelerator

	Return the list of Type Accelerator available on your system
.EXAMPLE
	Get-Accelerator

	Return the list of Type Accelerator available on your system
	This is a function alias created by [Alias()]
.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin
#>
	[Alias('Get-Acceletrator')]
	PARAM ()
	[System.Management.Automation.PSObject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::get
}