if(Test-Path "C:\Temp"){ # This curly bracket opens the if/else statement that checks if C:\Temp exists.

    Write-Host "C:\Temp already exists."
}

else{

    cd C:\
    md Temp > $null

    Write-Host "A directory called 'Temp' was created at 'C:\'"
} # This curly bracket closes the if/else statement that checks if C:\Temp exists.

cd C:\Temp

$RequiredModules = "Microsoft.Graph.Authentication","Microsoft.Graph.Users","Microsoft.Graph.Identity.DirectoryManagement"

foreach($module in $RequiredModules){

    if(Get-InstalledModule -Name $module){ # This curly bracket opens the if/else statement that checks if the AzureAD module is installed.

        Write-Host "
        Confirmed the" $module "module is installed."

        if(Get-Module -Name $module){ # This curly bracket opens the if/else statement that checks if the AzureAD module is loaded.

            Write-Host "
        Confirmed the" $module "module is loaded."
        }

        else{

            Import-Module -Name $module

            Write-Host "
        The" $module "Module was successfully loaded."
        } # This curly bracket closes the if/else statement that checks if the AzureAD module is loaded.
    } # This curly bracket closes the if/else statement that checks if the AzureAD module is installed.

    else{

        Install-Module -Name $module
        Import-Module -Name $module

        Write-Host "
        The" $module "Module was successfully loaded."
    }
} # This curly bracket closes the foreach loop that runs the installed/imported check for each required module.



Connect-MgGraph -ContextScope Process # The "Process" ContextScope prevents new PS sessions from using previously used credentials to authenticate and run the report, so it prompts for
                                      # authentication every time.

$DirectoryRoles = Get-MgDirectoryRole | Select DisplayName, Id # This command gets a list of the AAD admin roles that have ever been assigned and selects the display name and GUID of each
                                                               # admin role.

foreach($role in $DirectoryRoles){ # This curly bracket opens the foreach loop that gets the member list of each AAD admin role.

    $MembersOfRole = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id | Select Id # This command gets the Id value of each member in the list of each role.

    foreach($member in $MembersOfRole){ # This curly bracket opens the foreach loop that converts the Id of each member in the list of each role to that members DisplayName value.
        $MemberDisplayName = Get-MgUser -UserId $member.Id | Select DisplayName # This command is what converts each users Id to their Display Name.

    # This command dumps the list of members for each AAD admin role in a readable format with the DisplayName of the role and the associated users.  It uses the "Sort" function on the
    # "UserAssignedToRole" column to eliminate duplicate entries, that's a bug with the script I have to work out once Graph get's better documentation.
    Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id | Select @{Name="Azure AD Role"; Expression={$role.DisplayName}}, @{Name="UserAssignedToRole"; Expression={$MemberDisplayName.DisplayName}} | Sort UserAssignedToRole -Unique
    } # This curly bracket closes the foreach loop that dumps the readable report of assigned AAD admin roles.
} # This curly bracket closes the foreach loop that get's the Id's of each member  in the list of each role.
