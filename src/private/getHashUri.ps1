
function getHashUri {
    param (
        [String]$Uri
    )
    process {
        $stringAsStream = [System.IO.MemoryStream]::new()
        $writer = [System.IO.StreamWriter]::new($stringAsStream)
        $writer.write($Uri)
        $writer.Flush()
        $stringAsStream.Position = 0
        $hash = Get-FileHash -InputStream $stringAsStream
        return $hash
    }
}