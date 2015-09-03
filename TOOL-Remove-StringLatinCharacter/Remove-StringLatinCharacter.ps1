function Remove-StringLatinCharacters
{
	#http://www.lazywinadmin.com/2015/05/powershell-remove-diacritics-accents.html
	#Method 2 (From Marcin Krzanowicz)
	PARAM ([string]$String)
	[Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($String))
}