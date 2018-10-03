	# I felt need for this tool when one of my service intermittently unavailable. While I was using telnet service was available for time that time. 
    # I needed a telnet which can continuously keep connecting service port and report if port reachable or not
    
    # Telnet is nice utility to check service availability on remote server-port combination. 
    # But, problem with telnet is it can't run on continuous like "ping -t" 
    # also, on Windows 10 telnet is not by default activated. thus, at time when we need telnet on Windows 10 first we need to install telnet feature to use.
    # Here we have a small powershell magic to address both problems to continuous test port reachability
    
	
	while ($true) {test-netconnection <IP Address> -port <Port number> | Format-Table @{n='Timestamp';e={Get-DAte}},tcptestsucceeded}
