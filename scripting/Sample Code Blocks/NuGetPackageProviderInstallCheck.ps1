Write-Host "Checking if the NuGet package provider is installed..."

$NuGetInstallationCheck = Get-PackageProvider

if($NuGetInstallationCheck.Name -NotContains "NuGet"){

    Write-Host "Attempting to install the NuGet package provider..."
    
    Install-PackageProvider -Name NuGet -Scope CurrentUser -ErrorAction SilentlyContinue

    Write-Host "Verifying if the NuGet package provider is installed."
    
    $NuGetInstallationVerification = Get-PackageProvider

    if($NuGetInstallationVerification.Name -Contains "NuGet"){

        Write-Host "Confirmed the NuGet package provider was installed."
    }

    else{

        Write-Host "Failed to install the NuGet package provider.  Please attempt to manually run: 'Install-PackageProvider -Name NuGet -Scope CurrentUser'."

        Write-Host "The script will exit in 5 seconds..."

        exit
        }
}

else{

    Write-Host "Confirmed the NuGet package provider is installed."
}