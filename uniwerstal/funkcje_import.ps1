$path = Split-Path $MyInvocation.MyCommand.Path
$path =	(get-item $path).parent.FullName 
$path =	Join-Path $path -ChildPath "Finale" | Join-Path -ChildPath "funkcje.ps1"
. $path

