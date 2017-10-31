# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 25-Jun-2015.

#requires -version 2.0

<#
.SYNOPSIS
    Show or Update proxy environment variables from the system proxy settings.

.DESCRIPTION
    The function updates Linux like HTTP_PROXY and related environment variables with the current system proxy settings.
    Without any parameters it will show current values.

.OUTPUTS
    Returns string that is convenient to use as Powershell variable definition so that you can export the result of the
    function to be used elsewere: Update-CLIProxy | out-file proxy_vars.ps1

.EXAMPLE
    Update-CLIProxy -FromSystem -Verbose

    Update proxy environment variables in the current session (no -Register option).

.EXAMPLE
    proxyc -Clear -Register -Verbose

    Clear proxy CLI variables and remove them from the system

.NOTES
    Linux doesn't support setting globs (*) for NO_PROXY variable like Windows. If the same exclusions should work both with Windows
    and Linux tools, simply mix definitions and each tool will understand what it can. Additionally, delimiter for proxy
    exclusions on Windows is `;` and on Linux `,` which this function automatically handles. Keep this in mind in case you need
    to load Windows proxy settings from NO_PROXY variable previously created with this function.
    If the system proxy is disabled, the function will clear all variables just the same as with parameter Clear.
    For more info see http://goo.gl/ZUD2tC.
#>
function Update-CLIProxy()
{
    [CmdletBinding()]
    param (
        # Register enviornment variables in the system. Without this flag environment variables are local only.
        # Requires administrative rights. Must be used with Clear or FromSystem parameters.
        [switch] $Register,
        # Create environment variables from the system settings. If the system proxy properties are populated but
        # the proxy is disabled, this option will clear environment variables.
        [switch] $FromSystem,
        # Clear the environment variables for the current shell. Combine with the Register parameter, to unregister
        # envronment variables from the system.
        [switch] $Clear
    )

    if ($Register)  {
        if (!(test-admin)) { throw "Setting system environment requires admin privileges" }
        else { Write-Verbose "Remembering changes in the system environment" }
    }

    $proxy_vars = "http_proxy", "https_proxy", "ftp_proxy"

    if ($FromSystem -and !$Clear) {
        Write-Verbose "Setting proxy environment variables."

        $proxy = Update-Proxy
        if ($proxy.Enable -eq 0) {
            Write-Verbose "Proxy disabled, setting Clear flag"
            $Clear = $true
        }

        if (!$Clear) {
            if ($proxy.Server) { $Env:http_proxy = "http://" + $proxy.Server }
            $proxy_vars | % {
                Set-Item Env:$_ $Env:http_proxy
                if ($Register) { [Environment]::SetEnvironmentVariable($_, $Env:http_proxy, "Machine") }
            }

            $Env:no_proxy = $proxy.Override.Replace(";",",").Replace('*','') # linux format

            if ($Register) { [Environment]::SetEnvironmentVariable("no_proxy", $Env:no_proxy, "Machine") }
        }
    }

    if ($Clear) {
        Write-Verbose "Clearing proxy environment variables"
        $proxy_vars + "no_proxy" | % {
            Set-Item Env:$_ $null
            if ($Register) { [Environment]::SetEnvironmentVariable($_, $null, "Machine") }
        }
    }

    $env = @("Env:no_proxy")
    $proxy_vars | % { $env += "Env:$_" }

    $env | sort | % { "`${0,-15:0} = '{1}'" -f $_, (gi "$_" -ea SilentlyContinue).Value }
}

function test-admin() {
    $usercontext = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $usercontext.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

Set-Alias proxyc Update-CLIProxy
