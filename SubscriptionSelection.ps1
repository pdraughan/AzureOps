Login-AzureRmAccount
$subscriptionID = (Get-AzureRmSubscription | ogv -PassThru).SubscriptionID
Set-AzureRmContext -Subscription $subscriptionID