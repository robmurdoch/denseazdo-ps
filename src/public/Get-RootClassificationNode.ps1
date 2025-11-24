function Get-RootClassificationNode {
    <#
    .SYNOPSIS
        Provides access to the Work Item Tracking -> Classification Nodes -> Get Root Nodes REST API
    .DESCRIPTION
        Get a project's Root Iteration or Area Classification Node
    .EXAMPLE
        Get-RootClassificationNode -OrgConnection $org -Project $project -Node 'Iteration'

        Get the Root Iteration Node for a given Project.
    .EXAMPLE
        Get-RootClassificationNode -OrgConnection $org -Project $project -Node 'Area'

        Get the Root Area Node for a given Project.
    .INPUTS
        Org Connection can be piped to this Cmdlet
    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES
        This cmdlet caches results because get-area classification nodes don't change often.
    #>
    [CmdletBinding()]
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

        [Parameter(HelpMessage = 'Node to retrieve (Iteration or Area)')]
        [ValidateSet('Iteration', 'Area')]
        [String]$StructureType
    )
    process {

        $path = "$($Project.id)/_apis/wit/classificationnodes"

        $uri = getApiUri -OrgConnection $OrgConnection -Path $path

        Write-Output (getApiResponse -OrgConnection $OrgConnection `
            -Uri $uri -CacheResults `
            -CacheName $MyInvocation.MyCommand.Name).value | 
            Where-Object { $PSItem.structureType -like $StructureType }
    }
}
