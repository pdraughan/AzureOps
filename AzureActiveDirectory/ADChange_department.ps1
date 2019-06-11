$Current = Read-Host "What is the current Department you want to change"

$New = Read-Host "New Department"

Get-AzureADUser -Filter "Department eq '$Current'" | Select UserPrincipalName, Department 
Get-AzureADUser -Filter "Department eq '$Current'" | Set-AzureADUser -Department $New

Write-Host "Here are the results of your change"

Get-AzureADUser -Filter "Department  eq '$New'" | Select UserPrincipalName, Department
