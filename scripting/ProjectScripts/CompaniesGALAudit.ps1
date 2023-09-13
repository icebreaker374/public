if(Test-Path "C:\Temp\CompaniesGALAudit"){ # This curly bracket opens the if/else statement that checks if C:\Temp exists.

    Write-Host "C:\Temp\CompaniesGALAudit already exists."
}

else{

    cd C:\
    md Temp\CompaniesGALAudit > $null

    Write-Host "A directory called 'CompaniesGALAudit' was created at 'C:\Temp'"
} # This curly bracket closes the if/else statement that checks if C:\Temp exists.

cd C:\Temp\CompaniesGALAudit

$ClientInfo = Import-CSV C:\Temp\CompaniesInfo.csv

foreach($client in $ClientInfo){

    $currentClient = $client.OrgDisplayName
    
    $UserCSVExportPath = $PWD.ToString() + "\" + ($client.OrgDisplayName).ToString() + "_UserList.csv"
    
    Write-Host "
In 3 seconds, you will be prompted to login with Global Administrator credentials to connect to MSOnline for the following tenant to pull a list of users:" ($client.OrgDisplayName).ToString()
    
    Start-Sleep -Seconds 3
    
    Connect-MsolService

    Get-MsolUser -All | Where-Object {($_.UserPrincipalName -Match $client.PrimaryDomain) -and ($_.UserPrincipalName -NotMatch "#EXT#") -and ($_.isLicensed -EQ $true)} | Select DisplayName, UserPrincipalName | Sort UserPrincipalName | Export-CSV -NoTypeInformation $UserCSVExportPath
    
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
    
    foreach($client in $ClientInfo){

        if($client.OrgDisplayName -notmatch $currentClient){
        
            Write-Host "
In 3 seconds, you will be prompted to login with Global Administrator credentials to connect to Exchange Online for:" ($client.OrgDisplayName).ToString()
            
            Start-Sleep -Seconds 3
            
            Connect-ExchangeOnline -ShowBanner:$false

            Write-Host "
In 3 seconds, you will be prompted to login with Global Administrator credentials to connect to MSOnline for:" ($client.OrgDisplayName).ToString()
            
            Start-Sleep -Seconds 3
            
            Connect-MsolService
            
            $UsersInTenant = Import-CSV -Path $UserCSVExportPath
            
            $UsersNotContactInOtherTenantsPath = ($currentClient).ToString() + "_Users_NotContactIn_" + ($client.OrgDisplayName).ToString() + ".csv"
            
            foreach($user in $UsersInTenant){

                if(Get-MailContact -Identity $user.UserPrincipalName -ErrorAction SilentlyContinue){

                }

                else{
                
                Write-Host "
User:" $user.UserPrincipalName "does not exist in:" $client.OrgDisplayName "as a mail contact."

                $user.DisplayName + ",                " + $user.UserPrincipalName | Out-File $UsersNotContactInOtherTenantsPath -Append
                                
                }            

            }

            Write-Host "
A report of" $currentClient "users not in" $client.OrgDisplayName "as contacts was generated at:" $UsersNotContactInOtherTenantsPath

            Write-Host "
Disconnecting from Exchange Online for the following tenant:" ($client.OrgDisplayName).ToString()

            Disconnect-ExchangeOnline

            Start-Sleep -Seconds 2

            Write-Host "
Disconnecting from MSOnline for the following tenant:" ($client.OrgDisplayName).ToString()

            [Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()
           
            Start-Sleep -Seconds 2

        }

        else{

            Write-Host "
Users for" ($client.OrgDisplayName).ToString() "will not be checked as mail contacts in" ($client.OrgDisplayName).ToString()
        }
    }

}

# Referenced content:

# Reference URL: https://www.easy365manager.com/how-to-disconnect-from-msolservice/ Referenced content: [Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()    

# Reference URL: https://superuser.com/questions/1116643/why-does-export-csv-prompt-me-for-an-inputobject Referenced content: $result += $Mailbox.DisplayName + "," + $mailbox.Alias + "," + $mailbox.ServerName + "," + $user.Samaccountname + "," + $user.Surname + "," + $user.Enabled | Out-file $exportto -Append
