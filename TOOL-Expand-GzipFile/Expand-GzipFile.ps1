Function Expand-GZipFile
{
<#
.Synopsis
    Unzip a gz file
.Notes
    Change History
    1.0 | 2019/03/22 | francois-xavier cat (@lazywinadmin)
        based on https://social.technet.microsoft.com/Forums/windowsserver/en-US/5aa53fef-5229-4313-a035-8b3a38ab93f5/unzip-gz-files-using-powershell?forum=winserverpowershell
        add comment based help, error handling, missing parameters
        rename variables
.Example
    Expand-GZipFile -LiteralPath C:\tmp\lazywinadmin-2019.xml.gz -outfile C:\tmp\lazywinadmin-2019.xml

    Will expand the content of C:\tmp\lazywinadmin-2019.xml.gz to C:\tmp\lazywinadmin-2019.xml

.Example
    Expand-GZipFile -LiteralPath C:\tmp\lazywinadmin-2019.xml.gz

    Will expand the content of C:\tmp\lazywinadmin-2019.xml.gz to C:\tmp\lazywinadmin-2019.xml
#>
[CmdletBinding()]
Param(
    [ValidateScript({Test-path -Path $_})]
    [String]$LiteralPath,
    $outfile = ($LiteralPath -replace '\.gz$','')
)
try{
    $FileStreamIn = New-Object -TypeName System.IO.FileStream -ArgumentList $LiteralPath, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
    $output = New-Object -TypeName System.IO.FileStream -ArgumentList $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
    $GzipStream = New-Object -TypeName System.IO.Compression.GzipStream -ArgumentList $FileStreamIn, ([IO.Compression.CompressionMode]::Decompress)

    # Create  Buffer
    $buffer = New-Object -TypeName byte[] -ArgumentList 1024
    while($true){
        $read = $GzipStream.Read($buffer, 0, 1024)
        if ($read -le 0){break}
        $output.Write($buffer, 0, $read)
    }

    $GzipStream.Close()
    $output.Close()
    $FileStreamIn.Close()
}catch{
    throw $_
    if($GzipStream){$GzipStream.Close()}
    if($output){$output.Close()}
    if($FileStreamIn){$FileStreamIn.Close()}
}
}
