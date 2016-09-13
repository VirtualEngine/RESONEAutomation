$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost';
            PSDSCAllowPlainTextPassword = $true;

            ROADatabaseServer = 'controller.lab.local';
            ROADatabaseName   = 'RESONEAutomation';
            ROABinaryPath     = 'C:\SharedData\Software\RES\ONE Automation 2015\SR1';
            ROABinaryVersion  = '7.5.1.0';
        }
    )
}

configuration RESONEAutomationLabExample {
    param (
        ## RES ONE Automation SQL database/user credential
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        ## Microsoft SQL Server credentials used to create the RES ONE Automation database/user
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SQLCredential
    )

    Import-DscResource -ModuleName RESONEAutomation;

    node 'localhost' {

        ROALab 'ROALab' {

            DatabaseServer = $node.ROADatabaseServer;
            DatabaseName   = $Node.ROADatabaseName;
            Path           = $node.ROABinaryPath;
            Version        = $node.ROABinaryVersion;
            SQLCredential  = $SQLCredential;
            Credential     = $Credential;
            Ensure         = 'Present';
        }

    }

} #end configuration RESONEAutomationLabExample

if (-not $cred) { $cred = Get-Credential -UserName 'RESONEAutomation' -Message 'RES ONE Automation SQL account credential'; }
if (-not $sqlCred) { $sqlCred = Get-Credential -UserName 'sa' -Message 'Existing SQL account for database creation'; }
RESONEAutomationLabExample -OutputPath ~\Documents -ConfigurationData $config -Credential $cred -SQLCredential $sqlCred;
