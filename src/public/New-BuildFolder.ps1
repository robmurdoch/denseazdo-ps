function New-BuildFolder {
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
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,

        [Parameter(Mandatory = $true, 
            HelpMessage = 'Reference to an object obtained by Get-Project')]
        [Alias("P", "Proj")]
        [System.Object]$Project,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Enter the full path of the folder')]
        [String]$FullPath,
        
        [Parameter(HelpMessage = 'Enter a description for the folder')]
        [String]$Description
    )
    process {

        $path = "$($Project.Id)/_apis/build/folders"
        
        $query = @()
        if ($PSBoundParameters.ContainsKey('FullPath')) {
            $query += "path=$FullPath"
        }
            
        $folder = @{
            description = $Description
            path        = $FullPath
        }
        $body = $folder | ConvertTo-Json -Depth 3
                
        if ($PSCmdlet.ShouldProcess($FullPath, "Create new folder")) {
            $uri = getApiUri -OrgConnection $OrgConnection -Path $path -Query $query -Preview1
            Write-Output (putApiResponse -OrgConnection $OrgConnection `
                    -Uri $uri -Body $body)
        }
    }
}