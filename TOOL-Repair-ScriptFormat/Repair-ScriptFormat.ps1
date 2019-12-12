function Repair-ScriptFormat {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateScript( { Test-Path -Path $_ })]
        $Path,
        [System.String]$Settings = 'CodeFormatting'
    )

    begin {
        #Validate PSScriptAnalyzer is present
        #minimum vers
    }

    process {
        # Retrieve content
        $scriptContent = Get-Content -Path $Path -Raw

        # Apply Formatting
        $NewContent = Invoke-Formatter -ScriptDefinition $scriptContent -Settings $Settings

        # Replace whitespace lines
        #$NewContent = $NewContent -replace '\'

        $NewContent | Out-File -FilePath $Path -Force -NoNewline



    }
    end {

    }
}