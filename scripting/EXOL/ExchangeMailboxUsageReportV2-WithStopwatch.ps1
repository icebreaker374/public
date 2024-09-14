$ScriptStopWatch = [System.Diagnostics.Stopwatch]::new()
$ScriptStopWatch.Start()

$DateTime = Get-Date -Format "M-dd-yyyy-hmmtt"

$Licenses =  Import-CSV "Path\MicrosoftLicenses.csv" -Header LicenseId,LicenseName
$LicensesHashTable = @{}
foreach($license in $Licenses){
    $LicensesHashTable[$license.LicenseId]=$license.LicenseName
}

Write-Host "In 3 seconds you'll be presented a new browser window to authenticate with the Partner Center..."

Start-Sleep -Seconds 3

Connect-PartnerCenter -WarningAction SilentlyContinue | Out-Null

$CustomerList = Import-CSV "PathTo\Customers.csv"

foreach($customer in $CustomerList){

    $CustomerCounter = $customer.Counter
    $CustomerName = $customer.Name
    Write-Host "[$CustomerCounter] $CustomerName"
}

$ClientConnection = Read-Host "Enter the number corresponding to the client whose environment you want to connect to"
$ClientInfo = $CustomerList | Where {$_.Counter -EQ $ClientConnection} | Select Name, Domain, CustomerId
$ClientName = $ClientInfo.Name
$ClientId = $ClientInfo.CustomerId
$ClientDomain = $ClientInfo.Domain

$ReportPath = "PathTo\Reports\$ClientName\Exchange Mailbox Usage Reports"

if(Test-Path $ReportPath){

    Write-Host "Exchange mnailbox usage reports directory for $ClientName already exists."
}

else{
    
    md $ReportPath | Out-Null
    Write-Host "Exhange mailbox usage reports directory for $ClientName was created."
}

Start-Sleep -Seconds 2

cd $ReportPath

Write-Host "In 3 seconds you'll be prompted to authenticate to Exchange Online and Entra for $ClientName..."
Write-Host "There will be a delay between receiving both authentication prompts of 10-15 seconds."

Start-Sleep -Seconds 3

Connect-ExchangeOnline -DelegatedOrganization $ClientDomain -ShowBanner:$false

Connect-AzureAD -TenantId $ClientId -WarningAction SilentlyContinue | Out-Null

$Mailboxes = Get-Mailbox -Filter "DisplayName -NotLike 'Discovery Search*'" -ResultSize Unlimited | Sort DisplayName | Select DisplayName, UserPrincipalName, ProhibitSendQuota, ArchiveQuota, RecipientTypeDetails

$MailboxesLT70PercentCounter = 0
$MailboxesGE70LT90PercentCounter = 0
$MailboxesGE90PercentCounter = 0
$ArchivesLT70PercentCounter = 0
$ArchivesGE70LT90PercentCounter = 0
$ArchivesGE90PercentCounter = 0

