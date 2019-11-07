#allows for mass creation into one KeyVault, from the names of another
$subscriptionID = (Get-AzSubscription | Out-GridView -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID
$KeyVault = (Get-AzKeyVault | Out-GridView -Title "Select the KeyVault whose Secret names you wish to copy" -PassThru).VaultName
$GoingIntoKeyVault = (Get-AzKeyVault | Out-GridView -Title "Select the KeyVault to where you want to make the shells" -PassThru).VaultName
$secretNames = (Get-AzKeyVaultSecret -VaultName $keyvault).Name
$secretvalue = ConvertTo-SecureString "Intentionally Left Blank" -AsPlainText -Force

foreach ($Secret in $secretNames) {
    Set-AzKeyVaultSecret -VaultName $GoingIntoKeyVault -Name $Secret -SecretValue $secretvalue
    Write-Host "$Secret added to $GoingIntoKeyVault" -ForegroundColor Green
}