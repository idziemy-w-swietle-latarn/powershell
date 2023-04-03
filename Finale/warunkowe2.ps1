function Za-Lata($string_input){
    if ($string_input.length -eq 4){
        return "rok $string_input"
        }
    else {
        return "lata $string_input"
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

$company_types = @{
    'sk' = 'Spó³ka Komandytowa'
    'zoo' = 'Spó³ka z ograniczon¹ odpowiedzialnoœci¹'
    'sa' = 'Spó³ka akcyjna'
    }


$nazwa_folderu = Read-Host -Prompt 'nazwij folder dla dokumentow sprawy'
$sub_folder = "do druku"
$kod_sprawy = Read-Host '<RSP-XX.XXXX.MM>'
$data_wszczecia = Read-Host 'data wszczecia: XX miesi¹ca XXXX'
$imie_M = Read-Host 'imie mianownik'
$imie_D = Read-Host 'imie w dope³niaczu'
$imie_C = Read-Host 'imie w celowniku'
$nazwisko = Read-Host 'nazwisko'
$adres_doreczenia = Read-Host 'ulica i numery do doreczenia'
$kod_miasto_doreczenia = Read-Host 'kod i miasto doreczenia'
$data_ogloszenia = Read-Host 'data og³osenia: XX miesi¹ca XXXX'
$pan = Read-Host 'Pan czy Pani'
$za_lata = Read-Host -Prompt 'za lata w formacie xxxx-xxxx za rok format XXXX'
$nazwa_podmiotu = Read-Host -Prompt 'wprowadz nazwê podmiotu'
$rodzaje_spolki = Read-Host -Prompt 'rodzaje spolki oddzielone spacj¹ " " skróty: zoo, sk, sa'
$numer_krs = Read-Host -Prompt 'wprowadz numer krs'
$adres_siedziby = Read-Host "siedziba spó³ki wed³ug wzoru: 'w/we <miejscowoœci> przy ul. <nazwa ulicy> <numer>/<numer lokalu>'"
$data_wezwania = Read-Host 'data wezwania: XX miesi¹ca XXXX'



$imie_M2 = Read-Host 'imie 2 mianownik'
$imie_D2 = Read-Host 'imie 2 w dope³niaczu'
$imie_C2 = Read-Host 'imie 2 w celowniku'
$nazwisko2 = Read-Host 'nazwisko 2'
$pan2 = Read-Host 'Pan czy Pani 2'
$adres_doreczenia2 = Read-Host 'ulica i numery do doreczenia 2'
$kod_miasto_doreczenia2 = Read-Host 'kod i miasto doreczenia 2'
$data_ogloszenia2 = Read-Host 'data og³osenia 2: XX miesi¹ca XXXX'



$rodzaje_spolki = Parse-Company-Type $rodzaje_spolki $company_types
$za_lata = Za-Lata($za_lata)
$numer_krs = numerKRS $numer_krs
#$case_path = Join-Path . -ChildPath $sub_folder | Join-Path -ChildPath $nazwa_folderu

foreach ($_ in 1..2){
}

Create-Folder $nazwa_folderu $sub_folder

Get-ChildItem -Filter *.docx | ForEach-Object {
    $document = Get-WordDocument -Filepath $_.FullName
    
    $header = Get-wordheader -WordDocument $document -Type First
    foreach ($paragraph in $header.paragraphs){
        $paragraph.replacetext('data-wezwania', $data_wezwania)
        }
    
    $paragraphs = get-wordparagraphs -worddocument $document 
    foreach ($paragraph in $paragraphs){
        $paragraph.replacetext("nazwa-spó³ki", $nazwa_podmiotu)
        $paragraph.replacetext('<kod.sprawy>', $kod_sprawy)
        $paragraph.replacetext("numer-krs", $numer_krs)
        $paragraph.replacetext("adres-siedziby", $adres_siedziby)
        $paragraph.replacetext("za-lata", $za_lata)
        $paragraph.replacetext('data-wszczecia', $data_wszczecia)
        $paragraph.replacetext('data-wezwania', $data_wezwania)
        $paragraph.replacetext('data-ogloszenia', $data_ogloszenia)
        $paragraph.replacetext('rodzaje-spó³ki', $rodzaje_spolki)
        $paragraph.replacetext('imie-M>', $imie_M)
        $paragraph.replacetext('imie-D>', $imie_D)
        $paragraph.replacetext('imie-C>', $imie_C)
        $paragraph.replacetext('<nazwisko>', $nazwisko)
        $paragraph.replacetext('ulica-numery-doreczenia>', $adres_doreczenia)
        $paragraph.replacetext('kod-miasto-doreczenia>', $kod_miasto_doreczenia)
        $paragraph.replacetext('Pana-Pani>', $pan)

        $paragraph.replacetext('data-ogloszenia2', $data_ogloszenia2)
        $paragraph.replacetext('imie-M2>', $imie_M2)
        $paragraph.replacetext('imie-D2>', $imie_D2)
        $paragraph.replacetext('imie-C2>', $imie_C2)
        $paragraph.replacetext('<nazwisko2>', $nazwisko2)
        $paragraph.replacetext('ulica-numery-doreczenia2>', $adres_doreczenia2)
        $paragraph.replacetext('kod-miasto-doreczenia2>', $kod_miasto_doreczenia2)
        $paragraph.replacetext('Pana-Pani2>', $pan2)


     }    

    $get_location = Get-Location | Convert-Path
    $full_path = Join-Path $get_location -ChildPath $sub_folder | 
    Join-Path -ChildPath $nazwa_folderu | Join-Path -ChildPath ($_.BaseName + $_.Extension) 
    $full_path
    Save-WordDocument -Document $document -FilePath $full_path
    }