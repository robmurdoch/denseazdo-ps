function Get-SecurityNamespace {
    <#
    .SYNOPSIS
        Provides access to the Security service's SecurityNamespace Query api.
    .DESCRIPTION        
        Returns list of SecurityNamespace objects for the organization.
        SecurityNamespaces are needed to query object security.
    .EXAMPLE
        (Get-SecurityNamespace -OrgConnection $org).value
        Returns list of SecurityNamespace objects
    .INPUTS
        OrgConnection can be piped to this cmdlet
    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES
        This cmdlet caches results because root nodes cannot change.  
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Reference to Connection object returned from call to Connect-AzureDevOps')]
            [Alias("O","Org")]
            [System.Object]$OrgConnection
    )
    process {

        $path = '_apis/securitynamespaces'

        $uri = getApiUri -OrgConnection $OrgConnection -Path $path

        Write-Output (getApiResponse -OrgConnection $OrgConnection `
            -Uri $uri -CacheResults `
            -CacheName $MyInvocation.MyCommand.Name).value
    }
}