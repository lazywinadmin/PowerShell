function Remove-StringSpecialCharacter {
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

.PARAMETER SpecialCharacterToKeep
    Specifies the special character to keep in the output

.EXAMPLE
    Remove-StringSpecialCharacter -String "^&*@wow*(&(*&@"
    wow

.EXAMPLE
    Remove-StringSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*"

    wow
.EXAMPLE
    Remove-StringSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*" -SpecialCharacterToKeep "*","_","-"
    wow-_*

.NOTES
    Francois-Xavier Cat
    @lazywinadmin
    lazywinadmin.com
    github.com/lazywinadmin
#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('Text')]
        [System.String[]]$String,

        [Alias("Keep")]
        #[ValidateNotNullOrEmpty()]
        [String[]]$SpecialCharacterToKeep
    )
    PROCESS {
        try {
            IF ($PSBoundParameters["SpecialCharacterToKeep"]) {
                $Regex = "[^\p{L}\p{Nd}"
                Foreach ($Character in $SpecialCharacterToKeep) {
                    IF ($Character -eq "-") {
                        $Regex += "-"
                    }
                    else {
                        $Regex += [Regex]::Escape($Character)
                    }
                    #$Regex += "/$character"
                }

                $Regex += "]+"
            } #IF($PSBoundParameters["SpecialCharacterToKeep"])
            ELSE { $Regex = "[^\p{L}\p{Nd}]+" }

            FOREACH ($Str in $string) {
                Write-Verbose -Message "Original String: $Str"
                $Str -replace $regex, ""
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    } #PROCESS
}
