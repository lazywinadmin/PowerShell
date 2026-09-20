function Remove-StringDiacritic {
        # .SYNOPSIS
        #     This function will remove the diacritics (accents) characters from a string.
        # .DESCRIPTION
        #     This function will remove the diacritics (accents) characters from a string.
        # .PARAMETER Mode
        #     Set the function to run in StringMode or ObjectMode
        # .PARAMETER String
        #     Specifies the String(s) on which the diacritics need to be removed. Exclusive to StringMode
        #     For Dynammic parameters, refer to https://powershellmagazine.com/2014/05/29/dynamic-parameters-in-powershell/
        # .PARAMETER Object
        #     Specifies the Object on which the diacritics of all columns need to be removed. Exclusive to ObjectMode
        #     For Dynammic parameters, refer to https://powershellmagazine.com/2014/05/29/dynamic-parameters-in-powershell/
        # .PARAMETER NormalizationForm
        #     Specifies the normalization form to use
        #     https://msdn.microsoft.com/en-us/library/system.text.normalizationform(v=vs.110).aspx
        # .EXAMPLE
        #     PS C:\> Remove-StringDiacritic "L'été de Raphaël"
        #     L'ete de Raphael
        # .NOTES
        #     Francois-Xavier Cat
        #     @lazywinadmin
        #     lazywinadmin.com
        #     github.com/lazywinadmin
        #     Edited by dkabal14
        #     github.com/dkabal14
    [CMdletBinding()]
    PARAM
    (
        [ValidateNotNullOrEmpty()]
        [Alias('Text')]
        [System.String][Parameter(Position=0,Mandatory=$true)][validateset("StringMode","ObjectMode")]$Mode,
        [System.Text.NormalizationForm]$NormalizationForm = "FormD"
    )

    DynamicParam {
        if ($Mode -eq "StringMode") {
             #create a new ParameterAttribute Object
             $StringMode = New-Object System.Management.Automation.ParameterAttribute
             $StringMode.Position = 1
             $StringMode.Mandatory = $true

             #create an attributecollection object for the attribute we just created.
             $attributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]

             #add our custom attribute
             $attributeCollection.Add($StringMode)

             #add our paramater specifying the attribute collection
             $ageParam = New-Object System.Management.Automation.RuntimeDefinedParameter('String', [System.String], $attributeCollection)

             #expose the name of our parameter
             $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
             $paramDictionary.Add('String', $ageParam)
             return $paramDictionary
       }
       if ($Mode -eq "ObjectMode") {
            #create a new ParameterAttribute Object
            $ObjectMode = New-Object System.Management.Automation.ParameterAttribute
            $ObjectMode.Position = 1
            $ObjectMode.Mandatory = $true

            #create an attributecollection object for the attribute we just created.
            $attributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]

            #add our custom attribute
            $attributeCollection.Add($ObjectMode)

            #add our paramater specifying the attribute collection
            $ageParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Object', [pscustomobject], $attributeCollection)

            #expose the name of our parameter
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('Object', $ageParam)
            return $paramDictionary
        }
   }
    
    Process {
        if ($Mode -eq "ObjectMode")
        {
            $objText = $PSBoundParameters.Object | ConvertTo-Csv
            $result = @()
            foreach ($line in $objText.Split("/s"))
            {
                $String = $line
                FOREACH ($StringValue in $String) {
                    Write-Verbose -Message "$StringValue"
                    try {
                        # Normalize the String
                        $Normalized = $StringValue.Normalize($NormalizationForm)
                        $NewString = New-Object -TypeName System.Text.StringBuilder

                        # Convert the String to CharArray
                        $normalized.ToCharArray() |
                            ForEach-Object -Process {
                                if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($psitem) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
                                    [void]$NewString.Append($psitem)
                                }
                            }

                        #Combine the new string chars
                        $result +=  $($NewString -as [string])
                        $result | ConvertFrom-Csv
                    }
                    Catch {
                        Write-Error -Message $Error[0].Exception.Message
                    }
                }
            }
        }
        else 
        {
            $String = $PSBoundParameters.String
            FOREACH ($StringValue in $String) {
                Write-Verbose -Message "$StringValue"
                try {
                    # Normalize the String
                    $Normalized = $StringValue.Normalize($NormalizationForm)
                    $NewString = New-Object -TypeName System.Text.StringBuilder

                    # Convert the String to CharArray
                    $normalized.ToCharArray() |
                        ForEach-Object -Process {
                            if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($psitem) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
                                [void]$NewString.Append($psitem)
                            }
                        }

                    #Combine the new string chars
                    Write-Output $($NewString -as [string])
                }
                Catch {
                    Write-Error -Message $Error[0].Exception.Message
                }
            }
        }
    }
}
