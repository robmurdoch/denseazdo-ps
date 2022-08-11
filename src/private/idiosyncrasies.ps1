function getClassificationNodeDelimiter{
    param (
        [System.Object]$OrgConnection
    )

    if ($OrgConnection.getApiVersionNumber() -lt [double]5.0){
        return '::'
    }
    else {
        return ':'
    }
}