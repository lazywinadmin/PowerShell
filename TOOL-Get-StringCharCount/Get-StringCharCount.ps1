Function Get-StringCharCount
{
	<#
	.SYNOPSIS
		This function will count the number of characters in a string
	.DESCRIPTION
		This function will count the number of characters in a string
	.EXAMPLE
		PS C:\> Get-StringCharCount -String "Hello World"

		11
	.NOTES
		Francois-Xavier Cat
		@lazywinadm
		www.lazywinadmin.com	
	#>
	PARAM ([String]$String)
	($String -as [Char[]]).count
}