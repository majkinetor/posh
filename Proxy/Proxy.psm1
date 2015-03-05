# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 2015-02-26.

#requires -version 1.0

<#
.SYNOPSIS
    Get or set system proxy properties.

.DESCRIPTION
    This function implements unified method to set proxy system wide settings.
    It sets both WinINET ("Internet Options" proxy) and WinHTTP proxy.
    Without any arguments function will return the current proxy properties.
    To change a proxy property pass adequate argument to the function.

.EXAMPLE
    Update-Proxy -Server "myproxy.mydomain.com:8080" -Override "" -ShowGUI

    Set proxy server, clear overrides and show IE GUI.

.EXAMPLE
    Update-Proxy | Export-CSV proxy;  Import-CSV proxy | Update-Proxy -Verbose

    Save and reload proxy properties

.NOTES
    The format of the parameters is the same as seen in Internet Options GUI.
    To bypass proxy for a local network specify keyword ";<local>" at the end
    of the ProxyOveride values. Setting the proxy requires administrative prvilegies.

.OUTPUTS
    [HashTable]
#>
function Update-Proxy() {
    [CmdletBinding()]
    param(
        # Proxy:Port
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Server,
        # Semicollon delimited list of exlusions
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string] $Override,
        # 0 to disable, anything else to enable proxy
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string] $Enable,
        # Show Internet Options GUI
        [switch] $ShowGUI
    )
    $key  = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    $r = gp $key
    Write-Verbose "Reading proxy data from the registry"
    $proxy=@{
            Server   = if ($PSBoundParameters.Keys -contains 'Server')   {$Server}   else { $r.ProxyServer }
            Override = if ($PSBoundParameters.Keys -contains 'Override') {$Override} else { $r.ProxyOverride }
            Enable   = if ($PSBoundParameters.Keys -contains 'Enable')   {$Enable}   else { $r.ProxyEnable }
    }

    $set  = "Server","Override","Enable" | ? {$PSBoundParameters.Keys -contains $_ }
    if ($set) {
        if (!(test-admin)) { throw "Setting proxy requires admin privileges" }

        Write-Verbose "Saving proxy data to registry"

        sp $key ProxyServer   $proxy.Server
        sp $key ProxyOverride $proxy.Override
        sp $key ProxyEnable   $proxy.Enable
        if (!(refresh-system)) { Write-Warning "Can not force system refresh after proxy change" }

        Write-Verbose "Importing winhttp proxy from IE settings"
        $OFS = "`n"
        [string]$res = netsh.exe winhttp import proxy source=ie
        Write-Verbose $res.Trim()
    }

    new-object PSCustomObject -Property $proxy
    if ($ShowGUI) { start control "inetcpl.cpl,,4" }
}

<#
.SYNOPSIS
    Show or Update proxy environment variables from the system proxy settings.
.DESCRIPTION
    The function updates Linux like HTTP_PROXY and related environment variables with the current system proxy settings.
    Without any parameters it will show current values.
.OUTPUTS
    Returns string that is convenient to use as Powershell variable definition so that you can export the result of the
    function to be used elsewere: Update-CLIProxy | out-file proxy_vars.ps1
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
        if ($proxy.ProxyEnable -eq 0) { $Clear = $true }

        if (!$Clear) {
            if ($proxy.Server) { $Env:http_proxy = "http://" + $proxy.Server }
            $proxy_vars | % {
                Set-Item Env:$_ $Env:http_proxy
                if ($Register) { [Environment]::SetEnvironmentVariable($_, $Env:http_proxy, "Machine") }
            }

            $Env:no_proxy = $proxy.Override.Replace(";",",") # linux format
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


# The registry changes aren't seen until system is notified about it.
# Without this function you need to open Internet Settings window for changes to take effect. See http://goo.gl/OIQ4W4
function refresh-system() {
    $signature = @'
[DllImport("wininet.dll", SetLastError = true, CharSet=CharSet.Auto)]
public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int dwBufferLength);
'@

    $INTERNET_OPTION_SETTINGS_CHANGED   = 39
    $INTERNET_OPTION_REFRESH            = 37
    $type = Add-Type -MemberDefinition $signature -Name wininet -Namespace pinvoke -PassThru
    $a = $type::InternetSetOption(0, $INTERNET_OPTION_SETTINGS_CHANGED, 0, 0)
    $b = $type::InternetSetOption(0, $INTERNET_OPTION_REFRESH, 0, 0)
    return $a -and $b
}

Set-Alias proxy Update-Proxy
Set-Alias proxyc Update-CLIProxy
Export-ModuleMember -Function Update-Proxy, Update-CLIProxy -Alias *
