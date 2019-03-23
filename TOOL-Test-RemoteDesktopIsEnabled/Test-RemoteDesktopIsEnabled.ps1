function Test-RemoteDesktopIsEnabled
{
<#
.SYNOPSIS
  Function to check if RDP is enabled

.DESCRIPTION
  Function to check if RDP is enabled

.EXAMPLE
  Test-RemoteDesktopIsEnabled

  Test if Remote Desktop is enabled on the current machine

.EXAMPLE
  Test-RemoteDesktopIsEnabled -ComputerName SERVER01,SERVER02

  Test if Remote Desktop is enabled on the remote machine SERVER01 and SERVER02

.NOTES
	Francois-Xavier Cat
	@lazywinadm
	www.lazywinadmin.com
	github.com/lazywinadmin
#>


PARAM(
  [String[]]$ComputerName = $env:COMPUTERNAME
  )
  FOREACH ($Computer in $ComputerName)
  {
    TRY{
      IF (Test-Connection -Computer $Computer -count 1 -quiet)
      {
        $Splatting = @{
          ComputerName = $Computer
          NameSpace = "root\cimv2\TerminalServices"
        }
        # Enable Remote Desktop
        [boolean](Get-WmiObject -Class Win32_TerminalServiceSetting @Splatting).AllowTsConnections

        # Disable requirement that user must be authenticated
        #(Get-WmiObject -Class Win32_TSGeneralSetting @Splatting -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null
      }
    }
    CATCH{
      Write-Warning -Message "Something wrong happened"
      Write-Warning -MEssage $Error[0].Exception.Message
    }
  }#FOREACH

}#Function