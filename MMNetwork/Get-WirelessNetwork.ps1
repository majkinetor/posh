# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 24-Jun-2015.

#requires -version 3

<#
.SYNOPSIS
    List wireless networks

.DESCRIPTION
    Uses netsh wlan to get wireless network information in Powershell friendly way.
.NOTES
    This is a wrapper for english locale of netsh wlan.
#>
function Get-WirelessNetwork() {
    [CmdletBinding()]
    param(
        # List of Regex criteria for SSID. Ommit to get everything.
        [string[]]$SSID,

        #Controls if results are passed to format-table cmdlet or not.
        [switch]$List
    )

    if ((gwmi win32_operatingsystem).Version.Split(".")[0] -lt 6) { throw "Requires Windows Vista or higher." }
    if ((gsv "wlansvc").Status -ne "Running" ) { throw "Wlan service is not running." }

    $ifaces = netsh wlan show interfaces | sls '^\s*Name\s*:\s*(.+)\s*' | % { $_.matches[0].Groups[1].Value }

    $props = @( 'SSID', 'Authentication', 'Encryption', 'Signal', 'Radiotype', 'Channel', 'BSSID', 'Interface' )
    $nt = "" | select -Property $props
    $n  = $nt.PSObject.Copy()
    $results = @()
    $ifaces | % {
        $iface = $_
        while(1) {
            $netsh = netsh wlan show network mode=bssid interface="$iface" #repeat command until we get all the data
            if ($netsh -match 'Signal') { break }
            sleep -Milliseconds 200
        }

        $netsh | select -Skip 4 | % {
            if (!$_) { $n.Interface = $iface; $results += $n; $n = $nt.PSObject.Copy(); return }
            $a =  $_ -split ' : '
            $p = $a[0].Trim() -replace '[ \d]*'; $v = $a[1].Trim()
            if ($props -contains $p) { $n.$p = $v }
        }
    }
    $r = $results
    if ($SSID) {
        $SSID | % {$re=""}{ $re += "({0})|" -f $_ }; $re = $re -replace '.$'
        $r = $results | ? SSID -match $re
    }
    $r = $r | sort {[int]($_.Signal -replace "%")} -Descending
    if ($List) { $r } else { $r | ft }
}
