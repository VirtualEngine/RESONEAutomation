configuration ROAAgent {
<#
    .SYNOPSIS
        Installs the RES ONE Automation Agent component.
    .NOTES
        The Agent MSI needs to be manually extracted from the MSI first!
        7.0.0.0 is RES Automation Manager 2014
        7.5.0.0 is RES ONE Automation 2015
        7.5.1.0 is RES ONE Automation 2015 SR1
#>
    param (
        ## Specifies the Site ID (case-sensitive). You can find this at Setup > Licensing in the Console.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $SiteLicense,

        ## File path containing the RES ONE Automation MSIs or the literal path to the Agent MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## By default, the Agent will autodetect Dispatchers. To use a fixed list of Dispatchers instead, use
        ## this parameter to specify the names or GUIDs of Dispatchers to use. Separate multiple entries with a semi-colon (;).
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DispatcherList,
        
        ## Should the agent try autodetecting Dispatchers before using the $DispatcherList
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $UseAutodetectFirst = $true,
        
        ## Should the agent extend its list of Dispatchers by downloading a list of all Dispatchers.
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $DownloadDispatcherList = $false,
        
        ## To add the Agent as a member of one or more Teams, use this property to specify the names or GUIDs
        ## of the Teams. Separate multiple entries with a semi-colon (;).
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $AddToTeam,
        
        ## To run one or more Modules, Projects or Run Books on the new Agent as soon as it comes online, use this property
        ## to specify the GUIDs.
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InvokeProject,
        
        ## RES ONE Automation component version to be installed, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,
        
        ## The specified Path is a literal file reference (bypasses the $Versioncheck).
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $IsLiteralPath
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $resourceName = 'ROAAgent';
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
                    $setup = 'RES-AM-Agent-{1}.msi' -f $Architecture, $Version.ToString();
                    $msiProductName = 'RES Automation Manager 2014';
                }
                elseif ($Version.Minor -eq 5) {
                    $setup = 'RES-ONE-Automation-Agent-{1}.msi' -f $Architecture, $Version.ToString();
                    $msiProductName = 'RES ONE Automation 2015';
                }
            }
            Default {
                throw "$resourceName : Version '$($Version.Tostring())' is not currently supported :(.";
            }
        }

        ## Determine whether we're on the RTM release
        if ($Version.Build -eq 0) { $msiProductName = '{0} Agent' -f $msiProductName; }
        else { $msiProductName = '{0} SR{1} Agent' -f $msiProductName, $Version.Build; }
        
        $Path = Join-Path -Path $Path -ChildPath $setup;
    }

    xPackage $resourceName {
        Name = $msiProductName;
        ProductId = '';
        Path = $Path;
        Arguments = 'SITELICENSE="{0}" DISPATCHERLIST="{1}" [DISPATCHERAUTODETECTFIRST="{2}"] DISPATCHERGETLIST="{3}" ADDTOTEAM="{4}" INVOKEPROJECT="{5}"' -f $SiteLicense, $DispatcherList, [int]$UseAutodetectFirst, [int]$DownloadDispatcherList, $AddToTeam, $InvokeProject;
        ReturnCode = 0;
    }

}
