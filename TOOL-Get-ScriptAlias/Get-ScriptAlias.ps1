function Get-ScriptAlias {
    <#
    .SYNOPSIS
        Function to retrieve the aliases inside a Powershell script file.

    .DESCRIPTION
        Function to retrieve the aliases inside a Powershell script file.
        Using PowerShell AST Parser we are able to retrieve the functions and cmdlets used in the script.

    .PARAMETER Path
        Specifies the path of the script

    .EXAMPLE
        Get-ScriptAlias -Path "C:\LazyWinAdmin\testscript.ps1"

    .EXAMPLE
        "C:\LazyWinAdmin\testscript.ps1" | Get-ScriptAlias

    .EXAMPLE
        gci C:\LazyWinAdmin -file | Get-ScriptAlias

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
#>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript( { Test-Path -Path $_ })]
        [Alias("FullName")]
        [System.String[]]$Path
    )
    PROCESS {
        FOREACH ($File in $Path) {
            TRY {
                # Retrieve file content
                $ScriptContent = (Get-Content $File -Delimiter $([char]0))

                # AST Parsing
                $AbstractSyntaxTree = [System.Management.Automation.Language.Parser]::
                ParseInput($ScriptContent, [ref]$null, [ref]$null)

                # Find Aliases
                $AbstractSyntaxTree.FindAll( { $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true) |
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
                    }#ForEach-Object
            }#TRY
            CATCH {
                Write-Error -Message $($Error[0].Exception.Message)
            } #CATCH
        }#FOREACH ($File in $Path)
    } #PROCESS
}