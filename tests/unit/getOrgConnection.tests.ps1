Describe "PrivateFunctions" {
    BeforeAll {
 
        . "$PSScriptRoot/../../src/classes/OrgConnection.ps1"        
        
        $cmdletToTest = (Split-Path -Leaf $PSCommandPath).Replace(".tests.", ".")
 
        . "$PSScriptRoot/../../src/private/$cmdletToTest"
    }
 
    Context "getOrgConnection" {
 
        It 'When Token and Credential missing, AuthenticationMethod is DefaultCredentials' {
 
            $uri = 'http://localhost/defaultcollection'
          
            $org = getOrgConnection -Uri $uri 
            $org.AuthenticationMethod | Should -Be 'DefaultCredential'
            $org.Uri | Should -Be $uri 
        }
 
        It 'When Credential provided, AuthenticationMethod is Credentials' {
 
            $uri = 'http://localhost/defaultcollection'
            $un = 'MyUserName'
            $p = ConvertTo-SecureString "MyPlainTextPassword" -AsPlainText -Force          
            $cred = New-Object System.Management.Automation.PSCredential ($un, $p)
            $encodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $cred.UserName, $cred.Password)))

            $org = getOrgConnection -Uri $uri -Credential $cred
            $org.AuthenticationMethod | Should -Be 'Credential'
            $org.Headers.Authorization | Should -Be "Basic $encodedCredential"
            $org.Uri | Should -Be $uri 
        }
 
        It 'When PersonalAccessToken provided, AuthenticationMethod is Token' {
 
            $uri = 'http://localhost/defaultcollection'
            $pat = 'NotReallyASecret'
            $encodedToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$pat"))
        
            $org = getOrgConnection -Uri $uri -PersonalAccessToken $pat
            $org.AuthenticationMethod | Should -Be 'PersonalAccessToken'
            $org.Headers.Authorization | Should -Be "Basic $encodedToken"
            $org.Uri | Should -Be $uri 
        }
    }
}