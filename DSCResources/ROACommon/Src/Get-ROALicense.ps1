function Get-ROALicense {
<#
    .SYNOPSIS
        Retrieves a RES ONE Automation site license from the database.
    .NOTES
        This cmdlet currently only support Microsoft SQL servers.
#>
    [CmdletBinding(DefaultParameterSetName = 'SQLAuth')]
    [OutputType([System.String])]
    param (
        # Database server hosting the RES ONE Automation database
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Server,

        # Name of the RES ONE Automation database/instance
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Database,

        # SQL authentication username and password
        [Parameter(Mandatory, ParameterSetName = 'SQLAuth')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        # Use the current Windows credentials for authentication
        [Parameter(ParameterSetName = 'WindowsAuth')]
        [System.Management.Automation.SwitchParameter]
        $UseWindowsAuthentication
    )
    process {

        try {

            $environmentGuid = (Get-ROAEnvironment @PSBoundParameters).ToString();
            $dirtySiteLicense = 'RES-{0}' -f $environmentGuid.TrimStart('{').TrimEnd('}');
            $cleanSiteLicense = $dirtySiteLicense.Insert(8, '-').Insert(33, '-').Insert(38, '-');
            return $cleanSiteLicense.ToUpper();

        }
        catch {

            throw $_;
        }

    } #end process
} #end function Get-ROALicense