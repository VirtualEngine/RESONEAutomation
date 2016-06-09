#requires -Version 5

configuration ROALabBuildingBlock {
<#
    .SYNOPSIS
        Adds/removes a RES ONE Automation building block.
#>
    param (
        ## Source file path of the resource to be added.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Needs to be a valid RES ONE Automation or domain user.
        [Parameter()] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Credential,

        ## Use RES Automation Manager authentication.
        [Parameter()]
        [System.Boolean] $UseAutomationAuthentication,

        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64',

        [Parameter()] [ValidateSet('Present')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $pathFileInfo = New-Object -TypeName 'System.IO.FileInfo' -ArgumentList $Path;
    $resourceName = $pathFileInfo.Name.Replace(' ','').Replace('.','');

    if ($Architecture -eq 'x64') {
        ## TODO: Ideally xPackage would support environment variables in the path
        $pwrtechPath = 'C:\Program Files (x86)\RES Software\Automation Manager\WMC\wmc.exe';
    }
    elseif ($Architecture -eq 'x86') {
        $pwrtechPath = 'C:\Program Files\RES Software\Automation Manager\WMC\wmc.exe';
    }

    if ($Ensure -eq 'Present') {
        $arguments = '/action=importbb /file="{0}" /silent' -f $Path;
    }

    if ($PSBoundParameters.ContainsKey('Credential')) {

        if ($UseAutomationAuthentication) {

            xPackage $resourceName {
                Name = $resourceName;
                ProductId = '';
                Path = $pwrtechPath;
                Arguments = '{0} /user={1} /password={2}' -f $arguments, $Credential.UserName, $Credential.GetNetworkCredential().Password;
                ReturnCode = 0;
                InstalledCheckRegKey = 'Software\VirtualEngine';
                InstalledCheckRegValueName = $resourceName;
                InstalledCheckRegValueData = 'ROALabBuildingBlock';
                CreateCheckRegValue = $true;
                Ensure = $Ensure;
            }

        }
        else {

            xPackage $resourceName {
                Name = $resourceName;
                ProductId = '';
                Path = $pwrtechPath;
                Arguments = $arguments;
                ReturnCode = 0;
                PsDscRunAsCredential = $Credential;
                InstalledCheckRegKey = 'Software\VirtualEngine';
                InstalledCheckRegValueName = $resourceName;
                InstalledCheckRegValueData = 'ROALabBuildingBlock';
                CreateCheckRegValue = $true;
                Ensure = $Ensure;
            }

        }

    }
    else {

        xPackage $resourceName {
            Name = $resourceName;
            ProductId = '';
            Path = $pwrtechPath;
            Arguments = $arguments;
            ReturnCode = 0;
            InstalledCheckRegKey = 'Software\VirtualEngine';
            InstalledCheckRegValueName = $resourceName;
            InstalledCheckRegValueData = 'ROABuildingBlock';
            CreateCheckRegValue = $true;
            Ensure = $Ensure;
        }

    }

} #end configuration ROABuildingBlock
