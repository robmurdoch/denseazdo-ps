function getPagedApiResponse {
    [CmdletBinding()]
    param (
        [System.Object]$OrgConnection,
        [String]$Path,
        [String[]]$Query,
        [Int]$PageSize,
        [Switch]$CacheResults,
        [String]$CacheName
    )
    process {

        $loopCount = 0
        $continuationToken = $null

        do {
            $pageQuery = @()
            if ($PageSize){
                $pageQuery += "`$top=$PageSize"
            }
            else{
                $pageQuery += "`$top=$($global:AzDoPageSizePreference)"
            }

            if ($loopCount -gt 0) {
                $skip = $loopCount * $PageSize
                $pageQuery += "`$skip=$skip"
            }

            # ContinuationToken is a timestamp so it is not appropriate for cache key - it changes with every request
            # continuationToken=2021-10-20T23:03:40.0200000Z
            $cacheUri = getApiUri -OrgConnection $OrgConnection `
                -Path $Path -Query $Query -PageQuery $PageQuery
            $uriHash = getHashUri -Uri $cacheUri

            if ($loopCount -gt 0) {
                $pageQuery += "continuationToken=$continuationToken"
            }

            if ($CacheResults -and ($global:AzDoResultsCache.ContainsKey($uriHash.Hash))) {
                Write-Verbose "${$MyInvocation.MyCommand.Name} - Fetching response from cache"
                $webResponse = $global:AzDoResultsCache[$uriHash.Hash]
            }
            else {
                $uri = getApiUri -OrgConnection $OrgConnection `
                    -Path $Path -Query $Query -PageQuery $pageQuery
                Write-Verbose $uri
                
                if ($OrgConnection.Headers) {
                    $webResponse = Invoke-WebRequest `
                        -Method Get `
                        -Uri $Uri `
                        -Headers $OrgConnection.Headers
                }
                else {
                    $webResponse = Invoke-WebRequest `
                        -Method Get `
                        -Uri $Uri `
                        -UseDefaultCredentials
                }
                # $webResponse | Out-File 'C:\repos\DenseAzureDevOpsPs\scratch\unittest.txt'

                if ($null -ne $webResponse -and $webResponse -is [Microsoft.PowerShell.Commands.HtmlWebResponseObject] -and $null -ne $webResponse.Content) {
                    $null = cacheJsonDocument -Name $CacheName `
                        -RawResponse ($webResponse.Content | ConvertFrom-Json)
                }
            }

            if ($null -ne $webResponse -and $webResponse -is [Microsoft.PowerShell.Commands.HtmlWebResponseObject] -and $null -ne $webResponse.Content) {
                # Assuming json is returned
                Write-Output $webResponse.Content | ConvertFrom-Json
                if ($webResponse.Headers) {
                    $continuationToken = $webResponse.Headers['X-MS-ContinuationToken']
                }
            }
            else{
                # This supports unit testing CmdLets
                # In the event something unexpected is returned, caller can inspect the entire response.
                Write-Output $webResponse
            }
            
            $loopCount += 1
        } while ($null -ne $continuationToken)
    }
}