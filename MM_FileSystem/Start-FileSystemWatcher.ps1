<#
    Last Change: 14-Feb-2016.
    Modified: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Monitor directory for changes and call user action
.NOTE
    # Adapted from: https://mcpmag.com/articles/2015/09/24/changes-to-a-folder-using-powershell.aspx
#>
function Start-FileSystemWatcher  {
    [cmdletbinding()]
    Param (
        [string]$Path=$pwd,
        [ValidateSet('Changed','Created','Deleted','Renamed')]
        [string[]]$EventName= @('Changed','Created','Deleted','Renamed'),
        [string]$Filter,
        [System.IO.NotifyFilters]$NotifyFilter="FileName, DirectoryName, Attributes, Size, LastWrite, LastAccess, CreationTime, Security",
        [switch]$Recurse,
        [scriptblock]$Action,
        [int]$Throttle=-1
    )

    $FileSystemWatcher  = New-Object  System.IO.FileSystemWatcher
    $FileSystemWatcher.Path = $Path
    $FileSystemWatcher.Filter = $Filter
    $FileSystemWatcher.NotifyFilter =  $NotifyFilter
    $FileSystemWatcher.IncludeSubdirectories = $Recurse

    $FullAction= {
        switch  ($Event.SourceEventArgs.ChangeType) {
            'Renamed'  {
                $msg  = "{0} was {1} to {2} at {3}" -f $Event.SourceArgs[-1].OldFullPath, $Event.SourceEventArgs.ChangeType,
                                                       $Event.SourceArgs[-1].FullPath, $Event.SourceEventArgs.TimeGenerated
            }
            default  { $msg  = "{0} was {1} at {2}" -f $Event.SourceEventArgs.FullPath, $Event.SourceEventArgs.ChangeType, $Event.TimeGenerated }
        }
        $whcolors  = @{ ForegroundColor = 'Green'; BackgroundColor = 'Black' }
        Write-Host @whcolors $msg
        Write-Host @whcolors "Executing user action"
        $res = iex $event.MessageData
        Write-Host @whcolors "User action result: $res"
    }

    $ObjectEventParams  = @{ InputObject = $FileSystemWatcher; Action = $FullAction; MessageData = $Action }
    forEach  ($Item in $EventName) {
        $ObjectEventParams.EventName = $Item
        $ObjectEventParams.SourceIdentifier =  "File.$($Item)"
        Write-Verbose  "Starting watcher for Event: $($Item)"
        Register-ObjectEvent  @ObjectEventParams | out-null
    }
}
