
<#
.SYNOPSIS
    List top process relative to CPU load.
#>
function Get-CPULoad([switch]$NoLoop, [int]$Top=20, [string]$Computer) {

    $cpu = { Get-Counter '\Process(*)\% Processor Time' -ea 0 |% countersamples | select -Property instancename, cookedvalue |
                sort CookedValue -Descending | select -First $using:Top |
                ft @{L='Process'; E={$_.InstanceName.PadRight(30)}}, @{L='CPU'; E={($_.Cookedvalue/100).toString('P')}}
    }

    if ($NoLoop) { . $cpu; return }
    rjb top -ea 0
    while($true) {
        Start-Job -Name top -ScriptBlock $cpu | Out-Null
        Wait-Job top | Out-Null
        cls
        Receive-Job top
        rjb top
    }
}
sal top Get-CpuLoad

