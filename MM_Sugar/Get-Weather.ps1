<# .SYNOPSIS
    Retreves wather using wttr.in

   .EXAMPLE
    wtr
#>
function Get-Weather($City=$Env:City) {
    if ($City -eq $null) {
        $City = Read-Host "Specify city"
        [Environment]::SetEnvironmentVariable("City", $City, "User")
    }
    (Invoke-WebRequest http://wttr.in/$City).ParsedHtml.getElementsByTagName("pre") | % { $_.outerText }
}

sal wtr Get-Weather