foreach($mailbox in $Mailboxes){

    $UserStopWatch = [System.Diagnostics.Stopwatch]::new()
    $UserStopWatch.Start()
    
    $MailboxName = $mailbox.DisplayName
    $MailboxEmail = $Mailbox.UserPrincipalName
    $MailboxType = $mailbox.RecipientTypeDetails

    Write-Host "Collecting mailbox stats for $MailboxName ($MailboxEmail)"

    $MailboxStats = Get-MailboxStatistics -Identity $mailbox.UserPrincipalName

    $MailboxSize = ((($MailboxStats.TotalItemSize.Value).ToString()).SubString(0, (($MailboxStats.TotalItemSize.Value).ToString()).IndexOf("B")+1)).Replace(" ", "")
    $ProhibitSendQuota = (($mailbox.ProhibitSendQuota).SubString(0, [int](($mailbox.ProhibitSendQuota).IndexOf("B")+1))).Replace(" ", "")

    $PercentToStorageQuota = (([string]([decimal]::round((($MailboxSize/$ProhibitSendQuota)), 4))).Split(".")[1]).Insert(2, ".") + "%"

    if($PercentToStorageQuota -Match "00.00%"){

        $PercentToStorageQuota = "<00.01%"
    }

    else{}

    $ArchiveStats = Get-MailboxStatistics -Identity $mailbox.UserPrincipalName -Archive -ErrorAction SilentlyContinue

    if($ArchiveStats -NE $null){

        $ArchiveSize = ((($ArchiveStats.TotalItemSize.Value).ToString()).SubString(0, (($ArchiveStats.TotalItemSize.Value).ToString()).IndexOf("B")+1)).Replace(" ", "")
        $ArchiveQuota = (($mailbox.ArchiveQuota).SubString(0, [int](($mailbox.ArchiveQuota).IndexOf("B")+1))).Replace(" ", "")

        $PercentToArchiveQuota = (([string]([decimal]::round((($ArchiveSize/$ArchiveQuota)), 4))).Split(".")[1]).Insert(2, ".") + "%"

        if($PercentToArchiveQuota -Match "00.00%"){

            $PercentToArchiveQuota = "<00.01%"
        }

        else{}
    }

    else{

        $ArchiveQuota = "N/A"
        $PercentToArchiveQuota = "N/A"
        $ArchiveSize = "N/A"
    }

    $UserLicenses = Get-AzureADUser -ObjectId $mailbox.UserPrincipalName | Select AssignedLicenses

    if($UserLicenses -NE $null){
    
        foreach($userlicense in $UserLicenses.AssignedLicenses){

            $LicenseInfo = $userlicense.SkuId
            $UserLicenseNames += $LicensesHashTable.Item("$LicenseInfo") + ", "
        }

        if($UserLicenseNames -EQ $null){

            $UserLicenseNames = ""
        }

        else{}
    }

    else{}

    # Conditional formatting with Export-Excel for Mailbox Usage value.
    
    if($PercentToStorageQuota -LT "70.00%"){

        $ConditionalText = New-ConditionalText -Text "$PercentToStorageQuota" -BackgroundColor Lime -ConditionalTextColor Black
        $MailboxesLT70PercentCounter++
    }

    elseif(($PercentToStorageQuota -GE "70.00%") -and ($PercentToStorageQuota -LT "90.00%")){

        $ConditionalText = New-ConditionalText -Text "$PercentToStorageQuota" -BackgroundColor Yellow -ConditionalTextColor Black
        $MailboxesGE70LT90PercentCounter++
    }

    elseif($PercentToStorageQuota -GE "90.00%"){

        $ConditionalText = New-ConditionalText -Text "$PercentToStorageQuota" -BackgroundColor Red -ConditionalTextColor Black
        $MailboxesGE90PercentCounter++
    }

    else{}

    # Conditional formatting with Export-Excel for Archive Usage value.

    if($PercentToArchiveQuota -NotMatch "N/A"){

        if($PercentToArchiveQuota -LT "70.00%"){
        
            $ConditionalText2 = New-ConditionalText -Text "$PercentToArchiveQuota" -BackgroundColor Lime -ConditionalTextColor Black
            $ArchivesLT70PercentCounter++
        }

        elseif(($PercentToArchiveQuota -GE "70.00%") -and ($PercentToArchiveQuota -LT "90.00%")){

            $ConditionalText2 = New-ConditionalText -Text "$PercentToArchiveQuota" -BackgroundColor Yellow -ConditionalTextColor Black
            $ArchivesGE70LT90PercentCounter++
        }

        elseif($PercentToArchiveQuota -GE "90.00%"){

            $ConditionalText2 = New-ConditionalText -Text "$PercentToArchiveQuota" -BackgroundColor Red -ConditionalTextColor Black
            $ArchivesGE90PercentCounter++
        }

        else{}
    }

    else{}

    Get-Mailbox -Identity $mailbox.UserPrincipalName | Select @{N='MailboxType'; E={$MailboxType}}, DisplayName, @{N='UserPrincipalName';E={$MailboxEmail}}, @{N='PercentToStorageCapacity'; E={$PercentToStorageQuota}}, @{N='UsedMailboxCapacity'; E={$MailboxSize}}, @{N='MaxMailboxCapacity'; E={$ProhibitSendQuota}}, @{N='PercentToArchiveCapacity'; E={$PercentToArchiveQuota}}, @{N='UsedArchiveCapacity'; E={$ArchiveSize}}, @{N='MaxArchiveCapacity'; E={$ArchiveQuota}}, @{N='UserLicenses'; E={$UserLicenseNames}} | Export-Excel -Path ".\MailboxUsageReport-$DateTime.xlsx" -ConditionalFormat $ConditionalText,$ConditionalText2 -Append

    $UserLicenseNames = $null
    $ConditionalText = $null
    $ConditionalText2 = $null

    Start-Sleep -Seconds 1.5

    $UserStopWatch.Stop()
    $UserStopWatchSeconds = [string]($UserStopWatch.Elapsed.TotalSeconds)

    "Time to completion for $MailboxName ($MailboxEmail): $UserStopWatchSeconds" | Out-File ".\TimeToCompletionReport-$DateTime.txt" -Append
}

# Summary review section (conditional formatting for mailboxes lower than 70% usage, between 70-90% usage, and above 90%).

