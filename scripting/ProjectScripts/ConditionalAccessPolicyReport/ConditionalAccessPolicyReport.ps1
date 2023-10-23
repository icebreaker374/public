$Policies = Get-AzureADMSConditionalAccessPolicy

$PolicyCount = 1

foreach($policy in $Policies){

    $PolicyName = $policy.DisplayName

    Write-Host "Policy $PolicyCount" -ForegroundColor Cyan
    
    Write-Host "-----------------------------------------------------------------------------------------------------" -ForegroundColor Cyan
    
    Write-Host "CA Policy Name: '$PolicyName'" -ForegroundColor Magenta

    # Begin if/else statement for policy status.
    
    if($policy.State -EQ "enabled"){

        $PolicyStatus = "CA Policy Status: ENABLED"
        Write-Host ""
        Write-Host $PolicyStatus -ForegroundColor Green
    }

    elseif($policy.State -EQ "disabled"){

        $PolicyStatus = "CA Access Policy Status: DISABLED"
        Write-Host ""
        Write-Host $PolicyStatus -ForegroundColor Red
    }

    elseif($policy.State -EQ "enabledForReportingButNotEnforced"){

        $PolicyStatus = "CA Policy Status: REPORT-ONLY"
        Write-Host ""
        Write-Host $PolicyStatus -ForegroundColor Yellow
    }

    else{

        $PolicyStatus = "CA Access Policy Status: UNKNOWN"
        Write-Host ""
        Write-Host $PolicyStatus -ForegroundColor Red
    }

    # End if/else statement for policy status.  Begin if/else statement for included users check.
    
    if($policy.Conditions.Users.IncludeUsers -EQ "All"){

        $IncludedUsers = "All Users"

        Write-Host ""
        Write-Host "Included Users:" -ForegroundColor Green
        Write-Host $IncludedUsers -ForegroundColor Green
    }

    elseif($policy.Conditions.Users.IncludeUsers -EQ "None"){

        $IncludedUsers = "NONE"

        Write-Host ""
        Write-Host "Included Users:" -ForegroundColor Yellow
        Write-Host $IncludedUsers -ForegroundColor Yellow
    }
    
    elseif(($policy.Conditions.Users.IncludeUsers -NE "All") -and ($policy.Conditions.Users.IncludeUsers -NE "None")){

        $Users = @()
        
        foreach($user in $policy.Conditions.Users.IncludeUsers){

            $UserDisplayName = Get-AzureADUser -ObjectId $user | Select DisplayName

            $Users += $UserDisplayName.DisplayName
        }

        Write-Host ""
        Write-Host "Included Users:" -ForegroundColor Yellow

        foreach($useraccount in $Users){
            
            Write-Host $useraccount -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.IncludeUsers.Count -EQ "0"){

        $IncludedUsers = "NONE"

        Write-Host ""
        Write-Host "Included Users:" -ForegroundColor Yellow
        Write-Host $IncludedUsers -ForegroundColor Yellow
    }

    else{

        $IncludedUsers = "UNKNOWN"

        Write-Host ""
        Write-Host "Included Users:" -ForegroundColor Red
        Write-Host $IncludedUsers -ForegroundColor Red
    }

    # End if/else statement for included users check.  Begin if/else statement for excluded users check.

    if($policy.Conditions.Users.ExcludeUsers.Count -GT "0"){

        $Users = @()
        
        foreach($user in $policy.Conditions.Users.ExcludeUsers){

            $UserDisplayName = Get-AzureADUser -ObjectId $user | Select DisplayName

            $Users += $UserDisplayName.DisplayName
        }

        Write-Host ""
        Write-Host "Excluded Users:" -ForegroundColor Yellow

        foreach($useraccount in $Users){
            
            Write-Host $useraccount -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.ExcludeUsers.Count -EQ "0"){

        $ExcludedUsers = "NONE"

        Write-Host ""
        Write-Host "Excluded Users:" -ForegroundColor Green
        Write-Host $ExcludedUsers -ForegroundColor Green
    }

    else{

        $ExcludedUsers = "UNKNOWN"

        Write-Host ""
        Write-Host "Excluded users:" -ForegroundColor Red
        Write-Host $ExcludedUsers -ForegroundColor Red
    }

    # End if/else statement for excluded users check.  Begin if/else statement for included groups check.

    if($policy.Conditions.Users.IncludeGroups.Count -GT "0"){

        $Groups = @()
        
        foreach($group in $policy.Conditions.Users.IncludeGroups){

            $GroupDisplayName = Get-AzureADGroup -ObjectId $group | Select DisplayName

            $Groups += $GroupDisplayName.DisplayName
        }

        Write-Host ""
        Write-Host "Included Groups:" -ForegroundColor Yellow

        foreach($groupname in $Groups){
            
            Write-Host $groupname -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.IncludeGroups.Count -EQ "0"){

        $IncludedGroups = "NONE"

        Write-Host ""
        Write-Host "Included Groups:" -ForegroundColor Green
        Write-Host $IncludedGroups -ForegroundColor Green
    }

    else{

        $IncludedGroups = "UNKNOWN"

        Write-Host ""
        Write-Host "Included Groups:" -ForegroundColor Red
        Write-Host $IncludedGroups -ForegroundColor Red
    }

    # End if/else statement for included groups check.  Begin if/else statement for excluded groups check.

    if($policy.Conditions.Users.ExcludeGroups.Count -GT "0"){

        $Groups = @()
        
        foreach($group in $policy.Conditions.Users.ExcludeGroups){

            $GroupDisplayName = Get-AzureADGroup -ObjectId $group | Select DisplayName

            $Groups += $GroupDisplayName.DisplayName
        }

        Write-Host ""
        Write-Host "Excluded Groups:" -ForegroundColor Yellow

        foreach($groupname in $Groups){
            
            Write-Host $groupname -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.ExcludeGroups.Count -EQ "0"){

        $ExcludedGroups = "NONE"

        Write-Host ""
        Write-Host "Excluded Groups:" -ForegroundColor Green
        Write-Host $ExcludedGroups -ForegroundColor Green
    }

    else{

        $ExcludedGroups = "UNKNOWN"

        Write-Host ""
        Write-Host "Excluded Groups:" -ForegroundColor Red
        Write-Host $ExcludedGroups -ForegroundColor Red
    }

    # End if/else statement for excluded groups check.  Begin if/else statement for included applications check.

    if($policy.Conditions.Applications.IncludeApplications -EQ "None"){

        $IncludedApps = "NONE"

        Write-Host ""
        Write-Host "Included Apps:" -ForegroundColor Green
        Write-Host $IncludedApps -ForegroundColor Green
    }

    elseif($policy.Conditions.Applications.IncludeApplications.Count -GT "0"){
        
        $IncludedApps = @()
        
        foreach($app in $policy.Conditions.Applications.IncludeApplications){

            $IncludedApps += $app
        }

        Write-Host ""
        Write-Host "Included Apps:" -ForegroundColor Yellow
        Write-Host $IncludedApps -ForegroundColor Yellow
    }

    else{

        $IncludedApps = "UNKNOWN"

        Write-Host ""
        Write-Host "Included Apps:" -ForegroundColor Red
        Write-Host $IncludedApps -ForegroundColor Red
    }

    # End if/else statement for included applications check.  Begin if/else statement for excluded applications check.

    if($policy.Conditions.Applications.ExcludeApplications.Count -EQ "0"){

        $ExcludedApps = "NONE"

        Write-Host ""
        Write-Host "Excluded Apps:" -ForegroundColor Green
        Write-Host $ExcludedApps -ForegroundColor Green
    }

    elseif($policy.Conditions.Applications.ExcludeApplications.Count -GT "0"){
        
        $ExcludedApps = @()
        
        foreach($app in $policy.Conditions.Applications.ExcludeApplications){

            $ExcludedApps += $app
        }

        Write-Host ""
        Write-Host "Excluded Apps:" -ForegroundColor Yellow
        
        foreach($excludedApp in $ExcludedApps){
            
            Write-Host $excludedApp -ForegroundColor Yellow
        }
    }

    else{

        $ExcludedApps = "UNKNOWN"

        Write-Host ""
        Write-Host "Excluded Apps:" -ForegroundColor Red
        Write-Host $ExcludedApps -ForegroundColor Red
    }

    # End if/else statement for excluded applications check.  Begin if/else statement for included directory roles check.

    if($policy.Conditions.Users.IncludeRoles.Count -GT "0"){

        $Roles = @()
        
        foreach($role in $policy.Conditions.Users.IncludeRoles){

            $RoleDisplayName = Get-AzureADMSRoleDefinition -Id $role | Select DisplayName

            $Roles += $RoleDisplayName.DisplayName
        }

        Write-Host ""
        Write-Host "Included Roles:" -ForegroundColor Yellow

        foreach($rolename in $Roles){
            
            Write-Host $rolename -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.IncludeRoles.Count -EQ "0"){

        $IncludedRoles = "NONE"

        Write-Host ""
        Write-Host "Included Roles:" -ForegroundColor Green
        Write-Host $IncludedRoles -ForegroundColor Green
    }

    else{

        $IncludedRoles = "UNKNOWN"

        Write-Host ""
        Write-Host "Included Roles:" -ForegroundColor Red
        Write-Host $IncludedRoles -ForegroundColor Red
    }

    # End if/else statement for included directory roles check.  Begin if/else statement for excluded directory roles check.

    if($policy.Conditions.Users.ExcludeRoles.Count -GT "0"){

        $Roles = @()
        
        foreach($role in $policy.Conditions.Users.ExcludeRoles){

            $RoleDisplayName = Get-AzureADMSRoleDefinition -Id $role | Select DisplayName

            $Roles += $RoleDisplayName.DisplayName
        }

        Write-Host ""
        Write-Host "Excluded Roles:" -ForegroundColor Yellow

        foreach($rolename in $Roles){
            
            Write-Host $rolename -ForegroundColor Yellow
        }
    }

    elseif($policy.Conditions.Users.ExcludeRoles.Count -EQ "0"){

        $ExcludedRoles = "NONE"

        Write-Host ""
        Write-Host "Excluded Roles:" -ForegroundColor Green
        Write-Host $ExcludedRoles -ForegroundColor Green
    }

    else{

        $ExcludedRoles = "UNKNOWN"

        Write-Host ""
        Write-Host "Excluded Roles:" -ForegroundColor Red
        Write-Host $ExcludedRoles -ForegroundColor Red
    }

    # End if/else statement for included directory roles check.  Begin if/else statement for Block/Grant controls configuration.

    if($policy.GrantControls._Operator -EQ "AND"){

        $GrantControls = "Require all of the selected controls."

        Write-Host ""
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

        Write-Host ""
        Write-Host "Controls:" -ForegroundColor Green
        
        foreach($requiredcontrolname in $RequiredControlsWithDisplayName){

            Write-Host $requiredcontrolname -ForegroundColor Green
        }
    }

    elseif($policy.GrantControls._Operator -EQ "OR"){

        $GrantControls = "Require one of the selected controls."

        Write-Host ""
        Write-Host "Grant controls configuration: $GrantControls" -ForegroundColor Yellow

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
        Write-Host "Controls:" -ForegroundColor Yellow
        
        foreach($requiredcontrolname in $RequiredControlsWithDisplayName){

            Write-Host $requiredcontrolname -ForegroundColor Yellow
        }
    }

    # End if/else statement for Block/Grant controls configuration.


    # Block basic authentication policy check.

    if(($policy.Conditions.ClientAppTypes -Contains "ExchangeActiveSync") -and ($policy.Conditions.ClientAppTypes -Contains "Other") -and ($policy.GrantControls.BuiltInControls -Contains "Block")){

        Write-Host ""
        Write-Host "CA Policy '$PolicyName' DOES block basic authentication." -ForegroundColor Green
    }

    elseif(($policy.Conditions.ClientAppTypes -Contains "ExchangeActiveSync") -and ($policy.Conditions.ClientAppTypes -Contains "Other") -and ($policy.GrantControls.BuiltInControls -NotContains "Block")){

        Write-Host ""
        Write-Host "CA Policy '$PolicyName' ALLOWS basic authentication." -ForegroundColor Red
    }

    else{

        Write-Host ""
        Write-Host "CA Policy '$PolicyName' DOES NOT block basic authentication." -ForegroundColor Yellow
    }

    Write-Host "-----------------------------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    $PolicyCount++
}