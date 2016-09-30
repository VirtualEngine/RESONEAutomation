function Get-ROAEnvironment {
<#
    .SYNOPSIS
        Retrieves a RES ONE Automation environment GUID from the database.
    .NOTES
        This cmdlet currently only support Microsoft SQL servers.
#>
    [CmdletBinding(DefaultParameterSetName = 'SQLAuth')]
    [OutputType([System.Guid])]
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

        if ($PSCmdlet.ParameterSetName -eq 'SQLAuth') {

            $sqlConnectionString = 'Data Source={0};Initial Catalog={1};User Id={2};Password={3};' -f $Server, $Database, $Credential.UserName, $Credential.GetNetworkCredential().Password;
        }
        else {

            $sqlConnectionString = 'Data Source={0};Initial Catalog={1};Integrated Security=SSPI;' -f $Server, $Database;
        }

        try {

            $sqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection -Property @{ 'ConnectionString' = $sqlConnectionString; };
            $sqlConnection.Open();

            $sqlCommand = $sqlConnection.CreateCommand();
            $sqlCommand.CommandText = 'SELECT strValue AS License FROM tblSettings WHERE lngSetting = 6';

            $sqlDataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand;
            $dataSet = New-Object System.Data.DataSet;
            [ref] $null = $sqlDataAdapter.Fill($dataSet);

            $sqlConnection.Close();
            $roaEnvironmentGuid = New-Object -TypeName System.Guid($dataSet.Tables[0].License);
            return $roaEnvironmentGuid;

        }
        catch {

            throw $_;
        }

    } #end process
} #end function Get-ROAEnvironment
