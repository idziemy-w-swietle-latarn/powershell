function Parse-Za-Lata($string_input){
    $array_input = $string_input -split '-'
 #   if ($array_input.count -eq 1){
  #      return $array_input[0]
   #     }
    $var1 = [int]$array_input[0]
    $var2 = [int]$array_input[1]
    return ($var1..$var2 | % { ,[string]$_ })
    
}

function Za-Lata($string_input){
    if ($string_input.length -eq 4){
        return "za rok $string_input"
        }
    else {
        return "za lata $string_input"
        }
}

function numerKRS([string]$numerkrs){
    $excpected_len = 10
    $actual_len = $numerkrs.Length
    if ($actual_len -eq 10) {
        return $numerkrs
        }
    else {
        $diff = $excpected_len - $actual_len
        $prefix = "0" * $diff
        return $prefix + $numerkrs
    }

}

function Create-Folder($nazwa_folderu, $sub_folder){
    $path = Join-Path . -ChildPath $sub_folder | Join-Path -ChildPath $nazwa_folderu
    if (-not(Test-Path -Path $path)){
    New-Item -Path (Join-Path . -ChildPath $sub_folder) -Name $nazwa_folderu -ItemType "directory"
}
}

function Parse-Company-Type([string]$string_input, [System.Collections.Hashtable]$types){
    
    $output_list = [System.Collections.ArrayList]@()
    $array_input = $string_input -split " "| ForEach-Object{
        $var1 = $types[$_.trim()]
        if ($var1){
            $output_list.add($var1)
            }
        else {
            $output_list.add($_.trim())
            }
        }
    
    return $output_list -join " "
}

$company_types = @{
    'sk' = 'Spó³ka Komandytowa'
    'zoo' = 'Spó³ka z ograniczon¹ odpowiedzialnoœci¹'
    'sa' = 'Spó³ka akcyjna'
    }

$nazwa_folderu = Read-Host -Prompt 'nazwij folder dla dokumentow sprawy'
$sub_folder = "do druku"
$case_path = Join-Path . -ChildPath $sub_folder | Join-Path -ChildPath $nazwa_folderu
$za_lata = Read-Host -Prompt 'za lata w formacie xxxx-xxxx za rok format XXXX'
$nazwa_podmiotu = Read-Host -Prompt 'wprowadz nazwê podmiotu'
$rodzaje_spolek = Read-Host -Prompt 'wprowdz rodzaje spó³ki'
$rodzaje_spolek = Parse-Company-Type $rodzaje_spolek $company_types
$nazwa_podmiotu = $nazwa_podmiotu + " " + $rodzaje_spolek
$numer_krs = Read-Host -Prompt 'wprowadz numer krs'
$numer_krs = numerKRS $numer_krs
$adres_siedziby = Read-Host "wed³ug wzoru: 'w/we <miejscowoœci> przy ul. <nazwa ulicy> <numer>/<numer lokalu>'"
$data_wezwania = Read-Host 'data wezwania: XX miesi¹ca XXXX'

$lista_lat = Parse-Za-Lata($za_lata)
$za_lata = Za-Lata($za_lata)

Create-Folder $nazwa_folderu $sub_folder

Get-ChildItem -Filter *.docx | ForEach-Object {
    $document = Get-WordDocument $_.FullName
    
    $header = Get-wordheader -WordDocument $document -Type First
    foreach ($paragraph in $header.paragraphs){
        $paragraph.replacetext('data-wezwania', $data_wezwania)
        }
    
    $paragraphs = get-wordparagraphs -worddocument $document 
    foreach ($paragraph in $paragraphs){
        $paragraph.replacetext("pelna-nazwa-podmiotu", $nazwa_podmiotu)
        $paragraph.replacetext("pelny-numer-krs", $numer_krs)
        $paragraph.replacetext("adres-siedziby", $adres_siedziby)
        $paragraph.replacetext("za-lata", $za_lata)
        $paragraph.replacetext('data-wezwania', $data_wezwania)
     }    

    $get_location = Get-Location | Convert-Path
    $full_path = Join-Path $get_location -ChildPath $sub_folder | 
    Join-Path -ChildPath $nazwa_folderu | Join-Path -ChildPath ($_.BaseName + $_.Extension) 
    $full_path
    Save-WordDocument -Document $document -FilePath $full_path
    }