
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
     
Remove
------

cpx:

o -> new-hashobject
sudo -> su  (invoke-elevated)
edp -> edit-profile
addto-path -> add-pathvariable
%EDITOR% - $Pscx:Preferences["TextEditor"] = "gvim.exe"
New-Symlink -> New-Symlink

Docs
----

- [AdminTools] (AdminTools/AdminTools.md)
- [Desktop] (Desktop/Desktop.md)
- [FileSystem] (FileSystem/FileSystem.md)
- [Proxy](Proxy/Proxy.md)
- [Sugar] (Sugar/Sugar.md)
