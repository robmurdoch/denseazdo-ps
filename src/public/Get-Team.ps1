function Get-Team {
    <#
    .SYNOPSIS
        Provides access to the Core -> Teams -> Get Teams REST API 
    .DESCRIPTION
        Gets
    .EXAMPLE

    .INPUTS

    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES

    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true,
            ParameterSetName = 'List',
            HelpMessage = 'Reference to Connection object returned from call to Connect-AzureDevOps')]
        [Parameter(ParameterSetName = 'Item')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,

        [Parameter(ParameterSetName = 'List', 
            Mandatory = $true, 
            ValueFromPipeline = $true, 
            HelpMessage = 'Reference to an object obtained by Get-Project')]
        [Parameter(ParameterSetName = 'Item')]
        [Alias("P", "Proj")]
        [System.Object]$Project,
    
        [Parameter(Mandatory = $true,
            ParameterSetName = 'Item',
            HelpMessage = 'Enter the ID or Name of desired team',
            position = 1)]
        [string]$TeamId,
        
        [Parameter(ParameterSetName = 'List',
            HelpMessage = 'Cache results to reduce duplicate requests')]
        [Parameter(ParameterSetName = 'Item')]
        [Switch]$CacheResults,
        
        [Parameter(ParameterSetName = 'Item',
            HelpMessage = 'Include project capabilities in the results')]
        [Switch]$IncludeTeamDaysOff,
        
        [Parameter(ParameterSetName = 'Item',
            HelpMessage = 'Include project capabilities in the results')]
        [Switch]$IncludeFieldValues,
        
        [Parameter(ParameterSetName = 'Item',
            HelpMessage = 'Include project capabilities in the results')]
        [Switch]$IncludeTeamSettings
    )
    process {

        if ($PSCmdlet.ParameterSetName -eq 'Item' -and $TeamId) {
            $path = "_apis/projects/$($Project.Id)/teams/$TeamId"
            $teamSettingsPath = "$($Project.Id)/$($TeamId)/_apis/work/teamsettings"
            $teamFieldValuesPath = "$($Project.Id)/$($TeamId)/_apis/work/teamsettings/teamfieldvalues"

            $uri = getApiUri -OrgConnection $OrgConnection `
                -Path $path
    
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
    
            if ($IncludeTeamSettings) {
                $uri = getApiUri -OrgConnection $OrgConnection `
                    -Path $teamSettingsPath
    
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
    
            if ($IncludeFieldValues) {
                $uri = getApiUri -OrgConnection $OrgConnection `
                    -Path $teamFieldValuesPath
    
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
        else {
            $path = "_apis/projects/$($Project.Id)/teams"
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