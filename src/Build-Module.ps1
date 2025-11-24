[CmdletBinding(DefaultParameterSetName = "All")]
param(
    [Parameter(ParameterSetName = "UnitTest", Mandatory = $true)]
    [Parameter(ParameterSetName = "All")]
    [switch]$runUnitTests,

    [Parameter(ParameterSetName = "UnitTest")]
    [string]$testName
)
Write-Verbose "PSScriptRoot:$PSScriptRoot"
Write-Verbose "PSCommandPath:$PSCommandPath"

$inputFolders = @("$PSScriptRoot\classes", "$PSScriptRoot\private", "$PSScriptRoot\public")
$outputFile = 'DenseAzDO.psm1'
if (!(Test-Path -Path "$PSScriptRoot\..\dist")){
    New-Item -ItemType Directory -Path "$PSScriptRoot\..\dist"
}
$outputDir = Resolve-Path -Path "$PSScriptRoot\..\dist"

# $workingDir = Resolve-Path -Path "$PSScriptRoot\..\obj"

$output = Join-Path $outputDir $outputFile
$files = @()

foreach ($folder in $inputFolders) {
    Write-Verbose $folder
    foreach ($file in $(Get-ChildItem -Path $folder -filter '*.ps1')) {
        $files += (Resolve-Path $file.FullName)
    }
}

#$files = $files | select-object -Unique 

New-Item -ItemType file -Path $output -Force
Write-Output "Creating: $output"

$contents = New-Object System.Text.StringBuilder
 
ForEach ($file in $files) {
    Write-Verbose -Message "Merging from $file"
    $fileContents = Get-Content $file

    foreach ($line in $fileContents) {
        $line = ($line -replace ' +$', '')
        if ($null -ne $line.Trim() -and '' -ne $line.Trim()) {
            $contents.AppendLine($line) | Out-Null
        }
    }
}

Import-Module -Name Pester -Force
# Remove all trailing whitespace
Write-Output $contents.ToString() | Add-Content $output

if ($runUnitTests) {

    $pesterArgs = [PesterConfiguration]::Default
    $pesterArgs.Run.Path = '.\tests\unit'
    $pesterArgs.Output.Verbosity = "Detailed"
    $pesterArgs.TestResult.Enabled = $true
    $pesterArgs.TestResult.OutputPath = 'test-results.xml'
    
    if ($codeCoverage.IsPresent) {
        $pesterArgs.CodeCoverage.Enabled = $true
        $pesterArgs.CodeCoverage.OutputFormat = 'JaCoCo'
        $pesterArgs.CodeCoverage.OutputPath = "coverage.xml"
        $pesterArgs.CodeCoverage.Path = "./Source/**/*.ps1"
    }
    else {
        $pesterArgs.Run.PassThru = $false
    }
    
    if ($testName) {
        $pesterArgs.Filter.FullName = $testName
    }
    
    Invoke-Pester -Configuration $pesterArgs    
}

Remove-Module 'DenseAzDO' -ErrorAction Ignore
Import-Module "$PSScriptRoot\..\dist\DenseAzdo.psm1"
