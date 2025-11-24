Describe "PrivateFunctions" {
    BeforeAll {
 
        . "$PSScriptRoot/../../tests/unit/common.ps1"
        . "$PSScriptRoot/../../src/classes/OrgConnection.ps1"
        . "$PSScriptRoot/../../src/private/getOrgConnection.ps1"

        $cmdletToTest = (Split-Path -Leaf $PSCommandPath).Replace(".tests.", ".")
 
        . "$PSScriptRoot/../../src/private/$cmdletToTest"
        
        $org = getOrgConnection -Uri $OrgUri
        $org.ApiVersion = $org.ApiVersions[0]
    }
 
    Context "getApiUri" {
 
        It 'Combines Uri, Path, and ? Query appending & api-version' {
 
            $path = '_apis/projects'
            $query = @()
            $query += 'key=value'
            $queryString = $query -join '&'
            $expectedUri = "$OrgUri/$($path)?$queryString&$($org.ApiVersion)"
          
            (getApiUri -OrgConnection $org -Path $path -Query $query) | 
                Should -Be $expectedUri 
        }
 
        It 'Combines Uri and Path appending ? api-version missing query' {
 
            $path = '_apis/projects'
            $expectedUri = "$OrgUri/$($path)?$($org.ApiVersion)"
          
            (getApiUri -OrgConnection $org -Path $path) | 
                Should -Be $expectedUri
        }
 
        It 'Combines Uri and Path appending ? api-version with empty query' {
 
            $path = '_apis/projects'
            $query = ''
            $expectedUri = "$OrgUri/$($path)?$($org.ApiVersion)"
          
            (getApiUri -OrgConnection $org -Path $path -Query $query) | 
                Should -Be $expectedUri
        }
 
        It 'Combines Uri and Path appending ? api-version with multi-value query' {
 
            $path = '_apis/projects'
            $securityToken = '$/Scratch'
            $query = @()
            $query += "token=$securityToken"
            $query += 'second=two'
            $queryString = $query -join '&'
            $expectedUri = "$OrgUri/$($path)?$($queryString)&$($org.ApiVersion)"
          
            (getApiUri -OrgConnection $org -Path $path -Query $query) | 
                Should -Be $expectedUri
        }
 
        It 'Combines Uri, Path, Query and PageQuery appending ? api-version' {
 
            $path = '_apis/projects'
            $securityToken = '$/Scratch'
            $query = @()
            $query += "token=$securityToken"
            $query += 'second=two'
            $queryString = $query -join '&'
            $pageQuery = @()
            $pageQuery += "`$top=5"
            $pageQuery += "continuationToken=blah-blah-blah"
            $pageQueryString = $pageQuery -join '&'
            $expectedUri = "$OrgUri/$($path)?$($queryString)&$pageQueryString&$($org.ApiVersion)"
          
            (getApiUri -OrgConnection $org -Path $path -Query $query -PageQuery $pageQuery) | 
                Should -Be $expectedUri
        }
    }
}