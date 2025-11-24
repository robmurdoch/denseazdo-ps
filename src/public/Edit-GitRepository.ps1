function Edit-GitRepository {
    <#
    .SYNOPSIS
        Provides access to the Git -> Repositories -> Update REST API 
    .DESCRIPTION
        Edit a Git repository
    .EXAMPLE
        $repo = Get-GitRepository -OrgConnection $org -Project $project -RepositoryId 'MyRepo'
        Edit-GitRepository -OrgConnection $org -Project $project -GitRepository $repo -Name 'RenamedRepo' -DefaultBranch 'refs/heads/Feature'

        Renames a Git repo from MyRepo to RenamedRepo and changes the Default branch to Feature
    .INPUTS

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

        [Parameter(HelpMessage = 'Reference to an object obtained by Get-Project')]
        [Alias("P", "Proj")]
        [System.Object]$Project,

        [Parameter(Mandatory = $true, 
            HelpMessage = 'Reference to an object obtained by Get-GitRepository')]
        [System.Object]$GitRepository,

        [Parameter(HelpMessage = 'Name')]
        [string]$Name,

        [Parameter(HelpMessage = 'Default branch in the form of refs/heads/[branch]')]
        [string]$DefaultBranch
    )
    process {

        if ($Project) {
            $path = "$($Project.Id)/_apis/git/repositories/$($GitRepository.id)"
        }
        else {
            $path = "_apis/git/repositories/$($GitRepository.id)"
        }
        
        if ($Name -and $DefaultBranch) {
            $payload = @{
                name      = $Name
                defaultBranch = $DefaultBranch
            }
        } 
        elseif ($Name) {
            $payload = @{
                name = $Name
            }
        }
        elseif ($DefaultBranch) {
            $payload = @{
                defaultBranch = $DefaultBranch
            }
        }

        if ($payload){
            $body = $payload | ConvertTo-Json -Depth 2
        
            if ($PSCmdlet.ShouldProcess($Name, "Edit Git repository")) {
                $uri = getApiUri -OrgConnection $OrgConnection -Path $path
                Write-Output (patchApiResponse -OrgConnection $OrgConnection `
                        -Uri $uri -Body $body)
            }
        }
    }
}