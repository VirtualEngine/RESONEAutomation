# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        StartingProcess                 = Starting process '{0}' with parameters '{1}'.
        StartingProcessAs               = Starting process as user '{0}'.
        ProcessLaunched                 = Process id '{0}' successfully started.
        WaitingForProcessToExit         = Waiting for process id '{0}' to exit.
        ProcessExited                   = Process id '{0}' exited with code '{1}'.
        OpeningMSIDatabase              = Opening MSI database '{0}'.
'@
}

function ResolveProductName {
<#
    .SYNOPSIS
        Resolves the RES ONE Automation agent to the correct product name.
#>
    [CmdletBinding()]
    param (
        ## RES ONE Automation component version to be installed, i.e. 8.0.3.0
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        [Parameter(Mandatory)] [ValidateSet('Console','Dispatcher','Agent')]
        [System.String] $Component
    )

    [System.Version] $Version = $Version;
    switch ($Version.Major) {
        7 {
            if ($Version.Minor -eq 0) {
                $msiProductName = 'RES Automation Manager 2014';
            }
            elseif ($Version.Minor -eq 5) {
                $msiProductName = 'RES ONE Automation 2015';
            }
        }
        Default {
            throw "Version '$($Version.Tostring())' is not currently supported :(.";
        }
    } #end switch version
    
    switch ($Component) {
        'Console' {
            ## Determine whether we're on the RTM release
            if ($Version.Build -eq 0) {
                $msiProductName = '{0}' -f $msiProductName;
            }
            else {
                $msiProductName = '{0} SR{1}' -f $msiProductName, $Version.Build;
            }
        }
        'Dispatcher' {
            if ($Version.Build -eq 0) {
                $msiProductName = '{0} Dispatcher+' -f $msiProductName;
            }
            else {
                $msiProductName = '{0} SR{1} Dispatcher+' -f $msiProductName, $Version.Build;
            }
        }
        Default { #Agent
            if ($Version.Build -eq 0) {
                $msiProductName = '{0} {1}' -f $msiProductName, $Component;
            }
            else {
                $msiProductName = '{0} SR{1} {2}' -f $msiProductName, $Version.Build, $Component;
            }
        } #end Default

    } #end switch component
        
    return $msiProductName;

} #end function ResolveProductName

function ResolveSetupPath {
<#
    .SYNOPSIS
        Resolves the RES ONE Automation agent to the correct .msi
#>
    [CmdletBinding()]
    param (
        ## File path containing the RES ONE Automation MSIs or the literal path to the Agent MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## RES ONE Automation component version to be installed, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,
        
        ## The specified Path is a literal file reference (bypasses the $Versioncheck).
        [Parameter()] [ValidateNotNull()]
        [System.Management.Automation.SwitchParameter] $IsLiteralPath,

        [Parameter(Mandatory)] [ValidateSet('Agent')]
        [System.String] $Component,

        ## Catch-all to permit splatting
        [Parameter(ValueFromRemainingArguments)] $Arguments
    )

    if (-not $IsLiteralPath) {
        [System.Version] $Version = $Version;
        
        switch ($Component) {
            'Agent' {
                switch ($Version.Major) {
                    7 {
                        if ($Version.Minor -eq 0) {
                            $setup = 'RES-AM-Agent-{0}.msi' -f $Version.ToString();
                        }
                        elseif ($Version.Minor -eq 5) {
                            $setup = 'RES-ONE-Automation-Agent-{0}.msi' -f $Version.ToString();
                        }
                    }
                    Default {
                        throw "Version '$($Version.Tostring())' is not currently supported :(.";
                    }
                }
                $Path = Join-Path -Path $Path -ChildPath $setup;
            }
        } #end switch component
    } #end if not literal path
    
    return $Path;
} #end function ResolveSetupPath

