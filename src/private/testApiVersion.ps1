
function testApiVersion {
    param (
        [System.Object]$OrgConnection,
        [string]$ApiVersion,
        [string]$Feature
    )
    process {
        $testVersion = $ApiVersion.Substring($ApiVersion.IndexOf("=") + 1)
        $orgVersion = $OrgConnection.ApiVersion.Substring($OrgConnection.ApiVersion.IndexOf("=") + 1)
        if ($orgVersion -ge $testVersion){
            return $true
        }
        else{
            Write-Host "$Feature requrires $ApiVersion or greater" -ForegroundColor Red
            return $false
        }
    }
}