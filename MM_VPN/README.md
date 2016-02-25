MM_VPN
======

This module implements functions to connect to the VPN network using Powershell and Cisco Anyconnect.

Prerequisites
-------------

- [Cisco AnyConnect client](http://www.cisco.com/c/en/us/support/security/anyconnect-secure-mobility-client/tsd-products-support-series-home.html)
- Powershell 3+ (Windows 7 only)( `cinst powershell` )
- Enable script execution via `Set-ExecutionPolicy`

Installation
------------

[Install module](https://msdn.microsoft.com/en-us/library/dd878350(v=vs.85).aspx) in some of the designated folders.

Usage
-----

Create `myvpn.ps1` script file which will will hold the VPN connections. Source this script in your $PROFILE:

    . <path_to_power_vpn>\myvpn.ps1

To define connections within `myvpn.ps1` import `mm_vpn` module and define function for each VPN network:

**Example of myvpn.ps1 script**:

    import-module mm_vpn

    function acme() { connect-vpn $PSScriptRoot/acme  }
    function ibm()  { connect-vpn $PSScriptRoot/ibm }

In above case two connections are defined, `acme` and `ibm` which use configuration files defined in the same directory as `myvpn.ps1` script. 
After this, to connect to the network simply call the function from within console:

    PS> acme
    Connecting to VPN network using configuration 'acme'
    Cisco AnyConnect Secure Mobility Client (version 4.2.00096)
    ...

Complete cumulative log file is saved in the file `vpn.log` in the module directory.

Functions
---------

Module defines two functions:

- `connect-vpn $config -Timeout $seconds` (alias vpnc)  
Connect to the specified VPN network using given $config file path. By default, Timeout parameter is -1 which means that function will wait forever for the vpn client to return which might be problematic if connection parameters change on the server as it will result that any connect client stays in its REPL mode. To prevent this, specify Timeout parameter for function to terminate the client after desired wait time.
- `disconnect-vpn` (alias vpnd)   
Disconnect from the VPN network.


Configuration file
------------------

This is the simple text file where each line is the command or response that VPN client expects from the user. If the client stays in the REPL mode with given configuration that means that specified lines are incorrect in given context and should be fixed by executing `vpncli` and recording the correct sequence of answers given to the client in order to connect.

**Example**

    connect vpn.acme.com
    3
    my_user
    my_password

In any case, you should edit the configuration with your username and password.

Complete output example
-----------------------

This is the output when connecting to the VPN network "acme" with 60 seconds timeout:

    PS> vpnc $pwd\myvpn\acme 60
    --------------------------------------------------
    Connect-VPN started at 2016-02-11T13-18-45
    Started background vpn connection: acme

    Cisco AnyConnect Secure Mobility Client (version 3.1.12020) .
    Copyright (c) 2004 - 2015 Cisco Systems, Inc.  All Rights Reserved.
    >> state: Disconnected
    >> state: Disconnected
    >> notice: Ready to connect.
    >> registered with local VPN subsystem.
    >> contacting host (vpn.acme.com) for login information...
    >> notice: Contacting vpn.acme.com.
    >> Please enter your username and password.
        0) Cert-Full
        1) Cert-VPN
        2) Sec-LAIR
        3) VPN
    Group: [VPN]
    Username:  Password:
    >> state: Connecting
    >> notice: Establishing VPN session...
    >> notice: Checking for profile updates...
    >> notice: Checking for product updates...
    >> notice: Checking for customization updates...
    >> notice: Performing any required updates...
    >> state: Connecting
    >> notice: Establishing VPN session...
    >> notice: Establishing VPN - Initiating connection...
    >> notice: Establishing VPN - Examining system...
    >> notice: Establishing VPN - Activating VPN adapter...
    >> notice: Establishing VPN - Configuring system...
    >> notice: Establishing VPN...
    >> state: Connected
    VPN> goodbye...
    >> note: VPN Connection is still active
