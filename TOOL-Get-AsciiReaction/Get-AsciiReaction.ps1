function Get-AsciiReaction
{
<#

	.SYNOPSIS

	Displays Ascii for different reactions and copies it to clipboard.

	.DESCRIPTION

	Displays Ascii for different reactions and copies it to clipboard.

	.EXAMPLE

	Get-AsciiReaction -Name Shrug

	Displays a shurg and copies it to clipboard.

	.NOTES

	Based on Reddit Thread https://www.reddit.com/r/PowerShell/comments/4aipw5/%E3%83%84/
	and Matt Hodge function: https://github.com/MattHodge/MattHodgePowerShell/blob/master/Fun/Get-Ascii.ps1
#>
	[cmdletbinding()]
	Param
	(
		# Name of the Ascii 
		[Parameter()]
		[ValidateSet(
					 'Shrug',
					 'Disapproval',
					 'TableFlip',
					 'TableBack',
					 'TableFlip2',
					 'TableBack2',
					 'TableFlip3',
					 'Denko',
					 'BlowKiss',
					 'Lenny',
					 'Angry',
					 'DontKnow')]
		[string]$Name
	)

	$OutputEncoding = [System.Text.Encoding]::unicode

	# Function to write ascii to screen as well as clipboard it
	function Write-Ascii
	{
		[CmdletBinding()]
		Param
		(
			# Ascii Data
			[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
			[string]$Ascii
		)

		# Clips it without the newline
		Add-Type -Assembly PresentationCore
		$clipText = ($Ascii).ToString() | Out-String -Stream
		[Windows.Clipboard]::SetText($clipText)

		Write-Output $clipText
	}

	Switch ($Name)
	{
		'Shrug' { [char[]]@(175, 92, 95, 40, 12484, 41, 95, 47, 175) -join '' | Write-Ascii }
		'Disapproval' { [char[]]@(3232, 95, 3232) -join '' | Write-Ascii }
		'TableFlip' { [char[]]@(40, 9583, 176, 9633, 176, 65289, 9583, 65077, 32, 9531, 9473, 9531, 41) -join '' | Write-Ascii }
		'TableBack' { [char[]]@(9516, 9472, 9472, 9516, 32, 175, 92, 95, 40, 12484, 41) -join '' | Write-Ascii }
		'TableFlip2' { [char[]]@(9531, 9473, 9531, 32, 65077, 12541, 40, 96, 1044, 180, 41, 65417, 65077, 32, 9531, 9473, 9531) -join '' | Write-Ascii }
		'TableBack2' { [char[]]@(9516, 9472, 9516, 12494, 40, 32, 186, 32, 95, 32, 186, 12494, 41) -join '' | Write-Ascii }
		'TableFlip3' { [char[]]@(40, 12494, 3232, 30410, 3232, 41, 12494, 24417, 9531, 9473, 9531) -join '' | Write-Ascii }
		'Denko' { [char[]]@(40, 180, 65381, 969, 65381, 96, 41) -join '' | Write-Ascii }
		'BlowKiss' { [char[]]@(40, 42, 94, 51, 94, 41, 47, 126, 9734) -join '' | Write-Ascii }
		'Lenny' { [char[]]@(40, 32, 865, 176, 32, 860, 662, 32, 865, 176, 41) -join '' | Write-Ascii }
		'Angry' { [char[]]@(40, 65283, 65439, 1044, 65439, 41) -join '' | Write-Ascii }
		'DontKnow' { [char[]]@(9488, 40, 39, 65374, 39, 65307, 41, 9484) -join '' | Write-Ascii }
		default
		{
			[PSCustomObject][ordered]@{
				'Shrug' = [char[]]@(175, 92, 95, 40, 12484, 41, 95, 47, 175) -join '' | Write-Ascii
				'Disapproval' = [char[]]@(3232, 95, 3232) -join '' | Write-Ascii
				'TableFlip' = [char[]]@(40, 9583, 176, 9633, 176, 65289, 9583, 65077, 32, 9531, 9473, 9531, 41) -join '' | Write-Ascii
				'TableBack' = [char[]]@(9516, 9472, 9472, 9516, 32, 175, 92, 95, 40, 12484, 41) -join '' | Write-Ascii 
				'TableFlip2' = [char[]]@(9531, 9473, 9531, 32, 65077, 12541, 40, 96, 1044, 180, 41, 65417, 65077, 32, 9531, 9473, 9531) -join '' | Write-Ascii 
				'TableBack2' = [char[]]@(9516, 9472, 9516, 12494, 40, 32, 186, 32, 95, 32, 186, 12494, 41) -join '' | Write-Ascii 
				'TableFlip3' = [char[]]@(40, 12494, 3232, 30410, 3232, 41, 12494, 24417, 9531, 9473, 9531) -join '' | Write-Ascii 
				'Denko' = [char[]]@(40, 180, 65381, 969, 65381, 96, 41) -join '' | Write-Ascii 
				'BlowKiss' = [char[]]@(40, 42, 94, 51, 94, 41, 47, 126, 9734) -join '' | Write-Ascii 
				'Lenny' = [char[]]@(40, 32, 865, 176, 32, 860, 662, 32, 865, 176, 41) -join '' | Write-Ascii 
				'Angry' = [char[]]@(40, 65283, 65439, 1044, 65439, 41) -join '' | Write-Ascii 
				'DontKnow' = [char[]]@(9488, 40, 39, 65374, 39, 65307, 41, 9484) -join '' | Write-Ascii 
			}
		}
	}
}
