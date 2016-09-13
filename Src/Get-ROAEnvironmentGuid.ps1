function Get-ROAEnvironmentGuid {
<#
    .SYNOPSIS
        Retrieves a RES ONE Automation environment GUID from the database.
    .EXAMPLE
        Get-ROAEnvironmentGuid -Server CONTROLLER -Database RESONEAutomation -Credential (Get-Credential 'sa')

        Returns the RES ONE Automation environment GUID from the RESONEAutomation database on the CONTROLLER SQL
        server using SQL authentication.
    .EXAMPLE
        Get-ROAEnvironmentGuid -Server CONTROLLER -Database RESONEAutomation -WindowsAuthentication

        Returns the RES ONE Automation environment GUID from the RESONEAutomation database on the CONTROLLER SQL
        server using the current Windows credentials.
    .NOTES
        This cmdlet currently only supports Microsoft SQL servers.
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

        ## Call the method in \DSCResources\ROACommon
        Get-ROAEnvironment @PSBoundParameters;
    }
} #end function Get-ROAEnvironmentGuid
