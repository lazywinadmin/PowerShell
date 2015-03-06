function Test-RemoteDesktop
{
  <#
  .SYNOPSIS
    Function to check if RDP is enabled
  .DESCRIPTION
    Function to check if RDP is enabled
  .NOTES
    Francois-Xavier Cat
    @lazywinadm
    www.lazywinadmin.com
  #>
  
PARAM(
  [String[]]$ComputerName
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