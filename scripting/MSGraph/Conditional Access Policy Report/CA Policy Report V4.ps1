<#Write-Host "Checking if C:\Temp\GraphConditionalAccessPolicyReport already exists..."

Start-Sleep -Seconds 1.5

# Begin working directory check.

if(Test-Path "C:\Temp\GraphConditionalAccessPolicyReport"){

    Write-Host "C:\Temp\GraphConditionalAccessPolicyReport already exists."
}

else{
    
    cd C:\
    md Temp\GraphConditionalAccessPolicyReport > $null

    Write-Host "A directory called 'Temp\GraphConditionalAccessPolicyReport' was created at 'C:\'"
}

# End working directory check.

# Define report file path.

cd C:\Temp\GraphConditionalAccessPolicyReport

$ReportPath = ".\GraphConditionalAccessPolicyReport.xlsx"

# Begin required modules check.

$RequiredModules = @("Microsoft.Graph.Authentication","ImportExcel")

foreach($module in $RequiredModules){

    if(Get-InstalledModule -Name $module -ErrorAction SilentlyContinue){

        Write-Host "Confirmed the $module module is installed."

        if(Get-Module -Name $module -ErrorAction SilentlyContinue){

            Write-Host "Confirmed the $module module is loaded."
        }

        else{

            Write-Host "Attempting to load the $module module..."
            
            Import-Module -Name $module -ErrorAction SilentlyContinue

            if(Get-Module -Name $module -ErrorAction SilentlyContinue){
            
                Write-Host "The $module module was successfully loaded."
            }

            else{

                Write-Host "The $module module failed to load.  The script will exit in 3 seconds..."

                Start-Sleep -Seconds 3

                exit
            }
        }
    }

    else{

        Write-Host "Attempting to install and load the $module module..."
        
        Find-Module -Name $module | Install-Module -Scope CurrentUser -Force | Out-Null
        Import-Module $module

        if((Get-InstalledModule -Name $module -ErrorAction SilentlyContinue) -and (Get-Module -Name $module -ErrorAction SilentlyContinue)){

            Write-Host "The $module module was successfully installed and loaded."
        }

        else{

            Write-Host "The $module module either failed to install and/or failed to load.  Please install manually."
            Set-Clipboard -Value "Find-Module -Name $module | Install-Module -Scope CurrentUser -Force | Out-Null"
            Write-Host "The install command for the $module module has been added to your clipboard."
            Write-Host ""
            Write-Host "The script will exit in 5 seconds..."

            Start-Sleep -Seconds 5

            exit
        }
    }
}

# End required modules check. #>

$RequiredScopes = @("Directory.Read.All","Policy.Read.All")

Connect-MgGraph -Scopes $RequiredScopes -ContextScope Process -NoWelcome

# Initialize required hashtables.

