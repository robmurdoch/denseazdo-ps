function postApiResponse {
    [CmdletBinding()]
    param (
        [System.Object]$OrgConnection,
        [String]$Uri,
        [Object]$Body
    )
    process {

        if ($OrgConnection.Headers) {
            Invoke-RestMethod `
                -Method Post `
                -Uri $Uri `
                -Body $Body `
                -ContentType 'application/json' `
                -Headers $OrgConnection.Headers
        }
        else {
            Invoke-RestMethod `
                -Method Post `
                -Uri $Uri `
                -Body $Body `
                -ContentType 'application/json' `
                -UseDefaultCredentials
        }        
    }
}