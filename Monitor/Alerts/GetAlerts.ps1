$subscriptionID = (Get-AzSubscription | ogv -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID

Get-AzAlertRule -ResourceGroupName dashboards