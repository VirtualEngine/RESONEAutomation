@{
    RootModule         = 'RESONEAutomation.psm1';
    ModuleVersion      = '2.1.5';
    GUID               = '7879d40d-210f-4ab0-b870-a219dd0e8110';
    Author             = 'Iain Brighton';
    CompanyName        = 'Virtual Engine';
    Copyright          = '(c) 2016 Virtual Engine Limited. All rights reserved.';
    Description        = 'RES ONE Automation PowerShell cmdlets and configuration composite DSC resources. These resources are provided AS IS, and are not supported through any means.';
    FunctionsToExport  = @('Get-ROAEnvironmentGuid','Get-ROASiteLicense','Import-ROABuildingBlock');

    <# Removed for WMF 4 compaitibilty
    DscResourcesToExport = @('ROAAgent','ROABuildingBlock','ROAConsole','ROADatabase','ROADatabaseAgent',
                                'ROADispatcher'); #>

    PrivateData = @{
        PSData = @{
            Tags       = @('VirtualEngine','RES','ONE','Automation','Manager','DSC');
            LicenseUri = 'https://github.com/VirtualEngine/RESONEAutomation/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/RESONEAutomation';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
