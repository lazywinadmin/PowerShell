function Get-LogFast {
    <#
    .DESCRIPTION
        Function to read a log file very fast
    .SYNOPSIS
        Function to read a log file very fast
    .EXAMPLE
        Get-LogFast -Path C:\megalogfile.log
    .EXAMPLE
        Get-LogFast -Path C:\367.msp.0.log -Match "09:36:43:417" -Verbose

        VERBOSE: [PROCESS] Match found
        MSI (s) (A8:14) [09:36:43:417]: Note: 1: 2205 2:  3: Font
        VERBOSE: [PROCESS] Match found
        MSI (s) (A8:14) [09:36:43:417]: Note: 1: 2205 2:  3: Class
        VERBOSE: [PROCESS] Match found
        MSI (s) (A8:14) [09:36:43:417]: Note: 1: 2205 2:  3: TypeLib

    .NOTES
        Francois-Xavier cat
        @lazywinadmin
        lazywinadmin.com
        github.com/lazywinadmin

#>
    [CmdletBinding()]
    PARAM (
        $Path = "c:\Biglog.log",

        $Match
    )
    BEGIN {
        # Create a StreamReader object
        #  Fortunately this .NET Framework called System.IO.StreamReader allows you to read text files a line at a time which is important when you’ re dealing with huge log files :-)
        $StreamReader = New-Object -TypeName System.IO.StreamReader -ArgumentList (Resolve-Path -Path $Path -ErrorAction Stop).Path
    }
    PROCESS {
        # .Peek() Method: An integer representing the next character to be read, or -1 if no more characters are available or the stream does not support seeking.
        while ($StreamReader.Peek() -gt -1) {
            # Read the next line
            #  .ReadLine() method: Reads a line of characters from the current stream and returns the data as a string.
            $Line = $StreamReader.ReadLine()

            #  Ignore empty line and line starting with a #
            if ($Line.length -eq 0 -or $Line -match "^#") {
                continue
            }

            IF ($PSBoundParameters['Match']) {
                If ($Line -match $Match) {
                    Write-Verbose -Message "[PROCESS] Match found"

                    # Split the line on $Delimiter
                    #$result = ($Line -split $Delimiter)

                    Write-Output $Line
                }
            }
            ELSE { Write-Output $Line }
        }
    } #PROCESS
}