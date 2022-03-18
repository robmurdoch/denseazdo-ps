function Get-Tfvc {
    <#
    .SYNOPSIS
        Provides access to the Tfvc - List rest api
    .DESCRIPTION
        Providing various parameters allows one to retrieve specific changesets, recurse, oneLevel, previous changeset, and scoped paths
    .EXAMPLE
        Get-Tfvc -OrgConnection $OrgConnection -Project $project 

        Gets the project's root files/folders and direct descendents
    .EXAMPLE
        Get-Tfvc -OrgConnection $OrgConnection -Project $project -RecursionLevel 'oneLevel'

        Gets the project's root files/folders and direct descendents
    .EXAMPLE
        Get-Tfvc -OrgConnection $OrgConnection -Project $project -ScopePath '$/Scratch/Hidden'

        Gets the Hidden files/folders and direct descendents
    .EXAMPLE
        Get-Tfvc -OrgConnection $OrgConnection -Project $project -Version 2

        Gets the files/folders that existed as of changeset 2
    .EXAMPLE
        Get-Tfvc -OrgConnection $OrgConnection -Project $project -ScopePath '$/Scratch/Hidden/some.js' -Version 10 -VersionOption previous -VersionType 'changeset'

        Gets the some.js file prior to changeset 10
    .EXAMPLE
        Get-Tfvc -OrgConnection $OrgConnection -Project $project -ScopePath '$/Scratch/Hidden' -Version 9 -VersionType 'changeset'

        Gets the Hidden folder's files as of changeset 9
    .EXAMPLE
        # Get-Tfvc -OrgConnection $OrgConnection -Project $project -IncludeSecurity |
        # Select-Object 'path','isFolder', 'identity','inheritPermissions','Administer labels','Check in','Check in other users'' changes','Label','Lock','Manage branch','Manage permissions','Merge','Pend a change in a server workspace','Read','Revise other users'' changes','Undo other users'' changes','Unlock other users'' changes' |
        # Export-Csv "$Env:USERPROFILE\Downloads\Tfvc.csv"

        Get the tfvc security for all nodes that have unique security settings and writes the output to csv. Note: this excludes nodes that only inherit permission.
    .INPUTS
        Project can be piped to this cmdlet
    .OUTPUTS
        The results of Invoke-RestMethod for the various query options, IncludeSecurity returns custom objects
    .NOTES
        ToDo update this to retrieve a single Tfvc Item using the Get api
        ToDo update this to retrieve security information
    #>
    [CmdletBinding(DefaultParameterSetName = 'Latest')]
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
        
        [Parameter(ParameterSetName = 'Latest', 
            HelpMessage = 'Path to location from root; e.g. $/Scratch/DenseAzdoPs')]
        [Parameter(ParameterSetName = 'Version')]
        [String]$ScopePath,

        [Parameter(ParameterSetName = 'Latest', 
            HelpMessage = 'Version control recursion type; none, full (all descendents),oneLevel, oneLevelPlusNestedEmptyFolders(See AzDo Docs)')]
        [ValidateSet('Full', 'None', 'OneLevel', 'OneLevelPlusNestedEmptyFolders')]
        [Parameter(ParameterSetName = 'Security')]
        [String]$RecursionLevel,

        [Parameter(ParameterSetName = 'Latest', 
            HelpMessage = 'Include links to contents')]
        [Switch]$IncludeLinks,

        [Parameter(ParameterSetName = 'Version', 
            HelpMessage = 'Numeric version? See AzDo Docs')]
        [Int]$Version,

        [Parameter(ParameterSetName = 'Version', 
            HelpMessage = 'See AzDo Docs')]
        [ValidateSet('none', 'previous', 'useRename')]
        [String]$VersionOption,

        [Parameter(ParameterSetName = 'Version', 
            HelpMessage = 'See AzDo Docs')]
        [ValidateSet('change', 'changeset', 'date', 'latest', 'mergeSource', 'none', 'shelveset', 'tip')]
        [String]$VersionType,
        
        [Parameter(ParameterSetName = 'Security', 
            HelpMessage = 'Include security in the results')]
        [Switch]$IncludeSecurity,

        [Parameter(ParameterSetName = 'Latest', 
            HelpMessage = 'Cache results to reduce duplication requests')]
        [Parameter(ParameterSetName = 'Version')]
        [Switch]$CacheResults
    )
    process {

        Write-Verbose $PSCmdlet.ParameterSetName 
        $path = "$($Project.id)/_apis/tfvc/items"

        $query = @()

        if (-not $ScopePath){
            $ScopePath = "$/$($Project.name)"
        }
        $query += "scopePath=$ScopePath"
        if (-not $RecursionLevel){
            $RecursionLevel = 'None'
        }
        $query += "recursionLevel=$RecursionLevel"

        if ($IncludeLinks) {
            $query += 'includeLinks=true'
        }
        if ($Version) {
            $query += "versionDescriptor.version=$Version"
        }
        if ($VersionOption) {
            $query += "versionDescriptor.versionOption=$VersionOption"
        }
        if ($VersionType) {
            $query += "versionDescriptor.versionType=$VersionType"
        }

        if ($PSCmdlet.ParameterSetName -eq 'Security' -and $IncludeSecurity) {

            $securityNamespace = Get-SecurityNamespace -OrgConnection $OrgConnection `
                -NamespaceId 'a39371cf-0841-4c16-bbd3-276e341bc052'
    
            $rootSecurityToken = "$/$($project.name)"

            $acls = Get-Acl -OrgConnection $OrgConnection `
                -SecurityNamespace $securityNamespace `
                -SecurityToken $rootSecurityToken `
                -Recurse -IncludeExtendedInfo -CacheResults
    
            $slashCount = ($ScopePath.ToCharArray() | Where-Object { $_ -eq '/' } | Measure-Object).Count

            recurseTfvcNode -OrgConnection $OrgConnection `
                -Project $Project `
                -ScopePath $ScopePath `
                -RecursionLevel $RecursionLevel `
                -Level $slashCount `
                -Acls $acls `
                -SecurityNamespace $securityNamespace `
                -includeSecurity
        } 
        else {
            $uri = getApiUri -OrgConnection $OrgConnection -Path $path -Query $query

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