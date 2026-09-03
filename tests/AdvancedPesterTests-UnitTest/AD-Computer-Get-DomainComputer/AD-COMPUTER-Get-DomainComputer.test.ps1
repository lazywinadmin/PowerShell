Import-Module "$PSScriptRoot\Get-DomainComputer.psd1"
Import-Module "$PSScriptRoot\pester-installables\Pester\src\Pester.psd1"

Describe "AD-COMPUTER-Get-DomainComputer test for returning object"{
    $script:test=0
    $script:test++
    It "$("$script:test".padleft(3, '0')): Syntax test"{
            (Get-Command -Syntax Get-DomainComputer).Trim()| Should -BeTrue #Can be changed if someone gives me the output of the command before the pipeline
        }
    $script:test++
    It "$("$script:test".padleft(3, '0')): Compatibility with test objects"{
        try{
            Get-DomainComputer -ComputerName "dummycomputer" -Domain "dummydomain"
            $true| Should -BeTrue  #Can be changed if someone gives me the output of Get-DomainComputer in xml format, after export the object via $object|Export-CliXML "<Path>"
         }
         catch{
            Write-Host "$($_.exception.message) $($_.errordetails.message)"
            $false| Should -BeTrue
         }
        }
    }
