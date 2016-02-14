<#
.SYNOPSIS
    Set the DNS list for the interface

.EXAMPLE
    PS> Set-dns 10.32.34.192 @('8.8.8.8','4.4.4.4')

    Set the primary and secundary DNS for the interface with IP address 10.32.34.192
#>
function set-dns( [string]$ip, [string[]] $dnsList) {
    $Interface = Get-WmiObject Win32_NetworkAdapterConfiguration | ? { $_.IpAddress -eq $ip }
    $Interface.SetDNSServerSearchOrder($dnsList)
}

