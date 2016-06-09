configuration ROALab {
<#
    .SYNOPSIS
        Creates a RES ONE Automation single node lab deployment
    .NOTES
        The Console, Dispatcher and Agent MSIs need to be manually extracted first!
        7.0.0.0 is RES Automation Manager 2014
        7.5.0.0 is RES ONE Automation 2015
        7.5.1.0 is RES ONE Automation 2015 SR1
#>
    param (
        ## RES ONE Automation database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        ## RES ONE Automation database name (equivalient to DBNAME).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,
        
        ## Microsoft SQL username/password to connect to the RES ONE Automation database (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Credential,
        
        ## Microsoft SQL database credentials used to create the database (equivalient to DBCREATEUSER/DBCREATEPASSWORD).
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $SQLCredential,
        
        ## File path containing the RES ONE Automation MSIs or the literal path to the legacy console/Sync Tool MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
         [ValidateNotNullOrEmpty()] [System.String] $Path,
        
        ## RES ONE Automation component version to be installed, i.e. 7.5.1.0
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Version,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xNetworking;
    
    ## Can't import RESONEServiceStore composite resource due to circular references!
    Import-DscResource -Name ROADatabase, ROADispatcher, ROADatabaseAgent;

    ## If path -match '\.msi$', throw.
    if ($Path -match '\.msi$') {
        throw "Specified path '$Path' does not point to a directory.";
    }

    if ($Ensure -eq 'Present') {
        
        ROADatabase 'ROALabDatabase' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Path = $Path;
            Version = $Version;
            SQLCredential = $SQLCredential;
            Credential = $Credential;
            IsLiteralPath = $false;
            Ensure = $Ensure;
        }
       
        ROADispatcher 'ROALabDispatcher' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Path = $Path;
            Version = $Version;
            Credential = $Credential;
            Ensure = $Ensure;
            IsLiteralPath = $false;
            DependsOn = '[ROADatabase]ROALabDatabase';
        }
        
        ROADatabaseAgent 'ROALabDatabaseAgent' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Path = $Path;
            Version = $Version;
            Credential = $Credential;
            Ensure = $Ensure;
            IsLiteralPath = $false;
            DependsOn = '[ROADispatcher]ROALabDispatcher';
        }
        
    }
    elseif ($Ensure -eq 'Absent') {
        
        ROADatabaseAgent 'ROALabDatabaseAgent' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Path = $Path;
            Version = $Version;
            Credential = $Credential;
            IsLiteralPath = $false;
            Ensure = $Ensure;
        }

        ROADispatcher 'ROALabDispatcher' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Path = $Path;
            Version = $Version;
            Credential = $Credential;
            IsLiteralPath = $false;
            Ensure = $Ensure;
            DependsOn = '[ROADatabaseAgent]ROALabDatabaseAgent';
        }
        
        ROADatabase 'ROALabDatabase' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Path = $Path;
            Version = $Version;
            SQLCredential = $SQLCredential;
            Credential = $Credential;
            IsLiteralPath = $false;
            Ensure = $Ensure;
            DependsOn = '[ROADispatcher]ROALabDispatcher';
        }
    
    }
    
    xFirewall 'RESONEAutomationFirewall' {
        Name = 'RESONEAutomation-TCP-3163-In';
        Group = 'RES ONE Automation';
        DisplayName = 'RES ONE Automation (Dispatcher)';
        Action = 'Allow';
        Direction = 'Inbound';
        Enabled = $true;
        Profile = 'Any';
        Protocol = 'TCP';
        LocalPort = 3163;
        Description = 'RES ONE Automation Dispatcher Service';
        Ensure = $Ensure;
        DependsOn = '[ROADispatcher]ROALabDispatcher';
    }

    xFirewall 'RESONEAutomationDiscoveryFirewall' {
        Name = 'RESONEAutomation-UDP-3163-In';
        Group = 'RES ONE Automation';
        DisplayName = 'RES ONE Automation (Dispatcher Discovery)';
        Action = 'Allow';
        Direction = 'Inbound';
        Enabled = $true;
        Profile = 'Any';
        Protocol = 'UDP';
        LocalPort = 3163;
        Description = 'RES ONE Automation Dispatcher Service Discovery';
        Ensure = $Ensure;
        DependsOn = '[ROADispatcher]ROALabDispatcher';
    }

} #end configuration ROALab
