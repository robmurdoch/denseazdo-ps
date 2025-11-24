function Edit-Team {
    <#
    .SYNOPSIS
        Provides access to the ... REST API 
    .DESCRIPTION

    .EXAMPLE

    .INPUTS

    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES

    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'TeamField')]
    param (
        [Parameter(ParameterSetName = 'TeamField',
            Mandatory = $true,
            HelpMessage = 'Reference to Connection object returned from call to Connect-AzureDevOps')]
        [Parameter(ParameterSetName = 'Team Settings')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,

        [Parameter(ParameterSetName = 'TeamField',
            Mandatory = $true, 
            HelpMessage = 'Reference to an object obtained by Get-Project')]
        [Alias("P", "Proj")]
        [Parameter(ParameterSetName = 'Team Settings')]
        [System.Object]$Project,

        [Parameter(ParameterSetName = 'TeamField',
            Mandatory = $true, 
            HelpMessage = 'Reference to an object obtained by Get-Team')]
        [Parameter(ParameterSetName = 'Team Settings')]
        [System.Object]$Team,

        [Parameter(ParameterSetName = 'TeamField',
            Mandatory = $true, 
            HelpMessage = 'Reference to an object obtained by Get-Team')]
        [String]$TeamField,
        
        [Parameter(ParameterSetName = 'TeamField',
            Mandatory = $true, 
            HelpMessage = 'Default Area for the team')]
        [System.Object]$DefaultArea,
        
        [Parameter(ParameterSetName = 'Team Settings',
            HelpMessage = 'Backlog Iteration for the team')]
        [ValidateSet('AsTasks', 'AsRequirements', 'off')]
        [String]$BugsBehavior,
        
        [Parameter(ParameterSetName = 'Team Settings',
            HelpMessage = 'E.g. @CurrentIteration')]
        [String]$DefaultIterationMacro,
        
        [Parameter(ParameterSetName = 'Team Settings',
            HelpMessage = 'Backlog Iteration for the team')]
        [System.Object]$BacklogIteration,
        
        [Parameter(ParameterSetName = 'Team Settings',
            HelpMessage = 'Default Iteration for the team')]
        [System.Object]$DefaultIteration,
        
        [Parameter(ParameterSetName = 'Team Settings',
            HelpMessage = 'Array of day names (monday, tuesday, etc.')]
        [String[]]$WorkingDays
    )
    process {

        if ($PSCmdlet.ParameterSetName -eq 'TeamField' -and $TeamField -and $DefaultArea ) {
            $path = "$($Project.Id)/$($Team.Id)/_apis/work/teamsettings/teamfieldvalues"

            $defaultValue = "$($DefaultArea.path)".Replace('\Area', '')
            $payload = @{
                field        = @{
                    referenceName = $TeamField
                }
                defaultValue = $defaultValue
                values       = @(
                    @{
                        value           = $defaultValue
                        includeChildren = $true
                    }
                )
            }
            $body = $payload | ConvertTo-Json -Depth 3
        }

        if ($PSCmdlet.ParameterSetName -eq 'Team Settings' -and ($BacklogIteration -or $DefaultIteration -or $WorkingDays -or $BugsBehavior)) {
            $path = "$($Project.Id)/$($Team.Id)/_apis/work/teamsettings"

            $payload = @{}
            if ($BacklogIteration) {
                $payload.backlogIteration = $BacklogIteration.identifier
            }
            if ($DefaultIteration) {
                $payload.defaultIteration = $DefaultIteration.identifier
            }
            if ($WorkingDays) {
                $payload.workingDays = $WorkingDays
            }
            if ($BugsBehavior) {
                $payload.bugsBehavior = $BugsBehavior
            }
            if ($DefaultIterationMacro) {
                $payload.defaultIterationMacro = $DefaultIterationMacro
            }
            # $teamSettings
            $body = $payload | ConvertTo-Json -Depth 3
        }
        
        if ($PSCmdlet.ShouldProcess($Name, "Edit Team")) {
            $uri = getApiUri -OrgConnection $OrgConnection -Path $path
            Write-Output (patchApiResponse -OrgConnection $OrgConnection `
                    -Uri $uri -Body $body)
        }
    }
}