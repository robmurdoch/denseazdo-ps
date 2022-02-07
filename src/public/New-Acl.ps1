function New-Acl {
    <#
    .SYNOPSIS
        Provides access to the ... REST API 
    .DESCRIPTION

    .EXAMPLE

    .INPUTS

    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES

    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Reference to Connection object returned from call to Connect-AzureDevOps',
            Position = 0)]
        [Parameter(ParameterSetName = 'Item')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,
    
        [Parameter(HelpMessage = 'Security namespace')]
        [System.Object]$SecurityNamespace,
        
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Enter the Name of desired project',
            position = 1)]
        [HashTable]$Acl
    )
    process {

        $path = "_apis/accesscontrollists/$($SecurityNamespace.namespaceId)"
            
        $body = $Acl | ConvertTo-Json -Depth 10
                
        if ($PSCmdlet.ShouldProcess($Acl.value.token, "Create or Replace ACL")) {
            $uri = getApiUri -OrgConnection $OrgConnection -Path $path
            Write-Output (postApiResponse -OrgConnection $OrgConnection `
                    -Uri $uri -Body $body)
        }
    }
}