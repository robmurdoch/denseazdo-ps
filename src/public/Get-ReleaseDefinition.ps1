function Get-ReleaseDefinition {
    <#
    .SYNOPSIS
        Provides access to Release -> Definitions -> Get, List, Get Definition Revision, and Get Release Definition Hisitory REST API(s)
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
        [Parameter(ParameterSetName = 'ArtifactFilter')]
        [ValidateSet('definitionNameAscending', 'definitionNameDescending', 'lastModifiedAscending', 'lastModifiedDescending', 'none')]
        [String]$QueryOrder,

        [Parameter(ParameterSetName = 'IdFilter', 
            HelpMessage = 'List of properties to be expanded (returned)')]
        [Parameter(ParameterSetName = 'GenericFilter')]
        [Parameter(ParameterSetName = 'ArtifactFilter')]
        [ValidateSet('artifacts', 'environments', 'lastRelease', 'none', 'TagFilter', 'triggers', 'variables')]
        [String[]]$Expand,

        [Parameter(ParameterSetName = 'IdFilter', 
            HelpMessage = 'Array of definitionIds to retrieve')]
        [Int[]]$DefinitionIds,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Pattern filter for definition name (Search Text)')]
        [String]$Name,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Pattern filter for definition name is an exact match)')]
        [Switch]$ExactMatch,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Pattern filter for definition name contains folder)')]
        [Switch]$MatchFolder,

        [Parameter(ParameterSetName = 'IdFilter', 
            HelpMessage = 'List of properties to be expanded (returned)')]
        [Parameter(ParameterSetName = 'GenericFilter')]
        [Parameter(ParameterSetName = 'ArtifactFilter')]
        [String[]]$TagFilter,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'State is deleted')]
        [Switch]$Deleted,

        [Parameter(ParameterSetName = 'ArtifactFilter', 
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Identifier of the release source, e.g. {projectGuid}:{BuildDefinitionId}')]
        [String]$ArtifactSourceId,

        [Parameter(ParameterSetName = 'ArtifactFilter', 
            Mandatory = $true,
            HelpMessage = 'Filter definitions that use the artifactory type (use with ArtifactSourceId)')]
        [ValidateSet('Build', 'Jenkins', 'GitHub', 'Nuget', 'ExternalTFSBuild', 'Git', 'TFVC')]
        [String]$ArtifactType,

        [Parameter(ParameterSetName = 'GenericFilter', 
            HelpMessage = 'Filter to definitions under a folder (path)')]
        [String]$Folder,

        [Parameter(ParameterSetName = 'Item',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Get a single build definition')]
        [Parameter(ParameterSetName = 'Revisions',
            Mandatory = $true)] 
        [Int]$Id,
        
        [Parameter(ParameterSetName = 'Revisions', 
            Mandatory = $true,
            HelpMessage = 'Get revisions for a given definition (includes lightweight current version')]
        [Switch]$IncludeRevisions,
        
        [Parameter(ParameterSetName = 'Item',
            ValueFromPipelineByPropertyName = $true, 
            HelpMessage = 'Get a specific revision of the build definition (use with Id)')]
        [Int]$Revision,
        
        [Parameter(ParameterSetName = 'Item', 
            HelpMessage = 'Comma delimiated list of properties to return (use with Id)')]
        [String[]]$PropertyFilters,
        
        [Parameter(ParameterSetName = 'IdFilter',
            HelpMessage = 'Include security in the results (for filters)')]
        [Parameter(ParameterSetName = 'GenericFilter')] 
        [Parameter(ParameterSetName = 'ArtifactFilter')] 
        [Switch]$IncludeSecurity,
        
        [Parameter(HelpMessage = 'Cache results to reduce duplication requests')]
        [Switch]$CacheResults
    )
    process {

        Write-Verbose $PSCmdlet.ParameterSetName

        if ($PSCmdlet.ParameterSetName -eq 'Item' -and $PSBoundParameters.ContainsKey('Revision')) {
            $path = "$($Project.id)/_apis/release/definitions/$Id/revisions/$Revision"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Item') {
            $path = "$($Project.id)/_apis/release/definitions/$Id"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Revisions') {
            $path = "$($Project.id)/_apis/release/definitions/$Id/revisions"
        }
        else {
            $path = "$($Project.id)/_apis/release/definitions"
        }

        $query = @()
        if ($PSCmdlet.ParameterSetName -eq 'IdFilter') {            
            if ($PSBoundParameters.ContainsKey('DefinitionIds')) {
                $idList = $DefinitionIds -join ','
                $query += "definitionIdFilter=$idList"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'ArtifactFilter') {
            if ($PSBoundParameters.ContainsKey('ArtifactSourceId') -and $ArtifactSourceId.Length -gt 0) {
                $query += "artifactSourceId=$ArtifactSourceId"
            }
            if ($PSBoundParameters.ContainsKey('ArtifactType') -and $ArtifactType.Length -gt 0) {
                $query += "artifactType=$ArtifactType"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'GenericFilter') {            
            if ($PSBoundParameters.ContainsKey('Name') -and $Name.Length -gt 0) {
                $query += "searchText=$Name"
            }
            if ($ExactMatch){
                $query += "isExactNameMatch=true"
            }
            if ($MatchFolder){
                $query += "searchTextContainsFolderName=true"
            } 
            if ($PSBoundParameters.ContainsKey('TagFilter')) {
                $tagList = $TagFilter -join ','
                $query += "tagFilter=$tagList"
            }
            if ($Deleted){
                $query += 'isDeleted=true'
            }
            if ($PSBoundParameters.ContainsKey('Folder') -and $Folder.Length -gt 0) {
                $query += "path=$Folder"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'IdFilter' -or $PSCmdlet.ParameterSetName -eq 'ArtifactFilter' -or $PSCmdlet.ParameterSetName -eq 'GenericFilter') {
            if ($PSBoundParameters.ContainsKey('QueryOrder')) {
                $query += "queryOrder=$QueryOrder"
            }
        }
        if ($PSBoundParameters.ContainsKey('Expand')) {
            $expandList = $Expand -join ','
            $query += "`$expand=$expandList"
        }
        if ($PSBoundParameters.ContainsKey('PropertyFilters')) {
            $propertyFilterList = $PropertyFilters -join ','
            $query += "propertyFilters=$propertyFilterList"
        }

        if ($PSCmdlet.ParameterSetName -eq 'IdFilter' -or $PSCmdlet.ParameterSetName -eq 'ArtifactFilter' -or $PSCmdlet.ParameterSetName -eq 'GenericFilter') {
            
            if ($IncludeSecurity) {
                
                $securityNamespace = Get-SecurityNamespace -OrgConnection $OrgConnection `
                -NamespaceId 'c788c23e-1b46-4162-8f5e-d7585343b5de'

                $releaseDefinitions = getPagedApiResponse -OrgConnection $OrgConnection `
                    -Path $path -Query $query -CacheResults `
                    -CacheName $MyInvocation.MyCommand.Name
                
                foreach ($releaseDefinition in $releaseDefinitions.value) {

                    $token = "$($Project.Id)/$($releaseDefinition.id)"
                    $acls = Get-Acl -OrgConnection $OrgConnection `
                        -SecurityNamespace $securityNamespace `
                        -SecurityToken $token `
                        -IncludeExtendedInfo -CacheResults
                    $acl = $acls[0]
    
                    if ($null -ne $acl) {
                        $aces = Get-Ace -OrgConnection $OrgConnection `
                            -SecurityNamespace $SecurityNamespace `
                            -Acl $acl
                        appendToAces -ObjectToAppend $releaseDefinition -Aces $aces
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
        elseif ($PSCmdlet.ParameterSetName -eq 'Item' -or $PSCmdlet.ParameterSetName -eq 'Revisions') {
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