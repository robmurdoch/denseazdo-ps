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
 
    Context "Get-AzDoAcl" {

        It 'When Recurse passed, calls Security ACLs api with recurse option' {           
           
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $sn = @{namespaceid = '1234' }
            $token = '$/proj'
            $expectedPath = "$($OrgUri)/_apis/accesscontrollists/1234?token=$token&recurse=true*"
            
            $mockResponse = Get-AzDoAcl -OrgConnection $org -SecurityNamespace $sn -SecurityToken $token -Recurse

            $mockResponse | Should -BeLike $expectedPath
        }

        It 'When IncludeExtendedInfo passed, calls Security ACLs api with includeExtendedInfo option' {           
           
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $sn = @{namespaceid = '1234' }
            $token = '$/proj'
            $expectedPath = "$($OrgUri)/_apis/accesscontrollists/1234?token=$token&includeExtendedInfo=true*"

            $mockResponse = Get-AzDoAcl -OrgConnection $org -SecurityNamespace $sn -SecurityToken $token -IncludeExtendedInfo

            $mockResponse | Should -BeLike $expectedPath
        }

        It 'When IncludeExtendedInfo and Recurse passed, calls Security ACLs api with includeExtendedInfo and recurse options' {           
           
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $sn = @{namespaceid = '1234' }
            $token = '$/proj'
            $expectedPath = "$($OrgUri)/_apis/accesscontrollists/1234?token=$token&recurse=true&includeExtendedInfo=true*"

            $mockResponse = Get-AzDoAcl -OrgConnection $org -SecurityNamespace $sn -SecurityToken $token -Recurse -IncludeExtendedInfo

            $mockResponse | Should -BeLike $expectedPath
        }
    }
}

