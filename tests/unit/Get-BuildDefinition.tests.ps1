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
        . "$PSScriptRoot/../../src/public/Get-Identity.ps1"

        $cmdletToTest = (Split-Path -Leaf $PSCommandPath).Replace(".tests.", ".")
 
        . "$PSScriptRoot/../../src/public/$cmdletToTest"
        
        $org = getOrgConnection -Uri $OrgUri
        $org.ApiVersion = $org.ApiVersions[0]
    }
 
    Context "Get-BuildDefinition" {
        
        It 'When IncludeSecurity provided, Item ParameterSetName derived, throws' {
         
            $project = @{ id = 1234 }
            
            { Get-BuildDefinition -OrgConnection $org `
                    -Project $project `
                    -Id 1 `
                    -IncludeSecurity } | Should -Throw
        }

        It 'When IncludeSecurity provided, Revision ParameterSetName derived, throws' {
            
            $project = @{ id = 1234 }
            
            { Get-BuildDefinition -OrgConnection $org `
                    -Project $project `
                    -Id 1 `
                    -IncludeRevisions `
                    -IncludeSecurity } | Should -Throw
        }

        It 'When DefinitionIDs provided, IdFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $Ids = 1, 2, 3
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions?definitionIds=1,2,3*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -DefinitionIds $Ids

            $mockResponse.uri | Should -BeLike $expectedUri
        }
        
        It 'When IdFilter ParameterSetName derived and IncludeSecurity provided, Uri creation uses same strategy' {

            Mock -CommandName Get-SecurityNamespace -MockWith { return @{ value = @(@{ name = 'Build' }) } }
            Mock -CommandName Invoke-WebRequest -MockWith { return @{ value = @() } }
            $project = @{ id = 1234 }
            $Ids = 1
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -DefinitionIds $Ids `
                -IncludeSecurity

            $mockResponse | Should -BeNullOrEmpty
        }

        It 'When IdFilter ParameterSetName derived and IncludeAllPropertiies specified, includeAllProperties query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $Ids = 1, 2, 3
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions?definitionIds=1,2,3&includeAllProperties=true*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -DefinitionIds $Ids `
                -IncludeAllProperties

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When RepositoryType and RepositoryID provided, RepositoryFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $repositoryType = 'TfsGit'
            $repositoryId = 'Guid'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions?repositoryId=$repositoryId&repositoryType=$repositoryType*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -RepositoryType $repositoryType `
                -RepositoryId $repositoryId

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When RepositoryFilter ParameterSetName derived and includeLatestBuilds provided, includeLatestBuilds query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $repositoryType = 'TfsGit'
            $repositoryId = 'Guid'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions?repositoryId=$repositoryId&repositoryType=$repositoryType&includeLatestBuilds=true*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -RepositoryType $repositoryType `
                -RepositoryId $repositoryId `
                -IncludeLatestBuilds

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When Name provided, GenericFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }          
            $project = @{ id = 1234 }
            $nameFilter = 'beginswith*'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions?name=$nameFilter*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -Name $nameFilter

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When builtAfter provided, GenericFilter ParameterSetName derived, List REST API called, builtAfter and notBuiltAfter query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }           
            $project = @{ id = 1234 }
            $builtAfter = '1/1/2021'
            $notBuiltAfter = '3/31/2021'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions?builtAfter=$builtAfter&notBuiltAfter=$notBuiltAfter*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -BuiltAfter $builtAfter `
                -NotBuiltAfter $notBuiltAfter

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When Path provided, GenericFilter ParameterSetName derived, List REST API called, path query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }        
            $project = @{ id = 1234 }
            $folderFilter = '\Archive'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions?path=$folderFilter*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -Folder $folderFilter

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When TaskId provided, GenericFilter ParameterSetName derived, List REST API called, taskIdFilter query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }   
            $project = @{ id = 1234 }
            $taskIdGuid = 'c07295c8-ee27-4e5a-b436-fdfbf39ea84c'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions?taskIdFilter=$taskIdGuid*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -TaskId $taskIdGuid

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and queryOrder provided, queryOrder query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }  
            $project = @{ id = 1234 }
            $nameFilter = 'beginswith*'
            $queryOrder = 'definitionNameAscending'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions?name=$nameFilter&queryOrder=$queryOrder*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -Name $nameFilter `
                -QueryOrder $queryOrder

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When Id provided, Item ParameterSetName derived, Get REST API called' {
            
            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 1
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions/$id*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -Id $id

            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When Id provided and Revision included, Item ParameterSetName derived, revision query included' {
            
            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 1
            $revision = 2
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions/$id`?revision=$revision*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -Id $id `
                -Revision $revision

            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When Id provided and Revisions included, Revisions ParameterSetName derived, Get Definition Revisions REST API called' {
            
            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $id = 1
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/definitions/$id/revisions*"
            
            $mockResponse = Get-BuildDefinition -OrgConnection $org `
                -Project $project `
                -Id $id `
                -IncludeRevisions

            $mockResponse.uri | Should -BeLike $expectedUri
        }
        It 'When Revisions ParameterSetName derived and IncludeSecurity provided, throws' {
         
            $project = @{ id = 1234 }
            
            { Get-BuildDefinition -OrgConnection $org `
                    -Project $project `
                    -Id 1 `
                    -IncludeRevisions `
                    -IncludeSecurity } | Should -Throw
        }
    }
}

