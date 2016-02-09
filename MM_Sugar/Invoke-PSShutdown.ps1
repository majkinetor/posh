function Invoke-PSShutdown { shutdown -t 0 }
function Invoke-PSHibernate { shutdown -t 0 -h }
function Invoke-PSReboot { shutdown -t 0 -r }

sal halt Invoke-PSShutdown
sal hiber Invoke-PSHibernate
sal reboot Invoke-PSReboot
