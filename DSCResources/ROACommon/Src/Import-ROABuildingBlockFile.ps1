function Import-ROABuildingBlockFile {
<#
    .SYNOPSIS
        Imports RES ONE Automation building blocks.
#>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'PathCredential')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [System.String] $Path,

        # SQL authentication username and password
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'PathCredential')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        ## Credential is an internal RES ONE Automation user account.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'PathCredential')]
        [System.Boolean] $IsRESONEAutomationCredential
    )
    begin {

        $wmcPath = Get-ROAConsolePath;

    }
    process {

        $paths = @();
        if (-not (Test-Path -Path $Path)) {

            $exMessage = $localizedData.CannotFindPathError -f $Path;
            $ex = New-Object System.Management.Automation.ItemNotFoundException $exMessage;
            $category = [System.Management.Automation.ErrorCategory]::ObjectNotFound;
            $errRecord = New-Object System.Management.Automation.ErrorRecord $ex, 'PathNotFound', $category, $Path;
            $psCmdlet.WriteError($errRecord);
        }
        else {

            # Resolve any wildcards that might be in the path
            $provider = $null;
            $paths += $psCmdlet.SessionState.Path.GetResolvedProviderPathFromPSPath($Path, [ref] $provider);
        }

        foreach ($filePath in $paths) {

            $arguments = @(
                '/action=importbb',
                ('/file="{0}"' -f $filePath),
                '/silent'
            );

            if (($PSBoundParameters.ContainsKey('Credential')) -and ($IsRESONEAutomationCredential)) {

                $arguments += ('/user={0}' -f $Credential.UserName);
                $arguments += ('/password={0}' -f $Credential.GetNetworkCredential().Password);
                $exitCode = Start-WaitProcess -FilePath $wmcPath -ArgumentList $arguments;
            }
            elseif ($PSBoundParameters.ContainsKey('Credential')) {

                $exitCode = Start-WaitProcess -FilePath $wmcPath -ArgumentList $arguments -Credential $Credential;
            }
            else {

                $exitCode = Start-WaitProcess -FilePath $wmcPath -ArgumentList $arguments;
            }

            Write-Output -InputObject ([PSCustomObject] @{
                BuildingBlock = $filePath;
                ExitCode = $exitCode;
            });

        } #end foreach resolved path

    } #end process
} #end function Import-ROABuildingBlockFile
