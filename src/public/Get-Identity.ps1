function Get-Identity {
    <#
    .SYNOPSIS
        Provides access to the Identities Read Identities REST API
    .DESCRIPTION
        Returns the Identity of the provided Descripter
    .EXAMPLE
        Get-Identity -OrgConnection $org -Descriptor 'Microsoft.TeamFoundation.Identity;S-1-9-1551374245-1204400969-2402986413-2179408616-0-0-0-0-1'

        Gets the well-known 'Project Collection Administrators' identity
    .EXAMPLE
        Get-Identity -OrgConnection $org -FilterValue 'Project Collection Valid Users' -SearchFilter General -Verbose

        Gets the well-known 'Project Collection Valid Users' group identity
    .EXAMPLE
        Get-Identity -OrgConnection $org -FilterValue 'Administrator' -SearchFilter DisplayName -Verbose

        Gets all identities named Administrator
    .INPUTS
        OrgConnection can be piped to this cmdlet
    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES
        General notes
    #>
    [CmdletBinding(DefaultParameterSetName = 'Item')]
    param (
        [Parameter(ParameterSetName = 'Item',
            Mandatory = $true,
            HelpMessage = 'Reference to a Connection returned from call to Connect-AzureDevOps')]
        [Parameter(ParameterSetName = 'Search',
            Mandatory = $true)]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,
        
        [Parameter(ParameterSetName = 'Item',
            Mandatory = $true,
            HelpMessage = 'Identity Descriptor')]
        [String]$Descriptor,
        
        [Parameter(ParameterSetName = 'Search',
            Mandatory = $true,
            HelpMessage = 'A value to filter on, use in conjunction with SearchFilter')]
        [String]$FilterValue,
        
        [Parameter(ParameterSetName = 'Search',
            Mandatory = $true,
            HelpMessage = 'A search filter, use in conjunction with FilterValue')]
        [ValidateSet('AccountName', 'DisplayName', 'MailAddress', 'General', 'LocalGroupName')]
        [String]$SearchFilter,
        
        [Parameter(ParameterSetName = 'Item',
            HelpMessage = 'Cache results to reduce duplicate requests')]
        [Parameter(ParameterSetName = 'Search')]
        [Switch]$CacheResults
    )
    process {
        
        $path = "_apis/identities"
        $query = @()
        if ($PSCmdlet.ParameterSetName -eq 'Item') {
            $query += "descriptors=$Descriptor"
        }
        if ($PSCmdlet.ParameterSetName -eq 'Search') {
            $query += "searchFilter=$SearchFilter"
            $query += "filterValue=$FilterValue"
        }
        $uri = getApiUri -OrgConnection $OrgConnection -Path $path -Query $query

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