function GetWindowsInstallerPackageProperty {
<#
    .SYNOPSIS
        This cmdlet retrieves product name from a Windows Installer MSI database.
    .DESCRIPTION
        This function uses the WindowInstaller COM object to pull all values from the Property table from a MSI package.
    .NOTES
        Adapted from http://www.scconfigmgr.com/2014/08/22/how-to-get-msi-file-information-with-powershell/
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName='Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [System.String] $Path,
        
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [System.String] $LiteralPath,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]        [ValidateSet('ProductCode', 'ProductVersion', 'ProductName', 'UpgradeCode')] [System.String] $Property = 'ProductCode'
    )
    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $LiteralPath += $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        } # end if
    } #end begin
    process {
        $windowsInstaller = New-Object -ComObject WindowsInstaller.Installer;
        Write-Verbose -Message ($localizedData.OpeningMSIDatabase -f $LiteralPath);
        try {
            $msiDatabase = $windowsInstaller.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $windowsInstaller, @("$LiteralPath", 0));
            $query = "SELECT Value FROM Property WHERE Property = '$Property'";
            $view = $msiDatabase.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $msiDatabase, $query);
            $view.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $view, $null);
            $record = $view.GetType().InvokeMember('Fetch','InvokeMethod', $null, $view, $null);
            $value = $record.GetType().InvokeMember('StringData', 'GetProperty', $null, $record, 1);
            return $value;
        } 
        catch {
            throw;
        }
    } #end process
} #end function Get-WindowsInstallerPackageProperty

function StartWaitProcess {
<#
    .SYNOPSIS
        Starts and waits for a process to exit.
    .NOTES
        This is an internal function and shouldn't be called from outside.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Int32])]
    param (
        # Path to process to start.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $FilePath,

        # Arguments (if any) to apply to the process.
        [Parameter()] [AllowNull()]
        [System.String[]] $ArgumentList,

        # Credential to start the process as.
        [Parameter()] [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        # Working directory
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $WorkingDirectory = (Split-Path -Path $FilePath -Parent)
    )
    process {
        $startProcessParams = @{
            FilePath = $FilePath;
            WorkingDirectory = $WorkingDirectory;
            NoNewWindow = $true;
            PassThru = $true;
        };
        $displayParams = '<None>';
        if ($ArgumentList) {
            $displayParams = [System.String]::Join(' ', $ArgumentList);
            $startProcessParams['ArgumentList'] = $ArgumentList;
        }
        Write-Verbose ($localizedData.StartingProcess -f $FilePath, $displayParams);
        if ($Credential) {
            Write-Verbose ($localizedData.StartingProcessAs -f $Credential.UserName);
            $startProcessParams['Credential'] = $Credential;
        }
        if ($PSCmdlet.ShouldProcess($FilePath, 'Start Process')) {
            $process = Start-Process @startProcessParams -ErrorAction Stop;
        }
        if ($PSCmdlet.ShouldProcess($FilePath, 'Wait Process')) {
            Write-Verbose ($localizedData.ProcessLaunched -f $process.Id);
            Write-Verbose ($localizedData.WaitingForProcessToExit -f $process.Id);
            $process.WaitForExit();
            $exitCode = [System.Convert]::ToInt32($process.ExitCode);
            Write-Verbose ($localizedData.ProcessExited -f $process.Id, $exitCode);
        }
        return $exitCode;
    } #end process
} #end function StartWaitProcess

function GetRAMSiteLicense {
<#
    .SYNOPSIS
        Retrieves a RES ONE Automation Site License directory from the database.
    .NOTES
        This cmdlet currently only support Microsoft SQL servers.
#>
    [CmdletBinding(DefaultParameterSetName='SQLAuth')]
    param (
        # Database server to connect to
        [Parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]
        [System.String] $Server,
        
        # Database to connect to
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Database,
        
        # SQL authentication username
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Credential
    )
    process {
        $sqlConnectionString = 'Data Source={0};Initial Catalog={1};User Id={2};Password={3};' -f $Server, $Database, $Credential.UserName, $Credential.GetNetworkCredential().Password;
        $sqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection -Property @{ 'ConnectionString' = $sqlConnectionString; };
        $sqlConnection.Open();

        $sqlCommand = $sqlConnection.CreateCommand();
        $sqlCommand.CommandText = 'SELECT strValue AS License FROM tblSettings WHERE lngSetting = 6';

        $sqlDataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand;
        $dataSet = New-Object System.Data.DataSet;
        [ref] $null = $sqlDataAdapter.Fill($dataSet);

        $sqlConnection.Close();
        $dirtySiteLicense = "RES-$(($dataSet.Tables[0].License).Replace('{','').Replace('}',''))";
        $cleanSiteLicense = $dirtySiteLicense.Insert(8, '-').Insert(33, '-').Insert(38, '-');
        return $cleanSiteLicense;
    }
} #end function GetRAMSiteLicense

function GetProductEntry {
<#
    .NOTES
        https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/dev/DSCResources/MSFT_xPackageResource/MSFT_xPackageResource.psm1
#>
    param (
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Name,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $IdentifyingNumber,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegHive = 'LocalMachine',
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegKey,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegValueName,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegValueData
    )

    $uninstallKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
    $uninstallKeyWow64 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall';

    if ($IdentifyingNumber) {
        $keyLocation = "$uninstallKey\$identifyingNumber";
        $item = Get-Item $keyLocation -ErrorAction SilentlyContinue;
        if (-not $item) {
            $keyLocation = "$uninstallKeyWow64\$identifyingNumber";
            $item = Get-Item $keyLocation -ErrorAction SilentlyContinue;
        }
        return $item;
    }

    foreach ($item in (Get-ChildItem -ErrorAction Ignore $uninstallKey, $uninstallKeyWow64)) {
        if ($Name -eq (GetLocalizableRegKeyValue $item 'DisplayName')) {
            return $item;
        }
    }

    if ($InstalledCheckRegKey -and $InstalledCheckRegValueName -and $InstalledCheckRegValueData) {
        $installValue = $null;
        #if 64bit OS, check 64bit registry view first
        if ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName 'localhost' -ErrorAction SilentlyContinue).OSArchitecture -eq '64-bit') {
            $installValue = GetRegistryValueIgnoreError $InstalledCheckRegHive "$InstalledCheckRegKey" "$InstalledCheckRegValueName" Registry64;
        }

        if ($installValue -eq $null) {
            $installValue = GetRegistryValueIgnoreError $InstalledCheckRegHive "$InstalledCheckRegKey" "$InstalledCheckRegValueName" Registry32;
        }

        if ($installValue) {
            if ($InstalledCheckRegValueData -and $installValue -eq $InstalledCheckRegValueData) {
                return @{ Installed = $true; }
            }
        }
    }

    return $null;
} #end function GetProductEntry

