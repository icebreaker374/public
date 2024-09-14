Set-ExecutionPolicy Bypass -Scope Process -Force

Install-Module Evergreen -Force

Import-Module Evergreen -Force

Write-Host "Checking if Adobe Reader is installed..."

$AdobeInstallStatus = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Where-Object DisplayName -Match "Adobe Acrobat" | Select DisplayName, UninstallString

if($AdobeInstallStatus -EQ $null){

    Write-Host "Adobe Reader not installed, exiting in 3 seconds..."
    
    Start-Sleep -Seconds 3

    exit
}

else{

    $AdobeUninstallString = ($AdobeInstallStatus.UninstallString).SubString(14, ($AdobeInstallStatus.UninstallString).Length-14)
    
    Write-Host "Attempting to uninstall the current version of Adobe Reader..."
    
    Start-Process MsiExec.exe -ArgumentList "/x $AdobeUninstallString /qn" -Wait

    $AdobeUninstallConfirmation = $AdobeInstallStatus = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Where-Object DisplayName -Match "Adobe Acrobat" | Select DisplayName, UninstallString

    if($AdobeUninstallConfirmation -EQ $null){
    
        Write-Host "Successfully uninstalled Adobe Reader!"
    }

    else{
    
        Write-Host "Failed to uninstall Adobe Reader, exiting in 3 seconds..."

        Start-Sleep -Seconds 3

        exit
    }

    Write-Host "Attempting to download the Adobe Reader installer..."
    
    $AdobeURI = Get-EvergreenApp -Name AdobeAcrobatReaderDC | Where-Object {($_.Language -EQ "English") -and ($_.Architecture -EQ "x64")} | Select-Object -ExpandProperty URI

    Invoke-WebRequest -Uri $AdobeURI -OutFile "$env:Temp\AdobeReader.exe"

    if((Test-Path "$env:Temp\AdobeReader.exe") -EQ $True){
    
        Write-Host "Successfully downloaded the Adobe Reader installer!"
    }

    else{
    
        Write-Host "Failed to download the Adobe Reader installer, exiting in 3 seconds..."

        Start-Sleep -Seconds 3

        exit
    }

    Write-Host "Attempting to install the latest version of Adobe Reader..."
    
    Start-Process -FilePath "$env:Temp\AdobeReader.exe" -ArgumentList "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES" -Wait

    $AdobeInstallConfirmation = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Where-Object DisplayName -Match "Adobe Acrobat" | Select DisplayName, UninstallString

    if($AdobeInstallConfirmation -NE $null){
    
        Write-Host "Successfully installed the latest version of Adobe Reader!"
    }

    else{
    
        Write-Host "Failed to install the latest version of Adobe Reader, exiting in 3 seconds..."
    }
}
