function Get-TfvcSecurity {
    <#
    .SYNOPSIS
        Extract the permissions for a TFVC repository, report them for review.
    .DESCRIPTION
        Get the ACLs for the repo root $/Project. Iterate them and retrieve the identities one-by-one caching them along the way. Export the data to csv for importing to Excel to review.
    .EXAMPLE
        (Get-Project -OrgConnection $org).value
        Get all projects in an organization using the core List api.
    .EXAMPLE
        (Get-Project -OrgConnection $org).value | Get-Project -OrgConnection $org -CacheResults -IncludeCapabilities
        Gets all wellFormed (default) projects using the core List api. Output to the pipeline one-by-one to get 
    .EXAMPLE
        Get-Project -OrgConnection $org -stateFilter all
        Gets all projects regardless of their state.  
    .EXAMPLE
        Get-Project -OrgConnection $org -stateFilter deleting
        Gets all projects that are currently being deleted. Useful to poll this api after deleting a project to determine when it completes.
    .EXAMPLE
        $org = Connect-AzureDevOps -OrgUri 'https://tfs.company.net/defaultcollection' -PersonalAccessToken $mypersonalaccesstoken -Verbose
        Get-Project -OrgConnection $org | Where-Object {$PSItem.name -eq 'Scratch'} | Get-TfvcSecurity -OrgConnection $org | Export-Csv -Path tfvcsecurity.csv
        Connect to azure devops, get projects in the org that match the desired project, then get the Tfvc security Acls and Identities and export it to a csv file
    .EXAMPLE
        Get-Project -OrgConnection $org | 
            Where-Object {$PSItem.name -eq 'Scratch'} | 
            Get-TfvcSecurity -OrgConnection $org | 
            Select-Object -Property Org,Securable,Identity,InheritPermissions,Read,Checkin,CheckinOther,ReviseOther,ManageBranch,UndoOther,UnlockOther,Label,PendChange,AdminPropertyRights,Lock,LabelOther,Merge | 
            Export-Csv -Path $Env:USERPROFILE\Downloads\TFVC.csv
        Gets the TfvcSecurity for the Scratch Team Project, Ordering the columns, then saving the results to Csv
    .INPUTS
        Project Id causes cmdlet to fetch a single project, which, is necessary to get additional project details not available when using the core List api.
    .OUTPUTS
        The results of Invoke-RestMethod
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Reference to Connection object obtained from Connect-AzureDevOps')]
        [Alias("O", "Org")]
        [System.Object]$OrgConnection,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Reference to an object obtained by Get-Project')]
        [System.Object]$Project
    )
    begin {

        $sn = Get-SecurityNamespace -OrgConnection $OrgConnection | 
        Where-Object { $PSItem.name -eq 'VersionControlItems' }

    }
    process {

        Get-Acl `
            -OrgConnection $OrgConnection `
            -SecurityNamespace $sn `
            -SecurityToken "$/$($project.name)" `
            -Recurse -IncludeExtendedInfo |
        Get-Ace `
            -OrgConnection $OrgConnection `
            -SecurityNamespace $sn
        
        
        # ForEach-Object -Process {
        #     Get-Ace `
        #         -OrgConnection $OrgConnection `
        #         -SecurityNamespace $sn `
        #         -Acl $PSItem
        # }
    }
}
