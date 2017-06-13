function Get-ROAComponentInstallPath {
<#
    .SYNOPSIS
        Resolves the installation directory of the specified RES ONE Automation component.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Agent','Console','Dispatcher')]
        [System.String] $Component
    )
    process {

        $installedProducts = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*';
        $resProducts = $installedProducts |
                            Where-Object { $_.DisplayName -match '^RES' -and $_.DisplayName -match 'Automation' }

        if ($Component -eq 'Agent') {

            $resProduct = $resProducts |
                            Where-Object { $_.DisplayName -match 'Agent' }
        }
        elseif ($Component -eq 'Console') {

            $resProduct = $resProducts |
                            Where-Object { $_.DisplayName -notmatch 'Agent' -and $_.DisplayName -notmatch 'Dispatcher' }
        }
        elseif ($Component -eq 'Dispatcher') {

            $resProduct = $resProducts |
                            Where-Object { $_.DisplayName -match 'Dispatcher' }
        }

        return $resProduct.InstallLocation;

    } #end process
} #end function Get-ROAComponentInstallPath
