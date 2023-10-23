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

Connect-ExchangeOnline -ShowBanner:$false

$AllMailboxes = Get-Mailbox -ResultSize Unlimited

foreach($mailbox in $AllMailboxes){

    $TrustedSenderDomainList = Get-MailboxJunkEmailConfiguration -Identity $mailbox.Identity | Select -ExpandProperty TrustedSendersAndDomains
    $MailboxDisplayName = $mailbox.DisplayName
    $TrustedSenderDomainFilePath = "$PWD\TrustedSendersAndDomainsfor$MailboxDisplayName.txt"

    $TrustedSenderDomainList | Out-File $TrustedSenderDomainFilePath

    $BlockedSenderDomainList = Get-MailboxJunkEmailConfiguration -Identity $mailbox.Identity | Select -ExpandProperty BlockedSendersAndDomains
    $MailboxDisplayName = $mailbox.DisplayName
    $BlockedSenderDomainFilePath = "$PWD\BlockedSendersAndDomainsfor$MailboxDisplayName.txt"

    $BlockedSenderDomainList | Out-File $BlockedSenderDomainFilePath
}