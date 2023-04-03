Get-Location
Get-ChildItem -Filter *.docx | ForEach-Object {
    $_.FullName
    }