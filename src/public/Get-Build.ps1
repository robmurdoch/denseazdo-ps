function Get-Build {
    <#
    .SYNOPSIS
        Provides access to Build -> Builds -> Get, List, Get Build Changes, Get Build Logs, and Get Work Item Refs REST API(s)
    .DESCRIPTION
        Gets a list of Builds, a single Build, or a single Build with additional details
    .EXAMPLE
        $org = Connect-AzureDevOps -OrgUri 'https://org.domain.com/DenseAzDo
        (Get-Project -OrgConnection $org).value | ForEach-Object {
            Get-Build -OrgConnection $org -Project $PSitem | ForEach-Object {
                Write-Output (New-Object -TypeName PSObject -Property  @{
                        'project'         = $PSItem.project.name
                        'buildDefinition' = $PSItem.definition.name;
                        'buildNumber'     = $PSItem.buildNumber;
                        'queueTime'       = $PSItem.queueTime;
                        'startTime'       = $PSItem.startTime;
                        'finishTime'      = $PSItem.finishTime;
                        'sourceBranch'    = $PSItem.sourceBranch;
                        'requestedFor'    = $PSItem.requestedFor.displayName;
                    }
                )
            }
        } | Format-Table -AutoSize

        Get all of the builsd for all projects in an organization (collection). 
        Output Project name and some Build properties for each in table format.
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -BuildIDs 40,83

        Gets builds with id of 40 and 83
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -BranchName refs/heads/main

        Gets all builds for main branch.
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -BuildNumber 2021*

        Gets builds with buildNumber beginning with 2021 
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -DefinitionIds 8,9,10  

        Gets builds for definitions with id of 8, 9, and 10
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -DeletedFilter onlyDeleted

        Gets only builds that have been deleted 
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -MaxBuildsPerDefinition 1

        Gets all builds limiting results to only one per definition, combine with queryorder to get latest build for each definition
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -MaxTime 12/14/2021 -QueryOrder finishTimeAscending 

        Gets all builds up to 12/14/2021
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -MinTime 12/29/2021 -QueryOrder finishTimeDescending

        Gets all builds back to 12/29/2021
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -QueueIds 1

        Gets all builds that ran on queue with id of 1
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -ReasonFilter individualCI 

        Gets all builds that were queued due to CI
    .EXAMPLE
        $repo = Get-GitRepository -OrgConnection $org -Project $project | Select-Object -Last 1
        Get-Build -OrgConnection $org -Project $project -RepositoryId $repo.Id -RepositoryType TfsGit -Verbose

        Gets all builds of code in a given tfsgit repo
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -RequestedFor Administrator

        Gets all builds queued by Administrator
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -ResultFilter failed

        Get all builds that failed
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -StatusFilter cancelling

        Gets all builds that are in the process of being canceled
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -TagFilters flaky

        Gets all builds that have been tagged 'flaky'
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -Id 99

        Gets build with id 99
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -Id 99 -IncludeChanges

        Gets code changes included in build with id 99
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -Id 99 -IncludeLogs

        Gets logs for build with id 99
    .EXAMPLE
        Get-Build -OrgConnection $org -Project $project -Id 99 -IncludeWorkItems

        Gets work items included in build with id 99
    .INPUTS
        Project can be piped to this cmdlet
    .OUTPUTS
        The results of Invoke-RestMethod or Invoke-WebRequest (returning Content json)
    .NOTES
        Supports projects with more than 100 builds
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

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Builds for given branch')]
        [String]$BranchName,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Array of buildIds (system #s) to retrieve')]
        [Int[]]$BuildIds,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Build number filter string (* wildcards)')]
        [String]$BuildNumber,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Array of definitionIds to retrieve')]
        [Int[]]$DefinitionIds,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Include or exclude delete builds or report only deleted builds')]
        [ValidateSet('excludeDeleted', 'includeDeleted', 'onlyDeleted')]
        [String]$DeletedFilter,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Maximum number of builds for each definition')]
        [Int]$MaxBuildsPerDefinition,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Depending on query order builds finished/started before this time')]
        [String]$MaxTime,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Depending on query order builds finished/started after this time')]
        [String]$MinTime,
        
        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Comma delimiated list of properties to return (use with Id)')]
        [String[]]$Properties,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Determines the order results are returned in')]
        [ValidateSet('finishTimeAscending', 'finishTimeDescending', 'queueTimeAscending', 'queueTimeDescending', 'startTimeAscending', 'startTimeDescending')]
        [String]$QueryOrder,
        
        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Comma delimiated list of Queue IDs builds ran against')]
        [Int[]]$QueueIds,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Depending on query order builds finished/started after this time')]
        [ValidateSet('all', 'batchedCI', 'buildCompletion', 'checkInShelveset', 'individualCI', 'manual', 'none', 'pullRequest', 'resourceTrigger', 'schedule', 'scheduleForced', 'triggered', 'userCreated', 'validateShelveset')]
        [String]$ReasonFilter,

        [Parameter(ParameterSetName = 'RepositoryFilter', 
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Filter builds that use repository (use with RepositoryType)')]
        [String]$RepositoryId,

        [Parameter(ParameterSetName = 'RepositoryFilter', 
            Mandatory = $true,
            HelpMessage = 'Filter builds that use the repository type (use with RepositoryId)')]
        [ValidateSet('TfsGit', 'TfsVersionControl', 'GitHub', 'GitHubEnterprise', 'svn', 'Bitbucket', 'Git')]
        [String]$RepositoryType,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Filter builds requested by a specific user')]
        [String]$RequestedFor,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Depending on query order builds finished/started after this time')]
        [ValidateSet('canceled', 'failed', 'none', 'partiallySucceeded', 'succeeded')]
        [String]$ResultFilter,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Depending on query order builds finished/started after this time')]
        [ValidateSet('all', 'cancelling', 'completed', 'inProgress', 'none', 'notStarted', 'postponed')]
        [String]$StatusFilter,
        
        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Comma delimiated list of tags to filter results')]
        [String[]]$TagFilters,
        
        [Parameter(ParameterSetName = 'Item',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Get a single build definition')]
        [Parameter(ParameterSetName = 'Changes',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)] 
        [Parameter(ParameterSetName = 'Logs',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)] 
        [Parameter(ParameterSetName = 'WorkItems',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)] 
        [Int]$Id,
        
        [Parameter(ParameterSetName = 'Item', 
            HelpMessage = 'Comma delimiated list of properties to return (use with Id)')]
        [String[]]$PropertyFilters,
        
        [Parameter(ParameterSetName = 'Changes', 
            Mandatory = $true,
            HelpMessage = 'Get revisions for a given definition (includes lightweight current version')]
        [Switch]$IncludeChanges,
        
        [Parameter(ParameterSetName = 'Logs', 
            Mandatory = $true,
            HelpMessage = 'Get revisions for a given definition (includes lightweight current version')]
        [Switch]$IncludeLogs,
        
        [Parameter(ParameterSetName = 'WorkItems', 
            Mandatory = $true,
            HelpMessage = 'Get revisions for a given definition (includes lightweight current version')]
        [Switch]$IncludeWorkItems,
        
        [Parameter(HelpMessage = 'Cache results to reduce duplication requests')]
        [Switch]$CacheResults
    )
    process {

        Write-Verbose $PSCmdlet.ParameterSetName

        if ($PSCmdlet.ParameterSetName -eq 'Item') {
            $path = "$($Project.id)/_apis/build/builds/$Id"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Changes') {
            $path = "$($Project.id)/_apis/build/builds/$Id/changes"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Logs') {
            $path = "$($Project.id)/_apis/build/builds/$Id/logs"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'WorkItems') {
            $path = "$($Project.id)/_apis/build/builds/$Id/workitems"
        }
        else {
            $path = "$($Project.id)/_apis/build/builds"
        }

        $query = @()
        if ($PSCmdlet.ParameterSetName -eq 'RepositoryFilter') {
            if ($PSBoundParameters.ContainsKey('RepositoryId')) {
                $query += "repositoryId=$RepositoryId"
            }
            if ($PSBoundParameters.ContainsKey('RepositoryType')) {
                $query += "repositoryType=$RepositoryType"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'GenericFilter') {         
            if ($PSBoundParameters.ContainsKey('DefinitionIds')) {
                $idList = $DefinitionIds -join ','
                $query += "definitions=$idList"
            }
            if ($PSBoundParameters.ContainsKey('QueueIds')) {
                $idList = $QueueIds -join ','
                $query += "queues=$idList"
            }
            if ($PSBoundParameters.ContainsKey('BuildNumber')) {
                $query += "buildNumber=$BuildNumber"
            }
            if ($PSBoundParameters.ContainsKey('MinTime')) {
                $query += "minTime=$MinTime"
            }
            if ($PSBoundParameters.ContainsKey('MaxTime')) {
                $query += "maxTime=$MaxTime"
            }
            if ($PSBoundParameters.ContainsKey('RequestedFor')) {
                $query += "requestedFor=$RequestedFor"
            }
            if ($PSBoundParameters.ContainsKey('ReasonFilter')) {
                $query += "reasonFilter=$ReasonFilter"
            }
            if ($PSBoundParameters.ContainsKey('StatusFilter')) {
                $query += "statusFilter=$StatusFilter"
            }
            if ($PSBoundParameters.ContainsKey('ResultFilter')) {
                $query += "resultFilter=$ResultFilter"
            }
            if ($PSBoundParameters.ContainsKey('TagFilters')) {
                $tagList = $TagFilters -join ','
                $query += "tagFilters=$tagList"
            }
            if ($PSBoundParameters.ContainsKey('Properties')) {
                $propertyList = $Properties -join ','
                $query += "properties=$propertyList"
            }
            if ($PSBoundParameters.ContainsKey('MaxBuildsPerDefinition')) {
                $query += "maxBuildsPerDefinition=$MaxBuildsPerDefinition"
            }
            if ($PSBoundParameters.ContainsKey('DeletedFilter')) {
                $query += "deletedFilter=$DeletedFilter"
            }
            if ($PSBoundParameters.ContainsKey('BranchName')) {
                $query += "branchName=$BranchName"
            }
            if ($PSBoundParameters.ContainsKey('BuildIds')) {
                $idList = $BuildIds -join ','
                $query += "buildIds=$idList"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'GenericFilter' -or $PSCmdlet.ParameterSetName -eq 'RepositoryFilter') {
            if ($PSBoundParameters.ContainsKey('QueryOrder')) {
                $query += "queryOrder=$QueryOrder"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'Item') {
            if ($PSBoundParameters.ContainsKey('PropertyFilters')) {
                $propertyFilterList = $PropertyFilters -join ','
                $query += "propertyFilters=$propertyFilterList"
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'RepositoryFilter' -or $PSCmdlet.ParameterSetName -eq 'GenericFilter') {

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
        elseif ($PSCmdlet.ParameterSetName -eq 'Changes' -or $PSCmdlet.ParameterSetName -eq 'Logs' -or $PSCmdlet.ParameterSetName -eq 'WorkItems') {
            $uri = getApiUri -OrgConnection $OrgConnection `
                -Path $path -Query $query

            if ($CacheResults) {
                Write-Output (getApiResponse -OrgConnection $OrgConnection `
                        -Uri $uri -CacheResults `
                        -CacheName $MyInvocation.MyCommand.Name).value
            }
            else {
                Write-Output (getApiResponse -OrgConnection $OrgConnection `
                        -Uri $uri `
                        -CacheName $MyInvocation.MyCommand.Name).value
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
