<#
.SYNOPSIS
    Kill process using a given network port

.DESCRIPTION
    The function uses netstat to find a process using given port and kill it.
#>
function Stop-ProcessByPort( [ValidateNotNullOrEmpty()] [int] $Port ) {    
    $netstat = netstat.exe -ano | select -Skip 4
    $p_line  = $netstat | ? { $p = (-split $_ | select -Index 1) -split ':' | select -Last 1; $p -eq $Port } | select -First 1
    if (!$p_line) { Write-Host "No process found using port" $Port; return }    
    $p_id = $p_line -split '\s+' | select -Last 1
    if (!$p_id) { throw "Can't parse process id for port $Port" }
    
    $proc = Get-WmiObject win32_process -Filter "ProcessId = $p_id"
    if (!$proc) { Write-Host "Process with pid $p_id using port $Port is no longer running" }
    $proc.Terminate() | Out-Null

    #$p_name = ps -Id $p_id -ea 0 | kill -Force -PassThru | % ProcessName
    Write-Host "Process killed: $($proc.Name) (id $p_id) using port" $Port   
    Write-Host "  " $proc.Path
    Write-Host "  " $proc.CommandLine 
}

sal killp Stop-ProcessByPort
killp 3001
