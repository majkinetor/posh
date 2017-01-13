function Invoke-PSShutdown { shutdown /t 0 }
function Invoke-PSReboot { shutdown /t 0 /r }
function Invoke-PSHibernate {
    $enabled = Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Power -name HibernateEnabled | select -Expand HibernateEnabled
    if (!$enabled) { return 'Hibernate is not enabled. To enable it, run elevated: powercfg.exe /H ON' }

    shutdown /h
}

sal halt Invoke-PSShutdown
sal hiber Invoke-PSHibernate
sal reboot Invoke-PSReboot
