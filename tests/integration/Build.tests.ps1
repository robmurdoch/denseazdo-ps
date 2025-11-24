Describe "Build features" {
    BeforeAll {
        
        . "$PSScriptRoot/../../src/Build-Module.ps1"
        . "$PSScriptRoot/../../tests/integration/variables.ps1"
        . "$PSScriptRoot/../../tests/integration/secrets.ps1"

        # prompt for these if no secrets file exists
        # $orgUri = Read-Host -Prompt 'Enter org url'
        # $token = Read-Host -Prompt 'Enter Personal Access Token'

        $org = Connect-AzureDevOps -OrgUri $orgUri -PersonalAccessToken $token
        $project = Get-Project -OrgConnection $org -CacheResults | Select-Object -First 1
    }
    Context "Get-BuildDefinitions" {

        It 'Queries Build Definitions with paging' {
           
            $results = Get-BuildDefinition -OrgConnection $org `
                -Project $project -QueryOrder lastModifiedDescending

            $results.count | Should -BeGreaterThan 0
        }
    }
}

