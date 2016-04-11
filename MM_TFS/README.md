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

Module keeps TFS credentials in `$tfs.credentials`. If not specified you will be prompted for the credentials when running any of the functions. If the module [CredentialManager](https://github.com/davotronic5000/PowerShell_Credential_Manager) is available (to install run `Install-Module CredentialManager` in Powreshell 5+) credentials will be stored in the Windows Credential vault.

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
