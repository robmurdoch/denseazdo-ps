function getApiZipResponse {
    [CmdletBinding()]
    param (
        [System.Object]$OrgConnection,
        [String]$Uri,
        [String]$Path
    )
    process {
        if ($OrgConnection.Headers) {
            $null = Invoke-RestMethod `
                -Method Get `
                -Uri $Uri `
                -ContentType 'application\zip' `
                -Headers $OrgConnection.Headers `
                -OutFile $Path
        }
        else {
            $null = Invoke-RestMethod `
                -Method Get `
                -Uri $Uri `
                -ContentType 'application\zip' `
                -UseDefaultCredentials `
                -OutFile $Path
        }
    }
}