function Expand-ScriptAlias {
    <#
    .SYNOPSIS
        Function to replace Aliases used in a script by their fullname

    .DESCRIPTION
        Function to replace Aliases used in a script by their fullname.
        Using PowerShell AST we are able to retrieve the functions and cmdlets used in a script.

    .PARAMETER Path
        Specifies the Path to the file.
        Alias: FullName

    .EXAMPLE
        "C:\LazyWinAdmin\testscript.ps1", "C:\LazyWinAdmin\testscript2.ps1" | Expand-ScriptAlias

    .EXAMPLE
        gci C:\LazyWinAdmin -File | Expand-ScriptAlias

    .EXAMPLE
        Expand-ScriptAlias -Path "C:\LazyWinAdmin\testscript.ps1"

    .EXAMPLE
        "C:\LazyWinAdmin\testscript.ps1", "C:\LazyWinAdmin\testscript2.ps1" | Expand-ScriptAlias -Confirm

    .EXAMPLE
        "C:\LazyWinAdmin\testscript.ps1", "C:\LazyWinAdmin\testscript2.ps1" | Expand-ScriptAlias -WhatIf

        What if: Performing the operation "Expand Alias: select to Select-Object (startoffset: 15)" on target "C:\LazyWinAdmin\testscript2.ps1".
        What if: Performing the operation "Expand Alias: sort to Sort-Object (startoffset: 10)" on target "C:\LazyWinAdmin\testscript2.ps1".
        What if: Performing the operation "Expand Alias: group to Group-Object (startoffset: 4)" on target "C:\LazyWinAdmin\testscript2.ps1".
        What if: Performing the operation "Expand Alias: gci to Get-ChildItem (startoffset: 0)" on target "C:\LazyWinAdmin\testscript2.ps1".

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    PARAM (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript( { Test-Path -Path $_ })]
        [Alias('FullName')]
        [System.String]$Path
    )
    PROCESS {
        FOREACH ($File in $Path) {
            Write-Verbose -Message '[PROCESS] $File'

            TRY {
                # Retrieve file content
                $ScriptContent = (Get-Content $File -Delimiter $([char]0))

                # AST Parsing
                $AbstractSyntaxTree = [System.Management.Automation.Language.Parser]::
                ParseInput($ScriptContent, [ref]$null, [ref]$null)

                # Find Aliases
                $Aliases = $AbstractSyntaxTree.FindAll( { $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true) |
                    ForEach-Object -Process {
                        $Command = $_.CommandElements[0]
                        if ($Alias = Get-Alias | Where-Object -FilterScript { $_.Name -eq $Command }) {

                            # Output information
                            [PSCustomObject]@{
                                File              = $File
                                Alias             = $Alias.Name
                                Definition        = $Alias.Definition
                                StartLineNumber   = $Command.Extent.StartLineNumber
                                EndLineNumber     = $Command.Extent.EndLineNumber
                                StartColumnNumber = $Command.Extent.StartColumnNumber
                                EndColumnNumber   = $Command.Extent.EndColumnNumber
                                StartOffset       = $Command.Extent.StartOffset
                                EndOffset         = $Command.Extent.EndOffset

                            }#[PSCustomObject]
                        }#if ($Alias)
                    } | Sort-Object -Property EndOffset -Descending

                # The sort-object is important, we change the values from the end first to not lose the positions of every aliases.
                Foreach ($Alias in $Aliases) {
                    # whatif and confirm support
                    if ($psCmdlet.ShouldProcess($file, "Expand Alias: $($Alias.alias) to $($Alias.definition) (startoffset: $($alias.StartOffset))")) {
                        # Remove alias and insert full cmldet name
                        $ScriptContent = $ScriptContent.Remove($Alias.StartOffset, ($Alias.EndOffset - $Alias.StartOffset)).Insert($Alias.StartOffset, $Alias.Definition)
                        # Apply to the file
                        Set-Content -Path $File -Value $ScriptContent -Confirm:$false
                    }
                }#ForEach Alias in Aliases

            }#TRY
            CATCH {
                Write-Error -Message $($Error[0].Exception.Message)
            }
        }#FOREACH File in Path
    }#PROCESS
}#Expand-ScriptAlias