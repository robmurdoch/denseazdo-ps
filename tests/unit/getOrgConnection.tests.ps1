Describe "PrivateFunctions" {
    BeforeAll {
 
        . "$PSScriptRoot/../../src/classes/OrgConnection.ps1"        
        
        $cmdletToTest = (Split-Path -Leaf $PSCommandPath).Replace(".tests.", ".")
 
        . "$PSScriptRoot/../../src/private/$cmdletToTest"
    }
 
    Context "getOrgConnection" {
 
        It 'When Token and Credential missing, AuthenticationMethod is DefaultCredentials' {
 
            $uri = 'https://azdo1.experiment.net/defaultcollection'
          
            $org = getOrgConnection -Uri $uri 
            $org.AuthenticationMethod | Should -Be 'DefaultCredential'
            $org.Uri | Should -Be $uri 
        }
 
        It 'When Credential provided, AuthenticationMethod is Credentials' {
 
            $uri = 'https://azdo1.experiment.net/defaultcollection'
            $un = 'MyUserName'
            $pwd = ConvertTo-SecureString "MyPlainTextPassword" -AsPlainText -Force          
            $cred = New-Object System.Management.Automation.PSCredential ($un, $pwd)
            $encodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $cred.UserName, $cred.Password)))

            $org = getOrgConnection -Uri $uri -Credential $cred
            $org.AuthenticationMethod | Should -Be 'Credential'
            $org.Headers.Authorization | Should -Be "Basic $encodedCredential"
            $org.Uri | Should -Be $uri 
        }
 
        It 'When PersonalAccessToken provided, AuthenticationMethod is Token' {
 
            $uri = 'https://azdo1.experiment.net/defaultcollection'
            $pat = '2elpbbs554fj4gxio2circ5lqstofm6s41lpwgntq6li73v6hnxa'
            $encodedToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$pat"))
        
            $org = getOrgConnection -Uri $uri -PersonalAccessToken $pat
            $org.AuthenticationMethod | Should -Be 'PersonalAccessToken'
            $org.Headers.Authorization | Should -Be "Basic $encodedToken"
            $org.Uri | Should -Be $uri 
        }
    }
}