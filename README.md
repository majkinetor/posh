
Posh modules and functions
==========================

Install
-------

Add to profile:

```Powershell
    git clone https://github.com/majkinetor/posh
    mkdir -force (Split-Path -Parent $PROFILE) | out-null
    "`$Env:PSModulePath += `";$pwd\posh`"" | Out-File -Encoding ascii -Append $PROFILE
```
