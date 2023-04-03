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

function Create-Folder($nazwa_folderu, $path){
    $path_test = Join-Path $path -ChildPath $nazwa_folderu
    if (-not(Test-Path -Path $path_test)){
    New-Item -Path $path -Name $nazwa_folderu -ItemType "directory"
}}


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

function Parse-Company-Type([string]$string_input, [array]$types){
    

    $types = @{
        'sk' = 'S.K'
        'zoo' = 'Sp. z o.o.'
        'sa' = 'S.A'
        }

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

#$get_location = Get-Location | Convert-Path