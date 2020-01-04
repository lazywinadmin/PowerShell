Function Invoke-Ping {
    <#
.SYNOPSIS
    Ping or test connectivity to systems in parallel

.DESCRIPTION
    Ping or test connectivity to systems in parallel

    Default action will run a ping against systems
        If Quiet parameter is specified, we return an array of systems that responded
        If Detail parameter is specified, we test WSMan, RemoteReg, RPC, RDP and/or SMB

.PARAMETER ComputerName
    One or more computers to test

.PARAMETER Quiet
    If specified, only return addresses that responded to Test-Connection

.PARAMETER Detail
    Include one or more additional tests as specified:
        WSMan      via Test-WSMan
        RemoteReg  via Microsoft.Win32.RegistryKey
        RPC        via WMI
        RDP        via port 3389
        SMB        via \\ComputerName\C$
        *          All tests

.PARAMETER Timeout
    Time in seconds before we attempt to dispose an individual query.  Default is 20

.PARAMETER Throttle
    Throttle query to this many parallel runspaces.  Default is 100.

.PARAMETER NoCloseOnTimeout
    Do not dispose of timed out tasks or attempt to close the runspace if threads have timed out

    This will prevent the script from hanging in certain situations where threads become non-responsive, at the expense of leaking memory within the PowerShell host.

.EXAMPLE
    Invoke-Ping Server1, Server2, Server3 -Detail *

    # Check for WSMan, Remote Registry, Remote RPC, RDP, and SMB (via C$) connectivity against 3 machines

.EXAMPLE
    $Computers | Invoke-Ping

    # Ping computers in $Computers in parallel

.EXAMPLE
    $Responding = $Computers | Invoke-Ping -Quiet

    # Create a list of computers that successfully responded to Test-Connection

.LINK
    https://gallery.technet.microsoft.com/scriptcenter/Invoke-Ping-Test-in-b553242a

.FUNCTIONALITY
    Computers

.NOTES
    Warren F
    http://ramblingcookiemonster.github.io/Invoke-Ping/

.LINK
    https://github.com/lazywinadmin/PowerShell

#>
    [cmdletbinding(DefaultParameterSetName = 'Ping')]
    param (
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string[]]$ComputerName,

        [Parameter(ParameterSetName = 'Detail')]
        [validateset("*", "WSMan", "RemoteReg", "RPC", "RDP", "SMB")]
        [string[]]$Detail,

        [Parameter(ParameterSetName = 'Ping')]
        [switch]$Quiet,

        [int]$Timeout = 20,

        [int]$Throttle = 100,

        [switch]$NoCloseOnTimeout
    )
    Begin {

        #http://gallery.technet.microsoft.com/Run-Parallel-Parallel-377fd430
        function Invoke-Parallel {
            [cmdletbinding(DefaultParameterSetName = 'ScriptBlock')]
            Param (
                [Parameter(Mandatory = $false, position = 0, ParameterSetName = 'ScriptBlock')]
                [System.Management.Automation.ScriptBlock]$ScriptBlock,

                [Parameter(Mandatory = $false, ParameterSetName = 'ScriptFile')]
                [ValidateScript( { Test-Path $_ -pathtype leaf })]
                $ScriptFile,

                [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
                [Alias('CN', '__Server', 'IPAddress', 'Server', 'ComputerName')]
                [PSObject]$InputObject,

                [PSObject]$Parameter,

                [switch]$ImportVariables,

                [switch]$ImportModules,

                [int]$Throttle = 20,

                [int]$SleepTimer = 200,

                [int]$RunspaceTimeout = 0,

                [switch]$NoCloseOnTimeout = $false,

                [int]$MaxQueue,

                [validatescript( { Test-Path (Split-Path $_ -parent) })]
                [string]$LogFile = "C:\temp\log.log",

                [switch]$Quiet = $false
            )

            Begin {

                #No max queue specified?  Estimate one.
                #We use the script scope to resolve an odd PowerShell 2 issue where MaxQueue isn't seen later in the function
                if (-not $PSBoundParameters.ContainsKey('MaxQueue')) {
                    if ($RunspaceTimeout -ne 0) { $script:MaxQueue = $Throttle }
                    else { $script:MaxQueue = $Throttle * 3 }
                }
                else {
                    $script:MaxQueue = $MaxQueue
                }

                Write-Verbose -Message "Throttle: '$throttle' SleepTimer '$sleepTimer' runSpaceTimeout '$runspaceTimeout' maxQueue '$maxQueue' logFile '$logFile'"

                #If they want to import variables or modules, create a clean runspace, get loaded items, use those to exclude items
                if ($ImportVariables -or $ImportModules) {
                    $StandardUserEnv = [powershell]::Create().addscript( {

                            #Get modules and snapins in this clean runspace
                            $Modules = Get-Module | Select-Object -ExpandProperty Name
                            $Snapins = Get-PSSnapin | Select-Object -ExpandProperty Name

                            #Get variables in this clean runspace
                            #Called last to get vars like $? into session
                            $Variables = Get-Variable | Select-Object -ExpandProperty Name

                            #Return a hashtable where we can access each.
                            @{
                                Variables = $Variables
                                Modules   = $Modules
                                Snapins   = $Snapins
                            }
                        }).invoke()[0]

                    if ($ImportVariables) {
                        #Exclude common parameters, bound parameters, and automatic variables
                        Function _temp {
                            [cmdletbinding()]
                            param ()
                        }
                        $VariablesToExclude = @((Get-Command _temp | Select-Object -ExpandProperty parameters).Keys + $PSBoundParameters.Keys + $StandardUserEnv.Variables)
                        Write-Verbose -Message "Excluding variables $(($VariablesToExclude | Sort-Object) -join ", ")"

                        # we don't use 'Get-Variable -Exclude', because it uses regexps.
                        # One of the veriables that we pass is '$?'.
                        # There could be other variables with such problems.
                        # Scope 2 required if we move to a real module
                        $UserVariables = @(Get-Variable | Where-Object -FilterScript { -not ($VariablesToExclude -contains $_.Name) })
                        Write-Verbose -Message "Found variables to import: $(($UserVariables | Select-Object -expandproperty Name | Sort-Object) -join ", " | Out-String).`n"

                    }

                    if ($ImportModules) {
                        $UserModules = @(Get-Module | Where-Object -FilterScript { $StandardUserEnv.Modules -notcontains $_.Name -and (Test-Path $_.Path -ErrorAction SilentlyContinue) } | Select-Object -ExpandProperty Path)
                        $UserSnapins = @(Get-PSSnapin | Select-Object -ExpandProperty Name | Where-Object { $StandardUserEnv.Snapins -notcontains $_ })
                    }
                }

                #region functions

                Function Get-RunspaceData {
                    [cmdletbinding()]
                    param ([switch]$Wait)

                    #loop through runspaces
                    #if $wait is specified, keep looping until all complete
                    Do {

                        #set more to false for tracking completion
                        $more = $false

                        #Progress bar if we have inputobject count (bound parameter)
                        if (-not $Quiet) {
                            Write-Progress -Activity "Running Query" -Status "Starting threads"`
                                -CurrentOperation "$startedCount threads defined - $totalCount input objects - $script:completedCount input objects processed"`
                                -PercentComplete $(Try { $script:completedCount / $totalCount * 100 }
                                Catch { 0 })
                        }

                        #run through each runspace.
                        Foreach ($runspace in $runspaces) {

                            #get the duration - inaccurate
                            $currentdate = Get-Date
                            $runtime = $currentdate - $runspace.startTime
                            $runMin = [math]::Round($runtime.totalminutes, 2)

                            #set up log object
                            $log = "" | Select-Object Date, Action, Runtime, Status, Details
                            $log.Action = "Removing:'$($runspace.object)'"
                            $log.Date = $currentdate
                            $log.Runtime = "$runMin minutes"

                            #If runspace completed, end invoke, dispose, recycle, counter++
                            If ($runspace.Runspace.isCompleted) {

                                $script:completedCount++

                                #check if there were errors
                                if ($runspace.powershell.Streams.Error.Count -gt 0) {

                                    #set the logging info and move the file to completed
                                    $log.status = "CompletedWithErrors"
                                    Write-Verbose ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1]
                                    foreach ($ErrorRecord in $runspace.powershell.Streams.Error) {
                                        Write-Error -ErrorRecord $ErrorRecord
                                    }
                                }
                                else {

                                    #add logging details and cleanup
                                    $log.status = "Completed"
                                    Write-Verbose ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1]
                                }

                                #everything is logged, clean up the runspace
                                $runspace.powershell.EndInvoke($runspace.Runspace)
                                $runspace.powershell.dispose()
                                $runspace.Runspace = $null
                                $runspace.powershell = $null

                            }

                            #If runtime exceeds max, dispose the runspace
                            ElseIf ($runspaceTimeout -ne 0 -and $runtime.totalseconds -gt $runspaceTimeout) {

                                $script:completedCount++
                                $timedOutTasks = $true

                                #add logging details and cleanup
                                $log.status = "TimedOut"
                                Write-Verbose ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1]
                                Write-Error "Runspace timed out at $($runtime.totalseconds) seconds for the object:`n$($runspace.object | Out-String)"

                                #Depending on how it hangs, we could still get stuck here as dispose calls a synchronous method on the powershell instance
                                if (!$noCloseOnTimeout) { $runspace.powershell.dispose() }
                                $runspace.Runspace = $null
                                $runspace.powershell = $null
                                $completedCount++

                            }

                            #If runspace isn't null set more to true
                            ElseIf ($null -ne $runspace.Runspace) {
                                $log = $null
                                $more = $true
                            }

                            #log the results if a log file was indicated
                            if ($logFile -and $log) {
                                ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1] | Out-File $LogFile -append
                            }
                        }

                        #Clean out unused runspace jobs
                        $temphash = $runspaces.clone()
                        $temphash |
                        Where-Object -FilterScript { $null -eq $_.runspace } |
                        ForEach-Object -Process {
                            $Runspaces.remove($_)
                        }

                        #sleep for a bit if we will loop again
                        if ($PSBoundParameters['Wait']) { Start-Sleep -milliseconds $SleepTimer }

                        #Loop again only if -wait parameter and there are more runspaces to process
                    }
                    while ($more -and $PSBoundParameters['Wait'])

                    #End of runspace function
                }

                #endregion functions

                #region Init

                if ($PSCmdlet.ParameterSetName -eq 'ScriptFile') {
                    $ScriptBlock = [scriptblock]::Create($(Get-Content $ScriptFile | Out-String))
                }
                elseif ($PSCmdlet.ParameterSetName -eq 'ScriptBlock') {
                    #Start building parameter names for the param block
                    [string[]]$ParamsToAdd = '$_'
                    if ($PSBoundParameters.ContainsKey('Parameter')) {
                        $ParamsToAdd += '$Parameter'
                    }

                    $UsingVariableData = $Null


                    # This code enables $Using support through the AST.
                    # This is entirely from  Boe Prox, and his https://github.com/proxb/PoshRSJob module; all credit to Boe!

                    if ($PSVersionTable.PSVersion.Major -gt 2) {
                        #Extract using references
                        $UsingVariables = $ScriptBlock.ast.FindAll( { $args[0] -is [System.Management.Automation.Language.UsingExpressionAst] }, $True)

                        If ($UsingVariables) {
                            $List = New-Object -TypeName 'System.Collections.Generic.List`1[System.Management.Automation.Language.VariableExpressionAst]'
                            ForEach ($Ast in $UsingVariables) {
                                [void]$list.Add($Ast.SubExpression)
                            }

                            $UsingVar = $UsingVariables | Group-Object -Property Parent | ForEach-Object -Process { $_.Group | Select-Object -First 1 }

                            #Extract the name, value, and create replacements for each
                            $UsingVariableData = ForEach ($Var in $UsingVar) {
                                Try {
                                    $Value = Get-Variable -Name $Var.SubExpression.VariablePath.UserPath -ErrorAction Stop
                                    $NewName = ('$__using_{0}' -f $Var.SubExpression.VariablePath.UserPath)
                                    [pscustomobject]@{
                                        Name       = $Var.SubExpression.Extent.Text
                                        Value      = $Value.Value
                                        NewName    = $NewName
                                        NewVarName = ('__using_{0}' -f $Var.SubExpression.VariablePath.UserPath)
                                    }
                                    $ParamsToAdd += $NewName
                                }
                                Catch {
                                    Write-Error "$($Var.SubExpression.Extent.Text) is not a valid Using: variable!"
                                }
                            }

                            $NewParams = $UsingVariableData.NewName -join ', '
                            $Tuple = [Tuple]::Create($list, $NewParams)
                            $bindingFlags = [Reflection.BindingFlags]"Default,NonPublic,Instance"
                            $GetWithInputHandlingForInvokeCommandImpl = ($ScriptBlock.ast.gettype().GetMethod('GetWithInputHandlingForInvokeCommandImpl', $bindingFlags))

                            $StringScriptBlock = $GetWithInputHandlingForInvokeCommandImpl.Invoke($ScriptBlock.ast, @($Tuple))

                            $ScriptBlock = [scriptblock]::Create($StringScriptBlock)

                            Write-Verbose $StringScriptBlock
                        }
                    }

                    $ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock("param($($ParamsToAdd -Join ", "))`r`n" + $Scriptblock.ToString())
                }
                else {
                    Throw "Must provide ScriptBlock or ScriptFile"; Break
                }

                Write-Debug "`$ScriptBlock: $($ScriptBlock | Out-String)"
                Write-Verbose -Message "Creating runspace pool and session states"

                #If specified, add variables and modules/snapins to session state
                $sessionstate = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
                if ($ImportVariables) {
                    if ($UserVariables.count -gt 0) {
                        foreach ($Variable in $UserVariables) {
                            $sessionstate.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $Variable.Name, $Variable.Value, $null))
                        }
                    }
                }
                if ($ImportModules) {
                    if ($UserModules.count -gt 0) {
                        foreach ($ModulePath in $UserModules) {
                            $sessionstate.ImportPSModule($ModulePath)
                        }
                    }
                    if ($UserSnapins.count -gt 0) {
                        foreach ($PSSnapin in $UserSnapins) {
                            [void]$sessionstate.ImportPSSnapIn($PSSnapin, [ref]$null)
                        }
                    }
                }

                #Create runspace pool
                $runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
                $runspacepool.Open()

                Write-Verbose -Message "Creating empty collection to hold runspace jobs"
                $Script:runspaces = New-Object -TypeName System.Collections.ArrayList

                #If inputObject is bound get a total count and set bound to true
                $global:__bound = $false
                $allObjects = @()
                if ($PSBoundParameters.ContainsKey("inputObject")) {
                    $global:__bound = $true
                }

                #Set up log file if specified
                if ($LogFile) {
                    New-Item -ItemType file -path $logFile -force | Out-Null
                    ("" | Select-Object Date, Action, Runtime, Status, Details | ConvertTo-Csv -NoTypeInformation -Delimiter ";")[0] | Out-File $LogFile
                }

                #write initial log entry
                $log = "" | Select-Object Date, Action, Runtime, Status, Details
                $log.Date = Get-Date
                $log.Action = "Batch processing started"
                $log.Runtime = $null
                $log.Status = "Started"
                $log.Details = $null
                if ($logFile) {
                    ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1] | Out-File $LogFile -Append
                }

                $timedOutTasks = $false

                #endregion INIT
            }

            Process {

                #add piped objects to all objects or set all objects to bound input object parameter
                if (-not $global:__bound) {
                    $allObjects += $inputObject
                }
                else {
                    $allObjects = $InputObject
                }
            }

            End {

                #Use Try/Finally to catch Ctrl+C and clean up.
                Try {
                    #counts for progress
                    $totalCount = $allObjects.count
                    $script:completedCount = 0
                    $startedCount = 0

                    foreach ($object in $allObjects) {

                        #region add scripts to runspace pool

                        #Create the powershell instance, set verbose if needed, supply the scriptblock and parameters
                        $powershell = [powershell]::Create()

                        if ($VerbosePreference -eq 'Continue') {
                            [void]$PowerShell.AddScript( { $VerbosePreference = 'Continue' })
                        }

                        [void]$PowerShell.AddScript($ScriptBlock).AddArgument($object)

                        if ($parameter) {
                            [void]$PowerShell.AddArgument($parameter)
                        }

                        # $Using support from Boe Prox
                        if ($UsingVariableData) {
                            Foreach ($UsingVariable in $UsingVariableData) {
                                Write-Verbose -Message "Adding $($UsingVariable.Name) with value: $($UsingVariable.Value)"
                                [void]$PowerShell.AddArgument($UsingVariable.Value)
                            }
                        }

                        #Add the runspace into the powershell instance
                        $powershell.RunspacePool = $runspacepool

                        #Create a temporary collection for each runspace
                        $temp = "" | Select-Object PowerShell, StartTime, object, Runspace
                        $temp.PowerShell = $powershell
                        $temp.StartTime = Get-Date
                        $temp.object = $object

                        #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
                        $temp.Runspace = $powershell.BeginInvoke()
                        $startedCount++

                        #Add the temp tracking info to $runspaces collection
                        Write-Verbose ("Adding {0} to collection at {1}" -f $temp.object, $temp.starttime.tostring())
                        $runspaces.Add($temp) | Out-Null

                        #loop through existing runspaces one time
                        Get-RunspaceData

                        #If we have more running than max queue (used to control timeout accuracy)
                        #Script scope resolves odd PowerShell 2 issue
                        $firstRun = $true
                        while ($runspaces.count -ge $Script:MaxQueue) {

                            #give verbose output
                            if ($firstRun) {
                                Write-Verbose -Message "$($runspaces.count) items running - exceeded $Script:MaxQueue limit."
                            }
                            $firstRun = $false

                            #run get-runspace data and sleep for a short while
                            Get-RunspaceData
                            Start-Sleep -Milliseconds $sleepTimer

                        }

                        #endregion add scripts to runspace pool
                    }

                    Write-Verbose ("Finish processing the remaining runspace jobs: {0}" -f (@($runspaces | Where-Object -FilterScript { $null -ne $_.Runspace }).Count))
                    Get-RunspaceData -wait

                    if (-not $quiet) {
                        Write-Progress -Activity "Running Query" -Status "Starting threads" -Completed
                    }

                }
                Finally {
                    #Close the runspace pool, unless we specified no close on timeout and something timed out
                    if (($timedOutTasks -eq $false) -or (($timedOutTasks -eq $true) -and ($noCloseOnTimeout -eq $false))) {
                        Write-Verbose -Message "Closing the runspace pool"
                        $runspacepool.close()
                    }

                    #collect garbage
                    [gc]::Collect()
                }
            }
        }

        Write-Verbose -Message "PSBoundParameters = $($PSBoundParameters | Out-String)"

        $bound = $PSBoundParameters.keys -contains "ComputerName"
        if (-not $bound) {
            [System.Collections.ArrayList]$AllComputers = @()
        }
    }
    Process {

        #Handle both pipeline and bound parameter.  We don't want to stream objects, defeats purpose of parallelizing work
        if ($bound) {
            $AllComputers = $ComputerName
        }
        Else {
            foreach ($Computer in $ComputerName) {
                $AllComputers.add($Computer) | Out-Null
            }
        }

    }
    End {

        #Built up the parameters and run everything in parallel
        $params = @($Detail, $Quiet)
        $splat = @{
            Throttle        = $Throttle
            RunspaceTimeout = $Timeout
            InputObject     = $AllComputers
            parameter       = $params
        }
        if ($NoCloseOnTimeout) {
            $splat.add('NoCloseOnTimeout', $True)
        }

        Invoke-Parallel @splat -ScriptBlock {

            $computer = $_.trim()
            $detail = $parameter[0]
            $quiet = $parameter[1]

            #They want detail, define and run test-server
            if ($detail) {
                Try {
                    #Modification of jrich's Test-Server function: https://gallery.technet.microsoft.com/scriptcenter/Powershell-Test-Server-e0cdea9a
                    Function Test-Server {
                        [cmdletBinding()]
                        param (
                            [parameter(
                                Mandatory = $true,
                                ValueFromPipeline = $true)]
                            [string[]]$ComputerName,

                            [switch]$All,

                            [parameter(Mandatory = $false)]
                            [switch]$CredSSP,

                            [switch]$RemoteReg,

                            [switch]$RDP,

                            [switch]$RPC,

                            [switch]$SMB,

                            [switch]$WSMAN,

                            [switch]$IPV6,

                            [Management.Automation.PSCredential]$Credential
                        )
                        begin {
                            $total = Get-Date
                            $results = @()
                            if ($credssp -and -not $Credential) {
                                Throw "Must supply Credentials with CredSSP test"
                            }

                            [string[]]$props = Write-Output Name, IP, Domain, Ping, WSMAN, CredSSP, RemoteReg, RPC, RDP, SMB

                            #Hash table to create PSObjects later, compatible with ps2...
                            $Hash = @{ }
                            foreach ($prop in $props) {
                                $Hash.Add($prop, $null)
                            }

                            function Test-Port {
                                [cmdletbinding()]
                                Param (
                                    [string]$srv,

                                    $port = 135,

                                    $timeout = 3000
                                )
                                $ErrorActionPreference = "SilentlyContinue"
                                $tcpclient = New-Object -TypeName system.Net.Sockets.TcpClient
                                $iar = $tcpclient.BeginConnect($srv, $port, $null, $null)
                                $wait = $iar.AsyncWaitHandle.WaitOne($timeout, $false)
                                if (-not $wait) {
                                    $tcpclient.Close()
                                    Write-Verbose -Message "Connection Timeout to $srv`:$port"
                                    $false
                                }
                                else {
                                    Try {
                                        $tcpclient.EndConnect($iar) | Out-Null
                                        $true
                                    }
                                    Catch {
                                        Write-Verbose -Message "Error for $srv`:$port`: $_"
                                        $false
                                    }
                                    $tcpclient.Close()
                                }
                            }
                        }

                        process {
                            foreach ($name in $computername) {
                                $dt = $cdt = Get-Date
                                Write-Verbose -Message "Testing: $Name"
                                $failed = 0
                                try {
                                    $DNSEntity = [Net.Dns]::GetHostEntry($name)
                                    $domain = ($DNSEntity.hostname).replace("$name.", "")
                                    $ips = $DNSEntity.AddressList | ForEach-Object -Process {
                                        if (-not (-not $IPV6 -and $_.AddressFamily -like "InterNetworkV6")) {
                                            $_.IPAddressToString
                                        }
                                    }
                                }
                                catch {
                                    $rst = New-Object -TypeName PSObject -Property $Hash | Select-Object -Property $props
                                    $rst.name = $name
                                    $results += $rst
                                    $failed = 1
                                }
                                Write-Verbose -Message "DNS:  $((New-TimeSpan $dt ($dt = Get-Date)).totalseconds)"
                                if ($failed -eq 0) {
                                    foreach ($ip in $ips) {

                                        $rst = New-Object -TypeName PSObject -Property $Hash | Select-Object -Property $props
                                        $rst.name = $name
                                        $rst.ip = $ip
                                        $rst.domain = $domain

                                        if ($RDP -or $All) {
                                            ####RDP Check (firewall may block rest so do before ping
                                            try {
                                                $socket = New-Object -TypeName Net.Sockets.TcpClient -ArgumentList $name,3389 -ErrorAction stop
                                                if ($null -eq $socket) {
                                                    $rst.RDP = $false
                                                }
                                                else {
                                                    $rst.RDP = $true
                                                    $socket.close()
                                                }
                                            }
                                            catch {
                                                $rst.RDP = $false
                                                Write-Verbose -Message "Error testing RDP: $_"
                                            }
                                        }
                                        Write-Verbose -Message "RDP:  $((New-TimeSpan $dt ($dt = Get-Date)).totalseconds)"
                                        #########ping
                                        if (Test-Connection $ip -count 2 -Quiet) {
                                            Write-Verbose -Message "PING:  $((New-TimeSpan $dt ($dt = Get-Date)).totalseconds)"
                                            $rst.ping = $true

                                            if ($WSMAN -or $All) {
                                                try {
                                                    ############wsman
                                                    Test-WSMan $ip -ErrorAction stop | Out-Null
                                                    $rst.WSMAN = $true
                                                }
                                                catch {
                                                    $rst.WSMAN = $false
                                                    Write-Verbose -Message "Error testing WSMAN: $_"
                                                }
                                                Write-Verbose -Message "WSMAN:  $((New-TimeSpan $dt ($dt = Get-Date)).totalseconds)"
                                                if ($rst.WSMAN -and $credssp) {
                                                    ########### credssp
                                                    try {
                                                        Test-WSMan $ip -Authentication Credssp -Credential $cred -ErrorAction stop
                                                        $rst.CredSSP = $true
                                                    }
                                                    catch {
                                                        $rst.CredSSP = $false
                                                        Write-Verbose -Message "Error testing CredSSP: $_"
                                                    }
                                                    Write-Verbose -Message "CredSSP:  $((New-TimeSpan $dt ($dt = Get-Date)).totalseconds)"
                                                }
                                            }
                                            if ($RemoteReg -or $All) {
                                                try {
                                                    ########remote reg
                                                    [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ip) | Out-Null
                                                    $rst.remotereg = $true
                                                }
                                                catch {
                                                    $rst.remotereg = $false
                                                    Write-Verbose -Message "Error testing RemoteRegistry: $_"
                                                }
                                                Write-Verbose -Message "remote reg:  $((New-TimeSpan $dt ($dt = Get-Date)).totalseconds)"
                                            }
                                            if ($RPC -or $All) {
                                                try {
                                                    ######### wmi
                                                    $w = [wmi] ''
                                                    $w.psbase.options.timeout = 15000000
                                                    $w.path = "\\$Name\root\cimv2:Win32_ComputerSystem.Name='$Name'"
                                                    $w | Select-Object none | Out-Null
                                                    $rst.RPC = $true
                                                }
                                                catch {
                                                    $rst.rpc = $false
                                                    Write-Verbose -Message "Error testing WMI/RPC: $_"
                                                }
                                                Write-Verbose -Message "WMI/RPC:  $((New-TimeSpan $dt ($dt = Get-Date)).totalseconds)"
                                            }
                                            if ($SMB -or $All) {

                                                #Use set location and resulting errors.  push and pop current location
                                                try {
                                                    ######### C$
                                                    $path = "\\$name\c$"
                                                    Push-Location -Path $path -ErrorAction stop
                                                    $rst.SMB = $true
                                                    Pop-Location
                                                }
                                                catch {
                                                    $rst.SMB = $false
                                                    Write-Verbose -Message "Error testing SMB: $_"
                                                }
                                                Write-Verbose -Message "SMB:  $((New-TimeSpan $dt ($dt = Get-Date)).totalseconds)"

                                            }
                                        }
                                        else {
                                            $rst.ping = $false
                                            $rst.wsman = $false
                                            $rst.credssp = $false
                                            $rst.remotereg = $false
                                            $rst.rpc = $false
                                            $rst.smb = $false
                                        }
                                        $results += $rst
                                    }
                                }
                                Write-Verbose -Message "Time for $($Name): $((New-TimeSpan $cdt ($dt)).totalseconds)"
                                Write-Verbose -Message "----------------------------"
                            }
                        }
                        end {
                            Write-Verbose -Message "Time for all: $((New-TimeSpan $total ($dt)).totalseconds)"
                            Write-Verbose -Message "----------------------------"
                            return $results
                        }
                    }

                    #Build up parameters for Test-Server and run it
                    $TestServerParams = @{
                        ComputerName = $Computer
                        ErrorAction  = "Stop"
                    }

                    if ($detail -eq "*") {
                        $detail = "WSMan", "RemoteReg", "RPC", "RDP", "SMB"
                    }

                    $detail | Select-Object -Unique | ForEach-Object -Process { $TestServerParams.add($_, $True) }
                    Test-Server @TestServerParams | Select-Object -Property $("Name", "IP", "Domain", "Ping" + $detail)
                }
                Catch {
                    Write-Warning "Error with Test-Server: $_"
                }
            }
            #We just want ping output
            else {
                Try {
                    #Pick out a few properties, add a status label.  If quiet output, just return the address
                    $result = $null
                    if ($result = @(Test-Connection -ComputerName $computer -Count 2 -erroraction Stop)) {
                        $Output = $result | Select-Object -first 1 -Property Address,
                        IPV4Address,
                        IPV6Address,
                        ResponseTime,
                        @{ label = "STATUS"; expression = { "Responding" } }

                        if ($quiet) {
                            $Output.address
                        }
                        else {
                            $Output
                        }
                    }
                }
                Catch {
                    if (-not $quiet) {
                        #Ping failed.  I'm likely making inappropriate assumptions here, let me know if this is the case : )
                        if ($_ -match "No such host is known") {
                            $status = "Unknown host"
                        }
                        elseif ($_ -match "Error due to lack of resources") {
                            $status = "No Response"
                        }
                        else {
                            $status = "Error: $_"
                        }

                        "" | Select-Object -Property @{ label = "Address"; expression = { $computer } },
                        IPV4Address,
                        IPV6Address,
                        ResponseTime,
                        @{ label = "STATUS"; expression = { $status } }
                    }
                }
            }
        }
    }
}
