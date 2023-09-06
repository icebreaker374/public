New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchBoxTaskbarMode' -PropertyType 'DWord' -Value 0

New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\Currentversion\Explorer\Advanced' -Name 'ShowTaskViewButton' -PropertyType 'DWord' -Value 0
