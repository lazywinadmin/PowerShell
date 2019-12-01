Function New-SCCMTSAppVariable {
    <#
    .SYNOPSIS
        Function to create a SCCM Task Sequence Application Variable during the OSD

    .DESCRIPTION
        Function to create a SCCM Task Sequence Application Variable during the OSD

    .PARAMETER BaseVariableName
        Specifies the "Base Variable Name" present in the task "Install Application" of the Task Sequence.
        (In the 'Install application according to dynamic variable list' section)

    .PARAMETER ApplicationList
        Specifies the list of application to install.
        Those must match the SCCM Application name to install

    .EXAMPLE
        New-SCCMTSVariable -BaseVariableName "FX" -ApplicationList "Photoshop","AutoCad"

    .EXAMPLE
        New-SCCMTSVariable -BaseVariableName "FX" -ApplicationList $Variable

    .NOTES
        Francois-Xavier Cat
        lazywinadmin.com
        @lazywinadmin
    #>

    PARAM (
        [String]$BaseVariableName,
        [String[]]$ApplicationList
    )

    BEGIN {
        # Create an TaskSequence Environment Object
        $TaskSequenceEnvironment = New-Object -COMObject Microsoft.SMS.TSEnvironment
    }
    PROCESS {

        # Create a Counter
        $Counter = 1

        # Foreach Application we create an incremented variable
        $ApplicationList | ForEach-Object -Process {

            # Define the Variable Name
            $Variable = "$BaseVariableName{0:00}" -f $Counter

            # Create the Task Sequence Variable
            $TaskSequenceEnvironment.value("$Variable") = "$_"

            # Increment the counter
            [void]$Counter++
        }
    }
}