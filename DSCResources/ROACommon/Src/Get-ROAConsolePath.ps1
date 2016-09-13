function Get-ROAConsolePath {
<#
    .SYNOPSIS
        Returns the RES ONE Automation console path.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param ( )
    begin {
        Assert-ROAComponent -Component 'Console';
    }
    process {

        $wmcRootPath = Get-ROAComponentInstallPath -Component 'Console';
        $wmcPath = Join-Path -Path $wmcRootPath -ChildPath 'wmc.exe';
        if (-not (Test-Path -Path $wmcPath -PathType Leaf)) {
            throw ($localizedData.ROAConsoleNotFoundError);
        }
        return $wmcPath;

    } #end process
} #end function Get-ROAConsolePath
