Describe "PrivateFunctions" {
    BeforeAll {
 
        . "$PSScriptRoot/../../src/classes/OrgConnection.ps1"   
        
        $cmdletToTest = (Split-Path -Leaf $PSCommandPath).Replace(".tests.", ".")
 
        . "$PSScriptRoot/../../src/private/$cmdletToTest"
    }
 
    Context "getClassificationNodeDelimiter" {
 
        It 'When api-version less than 5.0 return double colons' {
 
            $uri = 'https://azdo1.experiment.net/defaultcollection'          
            $org = getOrgConnection -Uri $uri 
            $org.ApiVersion = 'api-version=4.1'
            
            $delimiter = getClassificationNodeDelimiter -OrgConnection $org

            $delimiter | Should -Be '::'
        }
    }
}