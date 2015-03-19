AdminTools
==========

Set-EnvironmentVariable (env)
-----------------------------

```Powershell
    # Set user variable editor
    env EDITOR (gcm gvim.exe) -Verbose

    # Set machine variable editor on multiple machines
    "computer1", "computer2" | env EDITOR notepad.exe -Machine
```

Start-ElevatedProcess (sudo)
----------------------------

```Powershell
    PS> sudo { env EDITOR notepad.exe -Machine } -NoExit

    PS> env EDITOR notepad.exe -Machine
    Exception calling "SetEnvironmentVariable" with "3" argument(s): "Requested registry access is not allowed."

    # Execute last command as sudo
    PS> sudo -L
```

Open-Regedit (regjump)
----------------------

```Powershell
    # Open regedit at HKLM:\Software by value from pipeline
    PS HKLM:\SOFTWARE\> gi . | regjump


    # Open regedit at HKLM:\Software via argument   sudo { env EDITOR notepad.exe -Machine }
    PS HKLM:\SOFTWARE\> Open-Regedit $pwd

```


