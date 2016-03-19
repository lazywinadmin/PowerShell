function Get-PerforceLog
{
<#
	.SYNOPSIS
		Function to parse the Perforce Log
	
	.DESCRIPTION
		Function to parse the Perforce Log
	
	.PARAMETER LiteralPath
		Specifies the Literal path of the log file to parse
	
	.PARAMETER Match
		Specifies the string to search
	
	.EXAMPLE
		Get-PerforceLog -Literalpath c:\perforce\log
	
	.EXAMPLE
		Get-PerforceLog -Literalpath c:\perforce\log Match 10.100.1.1
	
		Parse the log and only retrieve entries that contains the IP 10.100.1.1
	
	.EXAMPLE
		Get-PerforceLog -Literalpath c:\perforce\log -Match 1045
	
		Parse the log and only retrieve entries that contains the PID 1045
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	[OutputType([psobject])]
	param
	(
		[parameter(Mandatory)]
		[ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
		[ValidateNotNullOrEmpty()]
		[string]$LiteralPath ,
		
		[String]$Match
	)
	
	# Define function to convert the UnixDate to standard date
	Function Convert-FromUnixdate ($UnixDate)
	{
		[timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate))
	}
	
	# Create a StreamReader object
	#  Fortunately this .NET Framework called System.IO.StreamReader allows you to read text files a line at a time which is important when you' re dealing with huge log files :-)
	$StreamReader = New-object -TypeName System.IO.StreamReader -ArgumentList (Resolve-Path -Path $LiteralPath -ErrorAction Stop).Path
	
	Write-Verbose -Message "[PROCESS] Reading Stream from file: $Path"
	
	# .Peek() Method: An integer representing the next character to be read, or -1 if no more characters are available or the stream does not support seeking.
	while ($StreamReader.Peek() -gt -1)
	{
		# Read the next line
		#  .ReadLine() method: Reads a line of characters from the current stream and returns the data as a string.
		$Line = $StreamReader.ReadLine()
		
		IF (-not $PSBoundParameters['Match'])
		{
			#  Ignore empty line and line starting with a #
			if ($Line.length -eq 0 -or $Line -match "^#" -or $Line -match 'Perforce server info:')
			{
				continue
			}
			
			# Split the line on $Delimiter
			$result = ($Line -split ' ').trim()
			$Status = if ($result[4] -notmatch '@') { $result[4] }
			else { "NA" }
			$Duration = if ($result[4] -notmatch '@') { $result[5] }
			else { "NA" }
			$Username = if ($result[4] -match '@') { ($result[4] -split '\@')[0] }
			else { "NA" }
			$Workspace = if ($result[4] -match '@') { ($result[4] -split '\@')[1] }
			else { "NA" }
			$IPAddress = if ($result[4] -match '@') { ($result[5]) }
			else { "NA" }
			$Client = if ($result[4] -match '@') { ($result[6]) }
			else { "NA" }
			$Command = if ($result[4] -match '@') { ($result[7..$result.Count] -as [string]) }
			else { "NA" }
			
			
			[pscustomobject][ordered]@{
				DateTime = $result[0..1] -as [string] -as [datetime]
				PID = $result[3]
				Status = $Status
				Duration = $Duration
				Username = $Username
				Workspace = $Workspace
				IPAddress = $IPAddress
				Client = $Client
				Command = $Command
				Line = $Line.trim()
			}
		}
		IF ($PSBoundParameters['Match'])
		{
			IF ($Line -match $Match)
			{
				#  Ignore empty line and line starting with a #
				if ($Line.length -eq 0 -or $Line -match "^#" -or $Line -match 'Perforce server info:')
				{
					continue
				}
				
				# Split the line on $Delimiter
				$result = ($Line -split ' ').trim()
				$Status = if ($result[4] -notmatch '@') { $result[4] }
				else { "NA" }
				$Duration = if ($result[4] -notmatch '@') { $result[5] }
				else { "NA" }
				$Username = if ($result[4] -match '@') { ($result[4] -split '\@')[0] }
				else { "NA" }
				$Workspace = if ($result[4] -match '@') { ($result[4] -split '\@')[1] }
				else { "NA" }
				$IPAddress = if ($result[4] -match '@') { ($result[5]) }
				else { "NA" }
				$Client = if ($result[4] -match '@') { ($result[6]) }
				else { "NA" }
				$Command = if ($result[4] -match '@') { ($result[7..$result.Count] -as [string]) }
				else { "NA" }
				
				
				[pscustomobject][ordered]@{
					DateTime = $result[0..1] -as [string] -as [datetime]
					PID = $result[3]
					Status = $Status
					Duration = $Duration
					Username = $Username
					Workspace = $Workspace
					IPAddress = $IPAddress
					Client = $Client
					Command = $Command
					Line = $Line.trim()
				}
				
			}
			
			
		}
	}
	# Close Reader
	$StreamReader.Close()
}