$Policies = Get-AzureADMSConditionalAccessPolicy

foreach($policy in $Policies){

    Write-Host $policy.DisplayName

    # Begin if/else statement for policy status.
    
    if($policy.State -EQ "enabled"){

        $PolicyStatus = "Status: ENABLED"
    }

    elseif($policy.State -EQ "disabled"){

        $PolicyStatus = "Status: DISABLED"
    }

    else{

        $PolicyStatus = "Status: UNKOWN"
    }

    # End if/else statement for policy status.

    Write-Host $PolicyStatus
    Write-Host "
"
    # Begin if/else statement for included users check.
    
    if($policy.Conditions.Users.IncludeUsers -EQ "All"){

        $IncludedUsers = "Included users: All Users"
    }

    elseif(($policy.Conditions.Users.IncludeUsers -NE "All") -and ($policy.Conditions.Users.IncludeUsers -NE $null)){

        $Users = foreach($user in $policy.Conditions.Users.IncludeUsers){

            Get-AzureADUser -ObjectId $user | Select DisplayName
        }

        $IncludedUsers = "Included users: $Users"
    }

    else{

        $IncludedUsers = "Included users: UNKNOWN"
    }

    Write-Host "Included Users:" $Users.DisplayName
    Write-Host "
"

}