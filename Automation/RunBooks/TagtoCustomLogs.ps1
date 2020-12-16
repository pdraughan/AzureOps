<#
  .DESCRIPTION 
  As the AA RunAs Account, scans provided subscriptions for the existing Tags, and sends those values to Log Analytics as a custom log, for query and auditing purposes.
  # Creates A Custom Log "_CL" to a given $logType. Whatever is sent via POST in this case, appears in 
    # Log Analytics as "Tags_CL". Using an OuterLeft JOIN, you can include the Tags off a given resource in the alert information.

  .PARAMETER Subscriptions
  Subscriptions (multiple values accepted), from which you want to collect tags.  
  .PARAMETER customerId
  Log analytics WorkspaceID
  .PARAMETER sharedKey
  key from the workspace (same one used for manually registering an agent)

  .EXAMPLE
  ./TagtoCustomLogs.ps1 -subscriptions "1234-1234-23", "something else", "4321-432-12" -customerId "21345-1234-12" -sharedKey "base64 thingy"

#>

Param(
  [Parameter(Mandatory = $true)]
  [string]$Subscriptions,
  [Parameter(Mandatory = $true)]
  [string]$customerId,
  [Parameter(Mandatory = $true)]
  [string]$sharedKey
)




foreach ($sub in $subscriptions){
set-azcontext -Subscription $sub | Out-Null

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