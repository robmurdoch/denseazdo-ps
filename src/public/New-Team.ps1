function New-Team {
    <#
    .SYNOPSIS
        Provides access to the Core Teams Create REST API 
    .DESCRIPTION
        Use this Cmdlet to create a new Team
    .EXAMPLE
        New-Team -OrgConnection $orgConnection -Project $project -Name 'My Team'

        Create a new team named My Team that is not configured
    .EXAMPLE
        $team = New-Team -OrgConnection $orgConnection -Project $project -Name 'My Team'
            
        $defaultArea = New-ClassificationNode -OrgConnection $OrgConnection `
            -Project $Project -StructureGroup 'Areas' -Name 'My Team'
        $backlogIteration = New-ClassificationNode -OrgConnection $OrgConnection `
            -Project $Project -StructureGroup 'Iterations' -Name 'My Team'
        $defaultIteration = New-ClassificationNode -OrgConnection $OrgConnection `
            -Project $Project -StructureGroup 'Iterations' -ParentPath 'My Team' -Name 'My First Sprint'

        Edit-Team -OrgConnection $OrgConnection -Project $Project -Team $team `
            -TeamField 'System.AreaPath' -DefaultArea $defaultArea                        
        Edit-Team -OrgConnection $OrgConnection -Project $Project -Team $team `
            -BacklogIteration $backlogIteration -DefaultIteration $defaultIteration `
            -WorkingDays 'monday', 'tuesday', 'wednesday', 'thursday' -Verbose

        Create a new team and configure it with new Area, Iteration, and WorkingDays
    .EXAMPLE
        $team = New-Team -OrgConnection $orgConnection -Project $project -Name 'My Team'
            
        $defaultArea = New-ClassificationNode -OrgConnection $OrgConnection `
            -Project $Project -StructureGroup 'Areas' -Name 'My Team'
        $backlogIteration = New-ClassificationNode -OrgConnection $OrgConnection `
            -Project $Project -StructureGroup 'Iterations' -Name 'My Team'

        Edit-Team -OrgConnection $OrgConnection -Project $Project -Team $team `
            -TeamField 'System.AreaPath' -DefaultArea $defaultArea                        
        Edit-Team -OrgConnection $OrgConnection -Project $Project -Team $team `
            -BacklogIteration $backlogIteration -DefaultIterationMacro '@CurrentIteration'
    .EXAMPLE
        $team = New-Team -OrgConnection $orgConnection -Project $project -Name 'A Team'

        Edit-Team -OrgConnection $OrgConnection -Project $Project -Team $team `
            -TeamField 'System.AreaPath' -DefaultArea $defaultArea                        
        Edit-Team -OrgConnection $OrgConnection -Project $Project -Team $team `
            -DefaultIterationMacro '@CurrentIteration' -BugsBehavior 'AsRequirements'

        Create a new team and configure it with new Area, Iteration, and WorkingDays
    .INPUTS
        Organiza
    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES

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
            HelpMessage = 'Reference to an object obtained by Get-Project')]
        [Alias("P", "Proj")]
        [System.Object]$Project,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Enter the Name of desired team')]
        [String]$Name,
        
        [Parameter(HelpMessage = 'Describe the team')]
        [String]$Description = 'Team description'
    )
    process {

        $path = "_apis/projects/$($Project.Id)/teams"

        $team = @{
            name        = $Name
            description = $Description
        }
        $body = $team | ConvertTo-Json -Depth 3
                
        if ($PSCmdlet.ShouldProcess($Name, "Create team")) {
            $uri = getApiUri -OrgConnection $OrgConnection -Path $path
            Write-Output (postApiResponse -OrgConnection $OrgConnection `
                -Uri $uri -Body $body)
        }
    }
}