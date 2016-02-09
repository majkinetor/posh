<# .SYNOPSIS
    Returns all scheduled tasks under the username Path in Task Scheduler
#>

function Show-UserTasks() { Get-ScheduledTask -TaskPath *$Env:USERNAME* }
sal tasks Show-UserTasks
