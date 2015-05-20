function Remove-StringSpecialCharacter
{
<#
	.SYNOPSIS
		This function will remove the special character from a string.
		
	.DESCRIPTION
		This function will remove the special character from a string.
        I am using the regular expression "\w"  which means "any word character"
        which usually means alphanumeric (letters, numbers, regardless of case) plus underscore (_)
	
	.PARAMETER String
		Specifies the String on which the special character will be removed
    
    .SpecialCharacterToKeep
        Specifies the special character to keep in the output
	
	.EXAMPLE
		PS C:\> Remove-StringSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*"
		
		wow_

    .EXAMPLE
        PS C:\> Remove-StringSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*" -SpecialCharacterToKeep "*","_","-"

        wow-_*
	
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
		[ValidateNotNullOrEmpty()]
		[String[]]$SpecialCharacterToKeep
	)
	BEGIN
	{
		Foreach ($Character in $SpecialCharacterToKeep)
		{
			$Regex += "[^\w\.$character"
		}
		$Regex += "]"
	}
	PROCESS
	{
		$String -replace $regex, ""
	}
}