function ConvertFrom-Base64
{
	<#
	.SYNOPSIS
		Converts the specified string, which encodes binary data as base-64 digits, to an equivalent 8-bit unsigned integer array.

	.DESCRIPTION
		Converts the specified string, which encodes binary data as base-64 digits, to an equivalent 8-bit unsigned integer array.

	.PARAMETER String
		Specifies the String to Convert

	.EXAMPLE
		ConvertFrom-Base64 -String $ImageBase64 |Out-File ImageTest.png

	.NOTES
		Francois-Xavier Cat
		@lazywinadm
		www.lazywinadmin.com
		github.com/lazywinadmin
#>
	[CmdletBinding()]
	PARAM (
		[parameter(Mandatory = $true, ValueFromPipeline)]
		[String]$String
	)
	TRY
	{
		Write-Verbose -Message "[ConvertFrom-Base64] Converting String"
		[System.Text.Encoding]::Default.GetString(
		[System.Convert]::FromBase64String($String)
		)
	}
	CATCH
	{
		Write-Error -Message "[ConvertFrom-Base64] Something wrong happened"
		$Error[0].Exception.Message
	}
}
