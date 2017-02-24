#requires -version 3

Write-Host "Adding majkinetor's PowerShell modules to user $PROFILE"
mkdir -force (Split-Path -Parent $PROFILE) | out-null
if ($Env:PSModulePath -like "*$PSScriptRoot*") { Write-Host 'Modules are already registered, exiting'; return }
"`$Env:PSModulePath += `";$PSScriptRoot`"" | Out-File -Encoding ascii -Append $PROFILE