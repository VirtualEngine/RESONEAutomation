function Import-ROABuildingBlock {
<#
    .SYNOPSIS
        Imports a RES ONE Automation building block.
    .EXAMPLE
        Import-ROABuildingBlock -Path .\RESAM.xml

        Imports the 'RESAM.xml' building block into the RES ONE Automation database using the current
        Windows user credentials.
    .EXAMPLE
        Import-ROABuildingBlock -Path .\RESAM.xml -Credential (Get-Credential)

        Imports the 'RESAM.xml' building block into the RES ONE Automation database using the RES ONE
        Automation credentials supplied.
    .NOTES
        This cmdlet requires the RES ONE Automation console (WMC.EXE) to be installed.
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Path', ConfirmImpact = 'High')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'PathCredential')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [System.String[]] $Path,

        # Specifies a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is
        # used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
        # enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
        # characters as escape sequences.
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPathCredential')]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $LiteralPath,

        # Authentication username and password
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'PathCredential')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPathCredential')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        ## Credential is an internal RES ONE Automation user account.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'PathCredential')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPathCredential')]
        [System.Management.Automation.SwitchParameter] $IsRESONEAutomationCredential,

        ## Suppress import confirmation prompts
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    process {

        $paths = @()
        if ($psCmdlet.ParameterSetName -in 'Path','PathCredential') {

            foreach ($filePath in $Path) {

                if (-not (Test-Path -Path $filePath)) {

                    $ex = New-Object System.Management.Automation.ItemNotFoundException "Cannot find path '$filePath' because it does not exist.";
                    $category = [System.Management.Automation.ErrorCategory]::ObjectNotFound;
                    $errRecord = New-Object System.Management.Automation.ErrorRecord $ex,'PathNotFound', $category, $filePath;
                    $psCmdlet.WriteError($errRecord);
                    continue;
                }

                # Resolve any wildcards that might be in the path
                $provider = $null;
                $paths += $psCmdlet.SessionState.Path.GetResolvedProviderPathFromPSPath($filePath, [ref] $provider);
            }
        }
        else {

            foreach ($filePath in $LiteralPath) {

                if (-not (Test-Path -LiteralPath $filePath)) {

                    $ex = New-Object System.Management.Automation.ItemNotFoundException "Cannot find path '$filePath' because it does not exist.";
                    $category = [System.Management.Automation.ErrorCategory]::ObjectNotFound;
                    $errRecord = New-Object System.Management.Automation.ErrorRecord $ex, 'PathNotFound', $category, $filePath;
                    $psCmdlet.WriteError($errRecord);
                    continue;
                }

                # Resolve any relative paths
                $paths += $psCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($filePath);
            }
        }

        foreach ($filePath in $paths) {

            if ($Force -or ($psCmdlet.ShouldProcess($filePath, 'Import'))) {

                $importROABuildingBlockFileParams = @{
                    Path = $filePath;
                }
                if ($PSBoundParameters.ContainsKey('Credential')) {
                    $importROABuildingBlockFileParams['Credential'] = $Credential;
                    $importROABuildingBlockFileParams['IsRESONEAutomationCredential'] = $IsRESONEAutomationCredential.ToBool();
                }
                ## Call the method in \DSCResources\ROACommon
                Import-ROABuildingBlockFile @importROABuildingBlockFileParams;
            }
        }

    } #end process
} #end function Import-ROABuildingBlock
