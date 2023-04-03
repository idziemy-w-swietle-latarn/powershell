param(
    [array]$in_headers,
    [array]$in_paragraphs,
    $folder_depth
)

$parent_dir = Split-Path $MyInvocation.MyCommand.Path
. (Join-Path $parent_dir -Childpath "funkcje_import.ps1")

$headers_dict = @{}
$paragraphs_dict = @{}

<#
#@()
if ($folder_depth){
    $get_location = Get-Location | Convert-Path
    $folder_array = foreach ($number in 1 .. $folder_depth){
        $folder_name = Read-Host -Prompt 'Nazwa folderu'
        Create-Folder $folder_name $get_location
        $get_location = Join-Path $get_location -ChildPath $folder_name
    }
}
$get_location
#>


<#
Write-Host '---w nag³ówkach----'
foreach ($var in $in_headers){
    $headers_dict[$var] = Read-Host -Prompt "$var"
}
#>

Write-Host '-----w paragrafach------'
foreach ($var in $in_paragraphs){
    $paragraphs_dict[$var] = Read-Host -Prompt "$var"
}

$headers_dict
"--------------------------" 
$paragraphs_dict



Get-ChildItem -Filter *.docx | ForEach-Object {
    $test = Get-WordDocument -Filepath $_.FullName
    <#
    $headers = Get-WordHeader -Worddocument $test -Type All
    foreach ($header in $headers){
        $header.Text
        
        foreach($paragraph in $header.paragraphs){
            $paragrapgh
            $paragraph.Text
            }
        }#>
    
    $paragraphs = Get-Wordparagraphs -Worddocument $test
    foreach($paragraph in $paragraphs){
        foreach($var in $paragraphs_dict.GetEnumerator()){ 
            $paragraph.replacetext($var.Name, $var.Value)
        }
    }

    #fix destiny path
    Save-WordDocument -Document $test -FilePath $_.FullName
}