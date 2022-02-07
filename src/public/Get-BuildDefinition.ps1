function Get-BuildDefinition {
    <#
    .SYNOPSIS
        Provides access to Build -> Definitions -> Get, List, and Get Definition Revisions REST API(s)
    .DESCRIPTION
        Gets a list of Build Definitions or a single Build Definition
    .EXAMPLE
        $org = Connect-AzureDevOps -OrgUri 'https://org.domain.com/DenseAzDo
        Get-Project -OrgConnection $org | ForEach-Object {
            Get-BuildDefinition -OrgConnection $org `
                -Project $PSItem -QueryOrder lastModifiedDescending | ForEach-Object {
                    Write-Output (New-Object -TypeName PSObject -Property  @{
                        'project'    = $_.name
                        'authoredBy' = $PSItem.authoredBy.displayName;
                        'queue'      = $PSItem.queue.name;
                        'pool'       = $PSItem.queue.pool.name;
                        'id'         = $PSItem.id;
                        'name'       = $PSItem.name;
                        'path'       = $PSItem.path;
                    }
                )
            }
        }

        Get all of the build definitions for all projects in an organization (collection). 
        Outputs Project name and some Build properties for each.
    .EXAMPLE
        $project = Get-Project -OrgConnection $org -Id 'Agile Git' 
        Get-GitRepository -OrgConnection $org -Project $project | 
        Where-Object { $PSItem.name -eq 'MyRepo' } | 
        Select-Object @{name = 'RepositoryId'; expression = { $PSItem.id } } |
        Get-BuildDefinition -OrgConnection $org -Project $project -RepositoryType 'TfsGit' 

        Gets all build definitions that depend on the MyRepo TfsGit repository in the Agile Git project.
    .EXAMPLE
        Get-Project -OrgConnection $org -Id 'Agile Git' | 
        Get-BuildDefinition -OrgConnection $org -Name 'Net*' -Verbose  

        Gets all build definitions that begins with Net in the Agile Git project.
    .EXAMPLE
        Get-Project -OrgConnection $org -Id 'Agile Git' | 
        Get-BuildDefinition -OrgConnection $org -Name 'Net*' -IncludeSecurity

        Gets all build definitions that begins with Net in the Agile Git project with security settings (1 row per ACE) 
    .EXAMPLE
        Get-BuildDefinition -OrgConnection $org -Project $project -QueryOrder lastModifiedDescending  

        Gets all build definitions listed in date last modified descending order. 
    .EXAMPLE
        Get-BuildDefinition -OrgConnection $org -Project $project -Folder '\Archive'

        Gets all build definitions in the Archive folder. 
    .EXAMPLE
        Get-BuildDefinition -OrgConnection $org -Project $project -BuiltAfter '1/1/2021'

        Gets all build definitions that were built after 1/1/2021.
    .EXAMPLE
        Get-BuildDefinition -OrgConnection $org -Project $project -DefinitionIds 1,2,3

        Gets all build definitions with ID 1, 2, or 3.
    .EXAMPLE
        Get-BuildDefinition -OrgConnection $org -Project $project -Id 1

        Gets the build definition with ID of 1.
    .INPUTS
        Project can be piped to this cmdlet
    .OUTPUTS
        The results of Invoke-RestMethod or when -IncludeSecurity List of custom objects
    .NOTES
        Supports projects with more than 100 build definitions
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

        [Parameter(ParameterSetName = 'IdFilter', 
            HelpMessage = 'Determines the order results are returned in')]
        [Parameter(ParameterSetName = 'GenericFilter')]
        [Parameter(ParameterSetName = 'RepositoryFilter')]
        [ValidateSet('definitionNameAscending', 'definitionNameDescending', 'lastModifiedAscending', 'lastModifiedDescending', 'none')]
        [String]$QueryOrder,

        [Parameter(ParameterSetName = 'IdFilter', 
            HelpMessage = 'Array of definitionIds to retrieve')]
        [Int[]]$DefinitionIds,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Pattern filter for definition name')]
        [String]$Name,

        [Parameter(ParameterSetName = 'RepositoryFilter', 
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Filter definitions that use repository (use with RepositoryType)')]
        [String]$RepositoryId,

        [Parameter(ParameterSetName = 'RepositoryFilter', 
            Mandatory = $true,
            HelpMessage = 'Filter definitions that use the repository type (use with RepositoryId)')]
        [ValidateSet('TfsGit', 'TfsVersionControl', 'GitHub', 'GitHubEnterprise', 'svn', 'Bitbucket', 'Git')]
        [String]$RepositoryType,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Filter that have been build after a date')]
        [String]$BuiltAfter,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Filter that have not been build after a date')]
        [String]$NotBuiltAfter,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Filter to definitions under a folder')]
        [String]$Folder,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Filter to definitions that use specified task')]
        [String]$TaskId,
        
        [Parameter(ParameterSetName = 'IdFilter', 
            HelpMessage = 'Retrieve full definitions (Use with IdFilter and Filters)')]
        [Parameter(ParameterSetName = 'GenericFilter')]
        [Parameter(ParameterSetName = 'RepositoryFilter')]
        [Switch]$IncludeAllProperties,
        
        [Parameter(HelpMessage = 'Include latest build and latest completed build (not used with Id)')]
        [Switch]$IncludeLatestBuilds,
        
        [Parameter(ParameterSetName = 'Item',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Get a single build definition')]
        [Parameter(ParameterSetName = 'Revisions',
            Mandatory = $true)] 
        [Int]$Id,
        
        [Parameter(ParameterSetName = 'Item',
            ValueFromPipelineByPropertyName = $true, 
            HelpMessage = 'Get a specific revision of the build definition (use with Id)')]
        [Int]$Revision,
        
        [Parameter(ParameterSetName = 'Item', 
            HelpMessage = 'Get metrics back to a date/time (use with Id)')]
        [String]$MinMetricsTime,
        
        [Parameter(ParameterSetName = 'Item', 
            HelpMessage = 'Comma delimiated list of properties to return (use with Id)')]
        [String[]]$PropertyFilters,
        
        [Parameter(ParameterSetName = 'Revisions', 
            Mandatory = $true,
            HelpMessage = 'Get revisions for a given definition (includes lightweight current version')]
        [Switch]$IncludeRevisions,
        
        [Parameter(ParameterSetName = 'IdFilter',
            HelpMessage = 'Include security in the results (for filters)')]
        [Parameter(ParameterSetName = 'GenericFilter')] 
        [Parameter(ParameterSetName = 'RepositoryFilter')] 
        [Switch]$IncludeSecurity,
        
        [Parameter(HelpMessage = 'Cache results to reduce duplication requests')]
        [Switch]$CacheResults
    )
    process {

        Write-Verbose $PSCmdlet.ParameterSetName

        if ($PSCmdlet.ParameterSetName -eq 'Item') {
            $path = "$($Project.id)/_apis/build/definitions/$Id"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Revisions') {
            $path = "$($Project.id)/_apis/build/definitions/$Id/revisions"
        }
        else {
            $path = "$($Project.id)/_apis/build/definitions"
        }

        $query = @()
        if ($PSCmdlet.ParameterSetName -eq 'IdFilter') {            
            if ($PSBoundParameters.ContainsKey('DefinitionIds')) {
                $idList = $DefinitionIds -join ','
                $query += "definitionIds=$idList"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'RepositoryFilter') {
            if ($PSBoundParameters.ContainsKey('RepositoryId')) {
                $query += "repositoryId=$RepositoryId"
            }
            if ($PSBoundParameters.ContainsKey('RepositoryType')) {
                $query += "repositoryType=$RepositoryType"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'GenericFilter') {            
            if ($PSBoundParameters.ContainsKey('Name')) {
                $query += "name=$Name"
            }
            if ($PSBoundParameters.ContainsKey('BuiltAfter')) {
                $query += "builtAfter=$BuiltAfter"
            }
            if ($PSBoundParameters.ContainsKey('NotBuiltAfter')) {
                $query += "notBuiltAfter=$NotBuiltAfter"
            }
            if ($PSBoundParameters.ContainsKey('Folder') -and $Folder.Length -gt 0) {
                $query += "path=$Folder"
            }
            if ($PSBoundParameters.ContainsKey('TaskId') -and $TaskId.Length -gt 0) {
                $query += "taskIdFilter=$TaskId"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'IdFilter' -or $PSCmdlet.ParameterSetName -eq 'RepositoryFilter' -or $PSCmdlet.ParameterSetName -eq 'GenericFilter') {
            if ($IncludeAllProperties) {
                $query += "includeAllProperties=true"
            }
            if ($IncludeLatestBuilds) {
                $query += "includeLatestBuilds=true"
            }
            if ($PSBoundParameters.ContainsKey('QueryOrder')) {
                $query += "queryOrder=$QueryOrder"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'Item') {
            if ($PSBoundParameters.ContainsKey('Revision')) {
                $query += "revision=$Revision"
            }
            if ($PSBoundParameters.ContainsKey('MinMetricsTime')) {
                $query += "minMetricsTime=$MinMetricsTime"
            }
            if ($PSBoundParameters.ContainsKey('PropertyFilters')) {
                $propertyFilterList = $PropertyFilters -join ','
                $query += "propertyFilters=$propertyFilterList"
            }
            if ($IncludeLatestBuilds) {
                $query += "includeLatestBuilds=true"
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IdFilter' -or $PSCmdlet.ParameterSetName -eq 'RepositoryFilter' -or $PSCmdlet.ParameterSetName -eq 'GenericFilter' -or $PSCmdlet.ParameterSetName -eq 'Revisions') {
            
            if ($IncludeSecurity) {    
                $securityNamespace = Get-SecurityNamespace -OrgConnection $OrgConnection | 
                Where-Object { $PSItem.name -eq 'Build' }

                $builds = getPagedApiResponse -OrgConnection $OrgConnection `
                    -Path $path -Query $query -CacheResults `
                    -CacheName $MyInvocation.MyCommand.Name
                
                foreach ($build in $builds.value) {

                    $token = "$($Project.Id)/$($build.id)"
                    $acls = Get-Acl -OrgConnection $OrgConnection `
                        -SecurityNamespace $securityNamespace `
                        -SecurityToken $token `
                        -IncludeExtendedInfo -CacheResults
                    $acl = $acls[0]
    
                    if ($null -ne $acl) {
                        $aces = Get-Ace -OrgConnection $OrgConnection `
                            -SecurityNamespace $SecurityNamespace `
                            -Acl $acl
                        appendToAces -ObjectToAppend $build -Aces $aces
                    }
                }
            } 
            else {
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
