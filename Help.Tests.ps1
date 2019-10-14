$scripts = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter *.ps1 | 
                Where-Object FullName -NotMatch '.Tests.'


Describe -Tag 'Help' 'Help' {

    foreach ($script in $scripts) {

        Context "[$($script.FullName)] Validate Comment Based Help" {
            # Dot Source script
            . .\$script.FullName

            $functionHelp = Get-Help ($script.Name).TrimEnd('.ps1') -Full

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
        }
    }
}

