<#
.SYNOPSIS
    Clear all event logs
#>
function Clear-EventLogs {
    Get-EventLog * | % { Clear-EventLog $_.Log }
    Get-EventLog *
}

<#
.SYNOPSIS
    Get latest event log errors
#>
function Get-EventLogsErrors( [int] $First=50 ) {
    $r = @()
    Get-EventLog * | select -Expand Log | % {
        $l = $_
        try {
            $r += Get-EventLog $l -ea 0 | ? { $_.EntryType -eq 'Error' }
        }
        catch { Write-Warning "$($l): $_" }
    }
    $r
}

sal err Get-EventLogsErrors
