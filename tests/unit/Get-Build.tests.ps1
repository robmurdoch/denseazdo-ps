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
 
    Context "Get-Build" {

        It 'When DefinitionIDs provided, GenericFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $definitionIds = 1, 2, 3
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?definitions=1,2,3*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -DefinitionIds $definitionIds

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and QueueIds specified, Queues query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $queuesIds = 1, 2, 3
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?queues=1,2,3*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -QueueIds $queuesIds

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and BuildNumber specified, BuildNumber query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $buildNumber = 3
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?buildNumber=$buildNumber*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -BuildNumber $buildNumber

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and MinTime specified, minTime query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $minTime = '1/1/1021 08:00'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?minTime=$minTime*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -MinTime $minTime

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and MaxTime specified, maxTime query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $maxTime = '1/2/1021 08:00'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?maxTime=$maxTime*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -MaxTime $maxTime

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and RequestedFor specified, maxTime query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $requestedFor = 'Administrator'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?requestedFor=$requestedFor*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -RequestedFor $requestedFor

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and ReasonFilter specified, reasonFilter query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $reasonFilter = 'pullRequest'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?reasonFilter=$reasonFilter*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -ReasonFilter $reasonFilter

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and StatusFilter specified, statusFilter query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $statusFilter = 'inProgress'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?statusFilter=$statusFilter*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -StatusFilter $statusFilter

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and ResultFilter specified, resultFilter query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $resultFilter = 'failed'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?resultFilter=$statusFilter*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -ResultFilter $resultFilter

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and TagFilters specified, tagFilters query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $tagFilters = 'demo', 'experiment'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?tagFilters=demo,experiment*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -TagFilters $tagFilters

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and Properties specified, properties query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $properties = 'api', 'ui', 'applicationId'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?properties=api,ui,applicationId*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -Properties $properties

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and MaxBuildsPerDefinition specified, maxBuildsPerDefinition query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $maxBuildsPerDefinition = 10
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?maxBuildsPerDefinition=$maxBuildsPerDefinition*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -MaxBuildsPerDefinition $maxBuildsPerDefinition

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and DeletedFilter specified, deletedFilter query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $deletedFilter = 'includeDeleted'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?deletedFilter=$deletedFilter*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -DeletedFilter $deletedFilter

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and QueryOrder specified, queryOrder query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $queryOrder = 'finishTimeAscending'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?queryOrder=$queryOrder*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -QueryOrder $queryOrder

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and BranchName specified, branchName query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $branchName = 'finishTimeAscending'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?branchName=$branchName*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -BranchName $branchName

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and BuildIds specified, buildIds query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $buildIds = 1, 3, 5
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?buildIds=1,3,5*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -BuildIds $buildIds

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
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds?repositoryId=$repositoryId&repositoryType=$repositoryType*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -RepositoryType $repositoryType `
                -RepositoryId $repositoryId

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When Id provided, Item ParameterSetName derived, Get REST API called' {

            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 246
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds/$id*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -Id $id

            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When Item ParameterSetName derived and PropertyFilters specified, propertyFilters query included' {

            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 246
            $propertyFilters = 'this', 'that'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds/$id`?propertyFilters=this,that*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -Id $id `
                -PropertyFilters $propertyFilters


            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When IncludeChanges provided, Changes ParameterSetName derived, Get Build Changes REST API called' {
            
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $project = @{ id = 1234 }
            $id = 246
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds/$id/changes*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -Id $id `
                -IncludeChanges

            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When IncludeLogs provided, Logs ParameterSetName derived, Get Build Logs REST API called' {
            
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $project = @{ id = 1234 }
            $id = 246
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds/$id/logs*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -Id $id `
                -IncludeLogs

            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When WorkItems provided, WorkItems ParameterSetName derived, Get Build Work Items Refs REST API called' {
            
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ value = $Uri } }
            $project = @{ id = 1234 }
            $id = 246
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/build/builds/$id/workitems*"
            
            $mockResponse = Get-Build -OrgConnection $org `
                -Project $project `
                -Id $id `
                -IncludeWorkItems

            $mockResponse | Should -BeLike $expectedUri
        }
    }
}

