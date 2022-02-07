function Get-TfvcChangeset {
    <#
    .SYNOPSIS
        Provides access to the ... REST API
    .DESCRIPTION

    .EXAMPLE

    .INPUTS

    .OUTPUTS

    .NOTES

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Reference to Connection object obtained from Connect-AzureDevOps')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,

        [Parameter(Mandatory = $true, 
            HelpMessage = 'Reference to an object obtained by Get-Project')]
        [Alias("P", "Proj")]
        [System.Object]$Project,

        [Switch]$CacheResults
    )
    process {
        
        $path = "$($Project.id)/_apis/tfvc/changesets"

        $uri = getApiUri -OrgConnection $OrgConnection -Path $path

        if ($CacheResults){
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