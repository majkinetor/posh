function Wait-Action ([ScriptBlock]$Action, [int]$Timeout=20, [string] $Message) {
    Write-Host "Waiting for action to succeed up to $Timeout seconds"
    Write-Host "|== $Message"

    $start = Get-Date
    while ($true) {
        $elapsed = ((Get-Date) - $start).TotalSeconds
        if ($elapsed -ge $Timeout) {break}

        $j = Start-Job $Action
        $maxWait = [int]($Timeout-$elapsed)
        if ($maxWait -lt 1) { $maxWait = 1 }
        Wait-Job $j -Timeout $maxWait | Out-Null

        if ($j.State -eq 'Running') { $err = 'still running'; break }
        if ($j0 = $j.ChildJobs[0]) {
            if ($err = $j0.Error) { continue }
            if ($err = $J0.JobStateInfo.Reason) {continue}
        }
        try { Receive-Job $j -ErrorAction STOP | Out-Null; } catch { $err = "$_"; continue }

        Write-Host "Action succeded"; return
    }

    throw "Action timedout. Last error: $err"  
}
