Describe "PublicFunctions" {
    BeforeAll {
 
        . "$PSScriptRoot/../../tests/unit/common.ps1"
        . "$PSScriptRoot/../../src/classes/OrgConnection.ps1"
        . "$PSScriptRoot/../../src/private/getOrgConnection.ps1"
        . "$PSScriptRoot/../../src/private/getApiUri.ps1"
        . "$PSScriptRoot/../../src/private/getHashUri.ps1"
        . "$PSScriptRoot/../../src/private/cacheJsonDocument.ps1"
        . "$PSScriptRoot/../../src/private/getApiResponse.ps1"
        . "$PSScriptRoot/../../src/public/Get-Identity.ps1"

        $cmdletToTest = (Split-Path -Leaf $PSCommandPath).Replace(".tests.", ".")
 
        . "$PSScriptRoot/../../src/public/$cmdletToTest"

        $securityNamespaces = Get-Content "$PSScriptRoot/../../tests/mock/securitynamespaces.json"  | ConvertFrom-Json
        $org = getOrgConnection -Uri $OrgUri
        $org.ApiVersion = $org.ApiVersions[0]
    }
 
    Context "Get-ClassificationNode" {

        It 'When IDs passed calls Get Classification Nodes api with IDs parameter' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $project = @{ id=1234}
            $expectedPath = "$($OrgUri)/$($project.id)/_apis/wit/classificationnodes?ids=10&api-version*"
            
            $mockResponse = Get-ClassificationNode -OrgConnection $org -Project $project -Ids 10

            $mockResponse | Should -BeLike $expectedPath
        }

        It 'When IDs and Depth passed calls Get Classification Nodes api with Ids and depth parameters' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $project = @{ id=1234}
            $expectedPath = "$($OrgUri)/$($project.id)/_apis/wit/classificationnodes?ids=10&`$depth=1&api-version*"
            
            $mockResponse = Get-ClassificationNode -OrgConnection $org -Project $project -Ids 10 -Depth 1

            $mockResponse | Should -BeLike $expectedPath
        }

        It 'When Area Node passed calls Get api with node in Url' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return $Uri }
            $project = @{ id=1234}
            $n = 'project/child/grandchild'
            $expectedPath = "$($OrgUri)/$($project.id)/_apis/wit/classificationnodes/areas/$($n)?api-version*"
            
            $mockResponse = Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'areas' -Node $n

            $mockResponse | Should -BeLike $expectedPath
        }

        It 'When Area Node and Depth passed calls Get api with node in Url and Depth parameter' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return $Uri }
            $project = @{ id=1234}
            $n = 'project/child/grandchild'
            $expectedPath = "$($OrgUri)/$($project.id)/_apis/wit/classificationnodes/areas/$($n)?`$depth=1&api-version*"
            
            $mockResponse = Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'areas' -Node $n -Depth 1

            $mockResponse | Should -BeLike $expectedPath
        }

        It 'When Iteration Node and Depth passed calls Get api with node in Url and Depth parameter' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return $Uri }
            $project = @{ id=1234}
            $n = 'project/child/grandchild'
            $expectedPath = "$($OrgUri)/$($project.id)/_apis/wit/classificationnodes/iterations/$($n)?`$depth=1&api-version*"
            
            $mockResponse = Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'iterations' -Node $n -Depth 1

            $mockResponse | Should -BeLike $expectedPath
        }


    }
}

