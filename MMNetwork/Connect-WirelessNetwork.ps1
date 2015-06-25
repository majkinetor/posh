# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 25-Jun-2015.

#requires -version 3

# https://msdn.microsoft.com/en-us/library/windows/desktop/ms707381(v=vs.85).aspx
<#
.SYNOPSIS
    Connect to wireless network

.DESCRIPTION
    Connect to choosen wireless network. Create profile if it doesn't exist already.

.EXAMPLE
    Get-WirlessNetwork android | Connect-WirelessNetwork

    Connect to wireless network with preexisting profile
.EXAMPLE
    Get-WirlessNetwork android | Connect-WirelessNetwork -Key 1234567890 -Force

    Connect to wireless network and force creation of new profile with specified key
#>
function Connect-WirelessNetwork() {
    [CmdletBinding()]
    param(
        # Wireless network name
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$SSID,

        #Passphrase or a network key
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Key,

        # Specifies the authentication method that must be used to connect to the wireless LAN
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('open', 'shared', 'WPA-Personal', 'WPA2-Personal')] #WPA-Enterprise, WPA2-Enterprise
        [string]$Authentication='WPA2-Personal',

        # Sets the data encryption to use to connect to the wireless LAN
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('none','WEP','TKIP','CCMP')]
        [string]$Encryption='CCMP',

        # ConnectionType
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('ESS','IBSS')]
        [string]$ConnectionType='ESS',

        # Indicates whether connection to a wireless LAN should be automatic or initiated by user
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('auto','manual')]
        [string]$ConnectionMode = 'auto',

        # Force profile creation
        [switch]$Force
    )
    if (!$SSID) { throw "SSID must be specified" }

    netsh wlan show profile $SSID | out-null
    if ($LastExitCode -or $Force) {
        Write-Verbose "Creating profile $SSID"
        $auth = $Authentication -replace '-Personal', 'PSK'
        $enc  = $Encryption -replace 'CCMP', 'AES'
        if ($ConnectionType -eq 'IBSS') {$ConnectionMode = 'manual'}

        $keyType = 'passPhrase'
        if ($Encryption -eq 'WEP') { $keyType = 'networkKey' }

$profile_xml=@"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$SSID</name>
    <SSIDConfig>
        <SSID>
            <name>$SSID</name>
        </SSID>
    </SSIDConfig>
    <connectionType>$ConnectionType</connectionType>
    <connectionMode>$ConnectionMode</connectionMode>
    <MSM>
        <security>
            <authEncryption>
                <authentication>$auth</authentication>
                <encryption>$enc</encryption>
            </authEncryption>
            <sharedKey>
                <keyType>$keyType</keyType>
                <protected>false</protected>
                <keyMaterial>$Key</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
</WLANProfile>
"@
        #netsh wlan delete profile name=$SSID | out-null
        netsh wlan disconnect
        #$profile_fn = "$Env:Temp\tmp_profile.xml"
        $profile_fn = "tmp_profile.xml"
        $profile_xml | out-file $profile_fn
        netsh wlan add profile filename=$profile_fn
        if ($LastExitCode) {return}
        rm $profile_fn  #possibly overwrite this file to shred the password content
    } else { Write-Verbose "Using existing profile for $SSID" }

    netsh wlan connect name=$SSID #interface is mandatory if there are multiple
}

#Store: "$Env:ProgramData\Microsoft\WlanSvc\Profiles\Interfaces"
#If unencrypted key material is passed to WlanSetProfile, the key material is automatically encrypted before it is stored in the profile store.
