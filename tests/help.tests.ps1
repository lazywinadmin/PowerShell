$scripts = Get-ChildItem -Path (Split-Path $PSScriptRoot -parent) -Recurse -Filter *.ps1 |
    Where-Object -FilterScript {
        $_.FullName -NotMatch '.Tests.' -and
        $_.Fullname -notmatch [regex]::Escape('_Profiles') -and
        $_.Fullname -notmatch [regex]::Escape('_Template')
    } | Sort-Object

[regex]$regex = "(^[A-Z\-]+-)"

Describe -Tag 'Help' 'Help' {

    foreach ($script in $scripts) {

        Context "[$($script.BaseName)] Validate Comment Based Help" {

            # Correct name where file name does not match function name
            if ($script.Name -Match $regex) {
                $name = $script.BaseName.Replace($Matches[0], '')
            } elseif ($script.Name -match 'O365-') {
                $name = $script.BaseName.Replace($Matches[0], '')
            } elseif ($script.Name -match 'Function_Template.ps1') {
                $name = 'Get-Something'
            } else {
                $name = $script.BaseName
            }

            # Only process functions and not scripts
            if ((Get-Content -Path $script.FullName -TotalCount 1) -match 'function') {

                # Dot Source script
                . $($script.FullName)

                $functionHelp = Get-Help $name -Full

                It 'Contains Description' {
                    $functionHelp.Description | Should Not BeNullOrEmpty
                }

                It 'Contains Synopsis' {
                    $functionHelp.Synopsis | Should Not BeNullOrEmpty
                }

                It 'Contains Examples' {
                    $functionHelp.Examples | Should Not BeNullOrEmpty
                }

                It 'Contains Parameters' {
                    $functionHelp.Parameters | Should Not BeNullOrEmpty
                }
            } else {
                It "[$($script.BaseName)] is not a function" {
                } -Skip
            }
        }
    }
}

