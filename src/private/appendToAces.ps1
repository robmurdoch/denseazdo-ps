function appendToAces {
    [CmdletBinding()]
    param (
        [Object]$ObjectToAppend,
        [Hashtable[]]$Aces
    )
    process {
        
        foreach ($ace in $Aces) {
            foreach ($member in $($ObjectToAppend.PSObject.Properties)){
                $ace[$member.Name] = $member.Value
            }
            Write-Output (New-Object PSObject -Property $ace)
        }
    }
}