$CountriesHashTable = @{

"AF" = "Afghanistan"
"AX" = "Åland Islands"
"AL" = "Albania"
"DZ" = "Algeria"
"AS" = "American Samoa"
"AD" = "Andorra"
"AO" = "Angola"
"AI" = "Anguilla"
"AQ" = "Antarctica"
"AG" = "Antigua and Barbuda"
"AR" = "Argentina"
"AM" = "Armenia"
"AW" = "Aruba"
"AU" = "Australia"
"AT" = "Austria"
"AZ" = "Azerbaijan"
"BS" = "Bahamas"
"BH" = "Bahrain"
"BD" = "Bangladesh"
"BB" = "Barbados"
"BY" = "Belarus"
"BE" = "Belgium"
"BZ" = "Belize"
"BJ" = "Benin"
"BM" = "Bermuda"
"BT" = "Bhutan"
"BO" = "Bolivia"
"BQ" = "Bonaire"
"BA" = "Bosnia and Herzegovina"
"BW" = "Botswana"
"BV" = "Bouvet Island"
"BR" = "Brazil"
"IO" = "British Indian Ocean Territory"
"BN" = "Brunei Darussalam"
"BG" = "Bulgaria"
"BF" = "Burkina Faso"
"BI" = "Burundi"
"CV" = "Cabo Verde"
"KH" = "Cambodia"
"CM" = "Cameroon"
"CA" = "Canada"
"KY" = "Cayman Islands"
"CF" = "Central African Republic"
"TD" = "Chad"
"CL" = "Chile"
"CN" = "China"
"CX" = "Christmas Island"
"CC" = "Cocos (Keeling) Islands"
"CO" = "Colombia"
"KM" = "Comoros"
"CD" = "Democratic Republic of the Congo"
"CG" = "Congo (the)"
"CK" = "Cook Islands"
"CR" = "Costa Rica"
"CI" = "Côte d'Ivoire"
"HR" = "Croatia"
"CU" = "Cuba"
"CW" = "Curaçao"
"CY" = "Cyprus"
"CZ" = "Czechia"
"DK" = "Denmark"
"DJ" = "Djibouti"
"DM" = "Dominica"
"DO" = "Dominican Republic"
"EC" = "Ecuador"
"EG" = "Egypt"
"SV" = "El Salvador"
"GQ" = "Equatorial Guinea"
"ER" = "Eritrea"
"EE" = "Estonia"
"SZ" = "Eswatini"
"ET" = "Ethiopia"
"FK" = "Falkland Islands"
"FO" = "Faroe Islands"
"FJ" = "Fiji"
"FI" = "Finland"
"FR" = "France"
"GF" = "French Guiana"
"PF" = "French Polynesia"
"TF" = "French Southern Territories"
"GA" = "Gabon"
"GM" = "Gambia"
"GE" = "Georgia"
"DE" = "Germany"
"GH" = "Ghana"
"GI" = "Gibraltar"
"GR" = "Greece"
"GL" = "Greenland"
"GD" = "Grenada"
"GP" = "Guadeloupe"
"GU" = "Guam"
"GT" = "Guatemala"
"GG" = "Guernsey"
"GN" = "Guinea"
"GW" = "Guinea-Bissau"
"GY" = "Guyana"
"HT" = "Haiti"
"HM" = "Heard Island and McDonald Islands"
"VA" = "Holy See"
"HN" = "Honduras"
"HK" = "Hong Kong"
"HU" = "Hungary"
"IS" = "Iceland"
"IN" = "India"
"ID" = "Indonesia"
"IR" = "Iran"
"IQ" = "Iraq"
"IE" = "Ireland"
"IM" = "Isle of Man"
"IL" = "Israel"
"IT" = "Italy"
"JM" = "Jamaica"
"JP" = "Japan"
"JE" = "Jersey"
"JO" = "Jordan"
"KZ" = "Kazakhstan"
"KE" = "Kenya"
"KI" = "Kiribati"
"KP" = "orth Korea"
"KR" = "outh Korea"
"KW" = "Kuwait"
"KG" = "Kyrgyzstan"
"LA" = "Lao People's Democratic Republic"
"LV" = "Latvia"
"LB" = "Lebanon"
"LS" = "Lesotho"
"LR" = "Liberia"
"LY" = "Libya"
"LI" = "Liechtenstein"
"LT" = "Lithuania"
"LU" = "Luxembourg"
"MO" = "Macao"
"MG" = "Madagascar"
"MW" = "Malawi"
"MY" = "Malaysia"
"MV" = "Maldives"
"ML" = "Mali"
"MT" = "Malta"
"MH" = "Marshall Islands"
"MQ" = "Martinique"
"MR" = "Mauritania"
"MU" = "Mauritius"
"YT" = "Mayotte"
"MX" = "Mexico"
"FM" = "Micronesia"
"MD" = "Moldova"
"MC" = "Monaco"
"MN" = "Mongolia"
"ME" = "Montenegro"
"MS" = "Montserrat"
"MA" = "Morocco"
"MZ" = "Mozambique"
"MM" = "Myanmar"
"NA" = "Namibia"
"NR" = "Nauru"
"NP" = "Nepal"
"NL" = "Netherlands, Kingdom of the"
"NC" = "New Caledonia"
"NZ" = "New Zealand"
"NI" = "Nicaragua"
"NE" = "Niger"
"NG" = "Nigeria"
"NU" = "Niue"
"NF" = "Norfolk Island"
"MK" = "North Macedonia"
"MP" = "Northern Mariana Islands"
"NO" = "Norway"
"OM" = "Oman"
"PK" = "Pakistan"
"PW" = "Palau"
"PS" = "Palestine"
"PA" = "Panama"
"PG" = "Papua New Guinea"
"PY" = "Paraguay"
"PE" = "Peru"
"PH" = "Philippines"
"PN" = "Pitcairn"
"PL" = "Poland"
"PT" = "Portugal"
"PR" = "Puerto Rico"
"QA" = "Qatar"
"RE" = "Réunion"
"RO" = "Romania"
"RU" = "ussia/Russian Federation"
"RW" = "Rwanda"
"BL" = "Saint Barthélemy"
"SH" = "Saint Helena"
"KN" = "Saint Kitts and Nevis"
"LC" = "Saint Lucia"
"MF" = "Saint Martin (French part)"
"PM" = "Saint Pierre and Miquelon"
"VC" = "Saint Vincent and the Grenadines"
"WS" = "Samoa"
"SM" = "San Marino"
"ST" = "Sao Tome and Principe"
"SA" = "Saudi Arabia"
"SN" = "Senegal"
"RS" = "Serbia"
"SC" = "Seychelles"
"SL" = "Sierra Leone"
"SG" = "Singapore"
"SX" = "Sint Maarten (Dutch part)"
"SK" = "Slovakia"
"SI" = "Slovenia"
"SB" = "Solomon Islands"
"SO" = "Somalia"
"ZA" = "South Africa"
"GS" = "South Georgia and the South Sandwich Islands"
"SS" = "South Sudan"
"ES" = "Spain"
"LK" = "Sri Lanka"
"SD" = "Sudan"
"SR" = "Suriname"
"SJ" = "Svalbard"
"SE" = "Sweden"
"CH" = "Switzerland"
"SY" = "Syrian Arab Republic"
"TW" = "Taiwan"
"TJ" = "Tajikistan"
"TZ" = "Tanzania, the United Republic of"
"TH" = "Thailand"
"TL" = "Timor-Leste"
"TG" = "Togo"
"TK" = "Tokelau"
"TO" = "Tonga"
"TT" = "Trinidad and Tobago"
"TN" = "Tunisia"
"TR" = "Türkiye"
"TM" = "Turkmenistan"
"TC" = "Turks and Caicos Islands"
"TV" = "Tuvalu"
"UG" = "Uganda"
"UA" = "Ukraine"
"AE" = "United Arab Emirates"
"GB" = "United Kingdom of Great Britain and Northern Ireland"
"UM" = "United States Minor Outlying Islands"
"US" = "United States of America"
"UY" = "Uruguay"
"UZ" = "Uzbekistan"
"VU" = "Vanuatu"
"VE" = "Venezuela"
"VN" = "ietnam"
"VG" = "Virgin Islands (British)"
"VI" = "Virgin Islands (U.S.)"
"WF" = "Wallis and Futuna"
"EH" = "Western Sahara"
"YE" = "Yemen"
"ZM" = "Zambia"
"ZW" = "Zimbabwe"
}

