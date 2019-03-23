function Remove-StringLatinCharacter
{
<#
.SYNOPSIS
    Function to remove diacritics from a string
.PARAMETER String
	Specifies the String that will be processed
.EXAMPLE
    Remove-StringLatinCharacter -String "L'été de Raphaël"

    L'ete de Raphael
.EXAMPLE
    Foreach ($file in (Get-ChildItem c:\test\*.txt))
    {
        # Get the content of the current file and remove the diacritics
        $NewContent = Get-content $file | Remove-StringLatinCharacter

        # Overwrite the current file with the new content
        $NewContent | Set-Content $file
    }

    Remove diacritics from multiple files

.NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadm
    github.com/lazywinadmin

    BLOG ARTICLE
        http://www.lazywinadmin.com/2015/05/powershell-remove-diacritics-accents.html

    VERSION HISTORY
        1.0.0.0 | Francois-Xavier Cat
            Initial version Based on Marcin Krzanowic code
        1.0.0.1 | Francois-Xavier Cat
            Added support for ValueFromPipeline
        1.0.0.2 | Francois-Xavier Cat
            Add Support for multiple String
            Add Error Handling
#>
    [CmdletBinding()]
	PARAM (
		[Parameter(ValueFromPipeline=$true)]
		[System.String[]]$String
		)
	PROCESS
	{
        FOREACH ($StringValue in $String)
        {
            Write-Verbose -Message "$StringValue"

            TRY
            {
                [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($StringValue))
            }
		    CATCH
            {
                Write-Error -Message $Error[0].exception.message
            }
        }
	}
}