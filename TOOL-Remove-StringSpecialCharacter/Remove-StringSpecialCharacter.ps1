function Remove-StringSpecialCharacter
{
<#
	.SYNOPSIS
		This function will remove the special character from a string.
		
	.DESCRIPTION
		This function will remove the special character from a string.
        I'm using Unicode Regular Expressions with the following categories
        \p{L} : any kind of letter from any language.
        \p{Nd} : a digit zero through nine in any script except ideographic 
        
        http://www.regular-expressions.info/unicode.html
        http://unicode.org/reports/tr18/
	
	.PARAMETER String
		Specifies the String on which the special character will be removed
    
    .SpecialCharacterToKeep
        Specifies the special character to keep in the output
	
	.EXAMPLE
        PS C:\> Remove-StringSpecialCharacter -String "^&*@wow*(&(*&@"
        wow
    .EXAMPLE
		PS C:\> Remove-StringSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*"
		
		wow
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
		
		[Alias("Keep")]
		[ValidateNotNullOrEmpty()]
		[String[]]$SpecialCharacterToKeep
	)
	PROCESS
	{
		IF ($PSBoundParameters["SpecialCharacterToKeep"])
		{
			Foreach ($Character in $SpecialCharacterToKeep)
			{
				#$Regex += "[^\w\.$character"
				$Regex += "[^\p{L}\p{Nd}\.$character"
			}
			
			#$Regex += "]"
			$Regex += "]+"
		} #IF($PSBoundParameters["SpecialCharacterToKeep"])
		#ELSE {$Regex = "[^\w\.]"}
		ELSE { $Regex = "[^\p{L}\p{Nd}]+" }
		
		$String -replace $regex, ""
	} #PROCESS
}
