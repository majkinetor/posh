function Invoke-PSShutdown { shutdown /t 0 }
function Invoke-PSReboot { shutdown /t 0 /r }
function Invoke-PSHibernate {

    shutdown /t 0 /h
}

sal halt Invoke-PSShutdown
sal hiber Invoke-PSHibernate
sal reboot Invoke-PSReboot
