function Get-Accelerators {
    [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::get
}