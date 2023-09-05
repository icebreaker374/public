﻿if(Test-Path "C:\Temp"){

Write-Host "C:\Temp already exists."
}

else{

cd C:\
md Temp > $null

Write-Host "A directory called 'Temp' was created at 'C:\'"
}

Write-Host "You will be prompted to login with User/Global Admin credentials to connet to MSOnline in 5 seconds..."

Connect-MsolService

Write-Host "A list of unlicensed users that DO NOT have sign-in blocked will be generated:"

Get-MsolUser -All -EnabledFilter EnabledOnly| Where-Object {($_.isLicensed -eq $false) -and ($_.UserPrincipalName -NotMatch "onmicrosoft.com") -and ($_.UserPrincipalName -NotMatch "EXT")} | Select-Object UserPrincipalName | Export-CSV C:\Temp\ActiveUnlicensedUsers.csv