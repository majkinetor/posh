function Invoke-Shutdown { shutdown.exe /t 0 /s}
function Invoke-Reboot { shutdown.exe /t 0 /r }
function Invoke-Logout { logoff.exe }

function Invoke-Hibernation {
    $enabled = Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Power -name HibernateEnabled -ea 0 | select -Expand HibernateEnabled
    if (!$enabled) {  
        Write-Warning 'Hibernation doesn''t seem to be enabled on this system.'
        Write-Warning 'To enable it, run elevated: powercfg.exe /H ON'
        Write-Warning 'Alternativelly, go to `Control Panel\Hardware and Sound\Power Options\System Settings` to enable it.'
    }

    shutdown.exe /h
}


sal halt      Invoke-Shutdown
sal suspend   Invoke-Hibernation
sal hibernate Invoke-Hibernation
sal reboot    Invoke-Reboot
sal logout    Invoke-Logout
sal logoff    Invoke-Logout
