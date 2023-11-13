if(Test-Path "C:\Temp\ConditionalAccessPolicyReport"){

    Write-Host "C:\Temp\ConditionalAccessPolicyReport already exists."
}

else{
    
    cd C:\
    md Temp\ConditionalAccessPolicyReport > $null

    Write-Host "A directory called 'Temp\ConditionalAccessPolicyReport' was created at 'C:\'"
}

cd C:\Temp\ConditionalAccessPolicyReport

if(Get-InstalledModule AzureAD){

    Write-Host "
Confirmed the AzureAD PowerShell module is installed."

    if(Get-Module AzureAD){

        Write-Host "
Confirmed the AzureAD PowerShell Module is loaded."
    }

    else{
    
        Import-Module AzureAD

        Write-Host "
The AzureAD PowerShell Module was successfully loaded."
    }
}

else{

    Install-Module AzureAD -Scope CurrentUser
    Import-Module AzureAD

    Write-Host "
The AzureAD PowerShell module was successfully installed and loaded."
}

Write-Host ""
Write-Host "In 3 seconds you'll be prompted to enter Global Administrator credentials to connect to Azure AD..."

Start-Sleep -Seconds 3

Connect-AzureAD | Out-Null


$Policies = Get-AzureADMSConditionalAccessPolicy

$PolicyCount = 1

