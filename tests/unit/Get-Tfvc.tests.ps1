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
 
    Context "Get-Tfvc" {

        It 'When only org and project provided, does not include optional parameters' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $project = @{ id = 1234 }
            $expectedPath = "$($OrgUri)/$($project.id)/_apis/tfvc/items?api-version*"
            
            $mockResponse = Get-Tfvc -OrgConnection $org -Project $project

            $mockResponse | Should -BeLike $expectedPath
        }

        It 'When only ScopePath parameter is provided, uri query includes scopedPath parameter' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $project = @{ id = 1234 }
            $scopePath = '$/scratch/folder/subfolder'
            $expectedPath = "$($OrgUri)/$($project.id)/_apis/tfvc/items?scopePath=$scopePath&api-version*"
            
            $mockResponse = Get-Tfvc -OrgConnection $org -Project $project -ScopePath $scopePath

            $mockResponse | Should -BeLike $expectedPath
        }

        It 'When only RecursionLevel parameter is provided, uri query includes recursionLevel parameter' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $project = @{ id = 1234 }
            $recursionLevel = 'full'
            $expectedPath = "$($OrgUri)/$($project.id)/_apis/tfvc/items?recursionLevel=$recursionLevel&api-version*"
            
            $mockResponse = Get-Tfvc -OrgConnection $org -Project $project -RecursionLevel $recursionLevel

            $mockResponse | Should -BeLike $expectedPath
        }

        It 'When only IncludeLinks parameter is provided, uri query includes includeLinks parameter' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $project = @{ id = 1234 }
            $includeLinks = 'includeLinks=true'
            $expectedPath = "$($OrgUri)/$($project.id)/_apis/tfvc/items?$includeLinks&api-version*"
            
            $mockResponse = Get-Tfvc -OrgConnection $org -Project $project -IncludeLinks

            $mockResponse | Should -BeLike $expectedPath
        }

        It 'When RecursionLevel and IncludeLinks parameters are provided, uri query includes both recursionLevel and includeLinks parameter' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $project = @{ id = 1234 }
            $includeLinks = 'includeLinks=true'
            $recursionLevel = 'full'
            $expectedPath = "$($OrgUri)/$($project.id)/_apis/tfvc/items?recursionLevel=$recursionLevel&$includeLinks&api-version*"
            
            $mockResponse = Get-Tfvc -OrgConnection $org -Project $project -RecursionLevel $recursionLevel -IncludeLinks

            $mockResponse | Should -BeLike $expectedPath
        }

        It 'When IncludeSecurity parameter is provided with others, throw exception' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $project = @{ id = 1234 }
            
            { Get-Tfvc -OrgConnection $org `
                -Project $project `
                -RecursionLevel full -IncludeSecurity } |
            Should -Throw
        }
    }
}

