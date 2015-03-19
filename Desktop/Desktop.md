Desktop
=======

Set-PinnedApplication
---------------------

```Powershell
    Set-PinnedApplication -Action PinToTaskbar -FilePath "C:\WINDOWS\system32\notepad.exe"
    gcm notepad,explorer | Set-PinnedApplication -Action PinToStartMenu
```