function GetRegistryValueIgnoreError {
<#
    .NOTES
        https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/dev/DSCResources/MSFT_xPackageResource/MSFT_xPackageResource.psm1
#>

    param (
        [arameter(Mandatory)]
        [Microsoft.Win32.RegistryHive] $RegistryHive,

        [Parameter(Mandatory)] 
        [System.String] $Key,

        [Parameter(Mandatory)]
        [System.String] $Value,

        [Parameter(Mandatory)]
        [Microsoft.Win32.RegistryView] $RegistryView
    )

    try {
        $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($RegistryHive, $RegistryView);
        $subKey =  $baseKey.OpenSubKey($Key);
        if($subKey -ne $null) {
            return $subKey.GetValue($Value);
        }
    }
    catch {
        $exceptionText = ($_ | Out-String).Trim();
        Write-Verbose "Exception occured in Get-RegistryValueIgnoreError: $exceptionText";
    }
    return $null;
} #end function GetRegistryValueIgnoreError

function GetLocalizableRegKeyValue {
<#
    .NOTES
        https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/dev/DSCResources/MSFT_xPackageResource/MSFT_xPackageResource.psm1
#>

    param (
        [Parameter()]
        [System.Object] $RegKey,
        
        [Parameter()]
        [System.String] $ValueName
    )

    $res = $RegKey.GetValue("{0}_Localized" -f $ValueName);
    if (-not $res) {
        $res = $RegKey.GetValue($ValueName);
    }
    return $res;
} #end function GetLocalizableRegKeyValue
