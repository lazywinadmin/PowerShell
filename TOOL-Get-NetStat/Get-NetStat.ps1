function Get-NetStat {
    <#
.SYNOPSIS
    This function will get the output of netstat -n and parse the output
.DESCRIPTION
    This function will get the output of netstat -n and parse the output
.EXAMPLE
    Get-Netstat
.LINK
    https://lazywinadmin.com/2014/08/powershell-parse-this-netstatexe.html
.NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadmin
.LINK
    https://github.com/lazywinadmin/PowerShell
#>
    PROCESS {
        # Get the output of netstat
        $data = netstat -n

        # Keep only the line with the data (we remove the first lines)
        $data = $data[4..$data.count]

        # Each line need to be splitted and get rid of unnecessary spaces
        foreach ($line in $data) {
            # Get rid of the first whitespaces, at the beginning of the line
            $line = $line -replace '^\s+', ''

            # Split each property on whitespaces block
            $line = $line -split '\s+'

            # Define the properties
            $properties = @{
                Protocole          = $line[0]
                LocalAddressIP     = ($line[1] -split ":")[0]
                LocalAddressPort   = ($line[1] -split ":")[1]
                ForeignAddressIP   = ($line[2] -split ":")[0]
                ForeignAddressPort = ($line[2] -split ":")[1]
                State              = $line[3]
            }

            # Output the current line
            New-Object -TypeName PSObject -Property $properties
        }
    }
}