function Get-ProcessTemplate {
    <#
    .SYNOPSIS
        Provides access to the Core -> Processs -> List and Get REST APIs.
    .DESCRIPTION        
        Returns list of processes configured in the organization.
    .EXAMPLE
        Get-ProcessTemplate -OrgConnection $org

        Get all process templates in an organization (collection).
    .EXAMPLE
        Get-ProcessTemplate -OrgConnection $org -Id '27450541-8e31-4150-9947-dc59f998fc01' -Verbose

        Get a specific process templates by id within an organization (collection).
    .INPUTS
        OrgConnection can be piped to this cmdlet
    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES
          
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(ParameterSetName = 'List',
            Mandatory = $true,
            ValueFromPipeline = $true,            
            HelpMessage = 'Reference to Connection object returned from call to Connect-AzureDevOps')]
            [Parameter(ParameterSetName = 'Item')]
            [Alias("O","Org")]
            [System.Object]$OrgConnection,
    
            [Parameter(ParameterSetName = 'Item',
                Mandatory = $true,
                ValueFromPipelineByPropertyName = $true,
                HelpMessage = 'Enter the ID or Name of desired process')]
            [string]$Id,
        
            [Parameter(ParameterSetName = 'List',
                HelpMessage = 'Cache results to reduce duplicate requests')]
            [Parameter(ParameterSetName = 'Item')]
            [Switch]$CacheResults
    )
    process {

        if ($PSBoundParameters.ContainsKey('Id') -and $Id.Length -gt 0) {
            $path = "_apis/process/processes/$Id"
        }
        else {
            $path = '_apis/process/processes'
        }
        $uri = getApiUri -OrgConnection $OrgConnection `
            -Path $path
        
        if ($PSCmdlet.ParameterSetName -eq 'List') {
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
        elseif ($PSCmdlet.ParameterSetName -eq 'Item') {
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