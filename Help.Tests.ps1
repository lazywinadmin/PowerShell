Describe -Tag 'Help' 'Help' {
    # dot source script
    . .\TOOL-ConvertFrom-Base64\ConvertFrom-Base64.ps1
    . .\TOOL-Get-NetStat\Get-NetStat.ps1

    $scriptName = 'ConvertFrom-Base64', 'Get-NetStat'

    foreach ($script in $scriptName) {
        Context "[$script] Validate Comment Based Help" {
            $functionHelp = Get-Help $script -Full

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

