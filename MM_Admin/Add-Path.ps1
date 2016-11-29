<#
    Last Change: 29-Nov-2016.
    Author: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Add given directory to the machine PATH environment variable in an idempotent way.

.PARAMETER path
    Absolute or relative directory path. If ommited, defaults to $pwd.

#>
function Add-Path($path=$pwd, [switch]$Prepend, [switch]$User)
{

    $type = if ($User) { 'User' } else { 'Machine' }

    $path=(gi $path).FullName
    if (!(Test-Path $path)) { Write-Error "Path doesn't exist: $path"; return; }
    $Env:Path = [System.Environment]::GetEnvironmentVariable("PATH", $type)

    if (!$Env:path.EndsWith(";")) {$Env:Path += ";"}
    if ($Env:Path -like "*$path*") {return}

    if ($Prepend) { $Env:Path = $path + $Env:Path }
    else { $Env:Path += $path }

    [System.Environment]::SetEnvironmentVariable("PATH", $Env:Path, $type)

    # Notify system of change via WM_SETTINGCHANGE
    if (! ("Win32.NativeMethods" -as [Type]))
    {
        Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
            [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
            public static extern IntPtr SendMessageTimeout( IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@
    }

    $HWND_BROADCAST = [IntPtr] 0xffff; $WM_SETTINGCHANGE = 0x1a; $result = [UIntPtr]::Zero
    [Win32.Nativemethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, "Environment", 2, 5000, [ref] $result) | out-null
}
