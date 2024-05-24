$DateTime = Get-Date -Format "M-dd-yyyy-hmmtt"

Write-Host "In 3 seconds you'll be presented a new browser window to authenticate with the Partner Center..."

Start-Sleep -Seconds 3

Connect-PartnerCenter -WarningAction SilentlyContinue | Out-Null

$CustomerList = Import-CSV "$env:USERPROFILE\RMON Networks Inc\HD TAM Automation - Scripting\Script Resources\Customers.csv"
$CustomerCounter = 1
$Customers = Get-PartnerCustomer | Select Name, Domain, CustomerId, @{N='Counter'; E={$null}} | Where Name -In $CustomerList.Name | Sort Name -Unique

foreach($customer in $Customers){

    $CustomerName = $customer.Name
    $CustomerDomain = $customer.Domain
    $CustomerTenantId = $customer.CustomerId
    $customer.Counter = $CustomerCounter

    Write-Host "[$CustomerCounter] $CustomerName"

    $CustomerCounter++
}

$ClientConnection = Read-Host "Enter the number corresponding to the client whose environment you want to connect to"
$ClientInfo = $Customers | Where {$_.Counter -EQ $ClientConnection} | Select Name, Domain, CustomerId
$ClientName = $ClientInfo.Name
$ClientId = $ClientInfo.CustomerId
$ClientDomain = $ClientInfo.Domain

$ReportPath = "$env:USERPROFILE\RMON Networks Inc\HD TAM Automation - Scripting\Reports\$ClientName\SPF_DKIM_DMARC_Reports"

if(Test-Path $ReportPath){

    Write-Host "SPF_DKIM_DMARC reports directory for $ClientName already exists."
}

else{
    
    md $ReportPath | Out-Null
    Write-Host "SPF_DKIM_DMARC reports directory for $ClientName was created."
}

cd $ReportPath

Write-Host "In 3 seconds you'll be prompted to authenticate to Entra and Exchange for $ClientName..."

Start-Sleep -Seconds 3

Connect-AzureAD -TenantId $ClientId -WarningAction Ignore | Out-Null
Connect-ExchangeOnline -DelegatedOrganization $ClientDomain -ShowBanner:$false

$DomainList = Get-AzureADDomain -ErrorAction SilentlyContinue | Select Name

$DomainCounter = 1

if($DomainList -EQ $null){

    Write-Host "There was an error retreiving the domains from the tenant"
}

