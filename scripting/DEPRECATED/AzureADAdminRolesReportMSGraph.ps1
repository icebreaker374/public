$DirectoryRoles = Get-MgDirectoryRole | Select DisplayName, Id

foreach($role in $DirectoryRoles){

$MembersOfRole = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id | Select Id

    foreach($member in $MembersOfRole){
    $MemberDisplayName = Get-MgUser -UserId $member.Id | Select DisplayName

    Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id | Select @{Name="Azure AD Role"; Expression={$role.DisplayName}}, @{Name="UserAssignedToRole"; Expression={$MemberDisplayName.DisplayName}}}
}
