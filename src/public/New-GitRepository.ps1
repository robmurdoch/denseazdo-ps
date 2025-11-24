function New-GitRepository {
    <#
    .SYNOPSIS
        Provides access to the Git -> Repositories -> Create REST API 
    .DESCRIPTION
        Creates a new Git reposotiry
    .EXAMPLE
        New-GitRepository -OrgConnection $org -Project $project -Name 'scratch1'

        Create a new Git repository in a given project named Scratch1
    .INPUTS
        Project can be piped to this Cmdlet
    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES

    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Reference to Connection object returned from call to Connect-AzureDevOps')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true, 
            HelpMessage = 'Reference to an object obtained by Get-Project')]
        [Alias("P", "Proj")]
        [System.Object]$Project,
    
        [Parameter(Mandatory = $true,
            HelpMessage = 'Provide a name for the new repository')]
        [string]$Name
    )
    process {

        $path = "$($Project.Id)/_apis/git/repositories"
            
        $body = @{
            name         = $Name
        } | ConvertTo-Json -Depth 2
                
        if ($PSCmdlet.ShouldProcess($Name, "Create Git Repository")) {
            $uri = getApiUri -OrgConnection $OrgConnection -Path $path
            Write-Output (postApiResponse -OrgConnection $OrgConnection `
                    -Uri $uri -Body $body)
        }
    }
}