function cacheJsonDocument {
    [CmdletBinding(
        SupportsShouldProcess
    )]
    param (
        [String]$Name,
        $RawResponse
    )
    process {
        $json = $RawResponse | ConvertTo-Json -Depth 50
        $stringAsStream = [System.IO.MemoryStream]::new()
        $writer = [System.IO.StreamWriter]::new($stringAsStream)
        $writer.write($json)
        $writer.Flush()
        $stringAsStream.Position = 0
        $hash = Get-FileHash -InputStream $stringAsStream
        $json | Set-Content -Path "$Env:USERPROFILE\Downloads\$Name-$($hash.Hash).json" -Force
    }
}