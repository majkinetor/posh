# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 14-Feb-2016.

#requires -version 3.0

<#
.SYNOPSIS
    Connect to the VPN network

.EXAMPLE
    PS> connect-vpn myvpn\companyXYZ

    Connect to the VPN network using configuration file myvpn\companyXYZ.

.EXAMPLE
    PS> vpnc myvpn\companyXYZ -Timeout 120

    Connect to the VPN network in the background job. Terminate the job after 120s if still running.
#>
function connect-vpn( [string] $ConfigPath, [int] $Timeout = -1 ) {
    $log = "$PSScriptRoot\vpn.log"

    "-"*50 | tee $log -Append
    "Connet-VPN started at " + [DateTime]::UtcNow.ToString("s").Replace(':','-') | tee $log -Append

    if ($Timeout -eq -1) { connect-vpnfg $ConfigPath | tee $log -Append }
    else { connect-vpnbg $ConfigPath $Timeout | tee $log -Append }
}

function connect-vpnfg( [string]$ConfigPath ) {
    $ConfigPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ConfigPath)
    if (!(Test-Path $ConfigPath)) { throw "Unable to find config path: $ConfigPath" }

    $name = Split-Path -Leaf $ConfigPath
    "Connecting to VPN network using configuration '$name'"

    ps vpnui -ea 0 | kill | out-null            #vpncli doesn't work along with vpnui
    disconnect-vpn | out-null
    gc $ConfigPath | vpncli -s | compact-log
    vpnui

    "Connected to VPN network using configuration '$name'"
}

function connect-vpnbg( [string] $ConfigPath, [int] $Timeout ) {
    $script = [scriptblock]::Create(@"
        . $PSScriptRoot\vpn.ps1
        connect-vpnfg $ConfigPath
"@)
    $job = Start-Job -script $script -name (Split-Path -leaf $ConfigPath)
    "Started background vpn connection: $($job.Name)"
    wait-job $job -Timeout $Timeout
    if ($job.State -eq 'Running') { "Timeout exceeded, terminating job" }

    $out = receive-job $job; remove-job $job -force
    $out
}

<#
.SYNOPSIS
    Disconnect from the VPN network
#>
function disconnect-vpn() {
    "Disconnecting from VPN network"
    vpncli disconnect
}

function compact-log() {
    process {
        $res = $_ -split '\n' | ? { $_.Trim(); ($_ -ne '') -or ($_ -eq 'VPN>') }
        $res = $res | ? { $_ = $_.Trim(); $_ -ne '' -and $_ -ne 'VPN>'}
        $res
    }
}

function find-anyconnect() {
    if ((gcm vpncli,vpnui -ea 0).count -eq 2) { return }

    Get-ApplicationUninstallKey "cisco anyconnect" | select -First 1 -expand UninstallString | set ac
    if ($ac) { $ac = Split-Path $ac }
    if (!(Test-Path $ac)) {
        $ac = "c:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client"
        if (!(Test-Path $ac)) { $ac = "c:\Program Files\Cisco\Cisco AnyConnect Secure Mobility Client" }
        if (!(Test-Path $ac)) { throw 'Unable to find Cisco AnnyConnect Secure Mobility Client' }
    }

    sal -scope global vpncli "$ac\vpncli.exe"
    sal -scope global vpnui  "$ac\vpnui.exe"
}

function Get-ApplicationUninstallKey([string]$AppName)
{
    $local_key       = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $machine_key     = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $machine_key6432 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    gp @($machine_key6432, $machine_key, $local_key) -ea 0 | ? { $_.DisplayName -like "*$AppName*" }
}

sal vpnd disconnect-vpn
sal vpnc connect-vpn
find-anyconnect
