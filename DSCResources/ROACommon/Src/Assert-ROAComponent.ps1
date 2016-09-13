function Assert-ROAComponent {
<#
    .SYNOPSIS
        Ensures that the RES ONE Automation console is installed.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Agent','Console','Dispatcher')]
        [System.String] $Component
    )
    process {

        if (-not (Get-ROAComponentInstallPath -Component $Component)) {
            throw ($localizedData.ROAComponentNotFoundError -f $Component);
        }

    }
} #end function Assert-ROAComponent