$GuestTypesHashTable = @{

    "b2bCollaborationGuest" = "B2B Collaboration Guest Users"
    "b2bCollaborationMember" = "B2B Collaboration Member Users"
    "b2bDirectConnectUser" = "B2B Collaboration Direct Connect Users"
    "internalGuest" = "Loacl Guest Users"
    "serviceProvider" = "Service Provider Users"
    "otherExternalUser" = "Other External Users"
}

$PlatformsHashTable = @{

    "android" = "Android"
    "windows" = "Windows"
    "windowsPhone" = "Windows Phone"
    "macOS"= "MacOS"
    "linux" = "Linux"
}

$ClientAppTypesHashTable = @{

    "browser" = "Browser"
    "mobileAppsAndDesktopClients" = "Mobile apps and desktop clients"
    "exchangeActiveSync" = "Exchange ActiveSync clients"
    "other" = "Other clients"
}

# Initialize conditional text and conditional text items arrays.

$ConditionalTextItems = @("Policy Info:","Included Users:","Excluded Users:","Included Groups:","Excluded Groups:","Included Roles:","Excluded Roles:","Included Guest Types:",
"Excluded Guest Types:","Included Organizations:","Excluded Organizations:","Included Applications:","Excluded Applications:","Included User Actions:","Included Locations:",
"Excluded Locations:","Included Platforms:","Excluded Platforms:","Included Client App Types:","Grant Controls Setting:","Grant Controls:")
$ConditionalText = @()

# Add conditional text items to conditional text array.

foreach($conditionalTextItem in $ConditionalTextItems){

    $ConditionalText += New-ConditionalText -Text $conditionalTextItem -BackgroundColor DarkTurquoise -ConditionalTextColor Black
}

# Get conditional access policies and policy count.

$Policies = Invoke-MgGraphRequest -uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?filter=contains(displayName, 'Test')"
$policiesCount = $policies.value.Count

$policyCounter = 1 # Initialize policy counter variable.

# Begin policy reporting.

