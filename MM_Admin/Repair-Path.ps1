#requires -version 3
#http://stackoverflow.com/questions/4405091/how-do-you-avoid-over-populating-the-path-environment-variable-in-windows

<#
    Last Change: 10-Feb-2016.
    Author: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Cleanup and minimize the machine PATH variable.

.EXAMPLE
    PS> Repair-Path -Whatif
#>
function Repair-Path() {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        #Asks for each path whether to remove it
        [switch]$Interactive,
        #Convert paths to short names to make up more space
        [switch]$Shrink,
        #Convert all short paths to long names
        [switch]$Expand
        #[switch]$UseSymbolicLinks,
        #[switch]$RestoreBackup
    )

    function check_path_len( $path ) {
        if ($path.length -gt 2048)  { Write-Warning "Path length is longer then 2048 chars, some tools might not work correctly." }
        if ($path.length -gt 32767) { Write-Warning "Path length is longer then 32768 chars which is not supported by Windows."}
    }

    function choice () {
        $choices = [ordered]@{
            keep   = "&Keep", "Keep the path"
            remove = "&Remove", "Remove the path"
            stop   = "&Stop", "Stop interactive mode"
        }

        $c = @()
        $choices.GetEnumerator() | % { $c += New-Object System.Management.Automation.Host.ChoiceDescription $_.Value[0], $_.Value[1] }
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($c[0], $c[1], $c[2])
        $res = $host.ui.PromptForChoice($null, $v.dir, $options, 0)

        $choices.keys -split '\n'| select -Index $res
    }

    function double() {
        $d = $v.npath.Contains($v.dir + $v.sep) -or $v.npath.Contains($v.edir + $v.sep)
        $d = $d -or $v.npath.Contains( $v.dir + '\' + $v.sep) -or $v.npath.Contains( $v.edir + '\' + $v.sep )
        if (!$d) { return $false }

        $s.Duplicates += 1
        Write-Verbose "Duplicate removed: $($v.dir)"
        return $true
    }

    function invalid() {
        if (Test-Path $v.edir) { return $false}

        $s.Removed += $v.dir
        Write-Verbose "Path doesn't exist: $($v.dir)"
        return $true
    }

    function show_stats() {
        "Path modified:"
        "  Duplicates: $($s.Duplicates)"
        "  Empty paths: $($s.Empty)"
        "  Trailing separators: $($s.Trails)"

        "  Non existent: $($s.Removed.length)"
        $s.Removed | % { "    $_" }

        if ($Interactive) {
            "User selected: $($s.user.length)"
            $s.user | % { "    $_" }
        }
        "Old path length: $($v.path.length)"
        "New path length: $($v.npath.length)"
        check_path_len $v.npath
    }

    function shrink($Path) {
    $code = @'
[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError=true)]
public static extern uint GetShortPathName(string longPath,
StringBuilder shortPath,uint bufferSize);
'@
        $API = Add-Type -MemberDefinition $code -Name Path -UsingNamespace System.Text -PassThru
        $shortBuffer = New-Object Text.StringBuilder ($Path.Length * 2)
        $rv = $API::GetShortPathName( $Path, $shortBuffer, $shortBuffer.Capacity )
        if ($rv -ne 0) {
            $shortBuffer.ToString()
        } else { Write-Warning "Can't get short name for the path: $Path" }
    }

    function expand($path) {
        gi $path | select -ExpandProperty Fullname
    }

    function Test-Admin() {
        $usercontext = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        $usercontext.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    }

    # ===============================================

    $s=@{Removed = @(); User = @(); Duplicates = 0; Empty = 0; Trails = 0 }     #stats
    $v=@{path=''; npath=''; sep=';'; dir=''; edir=''}          #vars to share with nested funcs

    ""
    $v.path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if (!$v.path.EndsWith( $v.sep )) { $v.path += $v.sep }

    $answer = 'keep'
    $v.path -split $v.sep | % {
        if ($_.Trim() -eq '') {  $s.Empty += 1; return }
        $v.dir = $_
        $v.edir = [System.Environment]::ExpandEnvironmentVariables($v.dir)

        if ( double ){ return }
        if ( invalid) { return }

        if ($Interactive) { $answer = choice }
        if (('keep','stop') -contains $answer) {
            if ($answer -eq 'stop') { Write-Verbose "User stopped interaction"; $answer = 'keep'; $Interactive = $false }

            if ($v.dir.EndsWith("\")) { $v.dir = $v.dir -replace '.$'; $s.Trails += 1 }

            if ($Shrink) { $v.dir = shrink $v.dir }
            if ($Expand) { $v.dir = expand $v.dir }
            $v.npath += $v.dir + $v.sep
        }

        if ($answer -eq 'remove' ) {
            Write-Verbose "User removed path: $v.dir"
            $s.user += $v.dir
        }
    }

    if ($v.npath -eq $v.path ) { check_path_len $v.path; "Path not changed"; return }

    if( $pscmdlet.ShouldProcess("PATH environment variable", "Update") )
    {
        if (!(Test-Admin)) { throw "Setting the PATH requires administrative rights" }

        [Environment]::SetEnvironmentVariable("PATH", $v.npath, "Machine")
        $backupPath = "PATH_" + (get-date).ToString("yyyy-MM-dd_HHmmss")
        [Environment]::SetEnvironmentVariable($backupPath, $v.path, "Machine")
        "Old path backed up in the environment variable $backupPath"

        $Env:Path = $v.npath
    } else { "Path not changed, only results are shown:" }

    show_stats
    $v.npath
}

#Repair-Path -WhatIf:$true -Verbose -Shrink
