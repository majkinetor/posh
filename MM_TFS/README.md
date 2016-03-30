MM_TFS
======

This is Powershell module to communicate with TFS 2015 via its [REST interface](https://www.visualstudio.com/integrate/get-started/rest/basics). It provides several functions which allow you create, update, export and import build definitions, get build logs, get projects etc.

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

If you need to work constantly on a single project put this setting in your `$PROFILE`. To manage multiple projects or collections or tfs servers you could create multiple functions for each scenario that each set `$global:tfs` in its own way.

Functions
=========

The following section list some example usages. Before using any function you must specify your TFS credentials in `$tfs.credentials` using `Get-Credential`. To save a credential in the Windows Credentials Vault you must have [CredentialManager](https://github.com/davotronic5000/PowerShell_Credential_Manager) module installed.

Projects
--------

    Get-Projects
    Get-Project 'ProjectXYZ'
    Get-Project 1

Builds
------

    Get-Builds
    Get-BuildLogs
    Get-BuildLogs 220


Build Definitions
-----------------

    Get-BuildDefinition BuildXYZ -Export
    Get-BuildDefinitionHistory BuildXYZ
    New-BuildDefinition -JsonFile ProjectXYZ-BuildXYZ.json
    Update-BuildDefinition -JsonFile ProjectXYZ-BuildXYZ.json
    Remove-BuildDefinition BuildXYZ
