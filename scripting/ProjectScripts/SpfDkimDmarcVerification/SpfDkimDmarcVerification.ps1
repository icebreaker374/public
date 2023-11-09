$DomainList = Get-AzureADDomain -ErrorAction SilentlyContinue | Select Name

if($DomainList -EQ $null){

    Write-Host "There was an error retreiving the domains from the tenant"
}

else{

    Write-Host "The SPF/DKIM/DMARC record verification process will begin in 5 seconds..."

    Start-Sleep -Seconds 5
    
    foreach($domain in $DomainList){

        $DomainDisplayName = $domain.Name

        # Begin SPF record check for all domains in tenant.

        $SPFConfigurationCheck = Resolve-DnsName -Name $DomainDisplayName -Type TXT -Server 1.1.1.1 -ErrorAction SilentlyContinue | Select -ExpandProperty Strings

        if($Error.Exception -Match "$DomainDisplayName : DNS name does not exist"){

            Write-Host "There was an error retreiving SPF records for: $DomainDisplayName"

            $Error.Clear()
        }

        elseif($SPFConfigurationCheck -EQ $null){

            Write-Host "No SPF records were found for: $DomainDisplayName"
        }

        elseif($SPFConfigurationCheck -NE $null){

            Write-Host "'$DomainDisplayName' has the following SPF records setup:"
            Write-Host ""
            Write-Host "SpfRecords"
            Write-Host "----------"
        
            foreach($record in $SPFConfigurationCheck){

                Write-Host $record
                Write-Host ""
            }
        }

        else{

            Write-Host "SPF record status for '$DomainDisplayName' is unknown."
        }

        # End SPF record check for all domains in tenant. Begin DKIM configuration check for all domains in tenant.
        
        $DKIMConfigurationCheck = Get-DkimSigningConfig -Identity $DomainDisplayName -ErrorAction SilentlyContinue | Select Enabled

        if($Error.Exception -Match "Ex43C0AC"){

            Write-Host "
DKIM configuration/DKIM keys not created for: $DomainDisplayName"
            Write-Host ""

            $Error.Clear()
        }

        else{

            if($DKIMConfigurationCheck.Enabled -EQ $True){

                Write-Host "
Domain: $DomainDisplayName, DKIM Status: ENABLED"
                Write-Host ""
            }

            elseif($DKIMConfigurationCheck.Enabled -EQ $False){

                Write-Host "
Domain: $DomainDisplayName, DKIM Status: NOT ENABLED"
                Write-Host ""
            }

            else{

                Write-Host "
Domain: $DomainDisplayName, DKIM Status: UNKNOWN"
                Write-Host ""
            }
        }

        # End DKIM record check for all domains in tenant. Begin DMARC record check for all domains in tenant.

        $DMARCConfigurationCheck = Resolve-DnsName -Name _dmarc.$DomainDisplayName -Server 1.1.1.1 -ErrorAction SilentlyContinue

        if($Error.Exception -Match "_dmarc.$DomainDisplayName : DNS name does not exist"){

            Write-Host "No DMARC record was found for: $DomainDisplayName"
            Write-Host "
"

            $Error.Clear()
        }

        elseif($DMARCConfigurationCheck.Name -Match $DomainDisplayName){

            Write-Host "DMARC record is configured for: $DomainDisplayName"
            Write-Host "
"
        }

        else{

            Write-Host "DMARC configuration status for '$DomainDisplayName' is unknown."
            Write-Host "
"
        }

    }
}

Read-Host "Press Enter to continue..."

# https://www.reddit.com/r/PowerShell/comments/spdtqh/programmatically_validate_spfdkimdmarc_records/