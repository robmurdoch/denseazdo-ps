function putApiResponse {
    [CmdletBinding()]
    param (
        [System.Object]$OrgConnection,
        [String]$Uri,
        [Object]$Body
    )
    process {

        if ($OrgConnection.Headers) {
            Invoke-RestMethod `
                -Method Put `
                -Uri $Uri `
                -Body $Body `
                -ContentType 'application/json' `
                -Headers $OrgConnection.Headers
        }
        else {
            Invoke-RestMethod `
                -Method Put `
                -Uri $Uri `
                -Body $Body `
                -ContentType 'application/json' `
                -UseDefaultCredentials
        }        
    }
}