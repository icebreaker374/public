$RequiredModules = "ExchangeOnlineManagement","MSOnline","Microsoft.Online.SharePoint.PowerShell","MicrosoftTeams","AzureAD"

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

        Wrtie-Host "
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