foreach($policy in $Policies.value){
    
    $policyDisplayName = $policy.displayName
    
    # Policy based Write-Progress.

    Write-Progress -PercentComplete (($policyCounter/$policiesCount) * 100) -Status "[$policyCounter/$policiesCount] Processing CA polies..." -Activity "Processing policy: '$policyDisplayName'" -Id 0
    
    # Begin policy identifier.
    
    "Policy Info:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 1 -StartColumn 1 -ConditionalText $ConditionalText
    "Name: " + $policyDisplayName | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 2 -StartColumn 1

    # End policy identifier. Begin policy status check.
    
    $PolicyStatuses = @("enabled","disabled","enabledForReportingButNotEnforced")

    switch($policy.state){
    
        {"enabled"}{"State: ENABLED" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 3 -StartColumn 1}
        {"disabled"}{"State: DISABLED" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 3 -StartColumn 1}
        {"enabledForReportingButNotEnforced"}{"State: REPORT-ONLY" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 3 -StartColumn 1}
        {$policy.state -NotIn $PolicyStatuses}{"State: UNKNOWN" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 3 -StartColumn 1}
    }

    # End policy status check. Begin included users check.

    $IncludedUsers = $policy.conditions.users.includeUsers
    $IncludedUsersCount = $policy.conditions.users.includeUsers.Length
    $IncludedUsersReadable = @()

    # All users included process.

    if($IncludedUsers -Match "All"){

        "Included Users:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 1 -StartColumn 2 -ConditionalText $ConditionalText
        "ALL USERS" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 2 -StartColumn 2
    }
        
    # Specific users included process.
        
    else{

        if($IncludedUsersCount -GT 0){
            
            "Included Users:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 1 -StartColumn 2 -ConditionalText $ConditionalText
            
            foreach($includedUser in $IncludedUsers){
               
                try{
        
                    $includedUserObject = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$includedUser"
                    $includedUserObjectReadable = $includedUserObject.displayName + " (" + $includedUserObject.userPrincipalName + ")"
                     
                    $IncludedUsersReadable += $includedUserObjectReadable
                }

                catch{
                
                    $IncludedUsersReadable += $includedUser
                }
            }   

            $IncludedUsersReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 2 -StartColumn 2

            Get-Variable | Where Name -Match "IncludedUser" | Remove-Variable
        }

        else{

            "Included Users:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 1 -StartColumn 2 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 2 -StartColumn 2
        }
    }

    # End included users check. Begin excluded users check.

    $ExcludedUsers = $policy.conditions.users.excludeUsers
    $ExcludedUsersCount = $policy.conditions.users.excludeUsers.Count
    $ExcludedUsersReadable = @()

    switch($excludedUsersCount){
    
        # No users excluded process.

        {$ExcludedUsersCount -EQ 0}{
    
            "Excluded Users:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 1 -StartColumn 3 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 2 -StartColumn 3
        }
        
        # Specific users excluded process.
        
        {$ExcludedUsersCount -GT 0}{
        
            "Excluded Users:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 1 -StartColumn 3 -ConditionalText $ConditionalText
            
            foreach($excludedUser in $ExcludedUsers){
                
                try{
        
                    $excludedUserObject = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$excludedUser"
                    $excludedUserObjectReadable = $excludedUserObject.displayName + " (" + $excludedUserObject.userPrincipalName + ")"
                    
                    $ExcludedUsersReadable += $excludedUserObjectReadable                    
                }

                catch{
                
                    $ExcludedUsersReadable += $excludedUser
                }
            }

            $ExcludedUsersReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 2 -StartColumn 3

            Get-Variable | Where Name -Match "ExcludedUser" | Remove-Variable
        }
    }

    # End excluded users check. Begin included groups check.

    $IncludedGroups = $policy.conditions.users.includeGroups
    $IncludedGroupsCount = $policy.conditions.users.includeGroups.Count
    $IncludedGroupsReadable = @()

    switch($IncludedGroupsCount){
    
        {$IncludedGroupsCount -EQ 0}{
        
            "Included Groups:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 1 -StartColumn 4 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 2 -StartColumn 4
        }

        {$IncludedGroupsCount -GT 0}{
        
            "Included Groups:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 1 -StartColumn 4 -ConditionalText $ConditionalText
            
            foreach($includedGroup in $IncludedGroups){

                try{
        
                    $includedGroupObject = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/groups/$includedGroup"
                    $includedGroupObjectReadable = $includedGroupObject.displayName + " (" + $includedGroupObject.mail + ")"
                    $IncludedGroupsReadable += $includedGroupObjectReadable
                }

                catch{
                
                    $IncludedGroupsReadable += $includedGroup
                }
            }

            $IncludedGroupsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 2 -StartColumn 4

            Get-Variable | Where Name -Match "IncludedGroup" | Remove-Variable
        }
    }

    # End included groups check. Begin excluded groups check.

    $ExcludedGroups = $policy.conditions.users.excludeGroups
    $ExcludedGroupsCount = $policy.conditions.users.excludeGroups.Count
    $ExcludedGroupsReadable = @()

    switch($ExcludedGroupsCount){
    
        {$ExcludedGroupsCount -EQ 0}{
        
            "Excluded Groups:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 1 -StartColumn 5 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 2 -StartColumn 5
        }

        {$ExcludedGroupsCount -GT 0}{
        
            "Excluded Groups:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 1 -StartColumn 5 -ConditionalText $ConditionalText
            
            foreach($excludedGroup in $ExcludedGroups){

                try{
        
                    $excludedGroupObject = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/groups/$excludedGroup"
                    $excludedGroupObjectReadable = $excludedGroupObject.displayName + " (" + $excludedGroupObject.mail + ")"
                    $ExcludedGroupsReadable += $excludedGroupObjectReadable
                }

                catch{
                
                    $ExcludedGroupsReadable += $excludedGroup
                }

            }

            $ExcludedGroupsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow 2 -StartColumn 5

            Get-Variable | Where Name -Match "ExcludedGroup" | Remove-Variable
        }
    }

    # End excluded groups check. Begin included roles check.

    # Initialize new row variables.

    $newRow = (Import-Excel C:\Temp\GraphConditionalAccessPolicyReport\GraphConditionalAccessPolicyReport.xlsx -WorksheetName "Policy $policyCounter").Count + 2
    $newRowTable = (Import-Excel C:\Temp\GraphConditionalAccessPolicyReport\GraphConditionalAccessPolicyReport.xlsx -WorksheetName "Policy $policyCounter").Count + 3

    $IncludedRoles = $policy.conditions.users.includeRoles
    $IncludedRolesCount = $policy.conditions.users.includeRoles.Count
    $IncludedRolesReadable = @()

    switch($IncludedRolesCount){
    
        {$IncludedRolesCount -EQ 0}{
        
            "Included Roles:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 1 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 1
        }

        {$IncludedRolesCount -GT 0}{
        
            "Included Roles:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 1 -ConditionalText $ConditionalText
            
            foreach($includedRole in $IncludedRoles){

                try{
        
                    $includedRoleObject = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/directoryRoles(roleTemplateId='$includedRole')"
                    $includedRoleObjectReadable = $includedRoleObject.displayName
                    $IncludedRolesReadable += $includedRoleObjectReadable
                }

                catch{
                
                    $IncludedRolesReadable += $includedRole
                }

            }

            $IncludedRolesReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 1

            Get-Variable | Where Name -Match "IncludedRole" | Remove-Variable
        }
    }

    # End included roles check. Begin excluded roles check.

    $ExcludedRoles = $policy.conditions.users.excludeRoles
    $ExcludedRolesCount = $policy.conditions.users.excludeRoles.Count
    $ExcludedRolesReadable = @()

    switch($ExcludedRolesCount){
    
        {$ExcludedRolesCount -EQ 0}{
        
            "Excluded Roles:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 2 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 2
        }

        {$ExcludedRolesCount -GT 0}{
        
            "Excluded Roles:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 2 -ConditionalText $ConditionalText
            
            foreach($excludedRole in $ExcludedRoles){

                try{
        
                    $excludedRoleObject = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/directoryRoles(roleTemplateId='$excludedRole')"
                    $excludedRoleObjectReadable = $excludedRoleObject.displayName
                    $ExcludedRolesReadable += $excludedRoleObjectReadable
                }

                catch{
                
                    $ExcludedRolesReadable += $excludedRole
                }
            }

            $ExcludedRolesReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 2

            Get-Variable | Where Name -Match "ExcludedRole" | Remove-Variable
        }
    }

    # End included roles check. Begin included guest user types and organizations check.

    $IncludedGuestTypes = $policy.conditions.users.includeGuestsOrExternalUsers.guestOrExternalUserTypes -Split ","
    $IncludedGuestTypesCount = $policy.conditions.users.includeGuestsOrExternalUsers.guestOrExternalUserTypes.Count
    $IncludedOrganizationsMembershipType = $policy.conditions.users.includeGuestsOrExternalUsers.externalTenants.membershipKind
    $IncludedGuestTypesReadable = @()
    $IncludedOrganizationsReadable = @()

    switch($IncludedGuestTypesCount){
    
        {$IncludedGuestTypesCount -EQ 0}{
        
            "Included Guest Types:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 3 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 3
        }

        {$IncludedGuestTypesCount -GT 0}{
        
            "Included Guest Types:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 3 -ConditionalText $ConditionalText

            
            foreach($guestType in $IncludedGuestTypes){

                try{
                
                    $IncludedGuestTypesReadable += $GuestTypesHashTable.Item($guestType)
                }

                catch{
                
                    $IncludedGuestTypesReadable += $guestType
                }

            }

            $IncludedGuestTypesReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 3
        }
    }

    switch($IncludedOrganizationsMembershipType){
    
        {$IncludedOrganizationsMembershipType -EQ "All"}{
        
            "Included Organizations: " | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 4 -ConditionalText $ConditionalText
            "All Organizations" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 4
        }

        {$IncludedOrganizationsMembershipType -EQ "enumerated"}{
        
            "Included Organizations: " | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 4 -ConditionalText $ConditionalText
            
            $IncludedOrganizations = $policy.conditions.users.includeGuestsOrExternalUsers.externalTenants.members
            
            foreach($includedOrganization in $IncludedOrganizations){

                try{
                
                    $tenantInfo = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/findTenantInformationByTenantId(tenantId='$includedOrganization')"
                    $tenantName = $tenantInfo.displayName
                    $tenantDomain = $tenantInfo.defaultDomainName

                    $IncludedOrganizationsReadable += $tenantName + " (" + $tenantDomain + ")"
                }

                catch{
                
                    $IncludedOrganizationsReadable += $includedOrganization
                }
            }

            $IncludedOrganizationsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 4 -ConditionalText $ConditionalText
        }

        {$IncludedOrganizationsMembershipType -NotIn "All","enumerated"}{
        
            "Included Organizations: " | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 4 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 4
        }
    }

    # End included guest user types and organizations check. Begin excluded guest user types and organizations check.

    $ExcludedGuestTypes = $policy.conditions.users.excludeGuestsOrExternalUsers.guestOrExternalUserTypes -Split ","
    $ExcludedGuestTypesCount = $policy.conditions.users.excludeGuestsOrExternalUsers.guestOrExternalUserTypes.Count
    $ExcludedOrganizationsMembershipType = $policy.conditions.users.excludeGuestsOrExternalUsers.externalTenants.membershipKind
    $ExcludedGuestTypesReadable = @()
    $ExcludedOrganizationsReadable = @()

    switch($ExcludedGuestTypesCount){
    
        {$ExcludedGuestTypesCount -EQ 0}{
        
            "Excluded Guest Types:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 5 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 5
        }

        {$ExcludedGuestTypesCount -GT 0}{
        
            "Excluded Guest Types:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 5 -ConditionalText $ConditionalText
            
            foreach($guestType in $ExcludedGuestTypes){
                
                try{
                
                    $ExcludedGuestTypesReadable += $GuestTypesHashTable.Item($guestType)
                }

                catch{
                
                    $ExcludedGuestTypesReadable += $guestType
                }
            }

            $ExcludedGuestTypesReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 5
        }
    }

    # Increment new row variables.

    $newRow = (Import-Excel C:\Temp\GraphConditionalAccessPolicyReport\GraphConditionalAccessPolicyReport.xlsx -WorksheetName "Policy $policyCounter").Count + 2
    $newRowTable = (Import-Excel C:\Temp\GraphConditionalAccessPolicyReport\GraphConditionalAccessPolicyReport.xlsx -WorksheetName "Policy $policyCounter").Count + 3

    switch($ExcludedOrganizationsMembershipType){
    
        {$ExcludedOrganizationsMembershipType -EQ "All"}{
        
            "Excluded Organizations: " | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 1 -ConditionalText $ConditionalText
            "All Organizations" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 1
        }

        {$ExcludedOrganizationsMembershipType -EQ "enumerated"}{
        
            $ExcludedOrganizations = $policy.conditions.users.excludeGuestsOrExternalUsers.externalTenants.members
            
            "Excluded Organizations: " | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 1 -ConditionalText $ConditionalText
            
            foreach($excludedOrganization in $ExcludedOrganizations){
            
                try{
                
                    $tenantInfo = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/findTenantInformationByTenantId(tenantId='$excludedOrganization')"
                    $tenantName = $tenantInfo.displayName
                    $tenantDomain = $tenantInfo.defaultDomainName

                    $ExcludedOrganizationsReadable += $tenantName + " (" + $tenantDomain + ")"
                }

                catch{
                
                    $ExcludedOrganizationsReadable += $excludedOrganization
                }
            }

            $ExcludedOrganizationsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 1 -ConditionalText $ConditionalText
        }

        {$ExcludedOrganizationsMembershipType -NotIn "All","enumerated"}{
        
            "Excluded Organizations: " | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 1 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 1
        }
    }

    # End excluded guest user types and organizations check. Begin included applications check.

    $IncludedApplications = $policy.conditions.applications.includeApplications
    $IncludedApplicationsCount = $policy.conditions.applications.includeApplications.Count
    $IncludedApplicationsReadable = @()
    
    if($IncludedApplications -EQ "All"){
        
        "Included Applications:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 2 -ConditionalText $ConditionalText
        "All applications" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 2
    }

    elseif(($IncludedApplications -NE "All") -and ($IncludedApplicationsCount -GT 0)){
           
        "Included Applications:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 2 -ConditionalText $ConditionalText
            
        foreach($includedApplication in $IncludedApplications){
            
            if($includedApplication -EQ "MicrosoftAdminPortals"){
                
                $IncludedApplicationsReadable += "Microsoft Admin Portals"
            }

            elseif($includedApplication -EQ "Office365"){
               
                $IncludedApplicationsReadable += "Office 365"
            }

            else{
                
                try{
                    
                    $includedApplicationInfo = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals(appId='$includedApplication')"
                    $includedApplicatonName = $includedApplicationInfo.displayName

                    $IncludedApplicationsReadable += $includedApplicatonName
                }

                catch{
                    
                    $IncludedApplicationsReadable += $includedApplication
                }
            }
        }

            $IncludedApplicationsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 2 -ConditionalText $ConditionalText

            Get-Variable | Where Name -Match "IncludedApplication" | Remove-Variable -Force
    }

    else{
    
        "Included Applications:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 2 -ConditionalText $ConditionalText
        "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 2
    }

    # End included applications check. Begin excluded applications check.

    $ExcludedApplications = $policy.conditions.applications.excludeApplications
    $ExcludedApplicationsCount = $policy.conditions.applications.excludeApplications.Count
    $ExcludedApplicationsReadable = @()

    switch($ExcludedApplicationsCount){
    
        {$ExcludedApplicationsCount -EQ 0}{
        
            "Excluded Applications:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 3 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 3
        }

        {$ExcludedApplicationsCount -GT 0}{
        
            "Excluded Applications:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 3 -ConditionalText $ConditionalText
            
            foreach($excludedApplication in $ExcludedApplications){
            
                if($excludedApplication -EQ "MicrosoftAdminPortals"){
                
                    $ExcludedApplicationsReadable += "Microsoft Admin Portals"
                }

                elseif($excludedApplication -EQ "Office365"){
                
                    $ExcludedApplicationsReadable += "Office 365"
                }

                else{
                
                    try{
                    
                        $excludedApplicationInfo = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals(appId='$excludedApplication')"
                        $excludedApplicatonName = $excludedApplicationInfo.displayName

                        $ExcludedApplicationsReadable += $excludedApplicatonName
                    }

                    catch{
                    
                        $ExcludedApplicationsReadable += $excludedApplication
                    }
                }
            }

            $ExcludedApplicationsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 3 -ConditionalText $ConditionalText

            Get-Variable | Where Name -Match "ExcludedApplication" | Remove-Variable -Force
        }
    }

    # End excluded applications check. Begin included user actions check.

    $IncludedUserActions = $policy.conditions.applications.includeUserActions
    $IncludedUserActionsCount = $policy.conditions.applications.includeUserActions.Count
    $IncludedUserActionsReadable = @()

    switch($IncludedUserActionsCount){
    
        {$IncludedUserActionsCount -GT 0}{
        
            "Included User Actions:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 4 -ConditionalText $ConditionalText
            
            foreach($action in $IncludedUserActions){
    
                if($action -Match "registerdevice"){
        
                    $IncludedUserActionsReadable += "Register or join devices"
                }

                elseif($action -Match "registersecurityinfo"){
        
                    $IncludedUserActionsReadable += "Register security info"
                }

                else{
        
                    $IncludedUserActionsReadable += $action
                }
            }

            $IncludedUserActionsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 4
        }

        {$IncludedUserActionsCount -EQ 0}{
        
            "Included User Actions:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 4 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 4
        }
    }

    # End included user actions check. Begin included locations check.

    $IncludedLocations = $policy.conditions.locations.includeLocations
    $IncludedLocationsCount = $policy.conditions.locations.includeLocations.Count
    $IncludedLocationsReadable = @()
    
    if($IncludedLocations -EQ "All"){
        
        "Included Locations:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 5 -ConditionalText $ConditionalText
        "All locations" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 5
    }

    elseif($IncludedLocations -EQ "AllTrusted"){
    
        "Included Locations:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 5 -ConditionalText $ConditionalText
        "All trusted locations" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 5
    }

    else{

        if($IncludedLocationsCount -GT 0){

            "Included Locations:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 5 -ConditionalText $ConditionalText
            
            foreach($includedLocation in $IncludedLocations){
        
                if($includedLocation -EQ "00000000-0000-0000-0000-000000000000"){
                
                    $IncludedLocationsReadable += "Multifactor authentication trusted IPs"
                }
                
                else{
                
                    try{
                    
                        $locationInfo = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations/$includedLocation"
                        
                        switch($locationInfo.'@odata.type'){
                        
                            {$locationInfo.'@odata.type' -EQ "#microsoft.graph.countryNamedLocation"}{
                            
                                $locationType = "Country-based"
                            }

                            {$locationInfo.'@odata.type' -EQ "#microsoft.graph.ipNamedLocation"}{
                            
                                $locationType = "IP-based"
                            }
                        }
                        
                        $locationDisplayName = $locationInfo.displayName + " ($locationType)"
                        $IncludedLocationsReadable += $locationDisplayName
                    }

                    catch{
                    
                        $IncludedLocationsReadable += $includedLocation
                    }
                }
            }

            $IncludedLocationsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 5
        }

        else{
        
            "Included Locations:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 5 -ConditionalText $ConditionalText
            "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 5
        }
    }

    # End included locations check. Begin excluded locations check.

    $ExcludedLocations = $policy.conditions.locations.excludeLocations
    $ExcludedLocationsCount = $policy.conditions.locations.excludeLocations.Count
    $ExcludedLocationsReadable = @()

    # Increment new row variables.

    $newRow = (Import-Excel C:\Temp\GraphConditionalAccessPolicyReport\GraphConditionalAccessPolicyReport.xlsx -WorksheetName "Policy $policyCounter").Count + 2
    $newRowTable = (Import-Excel C:\Temp\GraphConditionalAccessPolicyReport\GraphConditionalAccessPolicyReport.xlsx -WorksheetName "Policy $policyCounter").Count + 3

    if($ExcludedLocationsCount -GT 0){
    
        foreach($excludedLocation in $ExcludedLocations){
    
            if($excludedLocation -EQ "00000000-0000-0000-0000-000000000000"){
                
                $ExcludedLocationsReadable += "Multifactor authentication trusted IPs"
            }
                
            else{
                
                try{
                    
                    $locationInfo = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations/$excludedLocation"
                        
                        switch($locationInfo.'@odata.type'){
                        
                            {$locationInfo.'@odata.type' -EQ "#microsoft.graph.countryNamedLocation"}{
                            
                                $locationType = "Country-based"
                            }

                            {$locationInfo.'@odata.type' -EQ "#microsoft.graph.ipNamedLocation"}{
                            
                                $locationType = "IP-based"
                            }
                        }
                        
                        $locationDisplayName = $locationInfo.displayName + " ($locationType)"
                        $ExcludedLocationsReadable += $locationDisplayName
                    }

                    catch{
                    
                        $ExcludedLocationsReadable += $excludedLocation
                    }
                }

                "Excluded Locations:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 1 -ConditionalText $ConditionalText
                $ExcludedLocationsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 1
        }
    }

    else{
    
        "Excluded Locations:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 1 -ConditionalText $ConditionalText
        "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 1
    }

    # End excluded locations check. Begin included device platforms check.

    $IncludedPlatforms = $policy.conditions.platforms.includeplatforms
    $IncludedPlatformsCount = $policy.conditions.platforms.includeplatforms.Count
    $IncludedPlatformsReadable = @()

    if($IncludedPlatformsCount -GT 0){
    
        switch($IncludedPlatforms){
        
            {$IncludedPlatforms -EQ "All"}{
            
                "Included Platforms:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 2 -ConditionalText $ConditionalText
                "All platforms" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 2
            }

            {$IncludedPlatforms -NE "All"}{
            
                "Included Platforms:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 2 -ConditionalText $ConditionalText
                
                foreach($includedPlatform in $IncludedPlatforms){
                
                    try{
                    
                        $IncludedPlatformsReadable += $PlatformsHashTable.Item($includedPlatform)
                    }

                    catch{
                    
                        $IncludedPlatformsReadable += $includedPlatform
                    }
                }

                $IncludedPlatformsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 2

                Get-Variable | Where Name -Match "Platforms" | Remove-Variable
            }
        }
    }


    else{
    
        "Included Platforms:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 2 -ConditionalText $ConditionalText
        "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 2
    }

    # End included device platforms check. Begin excluded device platforms check.

    $ExcludedPlatforms = $policy.conditions.platforms.excludeplatforms
    $ExcludedPlatformsCount = $policy.conditions.platforms.excludeplatforms.Count
    $ExcludedPlatformsReadable = @()

    if($ExcludedPlatformsCount -GT 0){
    
        switch($ExcludedPlatforms){
        
            {$ExcludedPlatforms -EQ "All"}{
            
                "Excluded Platforms:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 3 -ConditionalText $ConditionalText
                "All platforms" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 3
            }

            {$ExcludedPlatforms -NE "All"}{
            
                "Excluded Platforms:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 3 -ConditionalText $ConditionalText
                
                foreach($excludedPlatform in $ExcludedPlatforms){
                
                    try{
                    
                        $ExcludedPlatformsReadable += $PlatformsHashTable.Item($excludedPlatform)
                    }

                    catch{
                    
                        $ExcludedPlatformsReadable += $excludedPlatform
                    }
                }

                $ExcludedPlatformsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 3

                Get-Variable | Where Name -Match "Platforms" | Remove-Variable
            }
        }
    }

    else{
    
        "Excluded Platforms:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 3 -ConditionalText $ConditionalText
        "NONE" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 3
    }

    Get-Variable | Where Name -Match "Platforms" | Remove-Variable

    # End excluded platforms check. Begin included client app types check.

    $IncludedClientAppTypes = $policy.conditions.clientAppTypes
    $IncludedClientAppTypesReadable = @()
    
    if($IncludedClientAppTypes -EQ "all"){
        
        "Included Client App Types:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 4 -ConditionalText $ConditionalText
        "All client app types" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 4
    }

    else{
        
        foreach($clientAppType in $IncludedClientAppTypes){
            
            try{
                
                $IncludedClientAppTypesReadable += $ClientAppTypesHashTable.Item($clientAppType)
            }

            catch{
                
                $IncludedClientAppTypesReadable += $clientAppType
            }
        }

        "Included Client App Types:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 4 -ConditionalText $ConditionalText
        $IncludedClientAppTypesReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 4
    }

    # End included client app types check. Begin grant control operator check.

    $grantControlOperator = $policy.grantControls.operator

    switch($grantControlOperator){
    
        {"OR"}{
        
            "Grant Controls Setting:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 5 -ConditionalText $ConditionalText
            "One of the selected controls" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 5
        }

        {"AND"}{
        
            "Grant Controls Setting:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 5 -ConditionalText $ConditionalText
            "All of the selected controls" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 5
        }
    }

    # End grant control operator check. Begin grant control list check.

    # Increment new row variables.

    $newRow = (Import-Excel C:\Temp\GraphConditionalAccessPolicyReport\GraphConditionalAccessPolicyReport.xlsx -WorksheetName "Policy $policyCounter").Count + 2
    $newRowTable = (Import-Excel C:\Temp\GraphConditionalAccessPolicyReport\GraphConditionalAccessPolicyReport.xlsx -WorksheetName "Policy $policyCounter").Count + 3

    $GrantControls = $policy.grantControls.builtInControls
    $GrantControlsReadable = @()

    $policy.displayName
    $policy.grantControls.builtInControls
    ""
    
    if($GrantControls -EQ "block"){
    
        "Grant Controls:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 1 -ConditionalText $ConditionalText
        "Block access" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 1
    }

    else{
    
        foreach($grantControl in $GrantControls){
            
            if($grantControl -EQ "mfa"){
                
                $GrantControlsReadable += "Require MFA"
            }

            elseif($grantControl -EQ "compliantDevice"){
                
                $GrantControlsReadable += "Require compliant device"
            }

            elseif($grantControl -EQ "domainJoinedDevice"){
                
                $GrantControlsReadable += "Require Entra joined device"
            }

            elseif($grantControl -EQ "approvedApplication"){
                
                $GrantControlsReadable += "Require approved client app"
            }
                
            elseif($grantControl -EQ "compliantApplication"){
                
                $GrantControlsReadable += "Require app protection policy"
            }
                
            elseif($grantControl -EQ "passwordChange"){
                
                $GrantControlsReadable += "Require password change"
            }

            else{
            
                $GrantControlsReadable += $grantControl
            }
        }

        "Grant Controls:" | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRow -StartColumn 1 -ConditionalText $ConditionalText
        $GrantControlsReadable | Export-Excel -Path $ReportPath -WorksheetName "Policy $policyCounter" -StartRow $newRowTable -StartColumn 1

        Get-Variable | Where Name -Match "Grant" | Remove-Variable -Force
    }
    
    # Increment policy counter.
    
    $policyCounter++

    Remove-Variable newRow -Force
    Remove-Variable newRowTable -Force

    Start-Sleep -Milliseconds 50

    # Destroy newRow and newRowTable variables.      
}

# End policy reporting.
