RES ONE Automation DSC Resources
================================

## Included Resources

* **ROAAgent**: Deploys a RES ONE Automation agent or v10 agent+
* **ROABuildingBlock**: Imports a RES ONE Automation building block
* **ROAConsole**: Installs the RES ONE Automation console
* **ROADatabase**: Installs the RES ONE Automation console and creates a RES ONE Automation database
* **ROADatabaseAgent**: Installs a RES ONE Automation Agent, querying the database for the Site Id
* **ROADispatcher**: Deploys a RES ONE Automation Dispatcher
* **ROALab (Composite)**: Deploys a single-node RES ONE Automation server lab environment
* **ROAManagementPortal**: Deploys the RES ONE Automation v10 (and later) web management portal

### Required Resources

* **xNetworking**: ROALab requires https://github.com/PowerShell/xNetworking to create server firewall rules

ROAAgent
========

Deploys a RES ONE Automation agent or agent+.

### Syntax

```
ROAAgent [String] #ResourceName
{
    Path = [String]
    SiteId = [String]
    [ Version = [String] ]
    [ IsAgentPlus = [Boolean] ]
    [ IsLiteralPath = [Boolean] ]
    [ AddToTeam = [String[]] ]
    [ DispatcherList = [String[]] ]
    [ DownloadDispatcherList = [Bool] ]
    [ InvokeProject = [String[]] ]
    [ InheritSettings = [Bool] ]
    [ UseAutodetectFirst = [Bool] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROABuildingBlock
===================

Imports a RES ONE Automation building block.

### Syntax

```
ROABuildingBlock [String] #ResourceName
{
    Path = [String]
    [ Credential = [PSCredential] ]
    [ IsRESONEAutomationCredential = [Boolean] ]
    [ DeleteFromDisk = [Boolean] ]
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
    [ LicensePath = [String] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROADatabaseAgent
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
    [ IsAgentPlus = [Boolean] ]
    [ IsLiteralPath = [Boolean] ]
    [ AddToTeam = [String[]] ]
    [ DispatcherList = [String[]] ]
    [ DownloadDispatcherList = [Bool] ]
    [ InvokeProject = [String[]] ]
    [ InheritSettings = [Bool] ]
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
    [ BuildingBlockPath = [String] ]
    [ BuildingBlockCredential = [PSCredential] ]
    [ IsBuildingBlockCredentialRESONEAutomationUser = [Boolean] ]
    [ DeleteBuildingBlock = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROAManagementPortal
===================

Installs the RES ONE Automation v10 (and later) web management portal component.

### Syntax

```
ROAManagementPortal [String] #ResourceName
{
    Hostname = [String]
    CertificateThumbprint = [String]
    Path = [String]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present }]
}
```
