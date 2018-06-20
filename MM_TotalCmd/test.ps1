ls $PSScriptRoot\*.ps1 -Exclude test.ps1 | % { . $_ }

#Install-TCPlugin $PSScriptRoot\..\uninstaller64_1.0.1.rar Uninstaller64
#Uninstall-TCPlugin Uninstaller64
