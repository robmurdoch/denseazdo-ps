Describe "Work Item features" {
    BeforeAll {
        
        . "$PSScriptRoot/../../src/Build-Module.ps1"
        . "$PSScriptRoot/../../tests/integration/variables.ps1"
        . "$PSScriptRoot/../../tests/integration/secrets.ps1"

        # prompt for these if no secrets file exists
        # $orgUri = Read-Host -Prompt 'Enter org url'
        # $token = Read-Host -Prompt 'Enter Personal Access Token'

        $org = Connect-AzureDevOps -OrgUri $orgUri -PersonalAccessToken $token
        $project = Get-Project -OrgConnection $org -CacheResults -Id 'Basic Tfvc'
    }
    Context "Get-ClassificationNode, Get-RootClassificationNode, Get-Acl, Get-Ace, Get-Identity" {

        It 'Queries Work Item Tracking Classification Nodes Get api for single Area by Node' {
           
            $nodeName = 'Big Team'

            $results = Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'areas' -Node $nodeName -CacheResults

            $results.name | Should -Be $nodeName
        }

        # It 'Queries Work Item Tracking Classification Nodes Get api for a single Area by Node including child nodes' {
           
        #     $project = Get-Project -OrgConnection $org -CacheResults -Id 'Basic Tfvc'
        #     $nodeName = 'Big Team'

        #     $results = Get-Area -OrgConnection $org -Project $project -Node $nodeName -Depth 1 -CacheResults

        #     $results.children.count | Should -BeGreaterThan 0
        # }

        It 'Queries Work Item Tracking Classification Nodes Get api for a single Area by Id' {
           
            $nodeId = 17

            $results = Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'areas' -IDs $nodeId -CacheResults

            $results[0].id | Should -Be $nodeId
        }

        # It 'Queries Work Item Tracking Classification Nodes Get api for a single Area by Id including child nodes' {
           
        #     $project = Get-Project -OrgConnection $org -CacheResults -Id 'Basic Tfvc'
        #     $nodeId = 17

        #     $results = Get-Area -OrgConnection $org -Project $project -IDs $nodeId -Depth 1 -CacheResults

        #     $results[0].children.count | Should -BeGreaterThan 0
        # }

        It 'Queries Work Item Tracking Classification Nodes Get api for the Root Area Node including security' {
           
            $results = Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'areas' -IncludeSecurity

            $results.count | Should -BeGreaterThan 0
        }

        It 'Queries Work Item Tracking Classification Nodes Get api for single Iteration by Node' {
           
            $nodeName = 'Big Team'

            $results = Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'iterations' -Node $nodeName -CacheResults

            $results.name | Should -Be $nodeName
        }

        It 'Queries Work Item Tracking Classification Nodes Get api for a single Iteration by Node including child nodes' {
           
            $nodeName = 'Big Team'

            $results = Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'iterations' -Node $nodeName -Depth 1 -CacheResults

            $results.children.count | Should -BeGreaterThan 0
        }

        It 'Queries Work Item Tracking Classification Nodes Get api for a single Iteration by Id' {
           
            $nodeId = 18

            $results = Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'iterations' -IDs $nodeId -CacheResults

            $results[0].id | Should -Be $nodeId
        }

        It 'Queries Work Item Tracking Classification Nodes Get api for a single Iteration by Id including child nodes' {
           
            $nodeId = 18

            $results = Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'iterations' -IDs $nodeId -Depth 1 -CacheResults

            $results[0].children.count | Should -BeGreaterThan 0
        }

        It 'Queries Work Item Tracking Classification Nodes Get api for the Root Iteration Node including security' {
           
            $results = Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'iterations' -IncludeSecurity

            $results.count | Should -BeGreaterThan 0
        }
    }
}

