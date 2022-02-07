function New-Project {
    <#
    .SYNOPSIS
        Provides access to the Core Projects - Create REST API 
    .DESCRIPTION
        Provides access to the Core Project Create REST API.
    .EXAMPLE
        $processTemplate = Get-ProcessTemplate -OrgConnection $OrgConnection | 
            Where-Object { $PSItem.name -like 'Basic' }
        New-Project -OrgConnection $orgConnection -Name "MyProject" -ProcessTemplate $processTemplate
        Create a project named MyProject with the Basic process template and GIT version control.
    .EXAMPLE
        $processTemplate = Get-ProcessTemplate -OrgConnection $OrgConnection | 
            Where-Object { $PSItem.name -like 'Agile' }
        New-Project -OrgConnection $orgConnection -Name "MyProject" -VersionControlCapability Tfvc  -ProcessTemplate $processTemplate
        Create a project named MyProject with Agile project template and TFVC version control.
    .EXAMPLE
        $processTemplate = Get-ProcessTemplate -OrgConnection $OrgConnection -CacheResults | Where-Object { $PSItem.name -like 'Basic' }
        $newProjectResponse = New-Project -OrgConnection $orgConnection -Name "MyProject" -ProcessTemplate $processTemplate
        do {
            $i += 1
            Write-Progress -Activity "Create in Progress" -PercentComplete $i
            Start-Sleep -Milliseconds 250
            $operationStatus = getApiResponse -OrgConnection $orgConnection -Uri $newProjectResponse.url
            if ($i -eq 100){
                Write-Warning "Project creation didn't complete in a timely manner, manually check status"
            }
        } until ($operationStatus.Status -eq 'Succeeded' -or $i -eq 100)
        Create a project and poll for completion
    .INPUTS
        Version control defaults to GIT
    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES
        Cmdlet does not check if project exists before creating it, assume Azure DevOps will REST API call will fail if project exists.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Reference to Connection object returned from call to Connect-AzureDevOps',
            Position = 0)]
        [Parameter(ParameterSetName = 'Item')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,
    
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Enter the Name of desired project',
            position = 1)]
        [String]$Name,
    
        [Parameter(HelpMessage = 'Enter a description for the project')]
        [String]$Description,
        
        [Parameter(HelpMessage = 'Select the desired version control capability')]
        [ValidateSet('Git', 'Tfvc')]
        [String]$VersionControlCapability = 'Git',
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Select the process template capability')]
        [System.Object]$ProcessTemplate
    )
    process {

        $path = '_apis/projects'
            
        $body = @{
            name         = $Name
            description  = $Description
            capabilities = @{
                versioncontrol  = @{
                    sourceControlType = "$VersionControlCapability"
                }
                processTemplate = @{
                    templateTypeId = "$($ProcessTemplate.id)"
                }
            }
        } | ConvertTo-Json -Depth 3
                
        if ($PSCmdlet.ShouldProcess($Name, "Create Project")) {
            $uri = getApiUri -OrgConnection $OrgConnection -Path $path
            Write-Output (postApiResponse -OrgConnection $OrgConnection `
                    -Uri $uri -Body $body)
        }
    }
}