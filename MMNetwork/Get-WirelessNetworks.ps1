# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 23-Jun-2015.

#requires -version 3

<#
.SYNOPSIS
    List given interface wireless networks

.DESCRIPTION
    Uses netsh wlan to get wireless network information in Powershell friendly way.
    By default uses Wi-Fi interface name.
#>
function Get-WirelessNetworks([string]$Interface='Wi-Fi') {

    if ((gwmi win32_operatingsystem).Version.Split(".")[0] -lt 6) { throw "Requires Windows Vista or higher." }
    if ((gsv "wlansvc").Status -ne "Running" ) { throw "Wlan service is not running." }

    $props = @( 'SSID', 'Authentication', 'Encryption', 'Signal', 'Radiotype', 'Channel', 'BSSID' )

    $nt = "" | select -Property $props
    $n  = $nt.PSObject.Copy()
    $results = @()
    netsh wlan show network mode=bssid interface=$Interface | select -Skip 4 | % {
        if (!$_) { $results += $n; $n = $nt.PSObject.Copy(); return }
        $a =  $_ -split ' : '
        $p = $a[0].Trim() -replace '[ \d]*'; $v = $a[1].Trim()
        if ($props -contains $p) { $n.$p = $v }
    }
    $results
}
