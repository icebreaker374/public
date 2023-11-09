if(Test-Path "C:\Temp\CompaniesGALAudit"){ # This curly bracket opens the if/else statement that checks if C:\Temp exists.

    Write-Host "C:\Temp\CompaniesGALAudit already exists."
}

else{

    cd C:\
    
    md Temp\CompaniesGALAudit > $null

    Write-Host "A directory called 'CompaniesGALAudit' was created at 'C:\Temp'"
} # This curly bracket closes the if/else statement that checks if C:\Temp exists.

cd C:\Temp\CompaniesGALAudit

Start-Sleep -Seconds 1.5

Write-Host "Checking if the required modules are installed and loaded..." 

$RequiredModules = "ExchangeOnlineManagement","MSOnline"

foreach($module in $RequiredModules){ # This curly bracket opens the foreach loop that runs the installed/imported check for each required module.

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

$ClientInfo = Import-CSV C:\Temp\CompaniesInfo.csv

foreach($client in $ClientInfo){ # This curly bracket opens the top level foreach loop that begins the process of verifying if a companys current users exist as contacts in the other companies Exchange environments.  This top level loop simply dumps the list of current users in the current tenant pulled from the CSV into it's own CSV file based on the companys name.

    $currentClient = $client.OrgDisplayName    
    $UserCSVExportPath = $PWD.ToString() + "\" + ($client.OrgDisplayName).ToString() + "_UserList.csv"
    
    Write-Host "
In 3 seconds, you will be prompted to login with Global Administrator credentials to connect to MSOnline for the following tenant to pull a list of users:" ($client.OrgDisplayName).ToString()
    
    Start-Sleep -Seconds 3
    
    Connect-MsolService

    Write-Host "
Connected to MSOnline for" ($client.OrgDisplayName).ToString() "and user list will be generated."

    Start-Sleep -Seconds 1
    
    Get-MsolUser -All | Where-Object {($_.UserPrincipalName -Match $client.PrimaryDomain) -and ($_.UserPrincipalName -NotMatch "#EXT#") -and ($_.isLicensed -EQ $true)} | Select DisplayName, FirstName, LastName, @{Name="EmailAddress"; Expression={($_.UserPrincipalName)}}, @{Name="SplitUPN"; Expression={($_.UserPrincipalName).Split("@")[0]}}, @{Name="Organization"; Expression={($client.OrgDisplayName).ToString()}} | Sort UserPrincipalName | Export-CSV -NoTypeInformation $UserCSVExportPath
    # ^^^^^
    # This command will generate a list of users where their UPN suffix is not that of an external user, their UPN suffix DOES match their primary domain, and the user has a license assigned to them.  It then dumps the list of users into a CSV, and only exports their Display Name, Email Address/Username, and their username minus the @domain.com domain suffix (this is important for creation of mail contacts later in the script). 

    Write-Host "
A CSV with all licensed non-guest/external users in" ($client.OrgDisplayName).ToString() "was generated."

    Start-Sleep -Seconds 1
    
    Write-Host "
The report can be found at:" ($UserCSVExportPath).ToString()

    Start-Sleep -Seconds 1
    
    Write-Host "
Disconnecting from MSOnline for the following tenant:" ($client.OrgDisplayName).ToString()
    
    [Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()

    Write-Host "
Waiting 2 seconds before continuing..."

    Start-Sleep -Seconds 2
    
    foreach($client in $ClientInfo){ # This curly bracket is where the process of checking if the users in the current companys tenant exist in the others as mail contacts.  This process is repeated for all companies in the CSV imported at the beginning of the script.

        if($client.OrgDisplayName -notmatch $currentClient){ # This curly bracket opens the if/else statement that prevents you from checking if users exist as contacts in their home tenant.
        
            Write-Host "
In 3 seconds, you will be prompted to login with Global Administrator credentials to connect to Exchange Online for:" ($client.OrgDisplayName).ToString()
            
            Start-Sleep -Seconds 3
            
            Connect-ExchangeOnline -ShowBanner:$false

            Write-Host "
Connected to Exchange Online for:" ($client.OrgDisplayName).ToString()

            Start-Sleep -Seconds 1
            
            Write-Host "
In 3 seconds, you will be prompted to login with Global Administrator credentials to connect to MSOnline for:" ($client.OrgDisplayName).ToString()
            
            Start-Sleep -Seconds 3
            
            Connect-MsolService

            Write-Host "
Connected to MSOnline for:" ($client.OrgDisplayName).ToString()
            
            $UsersInTenant = Import-CSV -Path $UserCSVExportPath            
            $UsersNotContactInOtherTenantsPath = ($currentClient).ToString() + "_Users_NotExistAsContactIn_" + $client.OrgDisplayName + ".csv"
            $UsersFailedToAddAsContactInOtherTenantsPath = ($currentClient).ToString() + "_Users_FailedToAddAsContactIn_" + $client.OrgDisplayName + ".csv"
            $UsersAddedAsContactInOtherTenantsPath = ($currentClient).ToString() + "_Users_AddedAsContactIn_" + $client.OrgDisplayName + ".csv"
            
            foreach($user in $UsersInTenant){ # This curly bracket opens the foreach loop that actually checks if each user in the current companys tenant exists in all of the others as a contact.  If not it writes the fact that it doesn't to the PowerShell terminal output and dumps the users display name and email address to a CSV file.

                if(Get-MailContact -Identity $user.EmailAddress -ErrorAction SilentlyContinue){ # This curly bracket opens the if/else statement is what actually checks if the user exists in each of the other tenants as a contact and writes the output to the terminal and to a CSV if it doesn't.

                    Write-Host "
Confirmed the the user" $user.DisplayName "("$user.EmailAddress")" "exists as a mail contact in" $client.OrgDisplayName " and the script will now move on to the next user."
                }

                else{
                
                    Write-Host "
User" $user.DisplayName "("$user.EmailAddress")" "does not exist in" $client.OrgDisplayName "as a mail contact and will be added."
                    
                    New-MailContact -Name $user.DisplayName -ExternalEmailAddress $user.EmailAddress -Alias $user.SplitUPN -FirstName $user.FirstName -LastName $user.LastName -ErrorAction SilentlyContinue -Confirm:$false | Out-Null

                    if($Error.Exception -Match "Ex55FBCD"){ # This curly bracket opens the if/else statement that checks the error reason and sets the error info accordingly.

                        $ErrorDescription = "There is already another Exchange object using the name: " + $user.DisplayName
                    }

                    elseif($Error.Exception -Match "Ex1472D1"){

                        $ErrorDescription = "User exists as a guest user in Azure AD/Entra ID."
                    }

                    else{
                    } # This curly bracket closes the if/else statement that checks the error reason and sets the error info accordingly.

                    $Error.Clear()
                    
                    if(Get-MailContact -Identity $user.EmailAddress -ErrorAction SilentlyContinue){

                        Write-Host "
Confirmed the user" $user.DisplayName "("$user.EmailAddress")" "was added as a mail contact in" $client.OrgDisplayName "and the script will now move on to the next user."

                        $UserErrorInfo = $user.DisplayName + "," + $user.EmailAddress | Out-File $UsersAddedAsContactInOtherTenantsPath -Append
                    }

                    else{

                        Write-Host "
Failed to add" $user.DisplayName "("$user.EmailAddress")" "as a mail contact in" $client.OrgDisplayName "please add manually via the Exchange Admin Center."
                    
                        $user.DisplayName + "," + $user.EmailAddress + "," + $ErrorDescription | Out-File $UsersFailedToAddAsContactInOtherTenantsPath -Append
                    }

                    $Error.Clear()

                $user.DisplayName + "," + $user.EmailAddress | Out-File $UsersNotContactInOtherTenantsPath -Append
                } # This curly bracket opens the if/else statement is what actually checks if the user exists in each of the other tenants as a contact.
            } # This curly bracket closes the foreach loop that actually checks if each user in the current companys tenant exists in all of the others as a contact.
            
            $FullUsersNotContactInOtherTenantsPath = $PWD.ToString() + "\" + $UsersNotContactInOtherTenantsPath.ToString()
            $FullUsersFailedToAddAsContactInOtherTenantsPath = $PWD.ToString() + "\" + $UsersFailedToAddAsContactInOtherTenantsPath.ToString()
            $FullUsersAddedAsContactInOtherTenantsPath = $PWD.ToString() + "\" + $UsersAddedAsContactInOtherTenantsPath.ToString()
            
            if(Test-Path $FullUsersNotContactInOtherTenantsPath){
                
                Write-Host "
A report of" $currentClient "users not in" $client.OrgDisplayName "as contacts on the global address list was generated at:" $FullUsersNotContactInOtherTenantsPath
            }

            else{

                Write-Host "
No" $currentClient "users are missing as contacts from the global address list for:" $client.OrgDisplayName
            }

            if(Test-Path $FullUsersFailedToAddAsContactInOtherTenantsPath){
                
                Write-Host "
A report of" $currentClient "users that were not successfully added as contacts for" $client.OrgDisplayName "was generated at:" $FullUsersFailedToAddAsContactInOtherTenantsPath "please add these manually via the Exchange Admin Center."
            }

            else{

                Write-Host "
No errors occured when adding" $currentClient "users as contacts to the global address list for:" $client.OrgDisplayName
            }

            if(Test-Path $FullUsersAddedAsContactInOtherTenantsPath){
                
                Write-Host "
A report of" $currentClient "users that were added as contacts to the global address list for:" $client.OrgDisplayName "was generated at:" $FullUsersAddedAsContactInOtherTenantsPath
            }

            else{

                Write-Host "
No" $currentClient "users were added as contacts from the global address list for" $client.OrgDisplayName "please verify the other reports that no users failed to be added."
            }

            Start-Sleep -Seconds 1

            Write-Host "
Disconnecting from Exchange Online for the following tenant:" ($client.OrgDisplayName).ToString()

            Disconnect-ExchangeOnline -Confirm:$false

            Start-Sleep -Seconds 2

            Write-Host "
Disconnecting from MSOnline for the following tenant:" ($client.OrgDisplayName).ToString()

            [Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()
           
            Start-Sleep -Seconds 2
        } # This curly bracket closes the if/else statement that prevents you from checking if users exist as contacts in their home tenant.

        else{

            Write-Host "
Users for:" ($client.OrgDisplayName).ToString() "will not be checked as mail contacts in:" ($client.OrgDisplayName).ToString()
        }    
    } # This curly bracket is where the process of checking if the users in the current companys tenant exist in the others as mail contacts.  This process is repeated for all companies in the CSV imported at the beginning of the script.
} # This curly bracket closes the top level foreach loop that begins the process of verifying if a companies current users exist as contacts in the other companies Exchange environments.

$files = Get-ChildItem | Where-Object {($_.Name -Match ".csv")} | Select FullName

foreach($file in $files){ # This curly bracket opens a the foreach loop that runs a function to delete the UserList.csv files used temporarily by the script to reference information.

    if($file.FullName -Match "UserList.csv"){ # This curly bracket opens the if statement that checks if filenames contain the string "UserList.csv" and deletes the ones that do.

        Remove-Item $file.FullName

        Write-Host "Deleted the following temporary user list CSV:" $file.FullName
    } # This curly bracket closes the if statement that checks if filenames contain the string "UserList.csv" and deletes the ones that do.
} # This curly bracket opens a the foreach loop that runs a function to delete the UserList.csv files used temporarily by the script to reference information.

foreach($file in $files){ # This curly bracket opens the foreach loop that runs a function to delimit all the non-delimited reports generated by the script.

    $FullFilePath = $file.FullName
    $Data = Get-Content -Path $FullFilePath
    $Header = "DisplayName,EmailAddress,ErrorDescription"

    Set-Content $FullFilePath -Value $Header
    Add-Content -Path $FullFilePath -Value $Data

    Write-Host "Delimited the following report:"  $file.FullName

} # This curly bracket opens the foreach loop that runs a function to delimit all the non-delimited reports generated by the script.

Write-Host "Waiting 5 seconds before closing automatically..."

Start-Sleep -Seconds 5

# Referenced content:

# Reference URL: https://www.easy365manager.com/how-to-disconnect-from-msolservice/ Referenced content: [Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()    

# Reference URL: https://superuser.com/questions/1116643/why-does-export-csv-prompt-me-for-an-inputobject Referenced content: $result += $Mailbox.DisplayName + "," + $mailbox.Alias + "," + $mailbox.ServerName + "," + $user.Samaccountname + "," + $user.Surname + "," + $user.Enabled | Out-file $exportto -Append

# Reference URL: https://stackoverflow.com/questions/10496885/powershell-error-handling-do-something-if-no-error-occured Referenced content: if (!$error)

# Reference URL: https://powershellmagazine.com/2013/01/01/pstip-how-to-clear-the-error-variable/ Referenced content: $error.Clear()

# Reference URL: https://superuser.com/questions/1731579/adding-header-to-csv-file-using-powershell Referenced content: $File = 'O:\Temp\Import.csv'
#                                                                                                                       $Data = Get-Content -Path $File
#                                                                                                                       $Header = "Username,Login email,Identifier,First name,Last name"
#                                                                                                                       Set-Content $File -Value $Header
#                                                                                                                       Add-Content -Path $File -Value $Data