$MailboxesLT70PercentCT = New-ConditionalText -Text "Mailboxes lower than 70%: $MailboxesLT70PercentCounter" -BackgroundColor Lime -ConditionalTextColor Black

if($MailboxesGE70LT90PercentCounter -GT 0){

    $MailboxesGE70LT90PercentCT = New-ConditionalText -Text "Mailboxes between 70% and 90%: $MailboxesGE70LT90PercentCounter" -BackgroundColor Yellow -ConditionalTextColor Black
}

else{

    $MailboxesGE70LT90PercentCT = New-ConditionalText -Text "Mailboxes between 70% and 90%: $MailboxesGE70LT90PercentCounter" -BackgroundColor Lime -ConditionalTextColor Black
}

if($MailboxesGE90PercentCounter -GT 0){

    $MailboxesGE90PercentCT = New-ConditionalText -Text "Mailboxes higher than 90%: $MailboxesGE90PercentCounterCounter" -BackgroundColor Red -ConditionalTextColor Black
}

else{

    $MailboxesGE90PercentCT = New-ConditionalText -Text "Mailboxes higher than 90%: $MailboxesGE90PercentCounter" -BackgroundColor Lime -ConditionalTextColor Black
}

$ArchivesLT70PercentCT = New-ConditionalText -Text "Archives lower than 70%: $ArchivesLT70PercentCounter" -BackgroundColor Lime -ConditionalTextColor Black

if($ArchivesGE70LT90PercentCounter -GT 0){

    $ArchivesGE70LT90PercentCT = New-ConditionalText -Text "Archives between 70% and 90%: $ArchivesGE70LT90PercentCounter" -BackgroundColor Yellow -ConditionalTextColor Black
}

else{

    $ArchivesGE70LT90PercentCT = New-ConditionalText -Text "Archives between 70% and 90%: $ArchivesGE70LT90PercentCounter" -BackgroundColor Lime -ConditionalTextColor Black
}

if($ArchivesGE90PercentCounter -GT 0){

    $ArchivesGE90PercentCT = New-ConditionalText -Text "Archives higher than 90%: $ArchivesGE90PercentCounter" -BackgroundColor Red -ConditionalTextColor Black
}

else{

    $ArchivesGE90PercentCT = New-ConditionalText -Text "Archives higher than 90%: $ArchivesGE90PercentCounter" -BackgroundColor Lime -ConditionalTextColor Black
}

"" | Export-Excel -Path ".\MailboxUsageReport-$DateTime.xlsx" -Append
"Mailboxes lower than 70%: $MailboxesLT70PercentCounter" | Export-Excel -Path ".\MailboxUsageReport-$DateTime.xlsx" -Append -StartColumn 1 -ConditionalFormat $MailboxesLT70PercentCT
"Mailboxes between 70% and 90%: $MailboxesGE70LT90PercentCounter" | Export-Excel -Path ".\MailboxUsageReport-$DateTime.xlsx" -Append -StartColumn 1 -ConditionalFormat $MailboxesGE70LT90PercentCT
"Mailboxes higher than 90%: $MailboxesGE90PercentCounter" | Export-Excel -Path ".\MailboxUsageReport-$DateTime.xlsx" -Append -StartColumn 1 -ConditionalFormat $MailboxesGE90PercentCT
"" | Export-Excel -Path ".\MailboxUsageReport-$DateTime.xlsx" -Append
"Archives lower than 70%: $ArchivesLT70PercentCounter" | Export-Excel -Path ".\MailboxUsageReport-$DateTime.xlsx" -Append -StartColumn 1 -ConditionalFormat $ArchivesLT70PercentCT
"Archives between 70% and 90%: $ArchivesGE70LT90PercentCounter" | Export-Excel -Path ".\MailboxUsageReport-$DateTime.xlsx" -Append -StartColumn 1 -ConditionalFormat $ArchivesGE70LT90PercentCT
"Archives higher than 90%: $ArchivesGE90PercentCounter" | Export-Excel -Path ".\MailboxUsageReport-$DateTime.xlsx" -Append -StartColumn 1 -ConditionalFormat $ArchivesGE90PercentCT

$ScriptStopWatch.Stop()
$ScriptStopWatchSeconds = [string]($ScriptStopWatch.Elapsed.TotalSeconds)
"" | Out-File ".\TimeToCompletionReport-$DateTime.txt" -Append
"Time to script completion: $ScriptStopWatchSeconds" | Out-File ".\TimeToCompletionReport-$DateTime.txt" -Append

# Referenced some content from: https://www.thelazyadministrator.com/2018/03/19/get-friendly-license-name-for-all-users-in-office-365-using-powershell/