foreach($policy in $Policies){

    $PolicyName = $policy.DisplayName
    $PolicyID = $policy.Id

    Write-Host "Policy $PolicyCount" -ForegroundColor Cyan
    
    Write-Host "-----------------------------------------------------------------------------------------------------" -ForegroundColor Cyan
    
    Write-Host "CA Policy Name: '$PolicyName'" -ForegroundColor Magenta
    Write-Host "CA Policy ID: '$PolicyID'" -ForegroundColor Magenta

    # Begin if/else statement for policy status.
    
    Write-Host ""

    if($policy.State -EQ "enabled"){

        $PolicyStatus = "CA Policy Status: ENABLED"
        Write-Host $PolicyStatus -ForegroundColor Green
    }

    elseif($policy.State -EQ "disabled"){

        $PolicyStatus = "CA Access Policy Status: DISABLED"
        Write-Host $PolicyStatus -ForegroundColor Yellow
    }

    elseif($policy.State -EQ "enabledForReportingButNotEnforced"){

        $PolicyStatus = "CA Policy Status: REPORT-ONLY"
        Write-Host $PolicyStatus -ForegroundColor Yellow
    }

    else{

        $PolicyStatus = "CA Access Policy Status: UNKNOWN"
        Write-Host $PolicyStatus -ForegroundColor Red
    }

    # End if/else statement for policy status.  Begin if/else statement for included users check.
    
    Write-Host ""

    if($policy.Conditions.Users.IncludeUsers -EQ "All"){

        $IncludedUsers = "All Users"

        Write-Host "Included Users:" -ForegroundColor Green
        Write-Host $IncludedUsers -ForegroundColor Green
    }

    elseif($policy.Conditions.Users.IncludeUsers -EQ "None"){

        $IncludedUsers = "NONE"

        Write-Host "Included Users:" -ForegroundColor Yellow
        Write-Host $IncludedUsers -ForegroundColor Yellow
    }
    
    elseif(($policy.Conditions.Users.IncludeUsers -NE "All") -and ($policy.Conditions.Users.IncludeUsers -NE "None")){

        $Users = @()
        
        foreach($user in $policy.Conditions.Users.IncludeUsers){

            $UserDisplayName = Get-AzureADUser -ObjectId $user | Select DisplayName

            $Users += $UserDisplayName.DisplayName
        }

        Write-Host "Included Users:" -ForegroundColor Yellow

        foreach($useraccount in $Users){
            
            Write-Host $useraccount -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.IncludeUsers.Count -EQ "0"){

        $IncludedUsers = "NONE"

        Write-Host "Included Users:" -ForegroundColor Yellow
        Write-Host $IncludedUsers -ForegroundColor Yellow
    }

    else{

        $IncludedUsers = "UNKNOWN"

        Write-Host "Included Users:" -ForegroundColor Red
        Write-Host $IncludedUsers -ForegroundColor Red
    }

    # End if/else statement for included users check.  Begin if/else statement for excluded users check.

    Write-Host ""

    if($policy.Conditions.Users.ExcludeUsers.Count -GT "0"){

        $Users = @()
        
        foreach($user in $policy.Conditions.Users.ExcludeUsers){

            $UserDisplayName = Get-AzureADUser -ObjectId $user | Select DisplayName

            $Users += $UserDisplayName.DisplayName
        }

        Write-Host "Excluded Users:" -ForegroundColor Yellow

        foreach($useraccount in $Users){
            
            Write-Host $useraccount -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.ExcludeUsers.Count -EQ "0"){

        $ExcludedUsers = "NONE"

        Write-Host "Excluded Users:" -ForegroundColor Green
        Write-Host $ExcludedUsers -ForegroundColor Green
    }

    else{

        $ExcludedUsers = "UNKNOWN"

        Write-Host "Excluded users:" -ForegroundColor Red
        Write-Host $ExcludedUsers -ForegroundColor Red
    }

    # End if/else statement for excluded users check.  Begin if/else statement for included groups check.

    Write-Host ""

    if($policy.Conditions.Users.IncludeGroups.Count -GT "0"){

        $Groups = @()
        
        foreach($group in $policy.Conditions.Users.IncludeGroups){

            $GroupDisplayName = Get-AzureADGroup -ObjectId $group | Select DisplayName

            $Groups += $GroupDisplayName.DisplayName
        }

        Write-Host "Included Groups:" -ForegroundColor Yellow

        foreach($groupname in $Groups){
            
            Write-Host $groupname -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.IncludeGroups.Count -EQ "0"){

        $IncludedGroups = "NONE"

        Write-Host "Included Groups:" -ForegroundColor Green
        Write-Host $IncludedGroups -ForegroundColor Green
    }

    else{

        $IncludedGroups = "UNKNOWN"

        Write-Host "Included Groups:" -ForegroundColor Red
        Write-Host $IncludedGroups -ForegroundColor Red
    }

    # End if/else statement for included groups check.  Begin if/else statement for excluded groups check.

    Write-Host ""

    if($policy.Conditions.Users.ExcludeGroups.Count -GT "0"){

        $Groups = @()
        
        foreach($group in $policy.Conditions.Users.ExcludeGroups){

            $GroupDisplayName = Get-AzureADGroup -ObjectId $group | Select DisplayName

            $Groups += $GroupDisplayName.DisplayName
        }

        Write-Host "Excluded Groups:" -ForegroundColor Yellow

        foreach($groupname in $Groups){
            
            Write-Host $groupname -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.ExcludeGroups.Count -EQ "0"){

        $ExcludedGroups = "NONE"

        Write-Host "Excluded Groups:" -ForegroundColor Green
        Write-Host $ExcludedGroups -ForegroundColor Green
    }

    else{

        $ExcludedGroups = "UNKNOWN"

        Write-Host "Excluded Groups:" -ForegroundColor Red
        Write-Host $ExcludedGroups -ForegroundColor Red
    }

    # End if/else statement for excluded groups check.  Begin if/else statement for included applications check.

    Write-Host ""
    
    if($policy.Conditions.Applications.IncludeApplications -EQ "None"){

        $IncludedApps = "NONE"

        Write-Host "Included Apps:" -ForegroundColor Green
        Write-Host $IncludedApps -ForegroundColor Green
    }

    elseif($policy.Conditions.Applications.IncludeApplications -EQ "All"){

        $IncludedApps = "All cloud apps"

        Write-Host "Included Apps:" -ForegroundColor Green
        Write-Host $IncludedApps -ForegroundColor Green
    }
    
    elseif($policy.Conditions.Applications.IncludeApplications.Count -GT "0"){
        
        $IncludedApps = @()
        
        foreach($app in $policy.Conditions.Applications.IncludeApplications){

            $IncludedApps += $app
        }

        Write-Host "Included Apps:" -ForegroundColor Yellow
        Write-Host $IncludedApps -ForegroundColor Yellow
    }

    elseif($policy.Conditions.Applications.IncludeApplications.Capacity -EQ "0"){

        $IncludedApps = "NONE"
        
        Write-Host "Included Apps:" -ForegroundColor Green
        Write-Host $IncludedApps -ForegroundColor Green
    } # For the time being this elseif fixes a bug where if a policy targets
    
    else{

        $IncludedApps = "UNKNOWN"

        Write-Host "Included Apps:" -ForegroundColor Red
        Write-Host $IncludedApps -ForegroundColor Red
    }

    # End if/else statement for included applications check.  Begin if/else statement for excluded applications check.

    Write-Host ""

    if($policy.Conditions.Applications.ExcludeApplications.Count -EQ "0"){

        $ExcludedApps = "NONE"

        Write-Host "Excluded Apps:" -ForegroundColor Green
        Write-Host $ExcludedApps -ForegroundColor Green
    }

    elseif($policy.Conditions.Applications.ExcludeApplications.Count -GT "0"){
        
        $ExcludedApps = @()
        
        foreach($app in $policy.Conditions.Applications.ExcludeApplications){

            $ExcludedApps += $app
        }

        Write-Host "Excluded Apps:" -ForegroundColor Yellow
        
        foreach($excludedApp in $ExcludedApps){
            
            Write-Host $excludedApp -ForegroundColor Yellow
        }
    }

    else{

        $ExcludedApps = "UNKNOWN"

        Write-Host "Excluded Apps:" -ForegroundColor Red
        Write-Host $ExcludedApps -ForegroundColor Red
    }

    # End if/else statement for excluded applications check.  Begin if/else statement for included directory roles check.

    Write-Host ""

    if($policy.Conditions.Users.IncludeRoles.Count -GT "0"){

        $Roles = @()
        
        foreach($role in $policy.Conditions.Users.IncludeRoles){

            $RoleDisplayName = Get-AzureADMSRoleDefinition -Id $role | Select DisplayName

            $Roles += $RoleDisplayName.DisplayName
        }

        Write-Host "Included Roles:" -ForegroundColor Yellow

        foreach($rolename in $Roles){
            
            Write-Host $rolename -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.IncludeRoles.Count -EQ "0"){

        $IncludedRoles = "NONE"

        Write-Host "Included Roles:" -ForegroundColor Green
        Write-Host $IncludedRoles -ForegroundColor Green
    }

    else{

        $IncludedRoles = "UNKNOWN"

        Write-Host "Included Roles:" -ForegroundColor Red
        Write-Host $IncludedRoles -ForegroundColor Red
    }

    # End if/else statement for included directory roles check.  Begin if/else statement for excluded directory roles check.

    Write-Host ""

    if($policy.Conditions.Users.ExcludeRoles.Count -GT "0"){

        $Roles = @()
        
        foreach($role in $policy.Conditions.Users.ExcludeRoles){

            $RoleDisplayName = Get-AzureADMSRoleDefinition -Id $role | Select DisplayName

            $Roles += $RoleDisplayName.DisplayName
        }

        Write-Host "Excluded Roles:" -ForegroundColor Yellow

        foreach($rolename in $Roles){
            
            Write-Host $rolename -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.ExcludeRoles.Count -EQ "0"){

        $ExcludedRoles = "NONE"

        Write-Host "Excluded Roles:" -ForegroundColor Green
        Write-Host $ExcludedRoles -ForegroundColor Green
    }

    else{

        $ExcludedRoles = "UNKNOWN"

        Write-Host "Excluded Roles:" -ForegroundColor Red
        Write-Host $ExcludedRoles -ForegroundColor Red
    }

    # End if/else statement for excluded directory roles check.  Begin if/else statement for Block/Grant controls configuration.

    Write-Host ""
    
    if($policy.GrantControls._Operator -EQ "AND"){

        $GrantControls = "Require all of the selected controls."

        Write-Host "Grant controls configuration: $GrantControls" -ForegroundColor Green

        $RequiredControls = $policy.GrantControls.BuiltInControls
        $RequiredControlsWithDisplayName = @()

        foreach($requiredcontrol in $RequiredControls){

            if($requiredcontrol -EQ "Mfa"){

                $controlDisplayName = "Require multifactor authentication."
                $RequiredControlsWithDisplayName += $controlDisplayName
            }

            elseif($requiredcontrol -EQ "CompliantDevice"){

                $controlDisplayName = "Require device to be marked as compliant."
                $RequiredControlsWithDisplayName += $controlDisplayName
            }

            elseif($requiredcontrol -EQ "DomainJoinedDevice"){

                $controlDisplayName = "Require Microsoft Entra hybrid joined device."
                $RequiredControlsWithDisplayName += $controlDisplayName
            }

            elseif($requiredcontrol -EQ "ApprovedApplication"){

                $controlDisplayName = "Require approved client app."
                $RequiredControlsWithDisplayName += $controlDisplayName
            }

            elseif($requiredcontrol -EQ "CompliantApplication"){

                $controlDisplayName = "Require app protection policy."
                $RequiredControlsWithDisplayName += $controlDisplayName
            }

            else{
                
                $controlDisplayName = "UNKNOWN"
                $RequiredControlsWithDisplayName += $controlDisplayName
            }
        }

        Write-Host "Controls:" -ForegroundColor Green
        
        foreach($requiredcontrolname in $RequiredControlsWithDisplayName){

            Write-Host $requiredcontrolname -ForegroundColor Green
        }
    }

    elseif($policy.GrantControls._Operator -EQ "OR"){

        $GrantControls = "Require one of the selected controls."
        
        if($policy.GrantControls.BuiltInControls -Contains "Block"){
        
            Write-Host "Grant controls configuration: $GrantControls" -ForegroundColor Green
        }

        else{

            if($policy.GrantControls.BuiltInControls.Count -EQ "1"){
            
                Write-Host "Grant controls configuration: $GrantControls" -ForegroundColor Green
            }

            elseif($policy.GrantControls.BuiltInControls.Count -GT "1"){

                Write-Host "Grant controls configuration: $GrantControls" -ForegroundColor Yellow
            }
        }

        $RequiredControls = $policy.GrantControls.BuiltInControls
        $RequiredControlsWithDisplayName = @()

        foreach($requiredcontrol in $RequiredControls){

            if($requiredcontrol -EQ "Mfa"){

                $controlDisplayName = "Require multifactor authentication."
                $RequiredControlsWithDisplayName += $controlDisplayName
            }

            elseif($requiredcontrol -EQ "CompliantDevice"){

                $controlDisplayName = "Require device to be marked as compliant."
                $RequiredControlsWithDisplayName += $controlDisplayName
            }

            elseif($requiredcontrol -EQ "DomainJoinedDevice"){

                $controlDisplayName = "Require Microsoft Entra hybrid joined device."
                $RequiredControlsWithDisplayName += $controlDisplayName
            }

            elseif($requiredcontrol -EQ "ApprovedApplication"){

                $controlDisplayName = "Require approved client app."
                $RequiredControlsWithDisplayName += $controlDisplayName
            }

            elseif($requiredcontrol -EQ "CompliantApplication"){

                $controlDisplayName = "Require app protection policy."
                $RequiredControlsWithDisplayName += $controlDisplayName
            }

            elseif($requiredcontrol -EQ "Block"){

                $controlDisplayName = "Block Access."
                $RequiredControlsWithDisplayName += $controlDisplayName
            }
            
            else{
                
                $controlDisplayName = "UNKNOWN"
                $RequiredControlsWithDisplayName += $controlDisplayName
            }
        }

        Write-Host ""
        
        if($policy.GrantControls.BuiltInControls -Contains "Block"){
        
            Write-Host "Controls:" -ForegroundColor Green
        }

        elseif($policy.GrantControls.BuiltInControls.Count -EQ "1"){

            Write-Host "Controls:" -ForegroundColor Green
        }
        
        elseif($policy.GrantControls.BuiltInControls.Count -GT "1"){

            Write-Host "Controls:" -ForegroundColor Yellow
        }

        else{

            Write-Host "Controls:" -ForegroundColor Red
            Write-Host "UNKNOWN" -ForegroundColor Red
            Write-Host ""
            Write-Host "NOTE: The policy me be configured to use 'Require authentication strength'" -ForegroundColor Yellow
        }
        
        foreach($requiredcontrolname in $RequiredControlsWithDisplayName){

            if($requiredcontrolname -EQ "Block Access."){
                
                Write-Host $requiredcontrolname -ForegroundColor Green
            }

            elseif($requiredcontrolname -EQ "UNKNOWN"){
                
                Write-Host $requiredcontrolname -ForegroundColor Red
            }

            elseif($policy.GrantControls.BuiltInControls.Count -EQ "1"){
            
                Write-Host $requiredcontrolname -ForegroundColor Green
            }

            else{

                Write-Host $requiredcontrolname -ForegroundColor Yellow
            }
        }
    }

    # End if/else statement for Block/Grant controls configuration.  Begin included user actions check.

    Write-Host ""
    
    if($policy.Conditions.Applications.IncludeUserActions.Count -EQ "0"){

        Write-Host "Included user actions:" -ForegroundColor Green
        Write-Host "NONE" -ForegroundColor Green
    }

    elseif($policy.Conditions.Applications.IncludeUserActions -EQ "urn:user:registerdevice"){

        Write-Host "Included user actions:" -ForegroundColor Green
        Write-Host "Register or join devices" -ForegroundColor Green
    }
        
    elseif($policy.Conditions.Applications.IncludeUserActions -EQ "urn:user:registersecurityinfo"){

        Write-Host "Included user actions:" -ForegroundColor Green
        Write-Host "Register security information" -ForegroundColor Green
    }

    else{

        Write-Host "Included user actions:" -ForegroundColor Red
        Write-Host "UNKNOWN" -ForegroundColor Red
    }

    # End included user actions check.  Begin included device platforms check.

    Write-Host ""
    
    if($policy.Conditions.Platforms.IncludePlatforms -EQ "All"){

        Write-Host "Included device platforms:" -ForegroundColor Green
        Write-Host "All device platforms." -ForegroundColor Green
    }

    elseif(($policy.Conditions.Platforms.IncludePlatforms -NE "All") -and ($policy.Conditions.Platforms.IncludePlatforms.Count -GT "0")){

        Write-Host "Included device platforms:" -ForegroundColor Yellow
        
        foreach($platform in $policy.Conditions.Platforms.IncludePlatforms){

            Write-Host $platform -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Platforms.IncludePlatforms.Count -EQ "0"){

        Write-Host "Included device platforms:" -ForegroundColor Green
        Write-Host "NONE" -ForegroundColor Green
    }

    else{

        Write-Host "Included device platforms:" -ForegroundColor Red
        Write-Host "UNKNOWN" -ForegroundColor Red
    }

    # End included device platforms check.  Begin excluded device platforms check.

    Write-Host ""
    
    if($policy.Conditions.Platforms.ExcludePlatforms.Count -EQ "0"){
        
        Write-Host "Excluded device platforms:" -ForegroundColor Green
        Write-Host "NONE" -ForegroundColor Green
    }

    elseif($policy.Conditions.Platforms.ExcludePlatforms.Count -GT "0"){

        Write-Host "Excluded device platforms:" -ForegroundColor Yellow
        
        foreach($platform in $policy.Conditions.Platforms.ExcludePlatforms){

            Write-Host $platform -ForegroundColor Yellow
        }
    }

    else{

        Write-Host "Excluded device platforms:" -ForegroundColor Red
        Write-Host "UNKNOWN" -ForegroundColor Red
    }

    # End excluded device platforms check.  Begin included location configuration check.

    Write-Host ""
    
    if($policy.Conditions.Locations.IncludeLocations -EQ "All"){

        Write-Host "Included locations:" -ForegroundColor Green
        Write-Host "All locations" -ForegroundColor Green
    }

    elseif($policy.Conditions.Locations.IncludeLocations -EQ "AllTrusted"){

        Write-Host "Included locations:" -ForegroundColor Yellow
        Write-Host "All trusted locations" -ForegroundColor Yellow
    }

    elseif(($policy.Conditions.Locations.IncludeLocations -NE "All") -and ($policy.Conditions.Locations.IncludeLocations -NE "AllTrusted") -and ($policy.Conditions.Locations.IncludeLocations.Count -GT "0")){

        Write-Host "Included locations:" -ForegroundColor Yellow
        
        $IncludedLocations = $policy.Conditions.Locations.IncludeLocations
        
        foreach($location in $IncludedLocations){

            $LocationInfo = Get-AzureADMSNamedLocationPolicy -PolicyId $location

            $NamedLocationDisplayName = $LocationInfo.DisplayName

            Write-Host ""
            Write-Host "Location name: '$NamedLocationDisplayName'" -ForegroundColor Magenta  

            if($LocationInfo.IsTrusted -Match "False"){

                $LocationTrusted = "Trusted: NO"
                Write-Host $LocationTrusted -ForegroundColor Yellow
            }

            elseif($LocationInfo.IsTrusted -Match "True"){

                $LocationTrusted = "Trusted: YES"
                Write-Host $LocationTrusted -ForegroundColor Green
            }

            else{

                if($LocationInfo.OdataType -EQ "#microsoft.graph.countryNamedLocation"){
                
                    $LocationTrusted = "Trusted: Country based named locations cannot be flagged as a trusted location."
                    Write-Host $LocationTrusted -ForegroundColor Green
                }

                else{

                    $LocationTrusted = "Trusted: UNKNOWN"
                    Write-Host $LocationTrusted -ForegroundColor Red
                }
            }
        
            if($LocationInfo.OdataType -EQ "#microsoft.graph.countryNamedLocation"){
                
                Write-Host ""
                Write-Host "Included countries for '$NamedLocationDisplayName':" -ForegroundColor Yellow
                
                foreach($country in $LocationInfo.CountriesAndRegions){

                    Write-Host $country -ForegroundColor Yellow
                }
            }

            elseif($LocationInfo.OdataType -EQ "#microsoft.graph.ipNamedLocation"){

                Write-Host ""
                Write-Host "Included IP addresses for '$NamedLocationDisplayName':" -ForegroundColor Yellow
                
                foreach($ipaddress in $LocationInfo.IpRanges){

                    Write-Host $ipaddress.CidrAddress -ForegroundColor Yellow
                }
            }

            else{
            }
        
        }
    }

    else{
        Write-Host "Included locations:" -ForegroundColor Yellow
        Write-Host "NOT CONFIGURED" -ForegroundColor Yellow
    }
        

    # End included location configuration check.  Begin excluded location configuration check.

    Write-Host ""
        
    if($policy.Conditions.Locations.ExcludeLocations -EQ "AllTrusted"){

        Write-Host "Excluded locations:" -ForegroundColor Yellow
        Write-Host "All trusted locations" -ForegroundColor Yellow
    }

    elseif(($policy.Conditions.Locations.ExcludeLocations -NE "AllTrusted") -and ($policy.Conditions.Locations.ExcludeLocations.Count -GT "0")){
    
        Write-Host "Excluded locations:" -ForegroundColor Yellow
        
        $ExcludedLocations = $policy.Conditions.Locations.ExcludeLocations
        
        foreach($location in $ExcludedLocations){

            $LocationInfo = Get-AzureADMSNamedLocationPolicy -PolicyId $location

            $NamedLocationDisplayName = $LocationInfo.DisplayName

            Write-Host ""
            Write-Host "Location name: '$NamedLocationDisplayName'" -ForegroundColor Magenta

            if($LocationInfo.IsTrusted -Match "False"){

                $LocationTrusted = "Trusted: NO"
                Write-Host $LocationTrusted -ForegroundColor Yellow
            }

            elseif($LocationInfo.IsTrusted -Match "True"){

                $LocationTrusted = "Trusted: YES"
                Write-Host $LocationTrusted -ForegroundColor Green
            }

            else{

                if($LocationInfo.OdataType -EQ "#microsoft.graph.countryNamedLocation"){
                
                    $LocationTrusted = "Trusted: Country based named locations cannot be flagged as a trusted location."
                    Write-Host $LocationTrusted -ForegroundColor Green
                }

                else{

                    $LocationTrusted = "Trusted: UNKNOWN"
                    Write-Host $LocationTrusted -ForegroundColor Red
                }
            }
        
            Write-Host ""
            
            if($LocationInfo.OdataType -EQ "#microsoft.graph.countryNamedLocation"){
                
                Write-Host "Included countries for '$NamedLocationDisplayName':" -ForegroundColor Yellow
                
                foreach($country in $LocationInfo.CountriesAndRegions){

                    Write-Host $country -ForegroundColor Yellow
                }
            }

            elseif($LocationInfo.OdataType -EQ "#microsoft.graph.ipNamedLocation"){

                Write-Host "Included IP addresses for '$NamedLocationDisplayName':" -ForegroundColor Yellow
                
                foreach($ipaddress in $LocationInfo.IpRanges){

                    Write-Host $ipaddress.CidrAddress -ForegroundColor Yellow
                }
            }

            else{
            }
        }
    }

    else{
        Write-Host "Excluded locations:" -ForegroundColor Yellow
        Write-Host "NOT CONFIGURED" -ForegroundColor Yellow
    }

    # End excluded location configuration check. Begin session controls configuration check.

    Write-Host ""    
    Write-Host "Session control configurations:" -ForegroundColor Yellow
    Write-Host ""
    
    # Begin app enforced restrictions check.
    
    Write-Host "NOTE: App enforced restrictions only works with Office365, Exchange Online, and SharePoint Online." -ForegroundColor Yellow
    Write-Host ""
    
    if($policy.SessionControls.ApplicationEnforcedRestrictions.IsEnabled -NotMatch "True"){

        Write-Host "Use app enforced restrictions: NOT CONFIGURED" -ForegroundColor Yellow
    }

    elseif($policy.SessionControls.ApplicationEnforcedRestrictions -Match "True"){

        Write-Host "Use app enforced restrictions: ENABLED" -ForegroundColor Green
    }

    else{

        Write-Host "Use app enforced restrictions: UNKNOWN" -ForegroundColor Red
    }

    # End app enforced restrictions check.  Begin Conditional Access app control check.
    
    if($policy.SessionControls.CloudAppSecurity.CloudAppSecurityType -Match "McasConfigured"){

        Write-Host "Use Conditional Access App Control: CONFIGURED 'Use custom policy...'" -ForegroundColor Yellow
    }

    elseif($policy.SessionControls.CloudAppSecurity.CloudAppSecurityType -Match "MonitorOnly"){

        Write-Host "Use Conditional Access App Control: CONFIGURED 'Monitor Only'" -ForegroundColor Yellow
    }

    elseif($policy.SessionControls.CloudAppSecurity.CloudAppSecurityType -EQ "BlockDownloads"){

        Write-Host "Use Conditional Access App Control: CONFIGURED 'Block Downloads'" -ForegroundColor Yellow
    }

    else{

        Write-Host "Use Conditional Access App Control: NOT CONFIGURED" -ForegroundColor Yellow
    }

    # End Conditional Access app control check.  Begin sign-in frequency check.

    Write-Host ""
    Write-Host "NOTE: The sign-in frequency control 'every time' cannot be used with M365 applications." -ForegroundColor Yellow
    Write-Host ""
    
    if($policy.SessionControls.SignInFrequency.Type -Match "Hours"){

        $Hours = $policy.SessionControls.SignInFrequency.Value
    
        Write-Host "Sign-in frequency: Configured for periodic reauthentication every $Hours hours." -ForegroundColor Yellow
    }

    elseif($policy.SessionControls.SignInFrequency.Type -Match "Days"){

        $Days = $policy.SessionControls.SignInFrequency.Value
    
        Write-Host "Sign-in frequency: Configured for periodic reauthentication every $Days days." -ForegroundColor Yellow

    }

    else{

        Write-Host "Sign in frequency: NOT CONFIGURED" -ForegroundColor Yellow
    }

    # End sign-in frequency check.  Begin persistent browser check.

    Write-Host ""
    
    if($policy.SessionControls.PersistentBrowser.Mode -Match "Always"){

        Write-Host "Persistent browser session: Always persistent" -ForegroundColor Yellow
    }

    elseif($policy.SessionControls.PersistentBrowser.Mode -Match "Never"){

        Write-Host "Persistent browser session: Never persistent" -ForegroundColor Yellow
    }

    else{

        Write-Host "Persistent browser session: NOT CONFIGURED" -ForegroundColor Yellow
    }

    # End persistent browser check.

    # Block basic authentication policy check.

    Write-Host ""

    if(($policy.Conditions.ClientAppTypes -Contains "ExchangeActiveSync") -and ($policy.Conditions.ClientAppTypes -Contains "Other") -and ($policy.GrantControls.BuiltInControls -Contains "Block")){

        Write-Host "CA policy '$PolicyName' DOES block basic authentication." -ForegroundColor Green
    }

    elseif(($policy.Conditions.ClientAppTypes -Contains "ExchangeActiveSync") -and ($policy.Conditions.ClientAppTypes -Contains "Other") -and ($policy.GrantControls.BuiltInControls -NotContains "Block")){

        Write-Host "CA policy '$PolicyName' ALLOWS basic authentication." -ForegroundColor Red
    }

    else{

        Write-Host "CA policy '$PolicyName' DOES NOT block basic authentication." -ForegroundColor Yellow
    }

    # End basic authentication policy check. Begin require MFA for administrators (and block persistent browser session) check.

    Write-Host ""

    if(($policy.Conditions.Users.IncludeRoles.Count -GT "0") -and ($policy.SessionControls.PersistentBrowser -Match "Never")){

        Write-Host "CA policy '$PolicyName' requires MFA for administrators and blocks persistent browser sessions." -ForegroundColor Yellow

        $Roles = @()
        
        foreach($role in $policy.Conditions.Users.IncludeRoles){

            $RoleDisplayName = Get-AzureADMSRoleDefinition -Id $role | Select DisplayName

            $Roles += $RoleDisplayName.DisplayName
        }

        Write-Host "Included Roles:" -ForegroundColor Yellow

        foreach($rolename in $Roles){
            
            Write-Host $rolename -ForegroundColor Yellow
        }
    }

    elseif(($policy.Conditions.Users.IncludeRoles.Count -GT "0") -and ($policy.SessionControls.PersistentBrowser -Match "Always")){

        Write-Host "CA policy '$PolicyName' requires MFA for administrators and allows persistent browser sessions." -ForegroundColor Red

        $Roles = @()
        
        foreach($role in $policy.Conditions.Users.IncludeRoles){

            $RoleDisplayName = Get-AzureADMSRoleDefinition -Id $role | Select DisplayName

            $Roles += $RoleDisplayName.DisplayName
        }

        Write-Host "Included Roles:" -ForegroundColor Red

        foreach($rolename in $Roles){
            
            Write-Host $rolename -ForegroundColor Red
        }
    }

    else{

        Write-Host "CA policy '$PolicyName' does not require MFA for administrators and block persistent browser sessions." -ForegroundColor Yellow
    }

    Write-Host "-----------------------------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    $PolicyCount++
}

Read-Host "Press enter to exit"

# Azure AD PowerShell does not yet support retrieving information on the 'Require Authentication Strength' grant control.

# There is a property of the policy that can be retrieved from AzureAD PowerShell called Conditions.Applications.IncludeProtectionLevels, I don't know what this property pertains to in terms of a CA policy.  Same said for GrantControls.TermsOfUse.

<# Note that if you exclude Linux as a device platform from a CA policy the script might generate this error:

Get-AzureADMSConditionalAccessPolicy : Error converting value "linux" to type 'Microsoft.Open.MSGraph.Model.ConditionalAccessDevicePlatforms'. Path 
'value[5].conditions.platforms.excludePlatforms[3]', line 1, position 7440.
At C:\GitHub\public\scripting\ProjectScripts\ConditionalAccessPolicyReport\ConditionalAccessPolicyReport.ps1:1 char:13
+ $Policies = Get-AzureADMSConditionalAccessPolicy
+             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Get-AzureADMSConditionalAccessPolicy], ApiException
    + FullyQualifiedErrorId : Microsoft.Open.MSGraphV10.Client.ApiException,Microsoft.Open.MSGraphV10.PowerShell.GetAzureADMSConditionalAccessPolicy
#>