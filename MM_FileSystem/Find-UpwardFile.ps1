<#
    Last Change: 23-Jan-2016.
    Modified: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Finds the desired file by serarching upwards in the directory hieararchy
.EXAMPLE
    PS C:\Windows\System32> Find-UpwardFile explorer.exe

    Returns C:\Windows\explorer.exe
#>

function Find-UpwardFile {
    [CmdletBinding()]
    param(
        # Name of the file system object which location is searched for
        [string]$Name,
        # Directory path from which to start searching upward, by default current directory
        [string]$StartDir=".",
        # Set to return the parent
        [switch]$ReturnParent,
        # Set to return the file system object instead of string path
        [switch]$ReturnObject
    )

    $diStartDir = gi "$StartDir"
    if (!$?) { throw "Start directory doesn't exist: $StartDir" }

    while ($diStartDir.GetFileSystemInfos($Name).Length -eq 0)
    {
        $diStartDir = $diStartDir.Parent
        if ($diStartDir -eq $null) {return $null}
    }

    $o = $diStartDir.GetFileSystemInfos($Name)[0]
    if ($ReturnParent) {
        if ($o.Parent -ne $null) {
            if ($ReturnObject) { $o.Parent } else {$o.Parent.FullName }
        }
        else {
            if ($ReturnObject) { $o.Parent } else {$o.Directory.FullName}
        }
    } else {
        if ($ReturnObject) {$o} else {$o.FullName}
    }
}
