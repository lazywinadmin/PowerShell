function Disable-RemoteDesktop
{
  <#
  .SYNOPSIS
    Function remotely disable RDP
  .DESCRIPTION
    Function remotely disable RDP
  .NOTES
    Francois-Xavier Cat
    @lazywinadm
    www.lazywinadmin.com

    # MSDN/TechNet doc
    https://msdn.microsoft.com/en-us/library/aa383644%28v=vs.85%29.aspx
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
        (Get-WmiObject -Class Win32_TerminalServiceSetting @Splatting).SetAllowTsConnections(0,0) | Out-Null
        
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