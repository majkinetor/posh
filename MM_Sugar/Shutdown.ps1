function Invoke-Shutdown { shutdown /t 0 /s}
function Invoke-Reboot { shutdown /t 0 /r }
function Invoke-Hibernate {
    $enabled = Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Power -name HibernateEnabled -ea 0 | select -Expand HibernateEnabled
    if (!$enabled) {  
        Write-Warning 'Hibernation doesn''t seem to be enabled on this system.'
        Write-Warning 'To enable it, run elevated: powercfg.exe /H ON'
        Write-Warning 'Alternativelly, go to `Control Panel\Hardware and Sound\Power Options\System Settings` to enable it.'
    }

    shutdown /h
}

sal halt   Invoke-Shutdown
sal hiber  Invoke-Hibernate
sal reboot Invoke-Reboot
