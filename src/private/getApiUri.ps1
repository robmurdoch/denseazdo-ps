function getApiUri {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [System.Object]$OrgConnection,
        [String]$Path,
        [String[]]$Query,
        [String[]]$PageQuery,
        [Switch]$Preview1,
        [Switch]$Preview2
    )
    process {
        
        if($Preview1){
            $apiVersion = "$($OrgConnection.ApiVersion)-preview.1"
        }
        elseif ($Preview2){
            $apiVersion = "$($OrgConnection.ApiVersion)-preview.2"
        }
        else {
            $apiVersion = $OrgConnection.ApiVersion
        }

        if (($PSBoundParameters.ContainsKey('Query') -and $Query.Length -gt 0 -and $Query -ne '') -and `
            ($PSBoundParameters.ContainsKey('PageQuery') -and $PageQuery.Length -gt 0 -and $PageQuery -ne '')) {

            $queryString = $Query -join '&'
            $pageQueryString = $PageQuery -join '&'
            $retUri = "$($OrgConnection.Uri)/$($Path)?$($queryString)&$pageQueryString&$apiVersion"
        } 
        elseif ($PSBoundParameters.ContainsKey('Query') -and $Query.Length -gt 0 -and $Query -ne '') {

            $queryString = $Query -join '&'
            $retUri = "$($OrgConnection.Uri)/$($Path)?$($queryString)&$apiVersion"
        }
        elseif ($PSBoundParameters.ContainsKey('PageQuery') -and $PageQuery.Length -gt 0 -and $PageQuery -ne '') {

            $pageQueryString = $PageQuery -join '&'
            $retUri = "$($OrgConnection.Uri)/$($Path)?$($pageQueryString)&$apiVersion"
        }
        else {
            $retUri = "$($OrgConnection.Uri)/$($Path)?$apiVersion"
        }
        return $retUri
    }
}