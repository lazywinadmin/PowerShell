function Get-SCSMWorkItemUserInput {
    <#
    .SYNOPSIS
        Retrieve the input text provided by the user
    .DESCRIPTION
        Retrieve the input text provided by the user
    .PARAMETER WorkItemObject
        Specify the WorkItem Object
        Typically you'll need to retrieve the object prior to use this command
    .EXAMPLE
        Get-SCSMWorkItemUserInput -WorkItemObject
    .NOTES
        Initial version from http://itblog.no/4462
        Output PSOBject instead of array
    #>
    [CmdletBinding()]
    Param (
        $WorkItemObject
    )
    BEGIN {
        #Declare Vars
        $userInput = ""
        $ListArray = @()
    }
    PROCESS {
        $UserInput = $WorkItemObject.UserInput
        $content = [XML]$UserInput
        $inputs = $content.UserInputs.UserInput
        foreach ($input in $inputs) {
            if ($($input.Answer) -like "<value*") {
                [xml]$answer = $input.answer
                foreach ($value in $($($answer.values))) {
                    foreach ($item in $value) {
                        foreach ($txt in $($item.value)) {
                            $ListArray += $($txt.DisplayName)
                        }
                        #$Array += $input.Question + " = " + [string]::Join(", ", $ListArray)
                        $Props = @{
                            Question = $input.question
                            Answer   = $([string]::Join(", ", $ListArray))

                        }
                        New-Object -TypeName PSObject -Property $Props
                        $ListArray = $null
                    }
                }
            }
            else {
                if ($input.type -eq "enum") {
                    $ListGuid = Get-SCSMEnumeration -Id $input.Answer

                    $Props = @{
                        Question = $input.question
                        Answer   = $ListGuid.displayname

                    }
                    New-Object -TypeName PSObject -Property $Props
                }
                else {
                    $Props = @{
                        Question = $input.question
                        Answer   = $input.answer
                    }

                    New-Object -TypeName PSObject -Property $Props
                }
            }
        }# foreach ($input in $inputs)
        #Write-Output $Array
    }#PROCESS
}