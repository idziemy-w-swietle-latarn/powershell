Get-ChildItem -Filter *.docx | sort CreationTime | Foreach-Object {
    Start-Process -FilePath $_.FullName -Verb print
    Start-Sleep -Seconds 1
    Start-Process -FilePath $_.FullName -Verb print
    Start-Sleep -Seconds 2
    
    while (Get-PrintJob "AVI_Print"){
        Get-PrintJob "AVI_Print" | Write-Output
        Start-Sleep -Seconds 1
        }

    if (-not(Test-Path -Path '.\wydrukowane')){
        New-Item -Path . -Name "wydrukowane" -ItemType "directory"
        }

    Move-Item -Path $_.FullName -Destination ".\wydrukowane"
    }