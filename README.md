
# Posh modules and functions by majkinetor

This repository contains number of PowerShell modules I develop for various needs during my work on number of other projects. Every module is well documented and intented to work on any computer having adequate version of PowerShell.

## Install


```Powershell
    git clone https://github.com/majkinetor/posh
    ./posh/setup.ps1
```

To import-module from SMB share without security warning:

```Powershell
    $r = "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap"
    mkdir -force $r
    sp $r UNCAsIntranet 1
```

## Discover


To discover available functions from the CLI run `Get-Command`:

    gcm -module mm_network

To get help about specific function from the CLI run `Get-Help`:

    import-module mm_network
    man proxy

---

License: [MIT](https://opensource.org/licenses/MIT)
