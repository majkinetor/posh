
Posh modules and functions
==========================


Proxy
-----

Module to view or update IE, WINHTTP and CLI proxies.

```
    PS> ipmo proxy; gcm -Module proxy

    CommandType     Name                                               ModuleName
    -----------     ----                                               ----------
    Alias           proxy -> Update-Proxy                              proxy
    Alias           proxyc -> Update-CLIProxy                          proxy
    Function        Update-CLIProxy                                    proxy
    Function        Update-Proxy                                       proxy

    # Set proxy settings and show IE GUI
    PS> proxy -Server "myproxy.mydomain.com:8080" -Override "override1, override2" -Enable 1 -ShowGUI

    # Add to override list
    PS> $p = proxy
    PS> $p.Override += "*.domain.com" ; $p | proxy

    # Save / restore
    PS> proxy | Export-csv proxy
    PS> Import-csv proxy | proxy -Verbose | ft -Autosize

    VERBOSE: Reading proxy data from the registry
    VERBOSE: Saving proxy data to registry
    VERBOSE: Importing winhttp proxy from IE settings
    VERBOSE: Current WinHTTP proxy settings:

        Proxy Server(s) :  1.2.3.4:8080
        Bypass List     :  127.0.0.1;localhost;192.168.0.10;<local>

    Override                                   Server         Enable
    --------                                   ------         ------
    127.0.0.1;localhost;192.168.0.10;<local>   1.2.3.4:8080   1


    # Set console proxy
    PS> proxyc -FromSystem -Verbose

    VERBOSE: Setting proxy environment variables.
    VERBOSE: Reading proxy data from the registry
    $Env:ftp_proxy   = 'http://1.2.3.4:8080'
    $Env:http_proxy  = 'http://1.2.3.4:8080'
    $Env:https_proxy = 'http://1.2.3.4:8080'
    $Env:no_proxy    = '127.0.0.1,localhost,192.168.0.10,<local>'

    # Clear proxy CLI variables and remove them from the system
    PS> proxyc -Clear -Register -Verbose
```
