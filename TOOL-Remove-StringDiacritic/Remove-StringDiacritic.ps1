function Remove-StringDiacritic
{
<#
	.SYNOPSIS
		This function will remove the diacritics (accents) characters from a string.
		
	.DESCRIPTION
		This function will remove the diacritics (accents) characters from a string.
	
	.PARAMETER String
		Specifies the String on which the diacritics need to be removed
	
	.PARAMETER NormalizationForm
		Specifies the normalization form to use
		https://msdn.microsoft.com/en-us/library/system.text.normalizationform(v=vs.110).aspx
	
	.EXAMPLE
		PS C:\> Remove-StringDiacritic "L'été de Raphaël"
		
		L'ete de Raphael
	
	.NOTES
		Francois-Xavier Cat
		@lazywinadm
		www.lazywinadmin.com
#>
	
	param
	(
		[ValidateNotNullOrEmpty()]
		[Alias('Text')]
		[System.String]$String,
		[System.Text.NormalizationForm]$NormalizationForm = "FormD"
	)
	
	BEGIN
	{
		$Normalized = $String.Normalize($NormalizationForm)
		$NewString = New-Object -TypeName System.Text.StringBuilder
		
	}
	PROCESS
	{
		$normalized.ToCharArray() | ForEach-Object -Process {
			if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($psitem) -ne [Globalization.UnicodeCategory]::NonSpacingMark)
			{
				[void]$NewString.Append($psitem)
			}
		}
	}
	END
	{
		Write-Output $($NewString -as [string])
	}
}