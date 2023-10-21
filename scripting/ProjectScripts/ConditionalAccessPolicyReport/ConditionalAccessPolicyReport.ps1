$Policies = Get-AzureADMSConditionalAccessPolicy

$PolicyCount = 1

foreach($policy in $Policies){

    $PolicyName = $policy.DisplayName

    Write-Host "Policy $PolicyCount" -ForegroundColor Cyan
    
    Write-Host "-----------------------------------------------------------------------------------------------------" -ForegroundColor Cyan
    
    Write-Host "CA Policy Name: '$PolicyName'"

    # Begin if/else statement for policy status.
    
    if($policy.State -EQ "enabled"){

        $PolicyStatus = "CA Policy Status: ENABLED"
    }

    elseif($policy.State -EQ "disabled"){

        $PolicyStatus = "CA Access Policy Status: DISABLED"
    }

    elseif($policy.State -EQ "enabledForReportingButNotEnforced"){

        $PolicyStatus = "CA Policy Status: REPORT-ONLY"
    }

    else{

        $PolicyStatus = "CA Access Policy Status: UNKNOWN"
    }

    # End if/else statement for policy status.

    Write-Host ""
    Write-Host $PolicyStatus
    

    # Begin if/else statement for included users check.
    
    if($policy.Conditions.Users.IncludeUsers -EQ "All"){

        $IncludedUsers = "All Users"

        Write-Host ""
        Write-Host "Included Users:"
        Write-Host $IncludedUsers
    }

    elseif(($policy.Conditions.Users.IncludeUsers -NE "All") -and ($policy.Conditions.Users.IncludeUsers -NE $null)){

        $Users = @()
        
        foreach($user in $policy.Conditions.Users.IncludeUsers){

            $UserDisplayName = Get-AzureADUser -ObjectId $user | Select DisplayName

            $Users += $UserDisplayName.DisplayName
        }

        $IncludedUsers = $Users

        Write-Host ""
        Write-Host "Included Users:"

        foreach($useraccount in $Users){
            
            Write-Host $useraccount
        }
    }

    elseif($policy.Conditions.Users.IncludeUsers.Count -EQ "0"){

        $IncludedUsers = "NONE"

        Write-Host ""
        Write-Host "Included Users:"
        Write-Host $IncludedUsers
    }

    else{

        $IncludedUsers = "UNKNOWN"

        Write-Host ""
        Write-Host "Included Users:"
        Write-Host $IncludedUsers
    }

    # End if/else statement for included users check.  Begin if/else statement for excluded users check.

    if($policy.Conditions.Users.ExcludeUsers -EQ "All"){

        $ExcludedUsers = "All Users"

        Write-Host ""
        Write-Host "Excluded users:"
        Write-Host $ExcludedUsers
    }

    elseif(($policy.Conditions.Users.ExcludeUsers -NE "All") -and ($policy.Conditions.Users.ExcludeUsers -NE $null)){

        $Users = @()
        
        foreach($user in $policy.Conditions.Users.ExcludeUsers){

            $UserDisplayName = Get-AzureADUser -ObjectId $user | Select DisplayName

            $Users += $UserDisplayName.DisplayName
        }

        $ExcludedUsers = $Users

        Write-Host ""
        Write-Host "Excluded Users:"

        foreach($useraccount in $Users){
            
            Write-Host $useraccount
        }
    }

    elseif($policy.Conditions.Users.ExcludeUsers.Count -EQ "0"){

        $ExcludedUsers = "NONE"

        Write-Host ""
        Write-Host "Excluded Users:"
        Write-Host $ExcludedUsers
    }

    else{

        $ExcludedUsers = "UNKNOWN"

        Write-Host ""
        Write-Host "Excluded users:"
        Write-Host $ExcludedUsers
    }

    # End if/else statement for excluded users check.  Begin if/else statement for included groups check.

    if($policy.Conditions.Users.IncludeGroups.Count -GT "0"){

        $Groups = @()
        
        foreach($group in $policy.Conditions.Users.IncludeGroups){

            $GroupDisplayName = Get-AzureADGroup -ObjectId $group | Select DisplayName

            $Groups += $GroupDisplayName.DisplayName
        }

        $IncludedGroups = $Groups


        Write-Host ""
        Write-Host "Included Groups:"

        foreach($groupname in $Groups){
            
            Write-Host $groupname
        }
    }

    elseif($policy.Conditions.Users.IncludeGroups.Count -EQ "0"){

        $IncludedGroups = "NONE"

        Write-Host ""
        Write-Host "Included Groups:"
        Write-Host $IncludedGroups
    }

    else{

        $IncludedGroups = "UNKNOWN"

        Write-Host ""
        Write-Host "Included Groups:"
        Write-Host $IncludedGroups
    }

    # End if/else statement for included groups check.  Begin if/else statement for excluded groups check.

    if($policy.Conditions.Users.ExcludeGroups.Count -GT "0"){

        $Groups = @()
        
        foreach($group in $policy.Conditions.Users.ExcludeGroups){

            $GroupDisplayName = Get-AzureADGroup -ObjectId $group | Select DisplayName

            $Groups += $GroupDisplayName.DisplayName
        }

        $ExcludedGroups = $Groups


        Write-Host ""
        Write-Host "Excluded Groups:"

        foreach($groupname in $Groups){
            
            Write-Host $groupname
        }
    }

    elseif($policy.Conditions.Users.ExcludeGroups.Count -EQ "0"){

        $ExcludedGroups = "NONE"

        Write-Host ""
        Write-Host "Excluded Groups:"
        Write-Host $ExcludedGroups
    }

    else{

        $ExcludedGroups = "UNKNOWN"

        Write-Host ""
        Write-Host "Excluded Groups:"
        Write-Host $ExcludedGroups
    }

    # End if/else statement for excluded groups check.  Begin if/else statement for included applications check.












    # Block basic authentication policy check.

    if(($policy.Conditions.ClientAppTypes -Contains "ExchangeActiveSync") -and ($policy.Conditions.ClientAppTypes -Contains "Other") -and ($policy.GrantControls.BuiltInControls -Contains "Block")){

        Write-Host ""
        Write-Host "CA Policy '$PolicyName' DOES block basic authentication."
    }

    else{

        Write-Host ""
        Write-Host "CA Policy '$PolicyName' DOES NOT block basic authentication."
    }

    Write-Host "-----------------------------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    $PolicyCount++
}