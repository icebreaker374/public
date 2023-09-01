# The following if/else statement checks if C:\Temp already exists, if it doesn't it creates it as a working directory.

if(Test-Path "C:\Temp")

{
Write-Host "C:\Temp already exists."
}

else

{
cd C:\
md Temp > $null

Write-Host "A directory called 'Temp' was created at 'C:\'"
}

cd C:\Temp

if(Get-InstalledModule ExchangeOnlineManagement){ # This curly bracket opens the if/else statement that checks if the ExchangeOnlineManagement module is installed.

Write-Host "
Confirmed the ExchangeOnlineManagement PowerShell module is installed."

if(Get-Module ExchangeOnlineManagement){ # This curly bracket opens the if/else statement that checks if the ExchangeOnlineManagement module is loaded.

Write-Host "
Confirmed the AzureAD PowerShell Module is loaded."
}

else

{
    
Import-Module ExchangeOnlineManagement

Write-Host "
The ExchangeOnlineManagement PowerShell Module was successfully loaded."
} # This curly bracket closes the if/else statement that checks if the ExchangeOnlineManagement module is loaded.

} # This curly bracket closes the if/else statement that checks if the ExchangeOnlineManagement module is installed.

else
{

Install-Module ExchangeOnlineManagement -Scope CurrentUser
Import-Module ExchangeOnlineManagement

Write-Host "
The ExchangeOnlineManagement PowerShell module was successfully installed and loaded."

}

# Prompts the user for a file name to dump the primary SMTP address of all mailboxes in the tenant into in CSV format, waits 5 seconds, then prompts for Exchange/Global admin credentials
# to run the command to pull said list into a CSV.

$AllMailboxesCSVPath = Read-Host "
Enter the file name to export a list of mailboxes to like 'Mailboxes.csv'"

# Checks if the file you type in already exists in the C:\Temp directory.

if(Test-Path $AllMailboxesCSVPath)

{
    $FileExists = New-Object PSObject -Property @{ 
    Temp = "C:\Temp\"
    FileName = $AllMailboxesCSVPath
    }
    
    Write-Host "
    "($FileExists.Temp.ToString() + $FileExists.FileName) "already exists.  Please move the file out of C:\Temp and run the script again, this script will close in 5 seconds."

    Start-Sleep -Seconds 5

    exit
}

else

{

Write-Host "
Duplicate file not detected, the script will continue after a 2 second delay."

}


Write-Host "
You will be prompted to login with Exchange/Global Administrator credentials to connect to Exchange Online in 5 seconds..."

Start-Sleep -Seconds 5

Connect-ExchangeOnline

# The following command pulls a list of every mailbox in the Exchange environment and dumps a list with each mailboxes PrimarySMTPAddress into a CSV.

Get-Mailbox -ResultSize Unlimited | Select PrimarySMTPAddress | Export-CSV $AllMailboxesCSVPath -NoTypeInformation

# Imports the CSV with the list of primary SMTP addresses for all mailboxes in the Exchange environment.

$Mailboxes = Import-CSV $AllMailboxesCSVPath

# Each of the following foreach loops will check against the CSV containing the PrimarySMTPAddress of every shared mailbox in the Exchange environment and pulls the Send As,
# Send on Behalf of, and Read and Manage permissions for each one, then appends every entry to their respective CSV reports.

#This script excludes instances where the mailbox owner can send as themselves, because obviously we know that already.

foreach($mailbox in $Mailboxes){Get-MailboxPermission $mailbox.PrimarySmtpAddress | Where {$_.user.tostring() -ne "NT AUTHORITY\SELF"} | Select @{Name="MailboxOwnerAddress"; Expression={(Get-Recipient -Identity $mailbox.PrimarySmtpAddress | Select PrimarySmtpAddress)}}, User, AccessRights | Export-CSV C:\Temp\AllMailboxesFullAccessReport.csv -NoTypeInformation -Append}
foreach($mailbox in $Mailboxes){Get-RecipientPermission $mailbox.PrimarySmtpAddress | Where Trustee -ne "NT AUTHORITY\SELF" | Select @{Name="MailboxOwnerAddress"; Expression={(Get-Recipient -Identity $mailbox.PrimarySmtpAddress | Select PrimarySmtpAddress)}}, Trustee, AccessRights | Export-CSV C:\Temp\AllMailboxesSendAsReport.csv -NoTypeInformation -Append -Force}
foreach($mailbox in $Mailboxes){Get-Mailbox $mailbox.PrimarySmtpAddress | Where {$_.GrantSendOnBehalfTo -ne $null} | Select @{Name="MailboxOwnerAddress"; Expression={(Get-Recipient -Identity $mailbox.PrimarySmtpAddress | Select PrimarySmtpAddress)}}, @{l='SendOnBehalfOf';e={$_.GrantSendOnBehalfTo -join ", "}} | Export-CSV C:\Temp\AllMailboxesSendOnBehalfReport.csv -NoTypeInformation -Append -Force}

# Eliminates the garbage text at the beginning and and of the email addresses in the reports.

(Get-Content -path "C:\Temp\AllMailboxesFullAccessReport.csv" -Raw) -replace '@{PrimarySmtpAddress=', '' | Set-Content -Path "C:\Temp\AllMailboxesFullAccessReport.csv"
(Get-Content -path "C:\Temp\AllMailboxesFullAccessReport.csv" -Raw) -replace '}', '' | Set-Content -Path "C:\Temp\AllMailboxesFullAccessReport.csv"
(Get-Content -path "C:\Temp\AllMailboxesSendAsReport.csv" -Raw) -replace '@{PrimarySmtpAddress=', '' | Set-Content -Path "C:\Temp\AllMailboxesSendAsReport.csv"
(Get-Content -path "C:\Temp\AllMailboxesSendAsReport.csv" -Raw) -replace '}', '' | Set-Content -Path "C:\Temp\AllMailboxesSendAsReport.csv"
(Get-Content -path "C:\Temp\AllMailboxesSendOnBehalfReport.csv" -Raw) -replace '@{PrimarySmtpAddress=', '' | Set-Content -Path "C:\Temp\AllMailboxesSendOnBehalfReport.csv"
(Get-Content -path "C:\Temp\AllMailboxesSendOnBehalfReport.csv" -Raw) -replace '}', '' | Set-Content -Path "C:\Temp\AllMailboxesSendOnBehalfReport.csv"

# References:

# Reference URL: https://community.spiceworks.com/topic/2173426-get-mailboxpermission-helpdesk: Referenced content: @{Name="Displayname"; Expression={(Get-Recipient $_.user.ToString()).Displayname.ToString()}}
# Reference URL: https://www.slipstick.com/exchange/find-users-send-behalf-permission/ Referenced context: where {$_.GrantSendOnBehalfTo -ne $null} and @{l='SendOnBehalfOf';e={$_.GrantSendOnBehalfTo -join ";"}}
