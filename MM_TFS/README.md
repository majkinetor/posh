MM_TFS
======

This is Powershell module to communicate with TFS 2015 via its [REST interface](https://www.visualstudio.com/integrate/get-started/rest/basics). It provides several functions which allow you to create, update, export and import build definitions, get build logs, get projects etc.

Configuration
=============

Module uses global variable `$tfs` for its configuration:

    $tfs = @{
        root_url    = 'http://tfs015:8080/tfs'
        collection  = 'DefaultCollection'
        project     = 'ProjectXYZ'
        credential  = Get-Credential
        api_version = '1.0'
    }

Some attributes will take defaults if you don't specify them:

    $tfs.collection  = 'DefaultCollection'
    $tfs.api_version = '2.0'

If you need to work constantly on a single project put this setting in your `$PROFILE`. To manage multiple projects or collections or tfs servers you could create multiple functions for each scenario that each set `$global:tfs` in its own way, for example:

    function Set-TestTFSCreds() {
        $global:tfs = @{ ... }
    }

Then, prior to calling any module function run `Set-TestTFSCreds`.

Functions
=========

The following section list some example usages. 

TFS Credentials
---------------

Module keeps TFS credential in the `$tfs.Credentials`. If not specified you will be prompted for the credentials when running any of the functions. If the module [CredentialManager](https://github.com/davotronic5000/PowerShell_Credential_Manager) is available (to install run `Install-Module CredentialManager` in Powreshell 5+) credentials will be stored in the Windows Credential Vault and you will have a feature to specify credential only on first run. 

To use ad-hoc credentials when you have your main credential stored simply use: 
    
    $tfs.Credentials = Get-Credential

This way stored credentials will be overridden only for the current session. To change the stored credentials for all subsequent sessions either delete them using the Control Panel (Manage Windows Credentials) and run any function again or use the following command:

    $tfs.Credentials = New-TFSCredential    #Get credential and store it in Credential Manager.

Projects
--------

    Get-TFSProjects
    Get-TFSProject 'ProjectXYZ'
    Get-TFSProject 1

Builds
------

    Get-TFSBuilds
    Get-TFSBuildLogs
    Get-TFSBuildLogs 220


Build Definitions
-----------------

    Get-TFSBuildDefinition BuildXYZ -Export
    Get-TFSBuildDefinitionHistory BuildXYZ
    New-TFSBuildDefinition -JsonFile ProjectXYZ-BuildXYZ.json
    Update-TFSBuildDefinition -JsonFile ProjectXYZ-BuildXYZ.json
    Remove-TFSBuildDefinition BuildXYZ

Troubleshooting
---------------

All functions have a `Verbose` parameter that shows very detailed logs of every step involved:

    PS> Get-TFSBuildLogs -Verbose

    VERBOSE: No credentials specified, trying Windows Credential Manager
    VERBOSE: Populating RepositorySourceLocation property for module CredentialManager.
    VERBOSE: Loading module from path 'C:\Program Files\WindowsPowerShell\Modules\CredentialManager\1.0\CredentialManager.dll'.
    VERBOSE: Trying to get storred credentials for 'http://tfs015:8080/tfs'
    VERBOSE: Retrieving requested credential from Windows Credential Manager
    VERBOSE: New TFS credentials for 'http://tfs015:8080/tfs'
    VERBOSE: TFS Credential: majkinetor
    VERBOSE: URI: http://tfs015:8080/tfs/DefaultCollection/ProjectXYZ/_apis/build/builds?api-version=2.0
    VERBOSE: received 793807-byte response of content type application/json; charset=utf-8; api-version=2.0
    VERBOSE: Build id: 1456
    VERBOSE: Logs URI: http://tfs015:8080/tfs/DefaultCollection/ProjectXYZ/_apis/build/builds/1456/logs?api-version=2.0
    VERBOSE: GET http://10.1.6.27:8080/tfs/TrezorCollection/Trezor/_apis/build/builds/1456/logs?api-version=2.0 with 0-byte payload
    VERBOSE: received 738-byte response of content type application/json; charset=utf-8; api-version=2.0
    VERBOSE: Log URI: http://tfs015:8080/tfs/DefaultCollection/cc756267-fb53-4148-906f-471588d87bcb/_apis/build/builds/1456/logs/1
    ...
