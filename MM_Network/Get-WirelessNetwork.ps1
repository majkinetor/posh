﻿# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 16-Nov-2016.

#requires -version 3

<#
.SYNOPSIS
    List wireless networks

.DESCRIPTION
    Uses netsh wlan to get wireless network information in Powershell friendly way.

.EXAMPLE
    Get-WirelessNetwork

    Get all visible wireless networks.

.EXAMPLE
    Get-WirelessNetwork android

    Get only wireless networks that have android in its name.

.EXAMPLE
    Get-WirelessNetwork | ? Authentication -eq 'open'

    Get only wireless networks with open authentication.

.EXAMPLE
    Get-WirelessNetwork | ? { [int]$_.Signal -gt 70 }

    Get only wireless networks with signal stronger then 70%
#>
function Get-WirelessNetwork() {
    [CmdletBinding()]
    param(
        # List of Regex criteria for SSID. Ommit to get everything.
        [string[]]$SSID
    )
Write-Verbose $PSCmdlet.MyInvocation.PipelinePosition

    if (([int](gwmi win32_operatingsystem).Version.Split(".")[0]) -lt 6) { throw "Requires Windows Vista or higher." }
    if ((gsv "wlansvc").Status -ne "Running" ) { throw "Wlan service is not running." }

    $ifaces = netsh wlan show interfaces
    $ifaces_names = $ifaces | sls '^\s*Name\s*:\s*(.+)\s*' | % { $_.matches[0].Groups[1].Value }

    $props = @( 'SSID', 'Authentication', 'Encryption', 'Signal', 'Radiotype', 'Channel', 'BSSID', 'Interface', 'Status' )
    $nt = "" | select -Property $props
    $n  = $nt.PSObject.Copy()
    $results = @()
    $ifaces_names | % {
        $iface = $_
        while(1) {
            $netsh = netsh wlan show network mode=bssid interface="$iface" #repeat command until we get all the data
            if ($netsh -match 'Signal') {
                $iface_profiles = netsh wlan show profile interface="$iface"
                break
            }
            sleep -Milliseconds 300
        }

        $netsh | select -Skip 4 | % {
            if (!$_) {
                $n.Interface = $iface
                $n.Signal = $n.Signal -replace '.$'

                $status = $ifaces | sls "^\s*SSID\s*:\s*$($n.SSID)\s*" -Context 1,0
                $status = $status -split "\n|:" | select -Index 1 | % Trim
                if ($status -eq 'connected') { $n.Status = "Connected" }
                elseif ($iface_profiles -match $n.SSID) { $n.Status = "Disconnected" }

                $results += $n; $n = $nt.PSObject.Copy()
                return
            }
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
    $r
}
