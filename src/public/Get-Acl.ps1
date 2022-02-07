function Get-Acl {
    <#
    .SYNOPSIS
        Provides access to the older Security Access Control Lists service's Query api. 
    .DESCRIPTION
        Returns list of ACL objects for the security namespace and token 
    .EXAMPLE
        Get-Acl -OrgConnection $org -SecurityNamespace $sn
        Returns the Acl for the given SecurityToken in the given SecurityNamespace
    .EXAMPLE
        Get-Acl -OrgConnection $org -SecurityNamespace $sn $SecurityToken $t
        Returns the Acl for the given SecurityToken in the given SecurityNamespace
    .EXAMPLE
        Get-Acl -OrgConnection $org -SecurityNamespace $sn $SecurityToken $t -Recurse
        Returns all of the Acl for the given SecurityToken in the given SecurityNamespace recursively
    .EXAMPLE
        Get-Acl -OrgConnection $org -SecurityNamespace $sn $SecurityToken $t -IncludeExtendedInfo
        Returns the Acl for the given SecurityToken in the given SecurityNamespace and includes the Effective permissions
    .INPUTS
        None. You cannot pipe objects to Get-Acl.
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

        [Parameter(HelpMessage = 'Security descriptors to filter the results')]
        [String]$Descriptors,

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