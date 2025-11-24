function patchApiResponse {
    [CmdletBinding()]
    param (
        [System.Object]$OrgConnection,
        [String]$Uri,
        [Object]$Body
    )
    process {

        if ($OrgConnection.Headers) {
            Invoke-RestMethod `
                -Method Patch `
                -Uri $Uri `
                -Body $Body `
                -ContentType 'application/json' `
                -Headers $OrgConnection.Headers
        }
        else {
            Invoke-RestMethod `
                -Method Patch `
                -Uri $Uri `
                -Body $Body `
                -ContentType 'application/json' `
                -UseDefaultCredentials
        }        
    }
}