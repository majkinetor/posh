# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 25-Jun-2015.

#requires -version 3

<#
.SYNOPSIS
    Disconnect from wireless network interface and eventually remove profile for given SSID
#>
function Disconnect-WirelessNetwork() {
    [CmdletBinding()]
    param(
        # Wireless network name
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$SSID,

        # Force profile removal
        [switch]$Remove
    )
    netsh wlan disconnect
    if ($Remove) { netsh wlan delete profile name=$SSID }

}
