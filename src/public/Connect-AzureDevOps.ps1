function Connect-AzureDevOps {    
    <#
    .SYNOPSIS
        Establishes a connection to the Azure DevOps REST Api.
    .DESCRIPTION
        Connect-AzureDevOps must be called first before any other function. Supports Basic, Integrated, and Token authentication methods. An initial connection is made to the core project api so user must have read access to at least one project.

        This cmdlet returns an AzDoConnection object that can be used in subsequent methods. 
    .EXAMPLE
        Connect-AzureDevOps -Uri 'https://myorganization/DefaultCollection' -PersonalAccessToken mypersonalaccesstoken
        
        Connects with a personal access token (PAT).
    .EXAMPLE
        $creds = Get-Credential
        Connect-AzureDevOps -Uri 'https://somedomain/somecollection -Credentials $creds
        
        Connects with basic authentication using the provided credentials. 
    .EXAMPLE
        Connect-AzureDevOps -Uri $uri

        Connects with integrated windows authentication.
    .INPUTS
        None. You cannot pipe objects to Connect-AzureDevOps.
    .OUTPUTS
        PSObject that is needed to in other Cmdlet's OrgConnection parameter.
    .NOTES
        The OrgConnection object returned can contain secrets, e.g. a personal access token. Take care not to write or emit these secrets to files, verbose, information, debug and/or any other output.

        Connect-AzureDevOps attempts to detect the version of the higest REST API version supported by the organization. 
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true,
            ParameterSetName = 'Default',
            HelpMessage = 'Enter the collection address, e.g. https://mysite.mydomain.net/DefaultCollection',
            Position = 0)]
        [Parameter(ParameterSetName = 'Token')]
        [Parameter(ParameterSetName = 'Credential')]
        [Alias('CollectionUri', 'OrganizationUri')]
        [string]$OrgUri,
    
        [Parameter(Mandatory = $true,
            ParameterSetName = 'Token',
            HelpMessage = 'Enter your Personal Access Token (PAT)',
            position = 1)]
        [Alias('PAT')]
        [string]$PersonalAccessToken,
    
        [Parameter(Mandatory = $true,
            ParameterSetName = 'Credential',
            HelpMessage = 'Variable resulting from Get-Credential cmdlet',
            position = 1)]
        [Alias('Cred')]
        [System.Management.Automation.PSCredential]$Credential
    )
    process {
        
        if ($PSBoundParameters.ContainsKey("PersonalAccessToken")) {
            $org = getOrgConnection -Uri $OrgUri -PersonalAccessToken $PersonalAccessToken
        }
        elseif ($PSBoundParameters.ContainsKey("Credential")) {
            $org = getOrgConnection -Uri $OrgUri -Credential $Credential
        }
        else {
            $org = getOrgConnection -Uri $OrgUri
        }

        foreach ($version in $org.ApiVersions) {
            $org.ApiVersion = $version
            try {
                $uri = getApiUri -OrgConnection $org `
                    -Path '_apis/projects' -Query '$top=1'
                $null = getApiResponse -OrgConnection $org `
                    -Uri $uri -CacheName $MyInvocation.MyCommand.Name
                return $org
                break
            }
            catch {           
                if (($PSItem.ErrorDetails | ConvertFrom-Json).message -like '*out of range for this server*'){
                    Write-Warning "$version not supported, trying downlevel version"
                }
                else{
                    throw
                }
            }
        }
    }
}

[Int]$global:AzDoPageSizePreference = 100
[HashTable]$global:AzDoResultsCache = @{}