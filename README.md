
Posh modules and functions
==========================

Install
-------

```Powershell
    git clone https://github.com/majkinetor/posh
    posh/setup.ps1
```

To import-module from SMB share without security warning:

```Powershell
    $r = "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap"
    mkdir -force $r
    sp $r UNCAsIntranet 1
```

---

License: [MIT](https://opensource.org/licenses/MIT)
