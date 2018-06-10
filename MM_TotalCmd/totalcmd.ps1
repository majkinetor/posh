<#
Author: Miodrag Milic <miodrag.milic@gmail.com>
This script contains various Total Commander functions
#>

function Test-Commander {
    if (!($Env:COMMANDER_PATH -and (Test-Path $Env:COMMANDER_PATH))) { throw 'This package requires COMMANDER_PATH environment variable set' }
    
    if (ps totalcmd* -ea 0) {
        Write-Warning "Total Commander is running; restart it for any changes to take effect"
    }
}

function Get-TCInstallPath {
    function check($path) { (gi $path\totalcmd.exe -ea 0).VersionInfo.InternalName -eq 'TOTALCMD' }
    
    $res = $Env:COMMANDER_PATH
    if ( check $res ) { return $res }

    $res = (gp 'HKCU:\Software\Ghisler\Total Commander' -ea 0).InstallDir
    if ( check $res ) { return $res }

    $res = (gp 'HKLM:\Software\Ghisler\Total Commander' -ea 0).InstallDir
    if ( check $res ) { return $res }
}

function Get-TCIniPath {

    $res = $Env:COMMANDER_INI
    if ( $res -and (Test-Path $res)) { return $res }

    $res = (gp 'HKCU:\Software\Ghisler\Total Commander' -ea 0).IniFileName
    if ( $res -and (Test-Path $res)) { return $res }

    $res = (gp 'HKLM:\Software\Ghisler\Total Commander' -ea 0).IniFileName
    if ( $res -and (Test-Path $res)) { return $res }

    $res = "$Env:AppData\Ghisler\wincmd.ini"
    if ( $res -and (Test-Path $res)) { return $res }

    $res = "$Env:WinDir\wincmd.ini"
    if ( $res -and (Test-Path $res)) { return $res }
}

function Install-TCPlugin( [string] $Path, [string] $Name ) {
    
    $plugin_name = Split-Path $Path -Leaf
    $plugins_path = "$Env:COMMANDER_PATH\plugins"
    mkdir $plugins_path -ea 0 | Out-Null
    
    $tmpDestination = "$Env:TEMP\_tcp\$plugin_name"
    rm $tmpDestination -Recurse -ea 0
    7z x $Path "-o$tmpDestination"
    if ($LastExitCode) { throw "Error while unpacking plugin: $LastExitCode" }
   
    $plugin_types = 'wfx', 'wlx', 'wcx', 'wdx'
    $plugin_type = $plugin_types | ? { ([array](ls $tmpDestination\* -Include *$_*)).Count -gt 0 } | select -First 1
    if (!$plugin_type) { throw "Plugin type must be one of the: $plugin_types" }

    $plugin_path = "$plugins_path\$plugin_type\$Name"

    Write-Host "Installing Total Commander plugin files at: $plugin_path" 
    
    rm $plugin_path -Recurse -Force -ea 0
    mkdir $plugin_path -ea 0 | Out-Null
    mv $tmpDestination\* $plugin_path -Force

    if (!($iniPath = Get-TCIniPath)) { throw "Can't find Total Commander ini path" }
    
    Write-Host "Adding plugin to ini file: $iniPath"
    $iniContent = gc $iniPath -Encoding UTF8 -Raw

    if ($plugin_type -in 'wfx','wcx') {
        $iniContent | Set-IniValue FileSystemPlugins $Name $plugin_path\$Name.$plugin_type `
                    | Set-IniValue FileSystemPlugins64 $Name 1 `
                    | Save-Content $iniPath
    } else {
        throw "This plugin type is not yet supported"
    }

    # 'FileSystemPlugins'    Name=Path
    # 'PackerPlugins'        Name=Path
    # 'ListerPlugins'        No=Path
    # 'ContentPlugins'       No=Path
}

function Save-Content([string] $Path, [Parameter(ValueFromPipeline=$true)] [string] $Text) {
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
    [System.IO.File]::WriteAllText($Path, $Text, $Utf8NoBomEncoding)
}


function Uninstall-TCPlugin( [string] $Name ) {
    Write-Host "Removing Total Commander plugin files: $Name"
    rm $Env:COMMANDER_PATH\plugins\*\$Name -Recurse -Force

    Write-Host "Removing Total Commander ini key"
    if (!($iniPath = Get-TCIniPath)) { throw "Can't find Total Commander ini path" }
    $iniContent = gc $iniPath -Encoding UTF8 -Raw
    $iniContent | Set-IniValue FileSystemPlugins $Name | Save-Content $iniPath
}

Test-Commander