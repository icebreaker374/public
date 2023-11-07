# The following if/else statement checks if C:\Temp already exists, if it doesn't it creates it as a working directory.

if(Test-Path "C:\Temp\SharedMailboxDelegatedAccessReport"){

    Write-Host "C:\Temp\SharedMailboxDelegatedAccessReport already exists."
}

else{
    
    cd C:\
    md Temp\SharedMailboxDelegatedAccessReport > $null

    Write-Host "A directory called 'Temp\SharedMailboxDelegatedAccessReport' was created at 'C:\'"
}

cd C:\Temp\SharedMailboxDelegatedAccessReport

if(Get-InstalledModule ExchangeOnlineManagement){ # This curly bracket opens the if/else statement that checks if the ExchangeOnlineManagement module is installed.

    Write-Host "
Confirmed the ExchangeOnlineManagement PowerShell module is installed."

    if(Get-Module ExchangeOnlineManagement){ # This curly bracket opens the if/else statement that checks if the ExchangeOnlineManagement module is loaded.

        Write-Host "
Confirmed the ExchangeOnlineManagement PowerShell Module is loaded."
    }

    else{
    
        Import-Module ExchangeOnlineManagement

        Write-Host "
The ExchangeOnlineManagement PowerShell Module was successfully loaded."
    } # This curly bracket closes the if/else statement that checks if the ExchangeOnlineManagement module is loaded.
} # This curly bracket closes the if/else statement that checks if the ExchangeOnlineManagement module is installed.

else{

    Install-Module ExchangeOnlineManagement -Scope CurrentUser
    Import-Module ExchangeOnlineManagement

    Write-Host "
The ExchangeOnlineManagement PowerShell module was successfully installed and loaded."
}

# Prompts the user for a file name to dump the primary SMTP address of all mailboxes in the tenant into in CSV format, waits 5 seconds, then prompts for Exchange/Global admin credentials
# to run the command to pull said list into a CSV.

$AllMailboxesCSVPath = "C:\Temp\SharedMailboxDelegatedAccessReport\Mailboxes.csv"

Write-Host "
In 3 seconds, you will be prompted to login with Global Administrator credentials to connect to Exchange Online..."

Start-Sleep -Seconds 3

Connect-ExchangeOnline -ShowBanner:$false

# The following command pulls a list of every mailbox in the Exchange environment and dumps a list with each mailboxes PrimarySMTPAddress into a CSV.

Get-Mailbox -ResultSize Unlimited | Select PrimarySMTPAddress, DisplayName | Sort PrimarySMTPAddress | Export-CSV $AllMailboxesCSVPath -NoTypeInformation

# Imports the CSV with the list of primary SMTP addresses for all mailboxes in the Exchange environment.

$Mailboxes = Import-CSV $AllMailboxesCSVPath

# Each of the following foreach loops will check against the CSV containing the PrimarySMTPAddress of every shared mailbox in the Exchange environment and pulls the Send As, Send on Behalf of, and Read and Manage permissions for each one, then appends every entry to their respective CSV reports.

# This script excludes instances where the mailbox owner can send as themselves, because obviously we know that already.

foreach($mailbox in $Mailboxes){Get-MailboxPermission $mailbox.PrimarySmtpAddress | Where {$_.user.tostring() -ne "NT AUTHORITY\SELF"} | Select @{N="MailboxOwnerDisplayName"; E={$mailbox.DisplayName}}, @{N="MailboxOwnerAddress"; E={$mailbox.PrimarySmtpAddress}}, User, AccessRights | Export-CSV .\AllMailboxesFullAccessReport.csv -NoTypeInformation -Append}

foreach($mailbox in $Mailboxes){Get-RecipientPermission $mailbox.PrimarySmtpAddress | Where Trustee -ne "NT AUTHORITY\SELF" | Select @{N="MailboxOwnerDisplayName"; E={$mailbox.DisplayName}}, @{N="MailboxOwnerAddress"; E={$mailbox.PrimarySmtpAddress}}, @{N="User"; E={$_.Trustee}}, AccessRights | Export-CSV .\AllMailboxesSendAsReport.csv -NoTypeInformation -Append}

foreach($mailbox in $Mailboxes){Get-Mailbox $mailbox.PrimarySmtpAddress | Where {$_.GrantSendOnBehalfTo -ne $null} | Select @{N="MailboxOwnerDisplayName"; E={$mailbox.DisplayName}}, @{N="MailboxOwnerAddress"; Expression={$mailbox.PrimarySmtpAddress}}, @{N='SendOnBehalfOf';E={$_.GrantSendOnBehalfTo -join ", "}} | Export-CSV .\AllMailboxesSendOnBehalfReport.csv -NoTypeInformation -Append}

Remove-Item -Path $AllMailboxesCSVPath # This command deletes the Mailboxes.csv file the script creates to reference the mailboxes and pull permission reports.

# References:

# Reference URL: https://community.spiceworks.com/topic/2173426-get-mailboxpermission-helpdesk: Referenced content: @{Name="Displayname"; Expression={(Get-Recipient $_.user.ToString()).Displayname.ToString()}}
# Reference URL: https://www.slipstick.com/exchange/find-users-send-behalf-permission/ Referenced context: where {$_.GrantSendOnBehalfTo -ne $null} and @{l='SendOnBehalfOf';e={$_.GrantSendOnBehalfTo -join ";"}}