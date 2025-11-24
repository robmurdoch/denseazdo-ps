function appendTfvcNodeToAces {
    [CmdletBinding()]
    param (
        [Object]$Node,
        [Hashtable[]]$Aces
    )
    process {
        
        foreach ($ace in $Aces) {
            $ace['path'] = $Node.path
            $ace['isFolder'] = $Node.isFolder
            $ace['url'] = $Node.url
            Write-Output (New-Object PSObject -Property $ace)
        }
    }
}