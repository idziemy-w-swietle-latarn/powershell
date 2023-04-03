$in_headers = @('heathers')
$in_paragraphs = @('babacar')
$folder_depth = 0

$command = '& $env:SKRYPTY\uniwerstal\main.ps1 $in_headers $in_paragraphs $folder_depth'
Invoke-Expression $command