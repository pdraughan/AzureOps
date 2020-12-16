# Access Review for users only using RDS
AzureAD's Access Review does NOT encompass users that only use Azure DevOps (still no work around) or only access Azure resources via RDS. To compare an ADGroup membership against those that are actually using their credentials, you need to create a custom Log that submits users (properly formatted for easier joining within Log Analytics) of a given AD Group for comparison against a successful logon event within a connect Azure VM.

## Creating AD Group Members Custom Log
Update the following with your desired ADGroup(s), CustomerID, SharedKey (for Log Analytics), and adjust the "replace" at the bottom of the script, to better format the usernames.
```
$creds = (Get-AutomationPSCredential -Name 'ADJoin') # use auto creds
Connect-AzureAD -Credential $creds

# choose the AzureAD groups
$AADGroup = "xxxxxxxx", "xxxxxxxxxx"


$customerId = "xxxxxxxx"
$sharedKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$method = "POST"

# Set the name of the record type.
$logType = "ADGroupMembers"

# Create the function to create the authorization signature
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource) {
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId, $encodedHash
    return $authorization
}

# Create the function to create and post the request
Function Post-LogAnalyticsData($customerId, $sharedKey, $body, $logType) {
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
        "Authorization"        = $signature;
        "Log-Type"             = $logType;
        "x-ms-date"            = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }
}

foreach ($group in $AADGroup) {
    $array = @()
    $body = $null

    $ADGroupName = (Get-AzureADGroup -ObjectId $group -OutVariable ADGroupName).DisplayName
    Get-AzureADGroupMember -ObjectId $group | Select-Object DisplayName, UserPrincipalName -OutVariable client | Out-Null
foreach ($person in $client) {
    $UserName = $person.UserPrincipalName -replace '@xxxxxxxxxx.com', ''
    $array += ([pscustomobject]@{ Username = $UserName; ADGroup = $ADGroupName })
}

$body = $array | ConvertTo-Json

# Send the data to Log Analytics.

$uri = "https://$customerId.ods.opinsights.azure.com/api/logs?api-version=2016-04-01"

Send-OMSAPIIngestionFile -customerId $customerId -sharedKey $sharedKey -body $body -logType $logType #-TimeStampField CreationTime
#Write-Output $body
}
```
Feel encouraged to have this be a daily runbook, so that historic records are available.

## Joining AD Group members against Access
In Log Analytics, run the below query to get a list of users from the AD Group(s) that have NOT accessed any Azure VM for the past x days.
```
SecurityEvent
\\replace the following "DOMAIN NAME" with your AzureAD Domain name
| extend Account = trim(@"DOMAIN NAME\\", Account)
\\ adjust the day range as desired
| where TimeGenerated > ago(90d)
| where Activity == "4624 - An account was successfully logged on."
| join kind= rightanti (ADGroupMembers_CL) on $left.Account == $right.Username_s
| summarize by Username_s, ADGroup_s
```
The output is the username and ADGroup of users that should likely be deleted from AzureAD.