function recurseTfvcNode {

    [CmdletBinding(DefaultParameterSetName = 'Latest')]
    param (
        [System.Object]$OrgConnection,
        [System.Object]$Project,
        [String]$ScopePath,
        [String]$RecursionLevel,
        [String]$Level,
        [System.Object]$Acls,
        [System.Object]$SecurityNamespace,
        [Switch]$IncludeSecurity
    )
    process {
    
        $path = "$($Project.id)/_apis/tfvc/items"

        $query = @()
        $query += "scopePath=$ScopePath"        
        $query += "recursionLevel=$RecursionLevel"
        
        $uri = getApiUri -OrgConnection $OrgConnection `
            -Path $path -Query $query
        
        try {
            $reqursionLevelOverride = $null
            $tfvcNodes = getApiResponse -OrgConnection $OrgConnection `
                -Uri $uri `
                -CacheName $MyInvocation.MyCommand.Name
        }
        catch {

            # For large TFVC repos with many levels and Full recursion, TFS2018 errors
            # This solution overrides Full recursion to OneLevel then attempts to recurses children
            Write-Warning "Error retrieving $uri, retrying with OneLevel"
            $reqursionLevelOverride = 'OneLevel'
            
            $query = @()
            $query += "scopePath=$ScopePath"
            $query += "recursionLevel=$reqursionLevelOverride"

            try {
                $tfvcNodes = getApiResponse -OrgConnection $OrgConnection `
                    -Uri $uri `
                    -CacheName $MyInvocation.MyCommand.Name
            }
            catch {
                Write-Error "Error retrieving $uri, giving up"
            }
        }
    
        foreach ($node in $tfvcNodes.value) {
    
            $token = "$($node.path)"
            $acl = $acls | Where-Object { $PSItem.token -eq $token }
            if ($null -ne $acl) {
                $aces = Get-Ace -OrgConnection $OrgConnection `
                    -SecurityNamespace $SecurityNamespace `
                    -Acl $acl
                appendToAces -ObjectToAppend $node -Aces $aces
            }
            else {
                # If files only inheriting permissions (typical), ACLs are not returned
                Write-Output $node
            }

            if ($node.IsFolder -and $node.path -ne $ScopePath) {
                if ($recursionLevelOveride) {
                    Write-Warning "Returning to RecursionLevel $RecursionLevel"
                    if ($IncludeSecurity) {
                        recurseTfvcNode -OrgConnection $OrgConnection `
                            -Project $Project `
                            -ScopePath $node.path `
                            -RecursionLevel $RecursionLevel `
                            -Level ($Level + 1) `
                            -Acls $acls `
                            -SecurityNamespace $securityNamespace `
                            -IncludeSecurity
                    }
                    else {
                        recurseTfvcNode -OrgConnection $OrgConnection `
                            -Project $Project `
                            -ScopePath $node.path `
                            -RecursionLevel $RecursionLevel `
                            -Level ($Level + 1) `
                            -Acls $acls `
                            -SecurityNamespace $securityNamespace
                    }
                }
            }
        }
    }
}