function Test-DatePattern {
    #http://jdhitsolutions.com/blog/2014/10/powershell-dates-times-and-formats/
    $patterns = "d", "D", "g", "G", "f", "F", "m", "o", "r", "s", "t", "T", "u", "U", "Y", "dd", "MM", "yyyy", "yy", "hh", "mm", "ss", "yyyyMMdd", "yyyyMMddhhmm", "yyyyMMddhhmmss"

    Write-Host "It is now $(Get-Date)" -ForegroundColor Green

    foreach ($pattern in $patterns) {

        #create an Object
        [pscustomobject]@{
            Pattern = $pattern
            Syntax  = "Get-Date -format '$pattern'"
            Value   = (Get-Date -Format $pattern)
        }

    } #foreach

    Write-Host "Most patterns are case sensitive" -ForegroundColor Green
}
