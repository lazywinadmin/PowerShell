function Enable-RemoteDesktop
{
  <#
  .SYNOPSIS
    Function remotely enable RDP
  .DESCRIPTION
    Function remotely enable RDP
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
          NameSpace = rootcimv2TerminalServices
        }
        # Enable Remote Desktop
        (Get-WmiObject -Class Win32_TerminalServiceSetting @Splatting).SetAllowTsConnections(1,1) | Out-Null
        
        # Disable requirement that user must be authenticated
        #(Get-WmiObject -Class Win32_TSGeneralSetting @Splatting -Filter TerminalName='RDP-tcp').SetUserAuthenticationRequired(0)  Out-Null
      }
    }
    CATCH{
      Write-Warning -Message Something wrong happened
      Write-Warning -MEssage $Error[0].Exception.Message
    }
  }#FOREACH
  
}#Function