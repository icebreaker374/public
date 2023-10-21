$Policies = Get-AzureADMSConditionalAccessPolicy

foreach($policy in $Policies){

    $PolicyName = $policy.DisplayName

    Write-Host "----------------------------------------"
    
    Write-Host "Conditional Access Policy Name: '$PolicyName'"

    # Begin if/else statement for policy status.
    
    if($policy.State -EQ "enabled"){

        $PolicyStatus = "Policy Status: ENABLED"
    }

    elseif($policy.State -EQ "disabled"){

        $PolicyStatus = "Policy Status: DISABLED"
    }

    else{

        $PolicyStatus = "Policy Status: UNKOWN"
    }

    # End if/else statement for policy status.

    Write-Host $PolicyStatus
    Write-Host ""

    # Begin if/else statement for included users check.
    
    if($policy.Conditions.Users.IncludeUsers -EQ "All"){

        $IncludedUsers = "Included users: All Users"

        Write-Host $IncludedUsers
    }

    elseif(($policy.Conditions.Users.IncludeUsers -NE "All") -and ($policy.Conditions.Users.IncludeUsers -NE $null)){

        $Users = @()
        
        foreach($user in $policy.Conditions.Users.IncludeUsers){

            $UserDisplayName = Get-AzureADUser -ObjectId $user | Select DisplayName

            $Users += $UserDisplayName.DisplayName
        }

        $IncludedUsers = $Users

        Write-Host "Included Users:"

        foreach($useraccount in $Users){
            
            Write-Host $useraccount
        }
    }

    else{

        $IncludedUsers = "Included users: NONE"

        Write-Host $IncludedUsers
    }

    # End if/else statement for included users check.  Begin if/else statement for excluded users check.

    if($policy.Conditions.Users.ExcludeUsers -EQ "All"){

        $ExcludedUsers = "Excluded users: All Users"

        Write-Host ""
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

    else{

        $ExcludedUsers = "Excluded users: NONE"

        Write-Host ""
        Write-Host $ExcludedUsers
    }

    Write-Host "----------------------------------------"
    Write-Host ""
}