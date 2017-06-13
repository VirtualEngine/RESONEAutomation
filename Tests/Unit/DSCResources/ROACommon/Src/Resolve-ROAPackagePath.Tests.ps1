## Import the ROACommon module
$moduleRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..\..\DSCResources\ROACommon\ROACommon.psd1").Path;
Import-Module $moduleRoot -Force;

Describe 'RESONEAutomation\ROACommon\Resolve-ROAPackagePath' {

    It 'Should resolve v7.5 installer' {
        
        $v75InstallerMsi = 'RES-ONE-Automation-2015.msi';
        New-Item -Path $TestDrive -Name $v75InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROAPackagePath -Path $TestDrive -Component Installer -Version 7.5;

        $result.EndsWith($v75InstallerMsi) | Should Be $true;
    }

    It 'Should resolve later v7.5.5 installer' {
        
        $v75InstallerMsi = 'RES-ONE-Automation-2015.msi';
        New-Item -Path $TestDrive -Name $v75InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;
        $v755InstallerMsi = 'RES-ONE-Automation-2015-SR5.msi';
        New-Item -Path $TestDrive -Name $v755InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROAPackagePath -Path $TestDrive -Component Installer -Version 7.5;

        $result.EndsWith($v755InstallerMsi) | Should Be $true;
    }

    It 'Should resolve explicit v7.5.0 installer' {
        
        $v75InstallerMsi = 'RES-ONE-Automation-2015.msi';
        New-Item -Path $TestDrive -Name $v75InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;
        $v755InstallerMsi = 'RES-ONE-Automation-2015-SR5.msi';
        New-Item -Path $TestDrive -Name $v755InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROAPackagePath -Path $TestDrive -Component Installer -Version 7.5.0;

        $result.EndsWith($v75InstallerMsi) | Should Be $true;
    }

    It 'Should resolve v10.0.0.0 installer' {
        
        $v10InstallerMsi = 'RES ONE Automation 10.0.0.0.msi';
        New-Item -Path $TestDrive -Name $v10InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROAPackagePath -Path $TestDrive -Component Installer -Version 10.0;

        $result.EndsWith($v10InstallerMsi) | Should Be $true;
    }

    It 'Should resolve later v10.0.100.0 hotfix installer' {
        
        $v10InstallerMsi = 'RES ONE Automation 10.0.0.0.msi';
        New-Item -Path $TestDrive -Name $v10InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;
        $v10100InstallerMsi = 'RES ONE Automation 10.0.100.0.msi';
        New-Item -Path $TestDrive -Name $v10100InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROAPackagePath -Path $TestDrive -Component Installer -Version 10.0;

        $result.EndsWith($v10100InstallerMsi) | Should Be $true;
    }

    It 'Should resolve v10.0.0.0 agent+' {
        
        if ([System.Environment]::Is64BitOperatingSystem) {
            $v10AgentPlusMsi = 'RES-ONE-Automation-Agent+(x64)-10.0.0.0.msi';
        }
        else {
            $v10AgentPlusMsi = 'RES-ONE-Automation-Agent+(x86)-10.0.0.0.msi';
        }
        New-Item -Path $TestDrive -Name $v10AgentPlusMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROAPackagePath -Path $TestDrive -Component AgentPlus -Version 10.0;

        $result.EndsWith($v10AgentPlusMsi) | Should Be $true;
    }

    It 'Should throw when "AgentPlus" component is specified on versions prior to v10' {

        { Resolve-ROAPackagePath -Path $TestDrive -Component AgentPlus -Version 7.5 } | Should Throw 'Version 10 is required';
    }

    It 'Should throw when "ManagementPortal" component is specified on versions prior to v10' {

        { Resolve-ROAPackagePath -Path $TestDrive -Component ManagementPortal -Version 7.5 } | Should Throw 'Version 10 is required';
    }

    It 'Should resolve v10.0.0.0 Management Portal installer' {
        
        $v10100InstallerMsi = 'RES ONE Automation Management Portal 10.0.100.0.msi';
        New-Item -Path $TestDrive -Name $v10100InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROAPackagePath -Path $TestDrive -Component ManagementPortal -Version 10.0;

        $result.EndsWith($v10100InstallerMsi) | Should Be $true;
    }

} #end describe
