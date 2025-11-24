function Get-Project {
    <#
    .SYNOPSIS
        Provides access to the Core -> Projects -> List and Get REST APIs 
    .DESCRIPTION
        Returns a list of projects or a single project.
        By default the List REST API returns only 100 projects. For organizations (collections) with more than 100 projects, Get-Project will retrieve all projects 100 at a time.
    .EXAMPLE
        $orgUri = 'https://myserver.mydomain.com/myorg'
        $token = '[actual personal access token]'
        Connect-AzureDevOps -OrgUri $orgUri -PersonalAccessToken $token -Verbose |
            Get-Project -OrgConnection $org

        Get all projects in an organization (collection).
    .EXAMPLE
        $orgUri = 'https://myserver.mydomain.com/myorg'
        $token = '[actual personal access token]'
        $org = Connect-AzureDevOps -OrgUri $orgUri -PersonalAccessToken $token

        $global:AzDoPageSizePreference = 2
        Get-Project -OrgConnection $org

        Get all projects in an organization (collection) 2 at a time.
    .EXAMPLE
        Get-Project -OrgConnection $org | 
            Get-Project -OrgConnection $org -CacheResults -IncludeCapabilities | 
            Select-Object -Property "name" -ExpandProperty "Capabilities"
        
        Gets all wellFormed (default) projects in an organization including their capabilities and caching the results, piping them each to output only the project name and Capabilities. 
    .EXAMPLE
        Get-Project -OrgConnection $org -stateFilter all

        Gets all projects regardless of their state (new, deleted, createPending, etc.).
    .EXAMPLE
        Get-Project -OrgConnection $org -stateFilter deleting

        Gets all projects that are currently being deleted. Useful to poll this api after deleting a project to determine when it completes.
    .INPUTS
        OrgConnection can be piped to this Cmdlet
        A Project's ID can be piped to this Cmdlet.
    .OUTPUTS
        The results of Invoke-RestMethod or Invoke-WebMethod. Returns Singletons or Lists with .count and .value) depending on API called.
    .NOTES
        Collection must have at least 1 project that the calling user has permission to read.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(ParameterSetName = 'List',
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Reference to a Connection returned from call to Connect-AzureDevOps')]
        [Parameter(ParameterSetName = 'Item')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,
    
        [Parameter(ParameterSetName = 'Item',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Enter the ID or Name of desired project')]
        [string]$Id,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('all', 'createPending', 'deleted', 'deleting', 'new', 'unchanged', 'wellFormed')]
        [string]$StateFilter = 'wellFormed',
        
        [Parameter(ParameterSetName = 'List',
            HelpMessage = 'Cache results to reduce duplicate requests')]
        [Parameter(ParameterSetName = 'Item')]
        [Switch]$CacheResults,
        
        [Parameter(ParameterSetName = 'Item',
            HelpMessage = 'Include project capabilities in the results')]
        [Switch]$IncludeCapabilities,
        
        [Parameter(ParameterSetName = 'Item',
            HelpMessage = 'Include history in the results')]
        [Switch]$IncludeHistory
    )
    process {

        if ($PSCmdlet.ParameterSetName -eq 'Item') {
            $path = "_apis/projects/$($Id)"
        }
        else {
            $path = '_apis/projects'
        }

        $query = @()
        if ($PSCmdlet.ParameterSetName -eq 'List') {
            if ($StateFilter -ne 'wellFormed') {
                $query += "stateFilter=$StateFilter"
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Item') {
            if ($IncludeCapabilities) {
                $query += "includeCapabilities=true"
            }
            if ($IncludeHistory) {
                $query += "includeHistory=true"
            }
        }
        
        if ($PSCmdlet.ParameterSetName -eq 'List') {
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