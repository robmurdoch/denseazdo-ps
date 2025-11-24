function Get-Release {
    <#
    .SYNOPSIS
        Provides access to Release -> Releases -> Get Logs, Get Release, Get Release Environment, Get Release Revision, Get Task Log, and List REST API(s)
    .DESCRIPTION
        Gets a list of Releases, a single Release, or a single Release's details
    .EXAMPLE
        $org = Connect-AzureDevOps -OrgUri 'https://org.domain.com/DenseAzDo
        Get-Release -OrgConnection $org -Project $project -ReleaseExpand approvals | ForEach-Object {
            $project = $PSItem.projectReference
            $releaseDefinition = $PSItem.releaseDefinition
            $PSItem.environments | Where-Object { $PSItem.name -like '*Prod*' -and $PSItem.status -eq 'succeeded' } | ForEach-Object {
                Write-Output (New-Object -TypeName PSObject -Property @{
                        'project'           = $project.name;
                        'releaseDefinition' = $releaseDefinition.name;
                        'environment'       = $PSItem.name;
                        'approver'          = $PSItem.preDeployApprovals.approver.displayName;
                        'approvedBy'        = $PSItem.preDeployApprovals.approvedBy.displayName;
                    })
            }
        } | Format-Table -AutoSize

        Find all Releases in a given Project with Environments containing 'Prod' that succeeded and report the approver 
    .EXAMPLE        
        Get-Release -OrgConnection $org -Project $project

        Get all Releases with a given project
    .EXAMPLE
        Get-Project -OrgConnection $org | 
        Get-Release -OrgConnection $org -Verbose

        Get all of the Releases for all of the Projects in an Organization (Collection)
    .EXAMPLE
        Get-Project -OrgConnection $org | ForEach-Object {
            $project = $PSitem
            Get-Release -OrgConnection $org -Project $project | ForEach-Object {
                $release = $PSItem
                Get-Release -OrgConnection $org -Project $project -Id $release.Id -FilePath "$Env:USERPROFILE\Downloads\release-$($release.id)-log.zip"   
            }
        }

        Download all Release Logs for all Projects in an Organization (Collection) to the User's Downloads folder
    .EXAMPLE        
        Get-Release -OrgConnection $org -Project $project -Id 3

        Get Release with ID 3 in a given Project
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -Verbose -DefinitionId 2

        Get all Releases for a given Release Definition
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -DefinitionId 2 -DefinitionEnvironmentId 2

        Get all Releases for a given Release Definition and a given Environment
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -Verbose -Name 'Release'

        Get all Releases for a given Project with "Release" in the name
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -Verbose -CreatedBy 'Administrator'

        Get all Releases for a given Project created by the Administrator
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -Verbose -StatusFilter 'active', 'abandoned'

        Get all Releases for a given Project with a Status of active or abandoned
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -Verbose -MaxCreatedTime (Get-Date '1/1/2022 8:00:00 AM').ToUniversalTime()

        Get all Releases for a given Project created before 1/1/2022 8:00:00 AM
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -Verbose -MinCreatedTime (Get-Date '1/1/2022 8:00:00 AM').ToUniversalTime()

        Get all Releases for a given Project created after 1/1/2022 8:00:00 AM
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -ReleaseExpand approvals, artifacts

        Get all Releases for a given Project with approvals and artifacts included
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -ArtifactTypeId Build

        Get all Releases for a given Project that deploy a Build artifact
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -ReleaseIds 3,5

        Get Releases for given Ids (3 and 5) for a given Project
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -Id 3 -EnvironmentId 3 -taskId 4 -ReleaseDeployPhaseId 3

        Get Release Task Log given a Release ID, EnvironmentID, DployPhaseId, TaskID for a given Project
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -SourceBranchFilter main

        Get Releases for Definition with source code artifact that were triggered by main branch
    .EXAMPLE
        Get-Release -OrgConnection $org -Project $project -Id 8 -DefinitionSnapshotRevision 2

        Get revision 2 of Release 8 
    .INPUTS
        Project can be piped to this cmdlet
    .OUTPUTS
        The results of Invoke-RestMethod or Invoke-WebRequest (returning Content json)
    .NOTES
        Supports projects with more than 100 releases
    #>
    [CmdletBinding(DefaultParameterSetName = 'GenericFilter')]
    param (
        [Parameter(Mandatory = $true, 
            HelpMessage = 'Reference to Connection object obtained from Connect-AzureDevOps')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true, 
            HelpMessage = 'Reference to an object obtained by Get-Project')]
        [Alias("P", "Proj")]
        [System.Object]$Project,

        [Parameter(ParameterSetName = 'DefinitionFilter', 
            Mandatory = $true, 
            HelpMessage = 'Given a Release Definition Id, returns all Releases')]
        [Parameter(ParameterSetName = 'EnvironmentFilter')]
        [Int]$DefinitionId,

        [Parameter(ParameterSetName = 'EnvironmentFilter', 
            Mandatory = $true, 
            HelpMessage = 'Given a Release Definition Environment Id, returns all releases to that Environment')] 
        [Int]$DefinitionEnvironmentId,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Given an search string, returns only releases that contain the value provided; e.g. "Release" returns "Release-1" (no wildcard needed)')]
        [String]$Name,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Given the full name of a specific user, returns only releases they created')]
        [String]$CreatedBy,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Given a single or combination of Release Status, returns only releases in that status')]
        [ValidateSet('abandoned', 'active', 'draft', 'undefined')]
        [String[]]$StatusFilter,

        # [Parameter(ParameterSetName = 'GenericFilter', 
        #     HelpMessage = 'Given a single or combination of Environment Status, returns only releases with an environments in that status')]
        # [ValidateSet('canceled', 'inProgress', 'notStarted', 'partiallySucceeded', 'queued', 'rejected', 'scheduled', 'succeeded', 'undefined')]
        # [String]$EnvironmentStatusFilter,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Depending on query order, given a UTC date/time, returns releases created after that date/time')]
        [String]$MinCreatedTime,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Depending on query order, given a UTC date/time, returns releases created before that date/time')]
        [String]$MaxCreatedTime,

        [Parameter(ParameterSetName = 'IdFilter', 
            HelpMessage = 'Determines the order results are returned in')]
        [Parameter(ParameterSetName = 'GenericFilter')]
        [Parameter(ParameterSetName = 'ArtifactFilter')]
        [ValidateSet('ascending', 'descending')]
        [String]$QueryOrder,

        [Parameter(ParameterSetName = 'IdFilter', 
            HelpMessage = 'List of properties to be expanded (returned)')]
        [Parameter(ParameterSetName = 'GenericFilter')]
        [Parameter(ParameterSetName = 'ArtifactFilter')]
        [ValidateSet('approvals', 'artifacts', 'environments', 'manualInterventions', 'none', 'tags', 'variables')]
        [String[]]$ReleaseExpand,

        [Parameter(ParameterSetName = 'ArtifactFilter', 
            Mandatory = $true,
            HelpMessage = 'Return only releases with a given artifact type')]
        [ValidateSet('Build', 'Jenkins', 'GitHub', 'Nuget', 'Team Build (external)', 'ExternalTFSBuild', 'Git', 'TFVC', 'ExternalTfsXamlBuild')]
        [String]$ArtifactTypeId,

        [Parameter(ParameterSetName = 'ArtifactFilter', 
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Return only releases sourced from a specific artifact definition, e.g. {projectGuid}:{BuildDefinitionId}')]
        [String]$SourceId,

        [Parameter(ParameterSetName = 'ArtifactFilter',
            HelpMessage = 'Releases for a specific artifact id (buildid for build)')]
        [String]$ArtifactVersionId,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Return only releases from a specific source branch')]
        [String]$SourceBranchFilter,
        
        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Return only deleted releases')]
        [Switch]$ListDeleted,
        
        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Return releases with a specific tag(s)')]
        [String[]]$TagFilter,
        
        [Parameter(ParameterSetName = 'Item', 
            HelpMessage = 'Comma delimiated list of properties to return')]
        [Parameter(ParameterSetName = 'GenericFilter')] 
        [Parameter(ParameterSetName = 'ArtifactFilter')] 
        [Parameter(ParameterSetName = 'IdFilter')] 
        [String[]]$PropertyFilters,

        [Parameter(ParameterSetName = 'IdFilter', 
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Comma delimited list of release Ids to return')]
        [Int[]]$ReleaseIds,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Filter to definitions under a folder (path)')]
        [String]$Folder,
        
        [Parameter(ParameterSetName = 'Logs', 
            Mandatory = $true,
            HelpMessage = 'Path to write logs (.zip)')]
        [String]$FilePath,
        
        [Parameter(ParameterSetName = 'Item',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Get a single build definition')]
        [Parameter(ParameterSetName = 'Logs',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)] 
        [Parameter(ParameterSetName = 'Environments',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)] 
        [Parameter(ParameterSetName = 'Revision',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)] 
        [Parameter(ParameterSetName = 'TaskLog',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)] 
        [Int]$Id,
        
        [Parameter(ParameterSetName = 'Item', 
            HelpMessage = 'Filter the approval steps to a specific type')]
        [ValidateSet('all', 'approvalSnapshots', 'automatedApprovals', 'manualApprovals', 'none')]
        [String]$ApprovalFilters,

        [Parameter(ParameterSetName = 'Item', 
            HelpMessage = 'List of properties to be expanded (returned)')]
        [ValidateSet('none', 'TaskLog')]
        [String]$SingleReleaseExpand,
        
        # [Parameter(ParameterSetName = 'Environments', 
        #     Mandatory = $true,
        #     HelpMessage = 'Get environments for a given release')]
        # [Switch]$IncludeEnvironments,

        [Parameter(ParameterSetName = 'Environments', 
            Mandatory = $true,
            HelpMessage = 'Id of the definition environment to retrieve')]
        [Parameter(ParameterSetName = 'TaskLog',
            Mandatory = $true)] 
        [Int]$EnvironmentId,

        [Parameter(ParameterSetName = 'Revision', 
            Mandatory = $true,
            HelpMessage = 'Get revision id for a given release')]
        [Int]$DefinitionSnapshotRevision,
        
        [Parameter(ParameterSetName = 'TaskLog', 
            Mandatory = $true,
            HelpMessage = 'Get a task logs for a given release, environment, deployPhaseId, and taskid')]
        [Int]$TaskId,
        
        [Parameter(ParameterSetName = 'TaskLog', 
            Mandatory = $true,
            HelpMessage = 'Get a task logs for a given release, environment, deployPhaseId, and taskid')]
        [Int]$ReleaseDeployPhaseId,
        
        [Parameter(ParameterSetName = 'TaskLog', 
            HelpMessage = 'Get a task logs starting a specific line')]
        [Int]$StartLine,
        
        [Parameter(ParameterSetName = 'TaskLog', 
            HelpMessage = 'Get a task logs up to a specific line')]
        [Int]$EndLine,
        
        [Parameter(HelpMessage = 'Cache results to reduce duplication requests')]
        [Switch]$CacheResults
    )
    process {

        Write-Verbose $PSCmdlet.ParameterSetName

        if ($PSCmdlet.ParameterSetName -eq 'Item' -or $PSCmdlet.ParameterSetName -eq 'Revision') {
            $path = "$($Project.id)/_apis/release/releases/$Id"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Logs') {
            $path = "$($Project.id)/_apis/release/releases/$Id/logs"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Environments') {
            $path = "$($Project.id)/_apis/release/releases/$Id/environments/$EnvironmentId"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'TaskLog') {
            $path = "$($Project.id)/_apis/release/releases/$Id/environments/$EnvironmentId/deployPhases/$ReleaseDeployPhaseId/tasks/$TaskId/Logs"
        }
        else {
            $path = "$($Project.id)/_apis/release/releases"
        }

        $query = @()
        if ($PSCmdlet.ParameterSetName -eq 'ArtifactFilter') {
            if ($PSBoundParameters.ContainsKey('ArtifactTypeId')) {
                $query += "artifactTypeId=$ArtifactTypeId"
            }
            if ($PSBoundParameters.ContainsKey('SourceId')) {
                $query += "sourceId=$SourceId"
            }
            if ($PSBoundParameters.ContainsKey('ArtifactVersionId')) {
                $query += "artifactVersionId=$ArtifactVersionId"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'GenericFilter') {    
            if ($PSBoundParameters.ContainsKey('Name')) {
                $query += "searchText=$Name"
            }
            if ($PSBoundParameters.ContainsKey('CreatedBy')) {
                $query += "createdBy=$CreatedBy"
            }
            if ($PSBoundParameters.ContainsKey('StatusFilter')) {
                $statusList = $StatusFilter -join ','
                $query += "statusFilter=$statusList"
            }
            # if ($PSBoundParameters.ContainsKey('EnvironmentStatusFilter')) {
            #     # $statusList = $EnvironmentStatusFilter -join ','
            #     # $query += "environmentStatusFilter=$statusList"
            #     $query += "environmentStatusFilter=$EnvironmentStatusFilter"
            # }
            if ($PSBoundParameters.ContainsKey('MinCreatedTime')) {
                $query += "minCreatedTime=$MinCreatedTime"
            }
            if ($PSBoundParameters.ContainsKey('MaxCreatedTime')) {
                $query += "maxCreatedTime=$MaxCreatedTime"
            }
            if ($PSBoundParameters.ContainsKey('SourceBranchFilter')) {
                $query += "sourceBranchFilter=$SourceBranchFilter"
            }
            if ($PSBoundParameters.ContainsKey('Folder')) {
                $query += "path=$Folder"
            }
            if ($ListDeleted) {
                $query += "isDeleted=true"
            }
            if ($PSBoundParameters.ContainsKey('TagFilter')) {
                $tagList = $TagFilter -join ','
                $query += "tagFilter=$tagList"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'EnvironmentFilter' -or $PSCmdlet.ParameterSetName -eq 'DefinitionFilter') {        
            if ($PSBoundParameters.ContainsKey('DefinitionId')) {
                $query += "definitionId=$DefinitionId"
            } 
        }
        if ($PSCmdlet.ParameterSetName -eq 'EnvironmentFilter') {     
            if ($PSBoundParameters.ContainsKey('DefinitionEnvironmentId')) {
                $query += "definitionEnvironmentId=$DefinitionEnvironmentId"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'IdFilter') {    
            if ($PSBoundParameters.ContainsKey('ReleaseIds')) {
                $idList = $ReleaseIds -join ','
                $query += "releaseIdFilter=$idList"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'Item') {
            if ($PSBoundParameters.ContainsKey('ApprovalFilters')) {
                $query += "approvalFilters=$ApprovalFilters"
            }
            if ($PSBoundParameters.ContainsKey('SingleReleaseExpand')) {
                $expandList = $SingleReleaseExpand -join ','
                $query += "`$expand=$expandList"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'Revision') {
            if ($PSBoundParameters.ContainsKey('DefinitionSnapshotRevision')) {
                $query += "definitionSnapshotRevision=$DefinitionSnapshotRevision"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'TaskLog') {
            if ($PSBoundParameters.ContainsKey('StartLine')) {
                $query += "startLine=$StartLine"
            }
            if ($PSBoundParameters.ContainsKey('EndLine')) {
                $query += "endLine=$EndLine"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'GenericFilter' -or $PSCmdlet.ParameterSetName -eq 'ArtifactFilter' -or $PSCmdlet.ParameterSetName -eq 'IdFilter') {
            if ($PSBoundParameters.ContainsKey('QueryOrder')) {
                $query += "queryOrder=$QueryOrder"
            }
            if ($PSBoundParameters.ContainsKey('ReleaseExpand')) {
                $expandList = $ReleaseExpand -join ','
                $query += "`$expand=$expandList"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'GenericFilter' -or $PSCmdlet.ParameterSetName -eq 'ArtifactFilter' -or $PSCmdlet.ParameterSetName -eq 'IdFilter' -or $PSCmdlet.ParameterSetName -eq 'Item') {
            if ($PSBoundParameters.ContainsKey('PropertyFilters')) {
                $propertyFilterList = $PropertyFilters -join ','
                $query += "propertyFilters=$propertyFilterList"
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IdFilter' -or $PSCmdlet.ParameterSetName -eq 'GenericFilter' -or $PSCmdlet.ParameterSetName -eq 'ArtifactFilter' -or $PSCmdlet.ParameterSetName -eq 'DefinitionFilter' -or $PSCmdlet.ParameterSetName -eq 'EnvironmentFilter') {

            if ($CacheResults) {
                Write-Output (getPagedApiResponse -OrgConnection $OrgConnection `
                        -Path $path -Query $query -CacheResults `
                        -CacheName $MyInvocation.MyCommand.Name).value
            }
            else {
                Write-Output (getPagedApiResponse -OrgConnection $OrgConnection `
                        -Path $path -Query $query `
                        -CacheName $MyInvocation.MyCommand.Name).value
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Revision') {
            $uri = getApiUri -OrgConnection $OrgConnection `
                -Path $path -Query $query

            if ($CacheResults) {
                Write-Output (getApiResponse -OrgConnection $OrgConnection `
                        -Uri $uri -CacheResults `
                        -CacheName $MyInvocation.MyCommand.Name)
            }
            else {
                Write-Output (getApiResponse -OrgConnection $OrgConnection `
                        -Uri $uri `
                        -CacheName $MyInvocation.MyCommand.Name)
            }            
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Logs') {
            $uri = getApiUri -OrgConnection $OrgConnection `
                -Path $path -Query $query -Preview1
                
            getApiZipResponse -OrgConnection $OrgConnection `
                -Uri $uri -Path $FilePath
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Environments' -or $PSCmdlet.ParameterSetName -eq 'TaskLog') {
            $uri = getApiUri -OrgConnection $OrgConnection `
                -Path $path -Query $query -Preview1

            if ($CacheResults) {
                Write-Output (getApiResponse -OrgConnection $OrgConnection `
                        -Uri $uri -CacheResults `
                        -CacheName $MyInvocation.MyCommand.Name)
            }
            else {
                Write-Output (getApiResponse -OrgConnection $OrgConnection `
                        -Uri $uri `
                        -CacheName $MyInvocation.MyCommand.Name)
            }            
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Item') {
            $uri = getApiUri -OrgConnection $OrgConnection `
                -Path $path -Query $query

            if ($CacheResults) {
                Write-Output (getApiResponse -OrgConnection $OrgConnection `
                        -Uri $uri -CacheResults `
                        -CacheName $MyInvocation.MyCommand.Name)
            }
            else {
                Write-Output (getApiResponse -OrgConnection $OrgConnection `
                        -Uri $uri `
                        -CacheName $MyInvocation.MyCommand.Name)
            }            
        }
    }
}
