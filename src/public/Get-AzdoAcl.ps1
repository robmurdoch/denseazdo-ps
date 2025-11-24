function Get-AzDoAcl {
    <#
    .SYNOPSIS
        Provides access to the older Security Access Control Lists service's Query api. 
    .DESCRIPTION
        Returns list of ACL objects for the security namespace and token 
    .EXAMPLE
        Get-AzDoAcl -OrgConnection $org -SecurityNamespace (Get-SecurityNamespace -OrgConnection $org -NamespaceId 'a39371cf-0841-4c16-bbd3-276e341bc052' -Verbose)

        Returns the Acl(s) in the given SecurityNamespace. Note this works only for namespaces at the Org level that don't require token, e.g. TFVC.
    .EXAMPLE
        $sn = Get-SecurityNamespace -OrgConnection $org -NamespaceId 'c788c23e-1b46-4162-8f5e-d7585343b5de' -Verbose
        $project = Get-Project -OrgConnection $org -Verbose | Select-Object -First 1
        Get-AzDoAcl -OrgConnection $org -SecurityNamespace $sn -SecurityToken $($project.id) -Verbose

        Returns the Acl(s) for the root node of the ReleaseManagement security namespace in the first project in the collection.
    .INPUTS
        None. You cannot pipe objects to Get-AzDoAcl.
    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES
        
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Reference to Connection object obtained from Connect-AzureDevOps')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Reference to SecurityNamespace obtained from Get-SecurityNamespace')]
        [System.Object]$SecurityNamespace,

        [Parameter(HelpMessage = 'Security Token appropriate for the Acl desired')]
        [String]$SecurityToken,

        [Switch]$Recurse,
        [Switch]$IncludeExtendedInfo,
        [Switch]$CacheResults
    )
    process {

        $path = "_apis/accesscontrollists/$($SecurityNamespace.namespaceId)"
        
        $query = @()
        if ($SecurityToken) {
            $query += "token=$SecurityToken"
        }
        if ($Recurse) {
            $query += "recurse=true"
        }
        if ($IncludeExtendedInfo) {
            $query += "IncludeExtendedInfo=true"
        }
        
        $uri = getApiUri -OrgConnection $OrgConnection -Path $path -Query $query

        if ($CacheResults){
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