function getApiResponse {
    [CmdletBinding()]
    param (
        [System.Object]$OrgConnection,
        [String]$Uri,
        [Switch]$CacheResults,
        [String]$CacheName
    )
    process {
        $uriHash = getHashUri -Uri $Uri
        if ($CacheResults -and ($global:AzDoResultsCache.ContainsKey($uriHash.Hash))) {
            Write-Verbose "Returning cached results"
            $response = $global:AzDoResultsCache[$uriHash.Hash]
        }
        else {
            Write-Verbose $Uri

            if ($OrgConnection.Headers.ContainsKey('Authentication')) {
                $response = Invoke-RestMethod `
                    -Method Get `
                    -Uri $Uri `
                    -Headers $OrgConnection.Headers
            }
            else {
                $response = Invoke-RestMethod `
                    -Method Get `
                    -Uri $Uri `
                    -UseDefaultCredentials
            }

            # Write results to disk for debugging 
            # TODO conditionally based on DebugPreference
            $null = cacheJsonDocument -Name $CacheName `
                -RawResponse $response -Confirm:$false
            
            if ($CacheResults) {
                $global:AzDoResultsCache.Add($UriHash.Hash, $response)
            }
        }

        Write-Output $response
    }
}