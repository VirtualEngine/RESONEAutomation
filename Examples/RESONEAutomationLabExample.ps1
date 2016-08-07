$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost';
            PSDSCAllowPlainTextPassword = $true;

            ROADatabaseServer  = 'controller.lab.local';
            ROADatabaseName    = 'RESONEAutomation';
            ROABinariesPath    = 'C:\SharedData\Software\RES\ONE Automation 2015\SR1';
            ROABinariesVersion = '7.5.1.0';
        }
    )
}

configuration RESONEAutomationLabExample {
    param (
        ## RES ONE Automation SQL database/user credential
        [Parameter(Mandatory)]
        [PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        ## Microsoft SQL Server credentials used to create the RES ONE Automation database/user
        [Parameter(Mandatory)]
        [PSCredential]
        [System.Management.Automation.Credential()]
        $SQLCredential
    )

    Import-DscResource -ModuleName RESONEAutomation;

    node 'localhost' {

        ROALab 'ROALab' {
            DatabaseServer = $node.ROADatabaseServer;
            DatabaseName = $Node.ROADatabaseName;
            Path = $node.ROABinariesPath;
            Version = $node.ROABinariesVersion;
            SQLCredential = $SQLCredential;
            Credential = $Credential;
        }

    }

} #end configuration RESONEAutomationLabExample

if (-not $Cred) { $Cred = Get-Credential -UserName 'RESONEAutomation' -Message 'RES ONE Automation SQL account credential'; }
if (-not $sqlCred) { $sqlCred = New-Object PSCredential -ArgumentList 'sa', (ConvertTo-SecureString -String 'Tra1ning' -AsPlainText -Force); }
RESONEAutomationLabExample -OutputPath ~\Documents -ConfigurationData $config -Credential $cred -SQLCredential $sqlCred;
