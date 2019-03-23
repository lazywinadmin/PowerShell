function Resolve-ShortURL
{
<#
.SYNOPSIS
	Function to resolve a short URL to the absolute URI

.DESCRIPTION
	Function to resolve a short URL to the absolute URI

.PARAMETER ShortUrl
	Specifies the ShortURL

.EXAMPLE
	Resolve-ShortURL -ShortUrl http://goo.gl/P5PKq

.EXAMPLE
	Resolve-ShortURL -ShortUrl http://go.microsoft.com/fwlink/?LinkId=280243

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin
#>

	[CmdletBinding()]
	[OutputType([System.String])]
	PARAM
	(
		[String[]]$ShortUrl
	)

	FOREACH ($URL in $ShortUrl)
	{
		TRY
		{
			Write-Verbose -Message "$URL - Querying..."
			(Invoke-WebRequest -Uri $URL -MaximumRedirection 0 -ErrorAction Ignore).Headers.Location
		}
		CATCH
		{
			Write-Error -Message $Error[0].Exception.Message
		}
	}
}
