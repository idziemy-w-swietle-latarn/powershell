$vars = @(
'RMW(XXX)'
'nazwa-spolki'
'rodzaj-spolki'
'imie-nazwisko'
'ulica-i-numeracja'
'kod-i-poczta'
'godzina-XX.XX'
)

function Parse-Company-Type([string]$string_input){
    
    $types = @{
        'sk' = 'S.K.'
        'zoo' = 'Sp. z o.o.'
        'sa' = 'S.A.'
        }

    $output_list = [System.Collections.ArrayList]@()
    $array_input = $string_input -split " " | ForEach-Object{
        $var1 = $types[$_.trim().tolower()]
        if ($var1){
            $output_list.add($var1)
            }
        else{
            $output_list.add($_.trim())
            }
        }
    
    return $output_list -join " "
}

function Create-Folder($nazwa_folderu){
    $path = Join-Path . -ChildPath $nazwa_folderu
    if (-not(Test-Path -Path $path)){
    New-Item -Path . -Name $nazwa_folderu -ItemType "directory"
}}


$sending_date = Read-Host -Prompt 'data utworzenia dokumentu w formacie dd miesiąca rrrr'
$RMW_rok_XXXX = Read-Host -Prompt 'rok RMW w formacie XXXX'
$subponea_day = Read-Host -Prompt 'data wezwania w formacie XX miesiąca XXXX'

Create-Folder $subponea_day


while ($true){

    $subponea_data = @{}
    
    foreach ($var in $vars){
        $subponea_data[$var] = Read-Host -Prompt "wprowadz $var"
    }
    $output_filename = Read-Host -Prompt 'nazwa pliku wyjsciowego'
    $output_filename += '.docx'

    #{zoo: Sp. z o.o.;sk=S.K.;sa=S.A.}
    $subponea_data['rodzaj-spolki'] = Parse-Company-Type($subponea_data['rodzaj-spolki'])

    $subponea_data.values
    $RMW_rok_XXXX
    $subponea_day

    #$PWD = current working directory (where shell is currently)
    $get_location = Get-Location | Convert-Path
    $filepath = Join-Path $get_location -ChildPath 'wezwanie przed wszczęciem wzór.docx'
    $filepath2 = Join-Path $get_location -ChildPath $subponea_day | Join-Path -ChildPath $output_filename 
    $document = Get-WordDocument $filepath
    
    $header = Get-wordheader -WordDocument $document -Type First
    foreach ($paragraph in $header.paragraphs){
        $paragraph.replacetext('data-wezwania', $sending_date)}
    
    $paragraphs = get-wordparagraphs -worddocument $document 
    foreach ($paragraph in $paragraphs){
        $paragraph.replacetext("XXXX", $RMW_rok_XXXX)
        $paragraph.replacetext("dzien-miesiac-rok", $subponea_day)
        foreach($var in $vars){
            $paragraph.replacetext($var, $subponea_data[$var])}}

    Save-WordDocument -Document $document -FilePath $FilePath2
}