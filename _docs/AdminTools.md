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
    sudo { env EDITOR notepad.exe -Machine }
```

