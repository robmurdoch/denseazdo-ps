Describe "PublicFunctions" {
    BeforeAll {
 
        . "$PSScriptRoot/../../src/classes/OrgConnection.ps1"
        . "$PSScriptRoot/../../src/private/getOrgConnection.ps1"
        . "$PSScriptRoot/../../src/private/getApiResponse.ps1"
        . "$PSScriptRoot/../../src/public/Get-Project.ps1"

        $cmdletToTest = (Split-Path -Leaf $PSCommandPath).Replace(".tests.", ".")
 
        . "$PSScriptRoot/../../src/public/$cmdletToTest"

        [string]$fakeOrgUri = 'https://my.tfsinstance.com/DefaultCollection/'
    }
 
    Context "Connect-AzureDevOps" {
 
        It 'Supports token authentication' {
           
            $fakePAT = 'not-a-real-token'
            # Mock getOrgConnection {
            #     $org = [System.Object]::New($fakeOrgUri, @{Authorization = "Basic $fakePAT" }, 'PersonalAccessToken')
            #     $org.ApiVersion = 'api-version=7.0'
            #     return $org
            # }
            # I have to mock getApiUri because of PSInvalidCastException: Cannot convert the "OrgConnection" value of type "OrgConnection" to type "OrgConnection".
            # Mock getApiUri { return "$fakeOrgUri/_apis/projects`$top=1" }
            Mock getApiResponse { return $null }

            $org = Connect-AzureDevOps -OrgUri $fakeOrgUri -PersonalAccessToken $fakePAT

            $org.Headers.Authorization | Should -Be "Basic $fakePAT"
        }

        It 'Supports default credential authentication' {
           
            Mock getOrgConnection {
                $org = [System.Object]::New($fakeOrgUri, @{Authorization = "Basic $fakePAT" }, 'Token')
                $org.ApiVersion = 'api-version=7.0'
                return $org
            }
            # I have to mock getApiUri because of PSInvalidCastException: Cannot convert the "OrgConnection" value of type "OrgConnection" to type "OrgConnection".
            Mock getApiUri { return "$fakeOrgUri/_apis/projects`$top=1" }
            Mock getApiResponse { return @{value = @{id = 1}} }

            $org = Connect-AzureDevOps -OrgUri $fakeUri

            $org.AuthenticationMethod | Should -Be 'DefaultCredential'
            $org.Uri | Should -Be $fakeUri 
        }
    }
}