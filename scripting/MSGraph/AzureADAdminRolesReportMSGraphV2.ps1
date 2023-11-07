Write-Host "Checking if C:\Temp\AzureADAdminRolesReportMSGraph exisits..."

Start-Sleep -Milliseconds 1500

if(Test-Path "C:\Temp\AzureADAdminRolesReportMSGraph"){ # This curly bracket opens the if/else statement that checks if C:\Temp\AzureADAdminRolesReportMSGraph exists.

    Write-Host "C:\Temp\AzureADAdminRolesReportMSGraph already exists."
}

else{

    cd C:\
    md Temp\AzureADAdminRolesReportMSGraph > $null

    Write-Host "A directory called 'Temp\AzureADAdminRolesReportMSGraph' was created at C:\"
} # This curly bracket closes the if/else statement that checks if C:\Temp\AzureADAdminRolesReportMSGraph exists.

cd C:\Temp\AzureADAdminRolesReportMSGraph

Write-Host "Checking if the required modules are installed and loaded..."

Start-Sleep -Milliseconds 1500

$RequiredModules = "Microsoft.Graph.Authentication","Microsoft.Graph.Users","Microsoft.Graph.Identity.DirectoryManagement"

foreach($module in $RequiredModules){

    if(Get-InstalledModule -Name $module){ # This curly bracket opens the if/else statement that checks if the required modules are installed.

        Write-Host "
        Confirmed the" $module "module is installed."

        if(Get-Module -Name $module){ # This curly bracket opens the if/else statement that checks if the required modules are loaded.

            Write-Host "
        Confirmed the" $module "module is loaded."
        }

        else{

            Import-Module -Name $module

            Write-Host "
        The" $module "Module was successfully loaded."
        } # This curly bracket closes the if/else statement that checks if the required modules are loaded.
    } # This curly bracket closes the if/else statement that checks if the required modules are installed.

    else{

        Install-Module -Name $module -Scope CurrentUser
        Import-Module -Name $module

        Write-Host "
        The" $module "Module was successfully installed and loaded."
    }
} # This curly bracket closes the foreach loop that runs the installed/imported check for each required module.

Write-Host "In 3 seconds you will be prompted for Global Administrator credentials to connect to Microsoft Graph..."

Start-Sleep -Seconds 3

Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"  -ContextScope Process -NoWelcome # The "Process" ContextScope prevents new PS sessions from using previously used credentials to authenticate and run the report, so it prompts for authentication every time.

$DirectoryRoles = Get-MgDirectoryRole | Select DisplayName, Id # This command gets a list of the AAD admin roles that have ever been assigned (it seems that's the way Get-MgDirectoryRole works) and selects the display name and GUID of each admin role.

foreach($role in $DirectoryRoles){ # This curly bracket opens the foreach loop that gets the member list of each AAD admin role and outputs it to CSV.

    Write-Host "Checking assignments for the following role:" ($role.DisplayName).ToString()
    
    Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id | Select @{N="Azure AD Role"; E={$role.DisplayName}}, @{N="DisplayName"; E={$_.additionalProperties['displayName']}}, @{N="UserPrincipalName"; E={$_.additionalProperties['userPrincipalName']}} | Export-CSV .\AzureADAdminRolesReportMSGraph.csv -NoTypeInformation -Append
} # This curly bracket closes the foreach loop that gets the member list of each AAD admin role and outputs it to CSV.

# References

# Reference URL: https://stackoverflow.com/questions/73542815/display-hashtable-values-from-msgraph-output # Referenced content: @{E={$_.additionalProperties['displayName']}}