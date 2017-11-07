function Resolve-ROAPackagePath {
<#
    .SYNOPSIS
        Resolves the latest RES ONE Automation/Automation Manager installation package.
#>
    [CmdletBinding()]
    param (
        ## The literal file path or root search path
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Required RES ONE Automation/Automation Manager component
        [Parameter(Mandatory)]
        [ValidateSet('Console','Dispatcher','Agent','Installer','AgentPlus','ManagementPortal')]
        [System.String] $Component,

        ## RES ONE Automation component version to be installed, i.e. 7.0.4 or 7.5.3.1
        [Parameter(Mandatory)]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version check).
        [Parameter()]
        [System.Boolean] $IsLiteralPath
    )
    process {

        if (([System.String]::IsNullOrWhitespace($Version)) -and (-not $IsLiteralPath)) {

            throw ($localizedData.VersionNumberRequiredError);
        }
        elseif ($IsLiteralPath) {

            if ($Path -notmatch '\.msi$') {

                throw ($localizedData.SpecifedPathTypeError -f $Path, 'MSI');
            }
        }
        elseif ($Version -notmatch '^\d\d?\.\d\d?(\.\d\d?|\.\d\d?\.\d\d?)?$') {

            throw ($localizedData.InvalidVersionNumberFormatError -f $Version);
        }
        else {

            $versionMajor = $Version.Split('.')[0] -as [System.Int32];
            if (($Component -in 'AgentPlus','ManagementPortal') -and ($versionMajor -lt 10)) {
                
                throw ($localizedData.InvalidComponentVersionError -f $Component, 10);
            }
        }

        if ($IsLiteralPath) {

            $packagePath = $Path;
        }
        else {

            [System.Version] $productVersion = $Version;

            switch ($productVersion.Major) {

                10 {

                    switch ($productVersion.Minor) {

                        0 {

                            ## ProductName is only used by the 'Installer' and 'ManagementPortal' component
                            $productName = 'RES ONE Automation';
                            ## PackageName is used by all other components
                            $packageName = 'RES-ONE-Automation';
                        }
                        1 {

                            $productName = 'RES ONE Automation';
                            $packageName = 'RES-ONE-Automation';
                        }
                        2 {
                            
                            $productName = 'RES ONE Automation';
                            $packageName = 'RES-ONE-Automation';
                        }
                        Default {

                            throw ($localizedData.UnsupportedVersionError -f $productVersion.ToString());
                        }

                    } #end switch version minor

                } #end version 10

                7 {

                    switch ($productVersion.Minor) {

                        0 {

                            $packageName = 'RES-AM';
                            $productName = 'RES-AM-2014';
                        }
                        5 {

                            $packageName = 'RES-ONE-Automation';
                            $productName = 'RES-ONE-Automation-2015';
                        }
                        Default {

                            throw ($localizedData.UnsupportedVersionError -f $productVersion.ToString());
                        }

                    } #end switch version minor

                } #end version 7

                Default {

                    throw ($localizedData.UnsupportedVersionError -f $productVersion.ToString());
                }

            } #end switch version major

            ## Calculate the version search Regex. RES AM uses version numbers in the Console, Agent and Dispatcher MSIs
            ## This isn't used by the 'Installer' component as that has the SR moniker instead (like RES WM).
            if (($productVersion.Build -eq -1) -and ($productVersion.Revision -eq -1)) {

                ## We only have 'Major.Minor'
                $versionRegex = '{0}.{1}.\S+' -f $productVersion.Major, $productVersion.Minor;
            }
            elseif ($productVersion.Revision -eq -1) {

                ## We have 'Major.Minor.Build'
                $versionRegex = '{0}.{1}.{2}.\S+' -f $productVersion.Major, $productVersion.Minor, $productVersion.Build;
            }
            else {

                ## We have explicit version.
                $versionRegex = '{0}.{1}.{2}.{3}' -f $productVersion.Major, $productVersion.Minor, $productVersion.Build, $productVersion.Revision;
            }

            switch ($Component) {

                'Installer' {

                    if ($productVersion.Major -ge 10) {
                        
                        ## We need the RES ONE Automation 10.0.100.0.msi
                        $regex = '{0} {1}.msi' -f $productName, $versionRegex;
                    }
                    elseif ($productVersion.Build -eq 0) {

                        ## We're after the RTM release, e.g. specified 9.9.0 or 9.10.0
                        $regex = '{0}.msi' -f $productName;
                    }
                    elseif ($productVersion.Build -ge 1) {

                        ## We're after a specific SR, e.g. specified 9.9.3 or 9.10.2
                        $regex = '{0}-SR{1}.msi' -f $productName, $productVersion.Build;
                    }
                    else {

                        ## Find any
                        $regex = '{0}(-SR\d)?.msi' -f $productName;
                    }

                }

                'Agent' {

                    ## RES-ONE-Automation-2015-Agent-7.5.3.1 or RES-AM-Agent-7.0.4.3
                    $regex = '{0}-Agent-{1}.msi' -f $packageName, $versionRegex;

                } #end switch Agent

                'AgentPlus' {

                    $architecture = 'x86';
                    if ([System.Environment]::Is64BitOperatingSystem) {

                        $architecture = 'x64';
                    }

                    ## RES-ONE-Automation-Agent+(x64)-10.0.100.0
                    $regex = '{0}-Agent\+\({1}\)-{2}.msi' -f $packageName, $architecture, $versionRegex;
                }

                'Dispatcher' {

                    $architecture = 'x86';
                    if ([System.Environment]::Is64BitOperatingSystem) {

                        $architecture = 'x64';
                    }
                    ## RES-ONE-Automation-2015-Dispatcher+(x64)-7.5.3.1 or RES-AM-Dispatcher+(x64)-7.0.4.3
                    $regex = '{0}-Dispatcher\+\({1}\)-{2}.msi' -f $packageName, $architecture, $versionRegex;

                } #end switch Dispatcher

                'ManagementPortal' {

                    ## RES ONE Automation Management Portal 10.0.100.0.msi
                    $regex = '{0} Management Portal {1}.msi' -f $productName, $versionRegex;
                    
                }

                Default {

                    ## RES-ONE-Automation-2015-Console-7.5.3.1 or RES-AM-Console-7.0.4.3
                    $regex = '{0}-Console-{1}.msi' -f $packageName, $versionRegex;

                } #end switch Console/Database

            } #end switch component

            Write-Verbose -Message ($localizedData.SearchFilePatternMatch -f $regex);

            $packagePath = Get-ChildItem -Path $Path -Recurse |
                Where-Object { $_.Name -imatch $regex } |
                    Sort-Object -Property Name -Descending |
                        Select-Object -ExpandProperty FullName -First 1;

            if ((-not $IsLiteralPath) -and (-not [System.String]::IsNullOrEmpty($packagePath))) {

                Write-Verbose ($localizedData.LocatedPackagePath -f $packagePath);
                return $packagePath;
            }
            elseif ([System.String]::IsNullOrEmpty($packagePath)) {

                throw  ($localizedData.UnableToLocatePackageError -f $Component);
            }

        } #end if

    } #end process
} #end function
