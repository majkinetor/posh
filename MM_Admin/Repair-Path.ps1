#http://stackoverflow.com/questions/4405091/how-do-you-avoid-over-populating-the-path-environment-variable-in-windows

# some duplicate paths end with /
# whatif
# admin on UAC 
# %...% in path
function Repair-Path() {
    [CmdletBinding()]
    param(
        [switch]$ToShortNames,
        [switch]$ToLongNames,
        [switch]$UseSymbolicLinks,
        [switch]$ExpandVariables,
        [switch]$Interactive,
        [switch]$RestoreBackup
    )

    function show_path_len( $path ) {
        if ($path.length -gt 2048)  { Write-Warning "Path length is longer then 2048 chars, some tools might not work correctly." }
        if ($path.length -gt 32767) { Write-Warning "Path length is longer then 32768 chars which is not supported by Windows."}
    }

    function choice ($path) {
        $message = $path
        $keep    = New-Object System.Management.Automation.Host.ChoiceDescription "&Keep", "Keep the path"
        $remove  = New-Object System.Management.Automation.Host.ChoiceDescription "&Remove", "Delete the path"
        $stop    = New-Object System.Management.Automation.Host.ChoiceDescription "&Stop", "Stop the questions"
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($keep, $remove, $stop)
        $result  = $host.ui.PromptForChoice($null, $message, $options, 0)
        $result
    }

    $sep=";"

    $path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if (!$path.EndsWith( $sep )) { $path += $sep }

    $dirs = $path -split $sep

    $res = ''; $removed=@(); $dups=0; $empty=0; $user=@(); $answer = 0;
    $dirs | % {
        $dir = $_
        if ($dir.Trim() -eq '') {  $empty+=1; return }

        if ($res.Contains($dir + $sep)) { $dups += 1; Write-Verbose "Duplicate removed: $dir" }
        elseif (!(Test-Path $dir)) { $removed += $dir }
        else {
            if ($Interactive -and !$stop) { ""; $answer = choice $dir }
            if ($answer -eq 0) { $res += $dir + $sep }
            elseif ($answer -eq 1 ) {
                Write-Verbose "User removed path: $dir"
                $user += $dir
            }
            else {
                Write-Verbose "User stopped interaction"
                $stop = $true; $answer = 0;  $res += $dir + $sep
            }
        }
    }
    if ($res -eq $path ) { show_path_len $res; "Path not changed"; return }

    "Duplicates removed: $dups"
    "Empty paths removed: $empty"
    "Path doesn't exist: $($removed.length)"
    $removed | % { "  $_" }
    if ($Interactive) { 
        "User removed paths: $($user.length)"
        $user | % { "  $_" }
    }
    "Old path length: $($path.length)"
    "New path length: $($res.length)"
    show_path_len $res

    [Environment]::SetEnvironmentVariable("PATH", $res, "Machine")
    $backupPath = "PATH_" + (get-date).ToString("yyyy-MM-dd_HHmmss")
    [Environment]::SetEnvironmentVariable($backupPath, $path, "Machine")
    "Old path backed up in environment variable $backupPath"

    $Env:Path = $res
}

Repair-Path -Verbose -Interactive
