<#
  .DESCRIPTION 
  As the AA RunAs Account, get the number of subscribers to a given topic, and send it to a Log Analytics API for custom log retention.


  .PARAMETER SubscriptionID
  Subscription ID where the service bus is located.  
  .PARAMETER RG
  Resource Group where the service bus is located.
  .PARAMETER NameSpace
  Name of the Service Bus.

  .EXAMPLE
  ./SBSubscriberCount.ps1 -subscriptionID 1234-1234-23 -RG "Resource Group" -NameSpace "ServiceBus Namespace"

#>

Param(
  [Parameter(Mandatory = $true)]
  [string]$SubscriptionID,
  [Parameter(Mandatory = $true)]
  [string]$RG,
  [Parameter(Mandatory = $true)]
  [string]$NameSpace
)

$cred = Get-AutomationPSCredential -Name 'xxxx'
Connect-AzAccount -Credential $cred | Out-Null

Set-AzContext -Subscription $SubscriptionID | Out-Null
Get-AzServiceBusTopic -ResourceGroupName $RG -Namespace $NameSpace | Select-Object Name, SubscriptionCount -OutVariable Topics | Out-Null

#send daata to CustomLogs
# Get information required for Log Analytics workspace from Automation variables.
$customerId = "xxxxxx"
$sharedKey = "xxxxx"

$method = "POST"
# Set the name of the record type.
$logType = "ServiceBusTopics"

    # Create the function to create the authorization signature
    Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
    {
        $xHeaders = "x-ms-date:" + $date
        $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

        $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
        $keyBytes = [Convert]::FromBase64String($sharedKey)

        $sha256 = New-Object System.Security.Cryptography.HMACSHA256
        $sha256.Key = $keyBytes
        $calculatedHash = $sha256.ComputeHash($bytesToHash)
        $encodedHash = [Convert]::ToBase64String($calculatedHash)
        $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
        return $authorization
    }

    # Create the function to create and post the request
    Function Post-LogAnalyticsData($customerId, $sharedKey, $body, $logType)
    {
        $method = "POST"
        $contentType = "application/json"
        $resource = "/api/logs"
        $rfc1123date = [DateTime]::UtcNow.ToString("r")
        $contentLength = $body.Length
        $signature = Build-Signature `
            -customerId $customerId `
            -sharedKey $sharedKey `
            -date $rfc1123date `
            -contentLength $contentLength `
            -method $method `
            -contentType $contentType `
            -resource $resource
        $uri = "https://$customerid.ods.opinsights.azure.com/api/logs?api-version=2016-04-01"

        $headers = @{
            "Authorization" = $signature;
            "Log-Type" = $logType;
            "x-ms-date" = $rfc1123date;
            "time-generated-field" = $TimeStampField;
        }
}


$body = $Topics | ConvertTo-Json

    # Send the data to Log Analytics.
    Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $sharedKey -body $body -logType $logType #-TimeStampField CreationTime
   # write-output $body
