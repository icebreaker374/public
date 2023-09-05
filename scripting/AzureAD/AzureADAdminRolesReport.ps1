# The following if/else statement checks if C:\Temp already exists, if it doesn't it creates it as a working directory.

if(Test-Path "C:\Temp"){

Write-Host "C:\Temp already exists."
}

else{

cd C:\
md Temp > $null

Write-Host "A directory called 'Temp' was created at 'C:\'"
} # This curly bracket is the end of the if/else statement that checks for C:\Temp.

cd C:\Temp

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

}

Write-Host "
You will be prompted to login with Global Administrator credentials to connect to Azure Active Directory in 5 seconds..."

Start-Sleep -Seconds 5

Connect-AzureAD

$DirectoryRoles = Get-AzureADDirectoryRole | Select DisplayName, ObjectId # This command dumps all of the Azure AD roles that have ever been assigned into a variable.

foreach($role in $DirectoryRoles){

# This foreach loop writes the current role it's checking assignments for to the screen then get's a list of users with that role and dumps it into a CSV, then repeats for all
# remaining Azure AD roles.

Write-Host "Checking assignments for the following role:" ($role.DisplayName).ToString()

Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Select @{Name="Azure AD Role"; Expression={$role.DisplayName}}, DisplayName, UserPrincipalName | Export-CSV C:\Temp\AzureADAdminRolesReport.csv -NoTypeInformation -Append -Force

} #This curly bracket closes the foreach loop that checks for all Azure AD role assignments, the script ends here.
