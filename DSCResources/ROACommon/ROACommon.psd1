@{
    RootModule        = 'ROACommon.psm1'
    ModuleVersion     = '1.0'
    GUID              = '4c1bd214-d11d-4e51-92d2-56c2267aeff4'
    Author            = 'Iain Brighton'
    CompanyName       = 'Virtual Engine'
    Copyright         = '(c) 2016 Virtual Engine Limited. All rights reserved.'
    Description       = 'RES ONE Automation common function library'
    PowerShellVersion = '4.0'
    FunctionsToExport = @(
                            'Assert-ROAComponent',
                            'Get-InstalledProductEntry',
                            'Get-LocalizableRegistryKeyValue',
                            'Get-RegistryValueIgnoreError',
                            'Get-ROAComponentInstallPath',
                            'Get-ROAConsolePath',
                            'Get-ROAEnvironment',
                            'Get-ROALicense',
                            'Get-WindowsInstallerPackageProperty',
                            'Import-ROABuildingBlockFile',
                            'Register-PInvoke',
                            'Resolve-ROAPackagePath',
                            'Start-WaitProcess'
                        )
}
