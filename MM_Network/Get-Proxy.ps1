# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 22-Feb-2016.

#requires -version 3

<#
.SYNOPSIS
    Detect proxy for the url
#>

function Get-Proxy( [string]$Url = 'http://www.google.com' ) {
    $client = New-Object System.Net.WebClient
    if ($client.Proxy.IsBypassed($Url)) { return $null }
    $proxyAddr = $client.Proxy.GetProxy($url).Authority
    return $proxyAddr
}
