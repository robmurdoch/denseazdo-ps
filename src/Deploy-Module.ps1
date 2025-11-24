[CmdletBinding(DefaultParameterSetName = "All")]
param(
    [string[]]$ComputerName
)

$source = Resolve-Path -Path "$PSScriptRoot\..\dist\DenseAzDO.psm1"

foreach ($cn in $ComputerName) {
    
    $destination = "\\$cn\C$\Users\Administrator\Documents"
    Copy-Item -Path $source -Destination $destination

}

$userDocumentsFolder = ([Environment]::GetFolderPath("MyDocuments"))
$destination = "$userDocumentsFolder\PowerShell\Modules\DenseAzDO\"
if (-not (Test-Path -Path $destination)){

    New-Item -Path $destination -ItemType Directory
}
Copy-Item -Path $source -Destination $destination -Force