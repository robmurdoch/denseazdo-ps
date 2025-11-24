Describe "PrivateFunctions" {
    BeforeAll {
 
        . "$PSScriptRoot/../../tests/unit/common.ps1"
        . "$PSScriptRoot/../../src/classes/OrgConnection.ps1"
        . "$PSScriptRoot/../../src/private/getOrgConnection.ps1"
        . "$PSScriptRoot/../../src/private/getApiUri.ps1"
        . "$PSScriptRoot/../../src/private/getHashUri.ps1"
        . "$PSScriptRoot/../../src/private/cacheJsonDocument.ps1"

        $cmdletToTest = (Split-Path -Leaf $PSCommandPath).Replace(".tests.", ".")
 
        . "$PSScriptRoot/../../src/private/$cmdletToTest"
        
        $org = getOrgConnection -Uri $OrgUri
        $org.ApiVersion = $org.ApiVersions[0]
        $org.Headers = @{}
    }
 
    Context "getApiResponse" {

        It 'Creates uri with multiple query items' {
           
            Mock Invoke-RestMethod { return $Uri }

            $responseUri = getApiResponse -OrgConnection $org -uri $Uri -CacheName 'blah'

            $responseUri | Should -BeLike $Uri             
        }
    }
}

