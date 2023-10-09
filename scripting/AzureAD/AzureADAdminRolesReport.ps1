Write-Host "Checking if C:\Temp\AzureADAdminRolesReport exisits..."

Start-Sleep -Milliseconds 1500

if(Test-Path "C:\Temp\AzureADAdminRolesReport"){ # This curly bracket opens the if/else statement that checks if C:\Temp\AzureADAdminRolesReport exists.

    Write-Host "C:\Temp\AzureADAdminRolesReport already exists."
}

else{

    cd C:\
    md Temp\AzureADAdminRolesReport > $null

    Write-Host "
A directory called 'Temp\AzureADAdminRolesReport' was created at 'C:\'"
} # This curly bracket closes the if/else statement that checks if C:\Temp\AzureADAdminRolesReport exists.

cd C:\Temp\AzureADAdminRolesReport

if(Get-InstalledModule AzureAD){ # This curly bracket opens the if/else statement that checks if the AzureAD module is installed.

    Write-Host "
Confirmed the AzureAD PowerShell module is installed."

    if(Get-Module AzureAD){ # This curly bracket opens the if/else statement that checks if the AzureAD module is loaded.

        Write-Host "
Confirmed the AzureAD PowerShell Module is loaded."
    }

    else{
    
        Import-Module AzureAD

        Write-Host "
The AzureAD PowerShell Module was successfully loaded."
    } # This curly bracket closes the if/else statement that checks if the AzureAD module is loaded.

} # This curly bracket closes the if/else statement that checks if the AzureAD module is installed.

else{

    Install-Module AzureAD -Scope CurrentUser
    Import-Module AzureAD

    Write-Host "
The AzureAD PowerShell module was successfully installed and loaded."
} # This is where the checks for C:\Temp, installed modules, and imported modules end.

Write-Host "
You will be prompted to login with Global Administrator credentials to connect to Azure Active Directory in 3 seconds..."

Start-Sleep -Seconds 3

Connect-AzureAD

$DirectoryRoles = Get-AzureADDirectoryRole | Select DisplayName, ObjectId # This command dumps all of the Azure AD roles that have ever been assigned into a variable.

foreach($role in $DirectoryRoles){ # This foreach loop writes the current role it's checking assignments for to the screen then get's a list of users with that role and dumps it into a CSV, then repeats for all remaining Azure AD roles.

    Write-Host "Checking assignments for the following role:" ($role.DisplayName).ToString()

    Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Select @{Name="Azure AD Role"; Expression={$role.DisplayName}}, DisplayName, UserPrincipalName | Export-CSV C:\Temp\AzureADAdminRolesReport.csv -NoTypeInformation -Append

} #This curly bracket closes the foreach loop that checks for all Azure AD role assignments, the script ends here.
