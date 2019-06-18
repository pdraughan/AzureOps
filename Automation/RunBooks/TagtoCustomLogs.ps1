# Creates A Custom Log "_CL" to a given $logType. Whatever is sent via POST in this case, appears in 
# Log Analytics as "Tags_CL". Using an OuterLeft JOIN, you can include the Tags off a given resource in the alert information.

# declare the SubscriptionIDs you want scanned
$subscriptions = "xxxxxx","xxxxxx"

foreach ($sub in $subscriptions){
set-azcontext -Subscription $sub | Out-Null
# Get information required for Log Analytics workspace from Automation variables.
$customerId = "xxxxxxx"
$sharedKey = "xxxxxxxxxxxx"
$method = "POST"
# Set the name of the record type.
$logType = "Tags"

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

#do the actual tag research
$resources = Get-AzResource -ExpandProperties # -TagName "client" #adding that parameter limits the resources pulled in, but should expidite the runbook completion
$arr = @()
foreach($Azresource in $resources)
{
    #Fetching Tags
    $Tags = $Azresource.Tags
    $temp = "" | select ResourceName,ResourceId,Tags
    #Checkign if tags is null or have value
     if($Tags.Count -gt "0")
    {
        # Convert the job data to json

 #       $temp.ResourceName = $Azresource.Name
 #       $temp.ResourceId = $Azresource.ResourceId
        $temp.Tags = [string]($Tags.GetEnumerator() | % { "$($_.Key)=$($_.Value);" })
        $temp = $Azresource
       
        $arr +=$temp
    }
    else
    {
    Out-Null
    }
   
}
$body = $arr | ConvertTo-Json

    # Send the data to Log Analytics.

            $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + "/api/logs" + "?api-version=2016-04-01"

    Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $sharedKey -body $body -logType $logType #-TimeStampField CreationTime
    write-output $body
}