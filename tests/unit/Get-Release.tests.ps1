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
 
    Context "Get-Release" {

        It 'When ReleaseIds provided, IdFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $releaseIds = 1, 2, 3
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?releaseIdFilter=1,2,3*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -ReleaseIds $releaseIds

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When DefinitionId provided, DefinitionFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $definitionId = 1
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?definitionId=$definitionId*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -DefinitionId $definitionId

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When DefinitionEnvironmentId provided, EnvironmentFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $definitionEnvironmentId = 1
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?definitionEnvironmentId=$definitionEnvironmentId*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -DefinitionEnvironmentId $definitionEnvironmentId

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
            $name = 'Release'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?searchText=$name*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -Name $name

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When CreatedBy provided, GenericFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $createdBy = 'user'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?createdBy=$createdBy*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -CreatedBy $createdBy

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When StatusFilter provided, GenericFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $statusFilter = 'abandoned', 'active'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?statusFilter=abandoned,active*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -StatusFilter $statusFilter

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When MinCreatedTime provided, GenericFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $minCreatedTime = '1/1/2022'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?minCreatedTime=$minCreatedTime*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -MinCreatedTime $minCreatedTime

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When MaxCreatedTime provided, GenericFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $maxCreatedTime = '1/1/2022'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?maxCreatedTime=$maxCreatedTime*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -MaxCreatedTime $maxCreatedTime

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When SourceBranchFilter provided, GenericFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $sourceBranch = 'main'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?sourceBranchFilter=$sourceBranch*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -SourceBranchFilter $sourceBranch

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When Folder provided, GenericFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $folder = '/foo'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?path=$folder*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -Folder $folder

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When IsDeleted provided, GenericFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?isDeleted=true*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -ListDeleted

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When TagsFilter provided, GenericFilter ParameterSetName derived, List REST API called' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            }
            $project = @{ id = 1234 }
            $tags = 'tag1','tag2'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?tagFilter=tag1,tag2*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -TagFilter $tags

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When IdFilter ParameterSetName derived and QueryOrder specified, queryOrder query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $releaseIds = 1, 2, 3
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?releaseIdFilter=1,2,3&queryOrder=ascending*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -ReleaseIds $releaseIds `
                -QueryOrder ascending

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When GenericFilter ParameterSetName derived and Name specified, SearchText query included' {

            Mock -CommandName Invoke-WebRequest -MockWith { Write-Output @{
                    value = @{
                        uri = $uri
                    }
                }
            } 
            $project = @{ id = 1234 }
            $name = 'myrelease'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases?searchText=$name*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -Name $name

            $mockResponse.uri | Should -BeLike $expectedUri
        }

        It 'When EnvironmentId provided, Environments ParameterSetName derived, Get Release Environment REST API called' {

            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 3
            $environmentId = 1
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases/$id/environments/$environmentId*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -Id $id `
                -EnvironmentId $environmentId

            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When EnvironmentId, ReleaseDeployPhase, and TaskID provided, TaskLog ParameterSetName derived, Get Task Log REST API called' {

            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 3
            $environmentId = 1
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases/$id/environments/$environmentId*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -Id $id `
                -EnvironmentId $environmentId

            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When Id provided, Item ParameterSetName derived, Get Release REST API called' {

            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 246
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases/$id*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -Id $id

            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When Item ParameterSetName derived and PropertyFilters specified, propertyFilters query included' {

            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 246
            $propertyFilters = 'this', 'that'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases/$id`?propertyFilters=this,that*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -Id $id `
                -PropertyFilters $propertyFilters


            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When Item ParameterSetName derived and ApprovalFilters specified, approvalFilters query included' {

            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 2321
            $approvalFilters = 'approvalSnapshots'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases/$id`?approvalFilters=$approvalFilters*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -Id $id `
                -ApprovalFilters $approvalFilters


            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When Item ParameterSetName derived and SingleReleaseExpand specified, expand query included' {

            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 2321
            $expand = 'TaskLog'
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases/$id`?`$expand=TaskLog*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -Id $id `
                -SingleReleaseExpand $expand


            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When Revision ParameterSetName derived and DefinitionSnapshotRevision specified, definitionSnapshotRevision query included' {

            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 2321
            $revision = 2
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases/$id`?definitionSnapshotRevision=$revision*"
            
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -Id $id `
                -DefinitionSnapshotRevision $revision


            $mockResponse | Should -BeLike $expectedUri
        }

        It 'When TaskLog ParameterSetName derived and StartLine or EndLine specified, startline and endLine query included' {

            Mock -CommandName Invoke-RestMethod -MockWith { return $uri }
            $project = @{ id = 1234 }
            $id = 2321
            $environment = 4
            $deployPhase = 5
            $task = 6
            $startLine = 2
            $expectedUri = "$($org.Uri)/$($project.id)/_apis/release/releases/$id/environments/$environment/deployPhases/$deployPhase/tasks/$task/Logs`?startLine=$startLine*"
             
            $mockResponse = Get-Release -OrgConnection $org `
                -Project $project `
                -Id $id `
                -Environment $environment `
                -ReleaseDeployPhaseId $deployPhase `
                -TaskId $task `
                -StartLine $startLine

            $mockResponse | Should -BeLike $expectedUri
        }
    }
}

