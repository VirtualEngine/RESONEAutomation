configuration ROADatabase {
<#
    .SYNOPSIS
        Creates the RES ONE Automation database using the installer.
    .NOTES
        This also installs the RES ONE Automation console.
        7.0.0.0 is RES Automation Manager 2014
        7.5.0.0 is RES ONE Automation 2015
        7.5.1.0 is RES ONE Automation 2015 SR1
#>
    param (
        ## RES ONE Automation database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)]
        [System.String] $DatabaseServer,
        
        ## RES ONE Automation database name (equivalient to DBNAME).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,
        
        ## Microsoft SQL username/password to create (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,
        
        ## Microsoft SQL database credentials used to create the database (equivalient to DBCREATEUSER/DBCREATEPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $SQLCredential,
        
        ## File path containing the RES ONE Automation MSIs or the literal path to the installation MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,
        
        ## RES ONE Automation component version to be installed, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,
        
        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $resourceName = 'ROADatabase';
    if (([System.String]::IsNullOrWhitespace($Version)) -and (-not $IsLiteralPath)) {
        throw "$resourceName : Version number is required when not using a literal path.";
    }
    elseif ($IsLiteralPath) {
        if ($Path -notmatch '\.msi$') {
            throw "$resourceName : Specified path '$Path' does not point to an MSI file.";
        }
    }
    elseif ($Version -notmatch '^\d+\.\d+\.\d+\.\d+$') {
        throw "$resourceName : The specified version '$Version' does not match '1.2.3.4' format.";
    }
    
    if (-not $IsLiteralPath) {
        [System.Version] $Version = $Version;
        switch ($Version.Major) {
            7 {
                if ($Version.Minor -eq 0) {
                    $setup = 'RES-AM-2014';
                    $msiProductName = 'RES Automation Manager 2014';
                }
                elseif ($Version.Minor -eq 5) {
                    $setup = 'RES-ONE-Automation-2015';
                    $msiProductName = 'RES ONE Automation 2015';
                }
            }
            Default {
                throw "$resourceName : Version '$($Version.Tostring())' is not currently supported :(.";
            }
        }

        ## Determine whether we're on the RTM release
        if ($Version.Build -eq 0) {
            $setup = '{0}.msi' -f $setup;
        }
        else {
            $setup = '{0}-SR{1}.msi' -f $setup, $Version.Build;
            $msiProductName = '{0} SR{1}' -f $msiProductName, $Version.Build;    
        }
        $Path = Join-Path -Path $Path -ChildPath $setup;
    }

    if ($Ensure -eq 'Present') {
        xPackage $resourceName {
            Name = $msiProductName;
            ProductId = '';
            Path = $Path;
            Arguments = 'DBSERVER="{0}" DBNAME="{1}" DBUSER="{2}" DBPASSWORD="{3}" DBTYPE="MSSQL" DBCREATE="yes" DBCREATEUSER="{4}" DBCREATEPASSWORD="{5}"' -f $DatabaseServer, $DatabaseName, $Credential.Username, $Credential.GetNetworkCredential().Password, $SQLCredential.Username, $SQLCredential.GetNetworkCredential().Password;
            ReturnCode = 0;
        }
    }
    elseif ($Ensure -eq 'Absent') {
        xPackage $resourceName {
            Name = $msiProductName;
            ProductId = '';
            Path = $Path;
            ReturnCode = 0;
            Ensure = 'Absent';
        }
    }

} #end configuration ROADatabase
