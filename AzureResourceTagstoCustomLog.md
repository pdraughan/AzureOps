# Azure Resource Tags into Log Analytics Custom Log(s)
In order to consume Azure Resource tags into a Custom Log within Log Analytics, you must run a runbook on a regular interval so as to keep the "_CL" update with recent information.
* If the alert query is improved so as to ignore the time constraint from the qualifying query against the primary table, then the regularly running tag can be backed off to a lower refrequnency.

The runbook template is below. You will need to ensure your Automation account has the appropriate Variables available (_WorkspaceID_ and _WorkspaceKey_ as an example). Then, provide the Subscription ID(s) from whichever subscription you want the information to be gleaned and uploaded.

NOTE: Runbooks have a schedule limit of once an hour. If you need this to run more often, go to [this article](RunRunBooksOfften.md).
```
$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName
$creds = Get-AutomationPSCredential -Name 'Automan'
# Get information required for Log Analytics workspace from Automation variables.
$customerId = Get-AutomationVariable -Name 'WorkspaceID'
$sharedKey = Get-AutomationVariable -Name 'WorkspaceKey'

$subscriptions = "Sub 1","Sub 2","etc"

foreach ($sub in $subscriptions){
Connect-AzAccount -Credential $creds
set-azcontext -Subscription $sub | Out-Null
# Get information required for Log Analytics workspace from Automation variables.
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
        $uri = "https://$CustomID.ods.opinsights.azure.com/api/logs?api-version=2016-04-01"

        $headers = @{
            "Authorization" = $signature;
            "Log-Type" = $logType;
            "x-ms-date" = $rfc1123date;
            "time-generated-field" = $TimeStampField;
        }
    }

#do the actual tag research
try {Get-AzResource -ExpandProperties -outVariable resources}
catch {}
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

$uri = "https://$CustomerID.ods.opinsights.azure.com/api/logs?api-version=2016-04-01"
    Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $sharedKey -body $body -logType $logType #-TimeStampField CreationTime
    #write-output $body
}
```