Describe "Code features" {
    BeforeAll {
        
        . "$PSScriptRoot/../../src/Build-Module.ps1"
        . "$PSScriptRoot/../../tests/integration/variables.ps1"
        . "$PSScriptRoot/../../tests/integration/secrets.ps1"

        # TODO prompt for these if no secrets file exists (it should never be checked into version control)
        # $orgUri = Read-Host -Prompt 'Enter org url'
        # $token = Read-Host -Prompt 'Enter Personal Access Token'

        $org = Connect-AzureDevOps -OrgUri $orgUri -PersonalAccessToken $token
        $basicTfvcProject = Get-Project -OrgConnection $org -id 'Basic Tfvc'
        $agileGitProject = Get-Project -OrgConnection $org -id 'Agile Git'
    }
 
    Context "Get-Tfvc" {
        
        It 'Queries Tfvc Items List api' {
           
            $results = Get-Tfvc -OrgConnection $org -Project $basicTfvcProject

            $results.count | Should -BeGreaterThan 0
        }

        It 'Queries Tfvc Items List api and gets Root node' {
           
            $results = Get-Tfvc -OrgConnection $org -Project $basicTfvcProject

            $results[0].path | Should -BeLike '$/Basic Tfvc'
        }

        It 'Queries Tfvc Items List api for oneLevel' {
           
            $results = Get-Tfvc -OrgConnection $org -Project $basicTfvcProject `
                -RecursionLevel 'oneLevel'

            $results[0].path | Should -BeLike '$/Basic Tfvc'
        }

        It 'Queries Tfvc Items List api for Scoped Path' {
           
            $results = Get-Tfvc -OrgConnection $org -Project $basicTfvcProject `
                -ScopePath '$/Basic Tfvc/Hidden'

            $results[0].path | Should -Be '$/Basic Tfvc/Hidden'
        }

        It 'Queries Tfvc Items List api for Version' {
           
            $results = Get-Tfvc -OrgConnection $org -Project $basicTfvcProject `
                -Version 2

            $results[0].path | Should -Be '$/Basic Tfvc'
        }

        It 'Queries Tfvc Items List api for a Versioned Scoped Path with Version Option and Version Type, returns previous' {
           
            $results = Get-Tfvc -OrgConnection $org -Project $basicTfvcProject `
                -ScopePath '$/Basic Tfvc/Locked/Get-Folder.ps1' -Version 9 `
                -VersionOption previous -VersionType 'changeset'

            $results[0].path | Should -Be '$/Basic Tfvc/Locked/Get-Folder.ps1'
        }

        It 'Queries Tfvc Items List api for a Versioned Scoped Path with Version Type and version, returns changeset' {
           
            $results = Get-Tfvc -OrgConnection $org -Project $basicTfvcProject `
                -ScopePath '$/Basic Tfvc' -Version 8 -VersionType 'changeset'

            $results[0].path | Should -Be '$/Basic Tfvc'
        }

        It 'Queries Tfvc Items List api and includes security acls in results' {
           
            $results = Get-Tfvc -OrgConnection $org -Project $basicTfvcProject `
                -IncludeSecurity

            $results[0].Identity | Should -BeLike '*'
        }
    }
    
    Context "Get-GitRepository" {

    }
}

