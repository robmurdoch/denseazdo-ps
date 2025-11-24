function Get-GitRepository {
    <#
    .SYNOPSIS
        Provides access to the Git -> Repositories -> List, Get Repository, Get Deleted Repositories, Get Recycle Bin Repositories, and Get Repository With Parent REST API 
    .DESCRIPTION
        Gets a list of Git repositories or a single Git repository
    .EXAMPLE
        Get-GitRepository -OrgConnection $org -Project $project -Verbose

        Get all repositories in a project with verbose output
    .EXAMPLE
        Get-GitRepository -OrgConnection $org -Project $project -includeAllUrls

        Get all repositories in a project all urls are included in the results
    .EXAMPLE
        Get-GitRepository -OrgConnection $org -Project $project -includeHidden

        Get all repositories in a project including hidden ones
    .EXAMPLE
        Get-GitRepository -OrgConnection $org -Project $project -includeLinks | Select-Object -ExpandProperty _links

        Get a list of links for all repositories in a project
    .EXAMPLE
        Get-GitRepository -OrgConnection $org -Project $project -repositoryid 'NetCoreSln' -includeParent 

        Get the repository named NetCoreSln including the parent project
    .EXAMPLE
        Get-GitRepository -OrgConnection $org -Project $project -listRecycled

        Get all repositories in a project that are in the recycle bin
    .EXAMPLE
        Get-GitRepository -OrgConnection $org -Project $project -listDeleted

        Get all repositories in a project that have been deleted
    .INPUTS

    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES
        Currently does not support Projects with more than 100 repositories
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(ParameterSetName = 'List',
            Mandatory = $true,
            HelpMessage = 'Reference to Connection object returned from call to Connect-AzureDevOps')]
        [Parameter(ParameterSetName = 'Item')]
        [Parameter(ParameterSetName = 'ListRecycled')]
        [Parameter(ParameterSetName = 'ListDeleted')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,

        [Parameter(ParameterSetName = 'List',
            Mandatory = $true,
            ValueFromPipeline = $true, 
            HelpMessage = 'Reference to an object obtained by Get-Project')]
        [Parameter(ParameterSetName = 'Item')]
        [Parameter(ParameterSetName = 'ListRecycled')]
        [Parameter(ParameterSetName = 'ListDeleted')]
        [Alias("P", "Proj")]
        [System.Object]$Project,
    
        [Parameter(ParameterSetName = 'List',
            HelpMessage = 'Include all remote urls')]
        [Switch]$includeAllUrls,
    
        [Parameter(ParameterSetName = 'List',
            HelpMessage = 'Include hidden repositories')]
        [Switch]$includeHidden,
    
        [Parameter(ParameterSetName = 'List',
            HelpMessage = 'Include reference links')]
        [Switch]$includeLinks,
    
        [Parameter(ParameterSetName = 'ListRecycled',
            Mandatory = $true,
            HelpMessage = 'List only recycled repositories')]
        [Switch]$listRecycled,
    
        [Parameter(ParameterSetName = 'ListDeleted',
            Mandatory = $true,
            HelpMessage = 'List only deleted repositories')]
        [Switch]$listDeleted,
    
        [Parameter(ParameterSetName = 'Item',
            Mandatory = $true,            
            HelpMessage = 'Enter the ID or Name of desired repository')]
        [string]$RepositoryId,
    
        [Parameter(ParameterSetName = 'Item',
            HelpMessage = 'Include parent')]
        [Switch]$includeParent,
        
        [Parameter(ParameterSetName = 'List',
            HelpMessage = 'Cache results to reduce duplicate requests')]
        [Parameter(ParameterSetName = 'Item')]
        [Parameter(ParameterSetName = 'ListRecycled')]
        [Parameter(ParameterSetName = 'ListDeleted')]
        [Switch]$CacheResults
    )
    process {

        $query = @()

        if ($PSCmdlet.ParameterSetName -eq 'List') {

            $path = "$($Project.Id)/_apis/git/repositories"

            if ($includeAllUrls) {
                $query += "includeAllUrls=true"
            }
            if ($includeHidden) {
                $query += "includeHidden=true"
            }
            if ($includeLinks) {
                $query += "includeLinks=true"
            }

            $uri = getApiUri -OrgConnection $OrgConnection `
                -Path $path -Query $query
            Write-Verbose $uri

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

            $path = "$($Project.Id)/_apis/git/repositories/$RepositoryId"

            if ($includeAllUrls) {
                $query += "includeParent=true"
            }

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
        elseif ($PSCmdlet.ParameterSetName -eq 'ListRecycled') {
            if (testApiVersion -OrgConnection $OrgConnection -ApiVersion "api-version=7.0" -Feature 'listRecycled') {
                $path = "$($Project.Id)/_apis/git/recycleBin/repositories"
    
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
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ListDeleted') {
            if (testApiVersion -OrgConnection $OrgConnection -ApiVersion 'api-version=7.0' -Feature 'listDeleted') {
                $path = "$($Project.Id)/_apis/git/deletedrepositories"

                $uri = getApiUri -OrgConnection $OrgConnection `
                    -Path $path

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
        }
    }
}