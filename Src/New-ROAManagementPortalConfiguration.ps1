function New-ROAManagementPortalConfiguration {
<#
    .SYNOPSIS
        Creates a RES ONE Automation Management Portal web configuration file.
#>
    [CmdletBinding(DefaultParameterSetName = 'WindowsAuthentication')]
    param (
        ## Path to RES ONE Automation Management Portal web configuration file
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,

        ## RES ONE Automation database server/instance name.
        [Parameter(Mandatory)]
        [System.String] $DatabaseServer,

        ## RES ONE Automation database name.
        [Parameter(Mandatory)]
        [System.String] $DatabaseName,
        
        ## RES ONE Automation database access credential. Leave blank to use Windows Authentication for database access.
        [Parameter()]
        [System.Management.Automation.PSCredential] $Credential,

        ## RES ONE Automation API key.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ApiKey,

        ## RES ONE Identity Broker server Uri.
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.String] $ServerUrl,

        ## RES ONE Identity Broker application Uri.
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.String] $ApplicationUrl,

        ## RES ONE Identity Broker client Id.        
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.String] $ClientId,

        ## RES ONE Identity Broker client shared secret.
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.Management.Automation.PSCredential] $ClientSecret
    )

    ## Call method in ROACommon module
    Save-ROAManagementPortalConfiguration @PSBoundParameters;

} #end function
