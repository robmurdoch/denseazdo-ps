function Get-ProcessTemplate {
    <#
    .SYNOPSIS
        Provides access to the Core Processs List and Get REST API.
    .DESCRIPTION        
        Returns list of processes configured in the organization.
    .EXAMPLE
        
    .INPUTS
        OrgConnection can be piped to this cmdlet
    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES
          
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = 'List',
            HelpMessage = 'Reference to Connection object returned from call to Connect-AzureDevOps')]
            [Parameter(ParameterSetName = 'Item')]
            [Alias("O","Org")]
            [System.Object]$OrgConnection,
    
            [Parameter(Mandatory = $true,
                ValueFromPipelineByPropertyName = $true,
                ParameterSetName = 'Item',
                HelpMessage = 'Enter the ID or Name of desired process')]
            [string]$Id,
        
            [Parameter(ParameterSetName = 'List',
                HelpMessage = 'Cache results to reduce duplicate requests')]
            [Parameter(ParameterSetName = 'Item')]
            [Switch]$CacheResults
    )
    process {

        if ($PSBoundParameters.ContainsKey('Id') -and $Id.Length -gt 0) {
            $path = '_apis/process/processes/$($Id)'
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