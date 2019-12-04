function View-Cats {
    <#
    .SYNOPSIS
        This will open Internet explorer and show a different cat every 5 seconds
    .DESCRIPTION
    .NOTES
        #http://www.reddit.com/r/PowerShell/comments/2htfog/viewcats/
    #>
    Param(
        [int]$refreshtime = 5
    )
    $IE = New-Object -ComObject internetexplorer.application
    $IE.visible = $true
    $IE.FullScreen = $true
    $shell = New-Object -ComObject wscript.shell
    $shell.AppActivate("Internet Explorer")

    while ($true) {
        $request = Invoke-WebRequest -Uri "http://thecatapi.com/api/images/get" -Method get
        $IE.Navigate($request.BaseResponse.ResponseUri.AbsoluteUri)
        Start-Sleep -Seconds $refreshtime
    }
}
