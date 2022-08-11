function recurseClassificationNode {
    [CmdletBinding()]
    param (
        [System.Object]$OrgConnection,
        [System.Object]$SecurityNamespace,
        [System.Object]$ClassificationNodes,
        [String]$ParentNodeSecurityToken,
        [System.Object]$Acls
    )
    process {  

        if ($OrgConnection.getApiVersionNumber() -lt [double]5.0){
            $tokenDelimiter = '::'
        }
        else {
            $tokenDelimiter = ':'
        }

        foreach ($node in $ClassificationNodes) {          

            if ($ParentNodeSecurityToken) {
                $token = "$($ParentNodeSecurityToken)$($tokenDelimiter)vstfs:///Classification/Node/$($node.identifier)"
            }
            else {
                $token = "vstfs:///Classification/Node/$($node.identifier)"
            }

            $acl = $Acls | Where-Object { $PSItem.token -eq $token }
            if ($null -eq $acl) {
                Write-Verbose "ACL for [$($Node.name)] [$token] not found"
            }
            else {
                $aces = Get-Ace -OrgConnection $OrgConnection `
                    -SecurityNamespace $SecurityNamespace -Acl $acl
                appendToAces -ObjectToAppend $node -Aces $aces
            }

            Write-Verbose $node.Name
            
            if ($node.hasChildren) {                
                recurseClassificationNode -OrgConnection $OrgConnection `
                    -SecurityNamespace $SecurityNamespace `
                    -ClassificationNodes $node.children `
                    -ParentNodeSecurityToken $token `
                    -Acls $Acls
            }
        }
    }
}