$creds = (Get-AutomationPSCredential -Name 'xxxxxxxxxxxxx')
Connect-AzAccount -credential $creds

$subscriptions = "SubID", "xxxxxxxxxxxx"

# Get information required for Log Analytics workspace from Automation variables.
$customerId = (Get-AutomationVariable -Name 'LogAnalyticsID')
$sharedKey = (Get-AutomationVariable -Name 'LogAnalyticsKEY')
$method = "POST"
# Set the name of the record type.
$logType = "VPNConnection"

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
        $uri = "https://$customerId.ods.opinsights.azure.com/api/logs?api-version=2016-04-01"

        $headers = @{
            "Authorization" = $signature;
            "Log-Type" = $logType;
            "x-ms-date" = $rfc1123date;
            "time-generated-field" = $TimeStampField;
        }
}
foreach ($sub in $subscriptions){
set-azcontext -Subscription $sub | Out-Null
$arr = @()
Get-AzResource -Tag @{VPN = "ConnectionMonitoring"} | select Name, ResourceGroupName -OutVariable VPNs | Out-Null

foreach ($VPN in $VPNs){
$rg = $vpn.ResourceGroupName

if ($rg.count -gt 1){
    foreach ($group in $rg){
    Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rg | select Name -OutVariable Connections | Out-Null

        if ($Connections.Count -gt 1)
            {
            foreach ($Connection in $Connections){
               Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $Connection.Name | select Name,ConnectionStatus,Id -OutVariable temp
               $arr += $temp
               }
            }
        Else {Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $Connections.Name | select Name,ConnectionStatus,Id -OutVariable temp
            $arr += $temp
            }
    }
}
else {Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rg | select Name -OutVariable Connections | Out-Null

        if ($Connections.Count -gt 1)
            {
            foreach ($Connection in $Connections){
               Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $Connection.Name | select Name,ConnectionStatus,Id -OutVariable temp
               $arr += $temp
               }
            }
        ElseIf ($Connections.Count -eq 0)
        {
        }
        Else {Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $Connections.Name | select Name,ConnectionStatus,Id -OutVariable temp
            $arr += $temp
            }
      }
}
$body = $arr | ConvertTo-Json

    # Send the data to Log Analytics.

            $uri = "https://$customerId.ods.opinsights.azure.com/api/logs?api-version=2016-04-01"

    Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $sharedKey -body $body -logType $logType #-TimeStampField CreationTime
    #write-output $body
}