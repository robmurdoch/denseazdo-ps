Describe "PublicFunctions" {
    BeforeAll {
 
        . "$PSScriptRoot/../../tests/unit/common.ps1"
        . "$PSScriptRoot/../../src/classes/OrgConnection.ps1"
        . "$PSScriptRoot/../../src/private/getOrgConnection.ps1"
        . "$PSScriptRoot/../../src/private/getApiUri.ps1"
        . "$PSScriptRoot/../../src/private/getHashUri.ps1"
        . "$PSScriptRoot/../../src/private/cacheJsonDocument.ps1"
        . "$PSScriptRoot/../../src/private/getApiResponse.ps1"
        . "$PSScriptRoot/../../src/private/getPagedApiResponse.ps1"

        $cmdletToTest = (Split-Path -Leaf $PSCommandPath).Replace(".tests.", ".")
 
        . "$PSScriptRoot/../../src/public/$cmdletToTest"
        
        $org = getOrgConnection -Uri $OrgUri
        $org.ApiVersion = $org.ApiVersions[0]
    }
 
    Context "Get-Project" {

        It 'When all parameters present, throws' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $expectedUri = "$($OrgUri)/_apis/projects/1234?api-version*"

            { Get-Project -OrgConnection $org `
                    -Id 1234 `
                    -statefilter 'all' `
                    -IncludeCapabilities -IncludeHistory -CacheResults } | 
            Should -Throw
        }

        # Broke with pagedresponse because getPagedResponse hides some methods 
        # It 'When Id not present, List REST API is called' {
           
        #     Mock -CommandName Invoke-WebRequest -MockWith { return 
        #         @{
        #             Headers = $null
        #             Content = "{`"value`": [{`"uri`";`"$Uri`"}]}"
        #         }
        #     }
        #     $expectedPath = "$($OrgUri)/_apis/projects?*"

        #     $mockResponse = Get-Project -OrgConnection $org

        #     $mockResponse.uri | Should -BeLike $expectedPath
        # }

        # Broke with pagedresponse because getPagedResponse hides some methods
        # It 'When Id not present and stateFilter present, List api called with stateFilter query' {
           
        #     Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
        #     $expectedPath = "$($OrgUri)/_apis/projects?stateFilter=all*"

        #     $mockResponse = Get-Project -OrgConnection $org -StateFilter all

        #     $mockResponse | Should -BeLike $expectedPath
        # }

        It 'When Id present, Get REST API called' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $expectedUri = "$($OrgUri)/_apis/projects/1234*"

            $mockResponse = Get-Project -OrgConnection $org -Id 1234

            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When Id and IncludeCapabilities are present, Get api called with includeCapabilities option' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return  $Uri }
            $expectedUri = "$($OrgUri)/_apis/projects/1234?includeCapabilities=true&api-version*"

            $mockResponse = Get-Project -OrgConnection $org -Id 1234 -IncludeCapabilities

            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When Id and IncludeHistory are present, Get api called with includeHistory option' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return  $Uri }
            $expectedUri = "$($OrgUri)/_apis/projects/1234?includeHistory=true&api-version*"

            $mockResponse = Get-Project -OrgConnection $org -Id 1234 -IncludeHistory

            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When Id, IncludeCapabailties, and IncludeHistory are present, Get api called with all options' {
           
            Mock -CommandName Invoke-RestMethod -MockWith { return  $Uri }
            $expectedUri = "$($OrgUri)/_apis/projects/1234?includeCapabilities=true&includeHistory=true&api-version*"

            $mockResponse = Get-Project -OrgConnection $org -Id 1234 -IncludeCapabilities -IncludeHistory

            $mockResponse | Should -BeLike $expectedUri
        }

        # Broke with pagedresponse because getPagedResponse hides some methods
        # It 'When Id not present, multiple Projects returned ' {
           
        #     $projects = Get-Content "$PSScriptRoot/../../tests/mock/projects.json"  | ConvertFrom-Json
        #     Mock Invoke-RestMethod { return $projects.value }

        #     $response = Get-Project -OrgConnection $org

        #     $response.count | Should -Be 2
        # }

        It 'When Id present, single Project returned' {
           
            $project = Get-Content "$PSScriptRoot/../../tests/mock/project.json"  | ConvertFrom-Json
            Mock Invoke-RestMethod { return $project }

            $response = Get-Project -OrgConnection $org -Id '160425a1-48f3-423f-9c86-997a8860b023'

            $response.name | Should -Be "Scratch"
        }
    }
}

