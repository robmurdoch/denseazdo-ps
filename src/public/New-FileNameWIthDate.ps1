function New-FileNameWithDate {
    param(
        [String]$BaseName
    )
    
    process {
        if (-not $BaseName.Contains('.')) {
            throw "File extension missing"
        } 
        $extension = $BaseName.Substring($BaseName.LastIndexOf("."))
        $file = $BaseName.Substring(0, $BaseName.LastIndexOf("."))
        # if ($file.EndsWith("\")) {
        #     throw "File name missing"
        # } 
        # if ($file.Length -eq 0) {
        #     throw "Path missing"
        # }
        return "$file $(Get-Date -f yyyy-MM-dd)$extension"
    }
}