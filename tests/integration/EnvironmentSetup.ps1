. "$PSScriptRoot/../../src/Build-Module.ps1"
. "$PSScriptRoot/../../tests/integration/variables.ps1"
. "$PSScriptRoot/../../tests/integration/secrets.ps1"

"$PSScriptRoot/../../src/build-module.ps1"

$org = Connect-AzureDevOps -OrgUri $orgUri -PersonalAccessToken $token

#region Projects
$projects = Get-Project -OrgConnection $org
$basic = Get-ProcessTemplate -OrgConnection $org `
    -CacheResults | Where-Object { $PSItem.name -like 'Basic' }
$agile = Get-ProcessTemplate -OrgConnection $org `
    -CacheResults | Where-Object { $PSItem.name -like 'Agile' }

if ($projects | Where-Object { $PSitem.name -eq 'Basic Tfvc' }) {
    Write-Host 'Basic Tfvc project already exists'
}
else {
    $newProjectResponse = New-Project -OrgConnection $org `
        -Name 'Basic Tfvc' -ProcessTemplate $basic `
        -VersionControlCapability 'Tfvc'
    do {
        $i += 1
        Start-Sleep -Milliseconds 250
        $operationStatus = getApiResponse -OrgConnection $org `
            -Uri $newProjectResponse.url
        if ($i -eq 100) {
            Write-Warning "Project creation didn't complete in a timely manner, manually check status"
        }
    } until ($operationStatus.Status -eq 'Succeeded' -or $i -eq 100)
}
$basicTfvcProject = Get-Project -OrgConnection $org -Id 'Basic Tfvc'

if ($projects | Where-Object { $PSitem.name -eq 'Agile Git' }) {
    Write-Host 'Agile Git project already exists'
}
else {
    $newProjectResponse = New-Project -OrgConnection $org `
        -Name 'Agile Git' -ProcessTemplate $agile -VersionControlCapability 'Tfvc'
    do {
        $i += 1
        Start-Sleep -Milliseconds 250
        $operationStatus = getApiResponse -OrgConnection $org `
            -Uri $newProjectResponse.url
        if ($i -eq 100) {
            Write-Warning "Project creation didn't complete in a timely manner, manually check status"
        }
    } until ($operationStatus.Status -eq 'Succeeded' -or $i -eq 100)
}
$agileGitProject = Get-Project -OrgConnection $org -Id 'Agile Git'

if ($projects | Where-Object { $PSitem.name -eq 'An Empty Project' }) {
    Write-Host 'An Empty Project project already exists'
}
else {
    $newProjectResponse = New-Project -OrgConnection $org `
        -Name 'An Empty Project' -ProcessTemplate $agile -VersionControlCapability 'Git'
    do {
        $i += 1
        Start-Sleep -Milliseconds 250
        $operationStatus = getApiResponse -OrgConnection $org `
            -Uri $newProjectResponse.url
        if ($i -eq 100) {
            Write-Warning "Project creation didn't complete in a timely manner, manually check status"
        }
    } until ($operationStatus.Status -eq 'Succeeded' -or $i -eq 100)
}
$anEmptyProject = Get-Project -OrgConnection $org -Id 'An Empty Project'
#endregion

#region Teams
$bigTeam = Get-Team -OrgConnection $org -Project $basicTfvcProject | 
Where-Object { $PSItem.name -eq 'Big Team' }
if ($bigTeam) {
    Write-Host 'Big Team already exists'
}
else {
    $bigTeam = New-Team -OrgConnection $org -Project $basicTfvcProject -Name 'Big Team'
            
    $defaultArea = New-ClassificationNode -OrgConnection $org `
        -Project $basicTfvcProject -StructureGroup 'Areas' -Name 'Big Team'
    $backlogIteration = New-ClassificationNode -OrgConnection $org `
        -Project $basicTfvcProject -StructureGroup 'Iterations' -Name 'Big Team'
    $backlogIterationInitialSprint = New-ClassificationNode -OrgConnection $org `
        -Project $basicTfvcProject -StructureGroup 'Iterations' -ParentPath 'Big Team' -Name 'Sprint 1'

    Edit-Team -OrgConnection $org -Project $basicTfvcProject -Team $bigTeam `
        -TeamField 'System.AreaPath' -DefaultArea $defaultArea                        
    Edit-Team -OrgConnection $org -Project $basicTfvcProject -Team $bigTeam `
        -BacklogIteration $backlogIteration -DefaultIterationMacro '@CurrentIteration'
}

$littleTeam = Get-Team -OrgConnection $org -Project $basicTfvcProject | 
Where-Object { $PSItem.name -eq 'Little Team' }
if ($littleTeam) {
    Write-Host 'Little Team already exists'
}
else {
    $littleTeam = New-Team -OrgConnection $org -Project $basicTfvcProject -Name 'Little Team'
            
    $defaultArea = New-ClassificationNode -OrgConnection $org `
        -Project $basicTfvcProject -StructureGroup 'Areas' -Name 'Little Team'
    $backlogIteration = New-ClassificationNode -OrgConnection $org `
        -Project $basicTfvcProject -StructureGroup 'Iterations' -Name 'Little Team'
    $backlogIterationInitialSprint = New-ClassificationNode -OrgConnection $org `
        -Project $basicTfvcProject -StructureGroup 'Iterations' -ParentPath 'Little Team' -Name 'Sprint 1'

    Edit-Team -OrgConnection $org -Project $basicTfvcProject -Team $littleTeam `
        -TeamField 'System.AreaPath' -DefaultArea $defaultArea                        
    Edit-Team -OrgConnection $org -Project $basicTfvcProject -Team $littleTeam `
        -BacklogIteration $backlogIteration -DefaultIterationMacro '@CurrentIteration'
}
#endregion

#region Basic Tfvc Code
$initialChangesetCount = (Get-TfvcChangeset -OrgConnection $org `
        -Project $basicTfvcProject).count
if ($initialChangesetCount -gt 1) {
    Write-Host 'Initial changeset already exists'
}
else {
    $changeset = @{
        comment = 'Environment Setup - Changeset 1'
        changes = @(
            @{
                changeType = 'add'
                item       = @{
                    path            = "$/Basic Tfvc/Additional/readme.md"
                    contentMetadata = @{
                        encoding = 1200
                    }
                }
                newContent = @{
                    content     = 'Folder has additional security'
                    contentType = 'rawText'
                }
            },
            @{
                changeType = 'add'
                item       = @{
                    path            = "$/Basic Tfvc/Locked/readme.md"
                    contentMetadata = @{
                        encoding = 1200
                    }
                }
                newContent = @{
                    content     = 'Folder security prevents edits for mere mortals'
                    contentType = 'rawText'
                }
            },
            @{
                changeType = 'add'
                item       = @{
                    path            = "$/Basic Tfvc/Open/readme.md"
                    contentMetadata = @{
                        encoding = 1200
                    }
                }
                newContent = @{
                    content     = 'Folder security inherits all permissions'
                    contentType = 'rawText'
                }
            },
            @{
                changeType = 'add'
                item       = @{
                    path            = "$/Basic Tfvc/Hidden/readme.md"
                    contentMetadata = @{
                        encoding = 1200
                    }
                }
                newContent = @{
                    content     = 'Folder security prevents mere mortals from knowing it exists'
                    contentType = 'rawText'
                }
            }
        )
    }
    $changesetId = (New-ChangeSet -OrgConnection $org -Contents $changeset).changesetId
    Write-Host "Created Changeset $changesetId"
}
if ($initialChangesetCount -gt 2) {
    Write-Host 'Changeset 2 already exists'
}
else {
    $changeset = @{
        comment = 'Environment Setup - Changeset 2'
        changes = @(
            @{
                changeType = 'add'
                item       = @{
                    path            = "$/Basic Tfvc/Additional/Get-Folder.ps1"
                    contentMetadata = @{
                        encoding = 1200
                    }
                }
                newContent = @{
                    content     = 'Get-ChildItem'
                    contentType = 'rawText'
                }
            }
        )
    }
    $changesetId = (New-ChangeSet -OrgConnection $org -Contents $changeset).changesetId
    Write-Host "Created Changeset $changesetId"
}
if ($initialChangesetCount -gt 3) {
    Write-Host 'Changeset 3 already exists'
}
else {
    $changeset = @{
        comment = 'Environment Setup - Changeset 3'
        changes = @(
            @{
                changeType = 'add'
                item       = @{
                    path            = "$/Basic Tfvc/Hidden/Get-Folder.ps1"
                    contentMetadata = @{
                        encoding = 1200
                    }
                }
                newContent = @{
                    content     = 'Get-ChildItem'
                    contentType = 'rawText'
                }
            }
        )
    }
    $changesetId = (New-ChangeSet -OrgConnection $org -Contents $changeset).changesetId
    Write-Host "Created Changeset $changesetId"
}
if ($initialChangesetCount -gt 4) {
    Write-Host 'Changeset 4 already exists'
}
else {
    $changeset = @{
        comment = 'Environment Setup - Changeset 4'
        changes = @(
            @{
                changeType = 'add'
                item       = @{
                    path            = "$/Basic Tfvc/Locked/Get-Folder.ps1"
                    contentMetadata = @{
                        encoding = 1200
                    }
                }
                newContent = @{
                    content     = 'Get-ChildItem'
                    contentType = 'rawText'
                }
            }
        )
    }
    $changesetId = (New-ChangeSet -OrgConnection $org -Contents $changeset).changesetId
    Write-Host "Created Changeset $changesetId"
}
if ($initialChangesetCount -gt 5) {
    Write-Host 'Changeset 5 already exists'
}
else {
    
    $latestChangeSets = Get-TfvcChangeset -OrgConnection $org `
        -Project $basicTfvcProject
    $lastChangeSet = $latestChangeSets | Select-Object -First 1
    $changeset = @{
        comment = 'Environment Setup - Changeset 5'
        changes = @(
            @{
                changeType = 'edit'
                item       = @{
                    version         = $lastChangeSet.changesetId
                    path            = "$/Basic Tfvc/Locked/Get-Folder.ps1"
                    contentMetadata = @{
                        encoding = 1200
                    }
                }
                newContent = @{
                    content     = 'Get-ChildItem -Recurse'
                    contentType = 'rawText'
                }
            }
        )
    }
    $changesetId = (New-ChangeSet -OrgConnection $org -Contents $changeset).changesetId
    Write-Host "Created Changeset $changesetId"
}

$tfvcSecurityNamespace = Get-SecurityNamespace -OrgConnection $org | 
Where-Object { $PSItem.name -eq 'VersionControlItems' }
$projectAdminsGroup = Get-Identity -OrgConnection $org -SearchFilter LocalGroupName `
    -FilterValue '[Basic Tfvc]\Project Administrators'
$projectCollectionAdmins = Get-Identity -OrgConnection $org -SearchFilter LocalGroupName `
    -FilterValue "[$orgName]\Project Collection Administrators"
$projectContributorsGroup = Get-Identity -OrgConnection $org -SearchFilter LocalGroupName `
    -FilterValue '[Basic Tfvc]\Contributors'
$projectBuildService = Get-Identity -OrgConnection $org -SearchFilter General `
    -FilterValue "Basic Tfvc Build Service ($orgName)"
$aclHidden = @{
    value = @(
        @{
            inheritPermissions = 'false'
            token              = "$/Basic Tfvc/Hidden"
            acesDictionary     = @{
                $($projectCollectionAdmins.descriptor) = @{
                    descriptor = "$($projectCollectionAdmins.descriptor)"
                    allow      = 15871
                    deny       = 0
                }
                $($projectAdminsGroup.descriptor)      = @{
                    descriptor = "$($projectAdminsGroup.descriptor)"
                    allow      = 15871
                    deny       = 0
                }
                $($projectBuildService.descriptor)     = @{
                    descriptor = "$($projectBuildService.descriptor)"
                    allow      = 14367
                    deny       = 0
                }
            }
        }
    )
}
$null = New-Acl -OrgConnection $org `
    -SecurityNamespace $tfvcSecurityNamespace `
    -Acl $aclHidden
Write-Host "Hidden Tfvc path security configured"

$aclAdditional = @{
    value = @(
        @{
            inheritPermissions = 'true'
            token              = "$/Basic Tfvc/Additional"
            acesDictionary     = @{
                $($projectCollectionAdmins.descriptor) = @{
                    descriptor = "$($projectCollectionAdmins.descriptor)"
                    allow      = 8192
                    deny       = 0
                }
            }
        }
    )
}
$null = New-Acl -OrgConnection $org `
    -SecurityNamespace $tfvcSecurityNamespace `
    -Acl $aclAdditional
Write-Host "Additional Tfvc path security configured"

$aclLocked = @{
    value = @(
        @{
            inheritPermissions = 'true'
            token              = "$/Basic Tfvc/Locked"
            acesDictionary     = @{
                $($projectCollectionAdmins.descriptor) = @{
                    descriptor = "$($projectCollectionAdmins.descriptor)"
                    allow      = 0
                    deny       = 8192
                }
            }
        }
    )
}
$null = New-Acl -OrgConnection $org `
    -SecurityNamespace $tfvcSecurityNamespace `
    -Acl $aclLocked
Write-Host "Locked Tfvc path security configured"
#endregion

#region Agile Git Code
$gitRepos = Get-GitRepository -OrgConnection $org -Project $agileGitProject
$gitRepoNetCoreApp = $gitRepos | Where-Object { $PSItem.name -eq 'NetCoreSln' }
if ($gitRepoNetCoreApp) {
    Write-Host 'Git Repository NetCoreSln already exists'
} 
else {
    $gitRepoNetCoreApp = New-GitRepository -OrgConnection $org -Project $agileGitProject -Name 'NetCoreSln'

    if (Test-Path -Path "$($Env:TEMP)/NetCoreSln") {
        Remove-Item -Path "$($Env:TEMP)/NetCoreSln" -Recurse -Force
    }
    New-Item -ItemType Directory -Path "$($Env:TEMP)/NetCoreSln"
    $currentLocation = Get-Location
    Set-Location "$($Env:TEMP)/NetCoreSln"
    & git init
    Copy-Item "$PSScriptRoot/../../tests/samples/NetCore.sln" -Destination "$($Env:TEMP)/NetCoreSln"
    New-Item -ItemType Directory -Path "$($Env:TEMP)/NetCoreSln/NetCoreApp"
    Copy-Item "$PSScriptRoot/../../tests/samples/NetCoreApp/NetCoreApp.csproj" -Destination "$($Env:TEMP)/NetCoreSln/NetCoreApp/NetCoreApp.csproj"
    Copy-Item "$PSScriptRoot/../../tests/samples/NetCoreApp/Program.cs" -Destination "$($Env:TEMP)/NetCoreSln/NetCoreApp/Program.cs"
    & git add .
    & git commit -m 'Initial Commit'
    & git remote add origin "$($org.Uri)/$($agileGitProject.id)/_git/NetCoreSln"
    & git push -u origin master
    Write-Host "Created Git Repository NetCoreSln"

    Set-Location $currentLocation
}
$gitRepoNetFrameworkApp = $gitRepos | Where-Object { $PSItem.name -eq 'NetFrameworkSln' }
if ($gitRepoNetFrameworkApp) {
    Write-Host 'Git Repository NetFrameworkSln already exists'
} 
else {
    $gitRepoNetFrameworkApp = New-GitRepository -OrgConnection $org -Project $agileGitProject -Name 'NetFrameworkSln'

    if (Test-Path -Path "$($Env:TEMP)/NetFrameworkSln") {
        Remove-Item -Path "$($Env:TEMP)/NetFrameworkSln" -Recurse -Force
    }
    New-Item -ItemType Directory -Path "$($Env:TEMP)/NetFrameworkSln"
    $currentLocation = Get-Location
    Set-Location "$($Env:TEMP)/NetFrameworkSln"
    & git init
    Copy-Item "$PSScriptRoot/../../tests/samples/NetFramework.sln" -Destination "$($Env:TEMP)/NetFrameworkSln"
    New-Item -ItemType Directory -Path "$($Env:TEMP)/NetFrameworkSln/NetFrameworkApp"
    Copy-Item "$PSScriptRoot/../../tests/samples/NetFrameworkApp/NetFrameworkApp.csproj" -Destination "$($Env:TEMP)/NetFrameworkSln/NetFrameworkApp/NetFrameworkApp.csproj"
    Copy-Item "$PSScriptRoot/../../tests/samples/NetFrameworkApp/Program.cs" -Destination "$($Env:TEMP)/NetFrameworkSln/NetFrameworkApp/Program.cs"
    Copy-Item "$PSScriptRoot/../../tests/samples/NetFrameworkApp/App.config" -Destination "$($Env:TEMP)/NetFrameworkSln/NetFrameworkApp/App.config"
    & git add .
    & git commit -m 'Initial Commit'
    & git remote add origin "$($org.Uri)/$($agileGitProject.id)/_git/NetFrameworkSln"
    & git push -u origin master
    Write-Host "Created Git Repository NetFrameworkSln"

    Set-Location $currentLocation
}

#endregion

#region Wit
$iterationNamespace = Get-SecurityNamespace -OrgConnection $org | 
Where-Object { $PSItem.name -eq 'Iteration' }
$rootIterationNode = Get-RootClassificationNode -OrgConnection $org `
    -Project $basicTfvcProject -StructureType 'Iteration'
$projectReadersGroup = Get-Identity -OrgConnection $org -SearchFilter LocalGroupName `
    -FilterValue '[Basic Tfvc]\Readers'

$rootIterationNodeAcl = @{
    value = @(
        @{
            inheritPermissions = 'true'
            token              = "vstfs:///Classification/Node/$($rootIterationNode.identifier)"
            acesDictionary     = @{
                $($projectContributorsGroup.descriptor) = @{
                    descriptor = "$($projectContributorsGroup.descriptor)"
                    allow      = 1
                    deny       = 0
                }
                $($projectReadersGroup.descriptor)      = @{
                    descriptor = "$($projectReadersGroup.descriptor)"
                    allow      = 1
                    deny       = 0
                }
            }
        }
    )
}
$null = New-Acl -OrgConnection $org `
    -SecurityNamespace $iterationNamespace `
    -Acl $rootIterationNodeAcl
Write-Host "Root Iteration path security configured"

$bigTeamGroup = Get-Identity -OrgConnection $org -SearchFilter LocalGroupName `
    -FilterValue '[Basic Tfvc]\Big Team'
$bigTeamIterationNode = Get-ClassificationNode -OrgConnection $org `
    -Project $basicTfvcProject -StructureGroup 'Iterations' -Node 'Big Team'
$bigTeamIterationNodeAcl = @{
    value = @(
        @{
            inheritPermissions = 'true'
            token              = "vstfs:///Classification/Node/$($rootIterationNode.identifier):vstfs:///Classification/Node/$($bigTeamIterationNode.identifier)"
            acesDictionary     = @{
                $($bigTeamGroup.descriptor) = @{
                    descriptor = "$($bigTeamGroup.descriptor)"
                    allow      = 4
                    deny       = 0
                }
            }
        }
    )
}
$null = New-Acl -OrgConnection $org `
    -SecurityNamespace $iterationNamespace `
    -Acl $bigTeamIterationNodeAcl
Write-Host "Big Team Iteration path security configured"

$littleTeamGroup = Get-Identity -OrgConnection $org -SearchFilter LocalGroupName `
    -FilterValue '[Basic Tfvc]\Little Team'
$littleTeamIterationNode = Get-ClassificationNode -OrgConnection $org `
    -Project $basicTfvcProject -StructureGroup 'Iterations' -Node 'Little Team'
$littleTeamIterationNodeAcl = @{
    value = @(
        @{
            inheritPermissions = 'true'
            token              = "vstfs:///Classification/Node/$($rootIterationNode.identifier):vstfs:///Classification/Node/$($littleTeamIterationNode.identifier)"
            acesDictionary     = @{
                $($littleTeamGroup.descriptor) = @{
                    descriptor = "$($littleTeamGroup.descriptor)"
                    allow      = 4
                    deny       = 0
                }
            }
        }
    )
}
$null = New-Acl -OrgConnection $org `
    -SecurityNamespace $iterationNamespace `
    -Acl $littleTeamIterationNodeAcl
Write-Host "Little Team Iteration path security configured"

#endregion

#region Build
# Create Folder '\Archive'
# Create 3 builds, one in that folder and others in root
#endregion