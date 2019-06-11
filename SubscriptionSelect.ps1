#Login-AzAccount
$subscriptionID = (Get-AzSubscription | ogv -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID