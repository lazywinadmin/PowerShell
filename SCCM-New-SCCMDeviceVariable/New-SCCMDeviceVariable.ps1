function New-SCCMDeviceVariable {
    <#
    .SYNOPSIS
        function to create a new SCCM Device Variable

    .DESCRIPTION
        function to create a new SCCM Device Variable

        This function is relying on WMI to create a new SCCM Device Variable.
        You don't need the SCCM Module or SCCM Console installed to run it.
        Also this cmdlet support alternative credential.

    .PARAMETER ComputerName
        Specifies the SCCM Server

    .PARAMETER SiteCode
        Specifies the SCCM Site Code

    .PARAMETER Credential
        Specifies the alternative credential
        If not specified it will use the current user.

    .PARAMETER ResourceID
        Specifies the Device ResourceID

    .PARAMETER Name
        Specifies the Variable Name
        Alias: VariableName

    .PARAMETER Value
        Specifies the Variable Value
        Alias: VariableValue

    .PARAMETER IsMasked
        Specifies if the Variable value is masked.
        Default is $False

    .EXAMPLE
        New-SCCMDeviceVariable -ComputerName SCCM01 -SiteCode F01 -ResourceID 000000222 -Name Test01 -Value 'Some Information'

    .EXAMPLE
        New-SCCMDeviceVariable -ComputerName SCCM01 -SiteCode F01 -ResourceID 000000222 -Name Test02 -Value 'Secret information' -IsMasked $true

    .EXAMPLE
        New-SCCMDeviceVariable -ComputerName SCCM01 -SiteCode F01 -ResourceID 000000222 -Name Test03 -Value 'Some more info' -Credential (get-Credential)

    .EXAMPLE
        $MyParams = @{
            ComputerName = 'SCCM01'
            SiteCode = 'F01'
            ResourceID = '000000222'
            Name = 'Test03'
            Value = 'Some more info'
            Credential = (get-Credential)
        }

        New-SCCMDeviceVariable @MyParams

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
        github.com/lazywinadmin
    #>
    [cmdletbinding()]
    PARAM (
        [parameter(Mandatory = $true)]
        [Alias('SiteServer')]
        [System.String]$ComputerName,

        [parameter(Mandatory = $true)]
        [System.String]$SiteCode,

        [Alias("RunAs")]
        [PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [parameter(Mandatory = $true)]
        [int]$ResourceID,

        [parameter(Mandatory = $true)]
        [Alias("VariableName")]
        [System.String]$Name,

        [parameter(Mandatory = $true)]
        [Alias("VariableValue")]
        [System.String]$Value,

        [System.Boolean]$IsMasked = $false
    )
    PROCESS {
        TRY {
            Write-Verbose -Message "$ResourceID - Create splatting"
            $SCCM_Splatting = @{
                ComputerName = $ComputerName
                NameSpace    = "root\sms\site_$SiteCode"
            }

            IF ($PSBoundParameters['Credential']) {
                $SCCM_Splatting.Credential = $Credential
            }

            Write-Verbose -Message "$ResourceID - Verify if machine settings exist"
            # Check if the device already has a MachineSetting
            $MachineSettingsClass = Get-WmiObject @SCCM_Splatting -Query "SELECT ResourceID FROM SMS_MachineSettings WHERE ResourceID = '$ResourceID'"

            # If a Machine Settings is found
            if ($MachineSettingsClass) {
                Write-Verbose -Message "$ResourceID - Machine Settings Exists"

                # Create a new MachineVariable class instance
                Write-Verbose -Message "$ResourceID - Create Variable"
                $MachineVariablesClass = Get-WmiObject -list @SCCM_Splatting -Class "SMS_MachineVariable"
                $NewMachineVariableInstance = $MachineVariablesClass.CreateInstance()

                # Add the Variable
                $NewMachineVariableInstance.psbase.Properties['Name'].Value = $Name
                $NewMachineVariableInstance.psbase.Properties['Value'].Value = $Value
                $NewMachineVariableInstance.psbase.Properties['IsMasked'].Value = $IsMasked

                # Retrieve the Machine Settings
                $MachineSettingsClass.get()


                # Insert the variable we just created into the machine settings
                Write-Verbose -Message "$ResourceID - Insert machine Variable into machine settings"
                $MachineSettingsClass.MachineVariables += $NewMachineVariableInstance

                # Save our change back to SCCM
                Write-Verbose -Message "$ResourceID - Save Change"
                $MachineSettingsClass.Put()
            }
            else {
                Write-Verbose -Message "$ResourceID - Machine Settings does NOT Exists"

                # Create a new machine setting
                Write-Verbose -Message "$ResourceID - Machine Settings - Creation"
                $MachineSettingsClass = Get-WmiObject @SCCM_Splatting -List -Class 'SMS_MachineSettings'
                $NewMachineSettingsClassInstance = $MachineSettingsClass.CreateInstance()

                # Specify the Resource id and SourceSite(SiteCode)
                $NewMachineSettingsClassInstance.psbase.properties["ResourceID"].value = $ResourceID
                $NewMachineSettingsClassInstance.psbase.properties["SourceSite"].value = $SiteCode

                # Create a new MachineVariable class instance
                Write-Verbose -Message "$ResourceID - Machine Variable - Creation"
                $MachineVariablesClass = Get-WmiObject -list @SCCM_Splatting -Class "SMS_MachineVariable"
                $NewMachineVariablesInstance = $MachineVariablesClass.CreateInstance()

                # Add the Variable
                $NewMachineVariablesInstance.psbase.Properties['Name'].Value = $Name
                $NewMachineVariablesInstance.psbase.Properties['Value'].Value = $Value
                $NewMachineVariablesInstance.psbase.Properties['IsMasked'].Value = $IsMasked

                # Insert the variable we just created into the machine settings
                Write-Verbose -Message "$ResourceID - Insert machine Variable into machine settings"
                $NewMachineSettingsClassInstance.MachineVariables += $NewMachineVariablesInstance

                # Save our change back to SCCM
                Write-Verbose -Message "$ResourceID - Save Change"
                $NewMachineSettingsClassInstance.Put()
            }
        }
        CATCH {
            Write-Warning -Message "$ResourceID - Issue while processing the Device"
            $Error[0]
        }
        FINALLY
        { }
    } #Process
}
