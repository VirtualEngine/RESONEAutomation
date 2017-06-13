data localizedData {
    # Localized messages; culture="en-US"
    ConvertFrom-StringData @'
        StartingProcess                 = Starting process '{0}' '{1}'.
        StartingProcessAs               = Starting process '{0}' '{1}' as user '{2}'.
        ProcessExited                   = Process exited with code '{0}'.
        OpeningMSIDatabase              = Opening MSI database '{0}'.
        SearchFilePatternMatch          = Searching for files matching pattern '{0}'.
        LocatedPackagePath              = Located package '{0}'.

        VersionNumberRequiredError      = Version number is required when not using a literal path.
        SpecifedPathTypeError           = Specified path '{0}' does not point to a '{1}' file.
        InvalidVersionNumberFormatError = The specified version '{0}' does not match '1.2', '1.2.3' or '1.2.3.4' format.
        UnsupportedVersionError         = Version '{0}' is not supported/untested :(
        UnableToLocatePackageError      = Unable to locate '{0}' package.
        CannotFindPathError             = Cannot find path '{0}' because it does not exist.
        ROAComponentNotFoundError       = RES ONE Automation component '{0}' was not found.
        ROAConsoleNotFoundError         = RES ONE Automation console was not found.
        InvalidComponentVersionError    = Component '{0}' is not supported in this version. Version {1} is required.
'@
}

$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleSrcPath = Join-Path -Path $moduleRoot -ChildPath 'Src';
Get-ChildItem -Path $moduleSrcPath -Include '*.ps1' -Recurse |
    ForEach-Object {
        Write-Verbose -Message ('Importing library\source file ''{0}''.' -f $_.FullName);
        . $_.FullName;
    }


Export-ModuleMember -Function *;
