Describe "Core features" {
    BeforeAll {
        
        . "$PSScriptRoot/../../src/Build-Module.ps1"
        . "$PSScriptRoot/../../tests/integration/variables.ps1"
        . "$PSScriptRoot/../../tests/integration/secrets.ps1"

        # TODO prompt for these if no secrets file exists (file should never be checked into version control)
        # $orgUri = Read-Host -Prompt 'Enter org url'
        # $token = Read-Host -Prompt 'Enter Personal Access Token'

        #Connection to organization configured by EnvironmentSetup.ps1
        $org = Connect-AzureDevOps -OrgUri $orgUri -PersonalAccessToken $token
    }
 
    Context "Get-SecurityNamespace" {

        It 'Queries Security service SecurityNamespace List api' {
           
            $sns = Get-SecurityNamespace -OrgConnection $org
            $sns.count | Should -BeGreaterThan 0
        }

        It 'Supports OrgConnection piped as input' {
           
            $sns = $org | Get-SecurityNamespace
            $sns.count | Should -BeGreaterThan 0
        }

        It 'Finds the VersionControlItems SecurityNamespace' {
           
            $sn = Get-SecurityNamespace -OrgConnection $org | 
            Where-Object { $_.name -eq 'VersionControlItems' }

            $sn.namespaceId | Should -Be 'a39371cf-0841-4c16-bbd3-276e341bc052'
        }

        It 'Finds the Build SecurityNamespace' {
           
            $sn = Get-SecurityNamespace -OrgConnection $org | 
            Where-Object { $_.name -eq 'Build' }

            $sn.namespaceId | Should -Be '33344d9c-fc72-4d6f-aba5-fa317101a7e9'
        }
    }
 
    Context "Get-RootClassificationNode" {

        It 'Returns Area Root Classification Node' {
           
            $project = $org | Get-Project -CacheResults | Select-Object -First 1
            $result = Get-RootClassificationNode -OrgConnection $org -Project $project -StructureType "Area"

            $result.name | Should -BeLike "*"
        }

        It 'Returns Iteration Root Classification Node' {
           
            $project = $org | Get-Project -CacheResults | Select-Object -First 1
            $result = Get-RootClassificationNode -OrgConnection $org -Project $project -StructureType "Iteration"

            $result.name | Should -BeLike "*"
        }
    }

    Context "Get-AzDoAcl" {

        It 'Queries Security service Access Control List api for VersionControlItems Security Namespace' {
           
            $sn = $org | Get-SecurityNamespace | Where-Object { $PSItem.name -eq 'VersionControlItems' }
            $project = $org | Get-Project -CacheResults | Where-Object { $PSItem.name -eq $DefaultProjectName }
            $token = "$/$($project.name)"

            $results = Get-AzDoAcl -OrgConnection $org `
                -SecurityNamespace $sn `
                -SecurityToken $token `
                -Recurse -CacheResults

            $results.count | Should -BeGreaterThan 0
        }

        It 'Queries Security service Access Control List api for CSS Security Namespace' {
           
            $sn = $org | Get-SecurityNamespace | Where-Object { $PSItem.name -eq 'CSS' }

            $results = Get-AzDoAcl -OrgConnection $org `
                -SecurityNamespace $sn `
                -Recurse -CacheResults

            $results.count | Should -BeGreaterThan 0
        }
    }
 
    Context "Get-Ace, Get-Identity" {

        It 'Queries Security Access Control Entity Query api and Identities Read Identities api for VersionControlItems namespace' {
           
            $sn = Get-SecurityNamespace -OrgConnection $org | Where-Object { $PSItem.name -eq 'VersionControlItems' }
            $acls = Get-AzDoAcl -OrgConnection $org -SecurityNamespace $sn
            $aces = Get-Ace -OrgConnection $org -SecurityNamespace $sn -Acl $acls[0]
            $aces.count | Should -BeGreaterThan 0
            $aces[0].Identity | Should -BeLike '*'
        }

        It 'Queries Security Access Control Entity Query api and Identities Read Identities api for CSS namespace ' {
           
            $sn = Get-SecurityNamespace -OrgConnection $org | Where-Object { $PSItem.name -eq 'CSS' }
            $acls = Get-AzDoAcl -OrgConnection $org -SecurityNamespace $sn
            $aces = Get-Ace -OrgConnection $org -SecurityNamespace $sn -Acl $acls[0]
            $aces.count | Should -BeGreaterThan 0
            $aces[0].Identity | Should -BeLike '*'
        }
    }

    Context "Get-Project"{

        It 'Queries All Projects with Paging'{
            $global:AzDoPageSizePreference = 2
            $projects = Get-Project -OrgConnection $org
            $projects.count | Should -Be 3
        }

        It 'Gets same # of Projects'{
            $projects = Get-Project -OrgConnection $org
            $projects.count | Should -Be 3
        }

        It 'Supports Piped IDs'{
            $projects = Get-Project -OrgConnection $org | 
            Where-Object {$PSitem.name -like '* *'} | 
            Get-Project -OrgConnection $org -CacheResults -IncludeCapabilities
            $projects.count | Should -Be 3
        }
    }

    # Context "Get-Team"{

    #     It ''{

    #     }
    # }
}

