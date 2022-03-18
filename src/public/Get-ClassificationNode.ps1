function Get-ClassificationNode {
    <#
    .SYNOPSIS
        Provides access to Work Item Tracking -> Classification Nodes -> Get REST API
    .DESCRIPTION
        Get a list of Iterations or Areas. 
    .EXAMPLE
        $org = Connect-AzureDevOps -OrgUri 'https://azdo1.experiment.net/defaultcollection'
        $project = Get-Project -OrgConnection $org | Where-Object { $PSItem.name -eq 'Scratch' }
        Get-ClassificationNode -OrgConnection $org -Project $project -StructureGroup 'iterations' -IncludeSecurity -Depth 10 | 
            Select-Object "url","structureType","path","id","identifier","name","hasChildren","Identity","InheritPermissions","Create child nodes","Delete this node","Edit this node","Edit work items in this node","Manage test plans","Manage test suites","View permissions for this node","View work items in this node" |
            Export-Csv "$Env:USERPROFILE\Downloads\$($project.name)-iterations.csv"

        Esablish a connection to an Azure DevOps organization, get a Project, then export iterations with Security to a CSV file.
    .EXAMPLE
        Get-ClassificationNode -OrgConnection $orgConnection -Project $project  -StructureGroup 'areas' -Node 'windows team' -Depth 10 

        Get the Windows Team Area and all of its children
    .EXAMPLE
        Get-ClassificationNode -OrgConnection $orgConnection -Project $project  -StructureGroup 'iterations' -Ids 9

        Get the Iteration with Id 9 and none of its children
    .INPUTS
        Project can be piped to this cmdlet
    .OUTPUTS
        The results of Invoke-RestMethod for Ids and Nodes, IncludeSecurity returns custom objects
    .NOTES
        To retrieve Root Classification Nodes call Get-RootClassificationNodes instead.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Node')]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Reference to a Connection returned from call to Connect-AzureDevOps')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Reference to a Project returned from call to Get-Project Cmdlet')]
        [Alias("P", "Proj")]
        [System.Object]$Project,

        [Parameter(ParameterSetName = 'Node', 
            Mandatory = $true, 
            HelpMessage = 'Reference to an object obtained by Get-Project')]
        [Parameter(ParameterSetName = 'Security', 
            Mandatory = $true)]
        [ValidateSet("areas", "iterations")]
        [String]$StructureGroup,

        [Parameter(ParameterSetName = 'Node', 
            HelpMessage = 'Depth within the tree of nodes to fetch')]
        [Parameter(ParameterSetName = 'IDs')]
        [Parameter(ParameterSetName = 'Security')]
        [Int]$Depth = 0,

        [Parameter(ParameterSetName = 'Node', 
            HelpMessage = 'Path of a given node to return, e.g. rootNode/childNode/grandChildNode/...')]
        [String]$Node,

        [Parameter(ParameterSetName = 'IDs', 
            Mandatory = $true,
            HelpMessage = 'List of Ids to return, e.g. 1,2,3')]
        [Int[]]$Ids,
        
        [Parameter(ParameterSetName = 'Security', 
            HelpMessage = 'Include security in the results')]
        [Switch]$IncludeSecurity,
        
        [Parameter(HelpMessage = 'Cache results to reduce duplication requests')]
        [Switch]$CacheResults
    )
    process {

        if ($PSCmdlet.ParameterSetName -eq 'IDs' -and $PSBoundParameters.ContainsKey('Ids') -and $IDs.Count -gt 0) {
            $path = "$($Project.id)/_apis/wit/classificationnodes"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Node' -and $PSBoundParameters.ContainsKey('Node') -and $Node.Length -gt 0) {
            $path = "$($Project.id)/_apis/wit/classificationnodes/$StructureGroup/$Node"
        }
        else {
            $path = "$($Project.id)/_apis/wit/classificationnodes/$StructureGroup"
        }

        $query = @()
        if ($PSCmdlet.ParameterSetName -eq 'IDs' -and $PSBoundParameters.ContainsKey('Ids') -and $Ids.Count -gt 0) {
            $query += "ids=$Ids"
        }
        if ($Depth) {
            $query += "`$depth=$Depth"
        }

        $uri = getApiUri -OrgConnection $OrgConnection `
            -Path $path -Query $query
        
        if ($PSCmdlet.ParameterSetName -eq 'Security' -and $IncludeSecurity) {
    
            if ($StructureGroup -eq 'areas') {
                $rootNode = Get-RootClassificationNode -OrgConnection $OrgConnection `
                    -Project $Project -StructureType 'Area'
                $securityNamespace = Get-SecurityNamespace -OrgConnection $OrgConnection `
                    -NamespaceId '83e28ad4-2d72-4ceb-97b0-c7726d5502c3'    
            }
            else {
                $rootNode = Get-RootClassificationNode -OrgConnection $OrgConnection `
                    -Project $Project -StructureType 'Iteration'
                $securityNamespace = Get-SecurityNamespace -OrgConnection $OrgConnection `
                    -NamespaceId 'bf7bfa03-b2b7-47db-8113-fa2e002cc5b1'
            }
            
            $rootSecurityToken = "vstfs:///Classification/Node/$($rootNode.identifier)"

            $acls = Get-Acl -OrgConnection $OrgConnection `
                -SecurityNamespace $securityNamespace `
                -SecurityToken $rootSecurityToken `
                -Recurse -IncludeExtendedInfo -CacheResults
    
            if ($CacheResults) {
                $nodes = getApiResponse -OrgConnection $OrgConnection `
                    -Uri $uri -CacheResults `
                    -CacheName $MyInvocation.MyCommand.Name
            }
            else {
                $nodes = getApiResponse -OrgConnection $OrgConnection `
                    -Uri $uri `
                    -CacheName $MyInvocation.MyCommand.Name
            }

            recurseClassificationNode -OrgConnection $OrgConnection `
                -SecurityNamespace $SecurityNamespace `
                -ClassificationNodes $nodes `
                -Acls $acls
        } 
        else {
            if ($PSCmdlet.ParameterSetName -eq 'IDs' -and $PSBoundParameters.ContainsKey('Ids') -and $Ids.Count -gt 0) {
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
            elseif ($PSCmdlet.ParameterSetName -eq 'Node' -and $PSBoundParameters.ContainsKey('Node') -and $Node.Length -gt 0) {
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
}
