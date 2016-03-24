MM_TFS
======

This is powershell module to communicate with TFS 2015 via its [REST interface](https://www.visualstudio.com/integrate/get-started/rest/basics). It provides several functions which allow you create, update, export and import build definitions, get build logs, get projects etc.

Configuration
=============

Module uses global variable `$tfs` for its configuration. The most basic config would be:

    $tfs = @{
        root_url    = 'http://tfs015:8080/tfs'
        project     = 'ProjectXYZ'
        credential  = Get-Credential
    }


The module will merge user defined `$tfs` hash with its defaults:

    $tfs = @{
        root_url    = $tfs.root_url
        collection  = d $tfs.collection 'DefaultCollection'
        project     = $tfs.project
        api_version = d $tfs.api_version '2.0'
        credential  = $tfs.credential
    }

Function `d` is used to set defaults - it will use first argument if it exists or second otherwise. If you need to work constantly on a single project put this setting in your `$PROFILE`.

Functions
=========

The following section list some example usages. Before using any function you must specify your TFS credentials in `$tfs.credentials` using `Get-Credential`.

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
    Create-BuildDefinition -JsonFile ProjectXYZ-BuildXYZ.json
    Update-BuildDefinition -JsonFile ProjectXYZ-BuildXYZ.json
    Delete-BuildDefinition BuildXYZ
