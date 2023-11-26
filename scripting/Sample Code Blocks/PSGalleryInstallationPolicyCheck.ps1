Write-Host "Checking if PSGallery is a trusted repository..."

$PSRepository = Get-PSRepository -Name PSGallery

if($PSRepository.InstallationPolicy -NE "Trusted"){

    Write-Host "Attempting to set PSGallery as a trusted repository..."

    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue

    Write-Host "Verifying if PSGallery is now a trusted repository..."

    if($PSRepository.InstallationPolicy -Match "Trusted"){

        Write-Host "Confirmed PSGallery is now a trusted repository."
    }

    else{

        Write-Host "Failed to set PSGallery as a trusted repository.  Please attempt to manually run: 'Set-PSRepository -Name PSGallery -InstallationPolicy Trusted'."

        Write-Host "The script will exit in 5 seconds..."

        Start-Sleep -Seconds 5

        exit
    }
}

else{

    Write-Host "Confirmed PSGallery is already a trusted repository."
}