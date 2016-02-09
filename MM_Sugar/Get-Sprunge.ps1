# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 09-Feb-2016.

<#
.SYNOPSIS
    The client for the sprunge.us that lets you paste stuff online easily

.EXAMPLE
    PS> ls | sprunge

    Send content of the directory

.EXAMPLE
    PS> cat file.ps1 | sprunge ps1 -Open

    Send content of the file, highlight powershell and open it in the browser
#>
function get-sprunge([string]$FileType=".", [switch]$Open) {
    if (!(gcm curl.exe -ea 0)) { throw 'Sprunge requires curl. Use cinst curl.exe' }
    $url = $input | curl.exe -s -F 'sprunge=<-' -H  "Expect: " http://sprunge.us
    $url += "?$FileType"
    $url | clip
    if ($Open) { start $url }
    $url
}

sal sprunge get-sprunge
sal spaste get-sprunge
