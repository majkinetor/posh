<#
    Last Change: 14-May-2015.
    Author: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Add given directory to the machine PATH environment variable in an
    idempotent way.

.PARAMETER path
    Absolute or relative directory path. If ommited, defaults to $pwd.
#>
function AddTo-Path($path=$pwd)
{
   $path=(gi $path).FullName
   if (!(Test-Path $path)) { Write-Error "Path doesn't exist: $path"; return; }
   $Env:Path = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")

   if (!$Env:path.EndsWith(";")) {$Env:Path += ";"}
   if ($Env:Path -like "*;$path;*") {return}
   $Env:Path += $path
   [System.Environment]::SetEnvironmentVariable("PATH", $Env:Path, "Machine")
}
