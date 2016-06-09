RES ONE Automation DSC Resources
================================
## Included Resources
* **ROAAgent**: Deploys a RES ONE Automation agent
* **ROAConsole**: Installs the RES ONE Automation console
* **ROADatabase**: Installs the RES ONE Automation console and creates a RES ONE Automation database
* **ROADatabaseAgent**: Installs a RES ONE Automation Agent, querying the database for the Site Id
* **ROADispatcher**: Deploys a RES ONE Automation Dispatcher
* **ROALab (Composite)**: Deploys a single-node RES ONE Automation server lab environment
* **ROALabBuildingBlock (Compsite)**: Adds a RES ONE Automation building block
 * **NOTE: Requires Windows Management Framework 5 with Windows Authentication.**

## Required Resources
* **xNetworking**: ROALab requires https://github.com/PowerShell/xNetworking to create server firewall rules

ROAAgent
========
Deploys a RES ONE Automation agent.
### Syntax
```
ROAAgent [String] #ResourceName
{
    Path = [String]
    SiteId = [String]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ AddToTeam = [String[]] ]
    [ DispatcherList = [String[]] ]
    [ DownloadDispatcherList = [Bool] ]
    [ InvokeProject = [String[]] ]
    [ UseAutodetectFirst = [Bool] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROAConsole
==========
Installs the RES ONE Automation console.
### Syntax
```
ROAConsole [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    Path = [String]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROADatabase
===========
Installs the RES ONE Automation console and creates a RES ONE Automation database.
### Syntax
```
ROADatabase [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    SQLCredential = [PSCredential]
    Path = [String]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROAAgent
================
Installs a RES ONE Automation Agent, querying the database for the Site Id.
### Syntax
```
ROAAgent [String] #ResourceName
{
    DatabaseName = [String]
    DatabaseServer = [String]
    Credential = [PSCredential]
    Path = [String]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ AddToTeam = [String[]] ]
    [ DispatcherList = [String[]] ]
    [ DownloadDispatcherList = [Bool] ]
    [ InvokeProject = [String[]] ]
    [ UseAutodetectFirst = [Bool] ]
    [ Ensure = [String] { Absent | Present } ]
}

```

ROADispatcher
=============
Deploys a RES ONE Automation Dispatcher.
### Syntax
```
ROADispatcher [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    Path = [String]
    [ Version = [String]]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}

```

ROALab
======
Deploys a single-node RES ONE Automation lab server environment. 
### Syntax
```
ROALab [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    SQLCredential = [PSCredential]
    Path = [String]
    Version = [String]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROALabBuildingBlock
===================
Adds a RES ONE Automation building block.
### Syntax
```
ROALabBuildingBlock [String] #ResourceName
{
    Path = [String]
    [ Credential = [PSCredential] ]
    [ UseAutomationAuthentication = [Boolean] ]
    [ Architecture = [String] { x64 | x86 } ]
    [ Ensure = [String] { Present } ]
}

```
