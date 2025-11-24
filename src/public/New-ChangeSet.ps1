function New-ChangeSet {
    <#
    .SYNOPSIS
        Provides access to the ***** REST API 
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
    
        [Parameter(Mandatory = $true,
            HelpMessage = 'Provide the contents of the changeset')]
        [HashTable]$Contents
    )
    process {

        $path = '_apis/tfvc/changesets'
            
        $body = $Contents | ConvertTo-Json -Depth 10
                
        if ($PSCmdlet.ShouldProcess($Name, "Create ChangeSet")) {
            $uri = getApiUri -OrgConnection $OrgConnection -Path $path
            Write-Output (postApiResponse -OrgConnection $OrgConnection `
                    -Uri $uri -Body $body)
        }
    }
}