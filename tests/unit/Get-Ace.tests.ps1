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
    }
 
    Context "Get-Ace" {

        It 'When TFVC allow bit is 14367 and InheritPermissions is False, Effective permissions absent' {           
           
            Mock -CommandName Get-Identity -MockWith { return @{ providerDisplayName = 'nonsense' } }
            $sn = $securityNamespaces.value | Where-Object { $PSItem.name -eq 'VersionControlItems' }
            $acl = ConvertFrom-Json -InputObject @'
{
    "inheritPermissions": false,
    "token": "$/project/folder",
    "acesDictionary": {
        "nonsense": {
            "descriptor": "good",
            "allow": 14367,
            "deny": 0
        }
    }
}
'@
            $mockResponse = Get-Ace -OrgConnection $org -SecurityNamespace $sn -Acl $acl

            $mockResponse.InheritPermissions | Should -Be $false
            $mockResponse.Read | Should -Be 'Allow'
            $mockResponse."Pend a change in a server workspace" | Should -Be 'Allow'
            $mockResponse."Check in" | Should -Be 'Allow'
            $mockResponse.Label | Should -Be 'Allow'
            $mockResponse.Lock | Should -Be 'Allow'
            $mockResponse."Revise other users' changes" | Should -Be 'Not Set'
            $mockResponse."Unlock other users' changes" | Should -Be 'Not Set'
            $mockResponse."Undo other users' changes" | Should -Be 'Not Set'
            $mockResponse."Administer labels" | Should -Be 'Not Set'
            $mockResponse."Manage permissions" | Should -Be 'Not Set'
            $mockResponse."Check in other users' changes" | Should -Be 'Allow'
            $mockResponse.Merge | Should -Be 'Allow'
            $mockResponse."Manage branch" | Should -Be 'Allow'
        }

        It 'When TFVC allow bit is 15871 and InheritPermissions is False, Allow everywhere' {           
           
            Mock -CommandName Get-Identity -MockWith { return @{ providerDisplayName = 'nonsense' } }
            $sn = $securityNamespaces.value | Where-Object { $PSItem.name -eq 'VersionControlItems' }
            $acl = ConvertFrom-Json -InputObject @'
{
    "inheritPermissions": false,
    "token": "$/project/folder",
    "acesDictionary": {
        "nonsense": {
            "descriptor": "good",
            "allow": 15871,
            "deny": 0
        }
    }
}
'@
            $mockResponse = Get-Ace -OrgConnection $org -SecurityNamespace $sn -Acl $acl

            $mockResponse.InheritPermissions | Should -Be $false
            $mockResponse.Read | Should -Be 'Allow'
            $mockResponse."Pend a change in a server workspace" | Should -Be 'Allow'
            $mockResponse."Check in" | Should -Be 'Allow'
            $mockResponse.Label | Should -Be 'Allow'
            $mockResponse.Lock | Should -Be 'Allow'
            $mockResponse."Revise other users' changes" | Should -Be 'Allow'
            $mockResponse."Unlock other users' changes" | Should -Be 'Allow'
            $mockResponse."Undo other users' changes" | Should -Be 'Allow'
            $mockResponse."Administer labels" | Should -Be 'Allow'
            $mockResponse."Manage permissions" | Should -Be 'Allow'
            $mockResponse."Check in other users' changes" | Should -Be 'Allow'
            $mockResponse.Merge | Should -Be 'Allow'
            $mockResponse."Manage branch" | Should -Be 'Allow'
        }

        It 'When allow bit is 4127, some Allow exist' {           
           
            Mock -CommandName Get-Identity -MockWith { return @{ providerDisplayName = 'nonsense' } }
            $sn = $securityNamespaces.value | Where-Object { $PSItem.name -eq 'VersionControlItems' }
            $acl = ConvertFrom-Json -InputObject @'
{
    "inheritPermissions": true,
    "token": "$/project/folder",
    "acesDictionary": {
        "nonsense": {
            "descriptor": "good",
            "allow": 4127,
            "deny": 0
        }
    }
}
'@
            $mockResponse = Get-Ace -OrgConnection $org -SecurityNamespace $sn -Acl $acl

            $mockResponse.InheritPermissions | Should -Be $true
            $mockResponse.Read | Should -Be 'Allow'
            $mockResponse."Pend a change in a server workspace" | Should -Be 'Allow'
            $mockResponse."Check in" | Should -Be 'Allow'
            $mockResponse.Label | Should -Be 'Allow'
            $mockResponse.Lock | Should -Be 'Allow'
            $mockResponse."Revise other users' changes" | Should -Be 'Not Set'
            $mockResponse."Unlock other users' changes" | Should -Be 'Not Set'
            $mockResponse."Undo other users' changes" | Should -Be 'Not Set'
            $mockResponse."Administer labels" | Should -Be 'Not Set'
            $mockResponse."Manage permissions" | Should -Be 'Not Set'
            $mockResponse."Check in other users' changes" | Should -Be 'Not Set'
            $mockResponse.Merge | Should -Be 'Allow'
            $mockResponse."Manage branch" | Should -Be 'Not Set'
        }
    }
}