else{

    Write-Host "The SPF/DKIM/DMARC record verification process will begin in 5 seconds..."

    Start-Sleep -Seconds 5
    
    foreach($domain in $DomainList){

        $DomainDisplayName = $domain.Name

        # Begin SPF record check for all domains in tenant.

        $SPFConfigurationCheck = Resolve-DnsName -Name $DomainDisplayName -Type TXT -Server 1.1.1.1 -ErrorAction SilentlyContinue | Where {$_.Strings -Match "v=spf"} | Select -ExpandProperty Strings

        if($Error.Exception -Match "$DomainDisplayName : DNS name does not exist"){

            "Domain: $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 1
            "Unable to retrieve SPF records for: $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 3

            $Error.Clear()
        }

        elseif($SPFConfigurationCheck -EQ $null){

            "Domain: $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 1
            "No SPF records were found for: $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 3
        }

        elseif($SPFConfigurationCheck -NE $null){

            "Domain: $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 1
            "SPF Value: $SPFConfigurationCheck" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 3
        }

        else{

            "Domain: $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 1
            "SPF record status for '$DomainDisplayName' is unknown." | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 3
        }
        
        # End SPF record check for all domains in tenant. Begin DKIM configuration check for all domains in tenant.
        
        $DKIMConfigurationCheck = Get-DkimSigningConfig -Identity $DomainDisplayName -ErrorAction SilentlyContinue | Select Selector1CNAME, Selector2CNAME, Enabled
        
        if($Error.Exception -Match "Ex43C0AC"){

            "DKIM configuration/DKIM keys not created for: $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 6

            $Error.Clear()
        }
        
        $RequiredCNAME1Value = $DKIMConfigurationCheck.Selector1CNAME 
        $RequiredCNAME2VAlue = $DKIMConfigurationCheck.Selector2CNAME

        <# if($Error.Exception -Match "Ex43C0AC"){

            Write-Host "
DKIM configuration/DKIM keys not created for: $DomainDisplayName"
            Write-Host ""

            $Error.Clear()
        }

        else{ #>

            if($DKIMConfigurationCheck.Enabled -EQ $True){

                "M365 DKIM Status: ENABLED" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 5
                "Required CNAMES:" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 6
                "Name/Hostname Value:" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 7
                "Poinst To/Address Value:" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 3 -StartRow 7
                "selector1._domainkey" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 8
                "selector2._domainkey" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 9
                $RequiredCNAME1Value | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 3 -StartRow 8
                $RequiredCNAME1Value | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 3 -StartRow 9
            }

            elseif($DKIMConfigurationCheck.Enabled -EQ $False){

                "M365 DKIM Status: NOT ENABLED" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 5
                "Required CNAMES:" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 6
                "Name/Hostname Value:" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 7
                "Poinst To/Address Value:" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 3 -StartRow 7
                "selector1._domainkey" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 8
                "selector2._domainkey" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 9
                $RequiredCNAME1Value | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 3 -StartRow 8
                $RequiredCNAME1Value | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 3 -StartRow 9
            }

            else{

                "M365 DKIM Status: UNKNOWN" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 5
                "Required CNAMES:" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 6
                "Name/Hostname Value:" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 7
                "Poinst To/Address Value:" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 3 -StartRow 7
                "selector1._domainkey" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 8
                "selector2._domainkey" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 2 -StartRow 9
                $RequiredCNAME1Value | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 3 -StartRow 8
                $RequiredCNAME1Value | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 3 -StartRow 9
            }

            $CNAME1Verification = Resolve-DnsName -Name selector1._domainkey.$DomainDisplayName -Type CNAME -Server 1.1.1.1 -ErrorAction SilentlyContinue | Select *

            if($CNAME1Verification -EQ $Null){

                "CNAME 1 not found for $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 7
            }

            elseif($CNAME1Verification -NE $Null){

                "CNAME 1 found for $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 7
            }

            else{

                "CNAME 1 status unknown for $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 7
            }

            $CNAME2Verification = Resolve-DnsName -Name selector2._domainkey.$DomainDisplayName -Type CNAME -Server 1.1.1.1 -ErrorAction SilentlyContinue | Select *

            if($CNAME2Verification -EQ $Null){

                "CNAME 2 not found for $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 8
            }

            elseif($CNAME1Verification -NE $Null){

                "CNAME 2 found for $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 8
            }

            else{

                "CNAME 2 status unknown for $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 8
            }

        # End DKIM record check for all domains in tenant. Begin DMARC record check for all domains in tenant.

        $DMARCConfigurationCheck = Resolve-DnsName -Name _dmarc.$DomainDisplayName -Type TXT -Server 1.1.1.1 -ErrorAction SilentlyContinue | Select Strings

        if($Error.Exception -Match "_dmarc.$DomainDisplayName : DNS name does not exist"){

            "No DMARC record was found for: $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 10

            $Error.Clear()
        }

        elseif($DMARCConfigurationCheck -NE $null){

            "DMARC record is configured for: $DomainDisplayName" | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 10
            $DMARCConfigurationCheck | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 11

        }

        else{

            "DMARC configuration status for '$DomainDisplayName' is unknown." | Export-Excel -Path ".\SPF_DKIM_DMARC_Report-$DateTime.xlsx" -WorksheetName "Domain $DomainCounter" -StartColumn 1 -StartRow 10
        }

        $DomainCounter++

    }

    Disconnect-AzureAD
    Disconnect-ExchangeOnline -Confirm:$false
}

# https://www.reddit.com/r/PowerShell/comments/spdtqh/programmatically_validate_spfdkimdmarc_records/