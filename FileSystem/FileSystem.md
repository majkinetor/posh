FileSystem
==========

New-Symlink (ln)
----------------

```Powershell
    # Creates a symbolic link to downloads folder that resides on C:\users\admin\desktop.
    New-SymLink -Path "C:\users\admin\downloads" -SymName "C:\users\admin\desktop\downloads" -Directory

    # Use relative names, overwrite if exists
    New-SymLink -Path ..\document.txt -SymName SomeDocument -File -Force

```
