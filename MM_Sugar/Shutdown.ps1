function Invoke-Shutdown { shutdown /t 0 /s}
function Invoke-Reboot { shutdown /t 0 /r }
function Invoke-Hibernate {
    $enabled = Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Power -name HibernateEnabled | select -Expand HibernateEnabled
    if (!$enabled) { return 'Hibernation is not enabled on this system. 
     To enable it, run elevated: powercfg.exe /H ON
     Alternativelly, go to `Control Panel\Hardware and Sound\Power Options\System Settings` to enable it.'
    }

    shutdown /h
}

sal halt   Invoke-Shutdown
sal hiber  Invoke-Hibernate
sal reboot Invoke-Reboot
