<#
  .DESCRIPTION 
  Allows the user to interactively choose an AzureAD Group to which they want to join one or more AzureAD Applications.

  .EXAMPLE
  ./ADaddApptoADGroup.ps1

#>

$AADGroup = (Get-AzureADGroup | ogv -Title "Choose the AD Group to which you want to join the Service Principals" -PassThru)

$AzureADServicePrincipals = (Get-AzureADServicePrincipal -Top 10000 | ogv -Title "Choose the Enterprise Application(s) that you wish to add to the AD Group" -OutputMode Multiple)

foreach ($AzADServicePrincipal in $AzureADServicePrincipals) {
    Add-AzureADGroupMember -ObjectId $AADGroup.ObjectId -RefObjectId $AzureADServicePrincipals[$i].ObjectId

    Write-Host ""$AzADServicePrincipal.DisplayName"has been successfully added to"$AADGroup.DisplayName"" -ForegroundColor Green
}