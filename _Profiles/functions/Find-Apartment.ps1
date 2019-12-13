Function Find-Apartment {
    <#
    .SYNOPSIS
        Allow you search Appartement in craigslist
    .DESCRIPTION
    .NOTES
        #http://masterrex.com/?p=64
    #>
    param (
        [Parameter(Mandatory = $False)]$MinPrice = "0",
        [Parameter(Mandatory = $False)]$MaxPrice = "9999",
        [Parameter(Mandatory = $False)]$MaxPages = "1",
        [Parameter(Mandatory = $False)]$URL = "http://burlington.craigslist.org"
    )
    $AvailableRooms = @()
    For ($CurrentPage = 0; $CurrentPage -le $MaxPages; $CurrentPage++) {
        $WebPage = Invoke-WebRequest "$URL/search/roo?=roo&s=$Start&query=&zoomToPosting=&minAsk=$MinPrice&maxAsk=$MaxPrice&hasPic=1"
        $Results = $WebPage.ParsedHtml.body.innerHTML.Split("`n") | Where-Object -FilterScript { $_ -like "<P class=row*" }
        ForEach ($Item in $Results) {
            $ItemObject = $ID = $Price = $DatePosted = $Neighborhood = $Link = $Description = $Email = $null
            $ID = ($Item -replace ".*pid\=`"", "") -replace "`".*"
            $Price = ($Item -replace ".*class=price>", "") -replace "</SPAN>.*"
            $DatePosted = ($Item -replace ".*class=date>", "") -replace "</SPAN>.*"
            $Neighborhood = ($Item -replace ".*\<SMALL\>\(", "") -replace "\)\</SMALL>.*"
            If ($Neighborhood -like "<*") { $Neighborhood = "N/A" }
            $Link = $URL + ((($Item -replace ".*\<A href\=`"", "") -replace "\<.*") -split ('">'))[0]
            $Email = (($(Invoke-WebRequest $Link).ParsedHtml.body.innerHTML.Split("`n") | Where-Object -FilterScript { $_ -like "var displayEmail*" }) -replace "var displayEmail \= `"") -replace "`";"
            $Description = ((($Item -replace ".*\<A href\=`"", "") -replace "\<.*") -split ('">'))[1]
            $ItemObject = New-Object -TypeName PSObject -Property @{
                'ID'           = $ID
                'Price'        = $Price
                'DatePosted'   = $DatePosted
                'Neighborhood' = $Neighborhood
                'Link'         = $Link
                'Description'  = $Description
                'E-Mail'       = $Email
            }
            #$AvailableRooms += $ItemObject
            $ItemObject
        }
    }
    #Return $AvailableRooms
}