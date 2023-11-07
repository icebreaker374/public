Write-Host "Checking if C:\Temp\UnblockedUsersReport already exists..."

Start-Sleep -Milliseconds 1500

if(Test-Path "C:\Temp\UnblockedUsersReport"){
    
    Write-Host "
C:\Temp\UnblockedUsersReport already exists."
}

else{
    
    cd C:\
    md Temp\UnblockedUsersReport > $null
    
    Write-Host "
A directory called 'Temp\UnblockedUsersReport' was created at 'C:\'"
}

if(Get-InstalledModule MSOnline){ # This curly bracket opens the if/else statement that checks if the MSOnline module is installed.

    Write-Host "
Confirmed the MSOnline PowerShell module is installed."

    if(Get-Module MSOnline){ # This curly bracket opens the if/else statement that checks if the MSOnline module is loaded.

        Write-Host "
Confirmed the MSOnline PowerShell Module is loaded."
    }

    else{
    
        Import-Module MSOnline

        Write-Host "
The MSOnline PowerShell Module was successfully loaded."
    } # This curly bracket closes the if/else statement that checks if the MSOnline module is loaded.

} # This curly bracket closes the if/else statement that checks if the MSOnline module is installed.

else{

    Install-Module MSOnline -Scope CurrentUser
    Import-Module MSOnline

    Write-Host "
The MSOnline PowerShell module was successfully installed and loaded."
} # This is where the checks for C:\Temp, installed modules, and imported modules end.

Write-Host "
You will be prompted to login with User/Global Admin credentials to connet to MSOnline in 5 seconds..."

Connect-MsolService

$ReportExportPath = $PWD.ToString() + "\OpenUnlicensedUsersReport.csv" # This command defines the export path for the report with unlicensed users that DO NOT have sign-in blocked.

Write-Host "A list of unlicensed users that DO NOT have sign-in blocked will be generated at" $ReportExportPath.ToString()

Get-MsolUser -All -EnabledFilter EnabledOnly| Where-Object {($_.isLicensed -eq $false) -and ($_.UserPrincipalName -NotMatch "onmicrosoft.com") -and ($_.UserPrincipalName -NotMatch "EXT")} | Select-Object UserPrincipalName | Export-CSV $ReportExportPath -NoTypeInformation
# This command gets a list of all the users that DO NOT have sign in blocked and are unlicensed, where their UPN DOES NOT match that of an external user or the clients .onmicrosoft.com domain, and exports a CSV with the UPN of all the users that meet this criteria.
