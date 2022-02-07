function Get-Ace {
    <#
    .SYNOPSIS
        Unwraps an Access Control List (ACL) and returns all of its Access Control Entries (ACE) 
    .DESCRIPTION
        Retrieves the Identity for Each Access Control Entry (ACE) in an Access Control List (ACL)
        Iterates the SecurityNames Actions bit shifting their value with the ACEs Allow, Deny, EffectiveAllow, and EffectiveDeny values 
    .EXAMPLE
        Get-Ace -OrgConnection $org -SecurityNamespace $vcns -Acl $acl
    .INPUTS
        ACL can be piped to cmdlet
    .OUTPUTS
        All of the ACEs for given ACL
    .NOTES
        Effecctive Allow and Effective Deny are evaluted first to support inheritance in a heirarchy
        Allow and Deny are evaluated second to support explicit permissions
        If none of the above evaluate to true, the setting is Not Set 

        To speed processing all Identities are cached and reused
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            HelpMessage = 'Reference to Connection object obtained from Connect-AzureDevOps')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Reference to SecurityNamespace obtained from Get-SecurityNamespace')]
        [System.Object]$SecurityNamespace,
        
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Reference to Acl obtained from Get-Acl')]
        [System.Object]$Acl
    )
    process {
        
        $aces = $Acl.acesDictionary
        [Hashtable[]]$output = @()

        foreach ($ace in $aces.PSObject.Properties) {
        
            # Explicitely defining the objects properties enables ordering
            [hashtable]$aceOutput = @{
                Org                = $OrgConnection.Uri;
                SecurityToken      = $Acl.token;
                InheritPermissions = $Acl.inheritPermissions
            }

            $descriptor = $ace.value.descriptor
            $identity = Get-Identity `
                -OrgConnection $OrgConnection `
                -Descriptor $descriptor `
                -CacheResults
            if ($identity.customDisplayName) {
                $aceOutput.add('Identity', $identity.customDisplayName)
            }
            else {
                $aceOutput.add('Identity', $identity.providerDisplayName)
            }
        
            $allow = $ace.value.allow
            $deny = $ace.value.deny
            $effectiveAllow = $ace.value.extendedInfo.effectiveAllow
            $effectiveDeny = $ace.value.extendedInfo.effectiveDeny
            foreach ($action in $SecurityNamespace.actions) {
                $actionName = $($action.displayName)
                if (($effectiveAllow -band $action.bit) -eq $action.bit) {
                    $aceOutput[$actionName] = 'Effective Allow'
                }
                if (($allow -band $action.bit) -eq $action.bit) {
                    $aceOutput[$actionName] = 'Allow'
                }
                if (($effectiveDeny -band $action.bit) -eq $action.bit) {
                    $aceOutput[$actionName] = 'Effective Deny'
                }
                if (($deny -band $action.bit) -eq $action.bit) {
                    $aceOutput[$actionName] = 'Deny'
                }
                if (-not $aceOutput.ContainsKey($actionName)) {
                    $aceOutput[$actionName] = 'Not Set'
                }
            }
            $output += $aceOutput
        }
    
        return $output
    }
}