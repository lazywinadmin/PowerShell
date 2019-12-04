Function Lock-Computer {
    <#
.DESCRIPTION
    Function to Lock your computer
.SYNOPSIS
    Function to Lock your computer.
    This is using the win32 user32.dll library.
.EXAMPLE
    Lock-Computer

    This will lock the current computer
#>

    $signature = @"
[DllImport("user32.dll", SetLastError = true)]
public static extern bool LockWorkStation();
"@

    $LockComputer = Add-Type -memberDefinition $signature -name "Win32LockWorkStation" -namespace Win32Functions -passthru
    $LockComputer::LockWorkStation() | Out-Null
}