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
        $r += Get-EventLog $_ | ? { $_.EntryType -eq 'Error' }
    }
    $r
}

sal err Get-EventLogsErrors
