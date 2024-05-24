$RequiredModules = @("AzureAD","MSOnline","ExchangeOnlineManagement","MicrosoftTeams","PnP.PowerShell","PartnerCenter")

foreach($module in $RequiredModules){

    if(Get-InstalledModule -Name $module -ErrorAction SilentlyContinue){

        Write-Host "
Confirmed the $module module is installed."

        if(Get-Module -Name $module -ErrorAction SilentlyContinue){

            Write-Host "
Confirmed the $module module is loaded."
        }

        else{

            Write-Host "
Attempting to load the $module module..."
            
            Import-Module -Name $module -ErrorAction SilentlyContinue

            if(Get-Module -Name $module -ErrorAction SilentlyContinue){
            
                Write-Host "
The $module module was successfully loaded."
            }

            else{

                Write-Host "
The $module module failed to load.  The script will exit in 3 seconds..."

                Start-Sleep -Seconds 3

                exit
            }
        }
    }

    else{

        Write-Host "
Attempting to install and load the $module module..."
        
        Install-Module -Name $module -Scope CurrentUser -ErrorAction SilentlyContinue
        Import-Module -Name $module

        if((Get-InstalledModule -Name $module -ErrorAction SilentlyContinue) -and (Get-Module -Name $module -ErrorAction SilentlyContinue)){

            Write-Host "
The" $module "module was successfully installed and loaded."
        }

        else{

            Write-Host "
The $module module either failed to install and/or failed to load.  The script will exit in 3 seconds..."

            Start-Sleep -Seconds 3

            exit
        }
    }
}

Write-Host "Checking if the required modules are updated..."

foreach($module in $RequiredModules){

    $CurrentVersion = Get-InstalledModule -Name $module | Select Version
    $LatestVersion = Find-Module -Name $module | Select Version

    if($CurrentVersion.Version -GE $LatestVersion.Version){

        Write-Host "Latest version of the $module module is already installed."
    }

    elseif($CurrentVersion.Version -LT $LatestVersion.Version){

        Write-Host "Attempting to update the $module module..."

        Update-Module -Name $module -Scope CurrentUser

        if($CurrentVersion.Version -Match $LatestVersion.Version){
            
            Write-Host "Successfully updated the $module module."
        }

        else{

            Write-Host "Failed to update the $module module."
        }
    }

    else{

        Write-Host "Unable to confirm if the latest version of the $module module is installed."
    }
}