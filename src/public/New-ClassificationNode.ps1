function New-ClassificationNode {
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

        [Parameter(Mandatory = $true, 
            HelpMessage = 'Reference to an object obtained by Get-Project')]
        [Alias("P", "Proj")]
        [System.Object]$Project,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'The classification node structure group (area or iteration)')]
        [ValidateSet('Areas', 'Iterations')]
        [String]$StructureGroup,
        
        [Parameter(HelpMessage = 'Path to where the node should be appended')]
        [String]$ParentPath,
        
        [Parameter(Mandatory = $true,
            HelpMessage = 'Enter the Name of desired project')]
        [String]$Name
    )
    process {

        if ($ParentPath) {
            $path = "$($Project.Id)/_apis/wit/classificationnodes/$StructureGroup/$ParentPath"
        }
        else {
            $path = "$($Project.Id)/_apis/wit/classificationnodes/$StructureGroup"
        }
            
        $classification = @{
            name = $Name
        }
        $body = $classification | ConvertTo-Json -Depth 10
                
        if ($PSCmdlet.ShouldProcess($Name, "Create node")) {
            $uri = getApiUri -OrgConnection $OrgConnection -Path $path
            Write-Output (postApiResponse -OrgConnection $OrgConnection `
                    -Uri $uri -Body $body)
        }
    }
}