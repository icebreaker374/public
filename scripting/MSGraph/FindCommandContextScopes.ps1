$Cmdlet = Read-Host "Please enter the cmdlet you want to view the available context scopes for"

((Find-MgGraphCommand -Command $Cmdlet).Permissions.Name) | Select @{N='AvailableContextScopes'; E={$_}} | Out-String

Read-Host "Press Enter to exit"

# Referenced content:

#Referenced URL: https://stackoverflow.com/questions/42708128/show-output-before-read-host Referenced Content: $GetSQL = Get-SqlVersions | Out-String