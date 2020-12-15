# WARNING: These are notes and various scripts used for research whilst I attempt to understand Policy vs ASC and how to discern affected items in each.

    $SecurityTasks = Get-AzSecurityAssessment # get all recommendations from ASC

    $SecurityTasks | ogv -OutputMode Multiple -OutVariable one #| ? {$_.RecommendationType -match "container"}
    #Write-Host $Detailed
<#
    foreach ($Detail in $resources) {
       $information = Get-AzSecurityAssessmentMetadata -ResourceId $Detail.Id
       Write-Host $information -ForegroundColor green

       $violator = Get-AzSecuritySubAssessment -AssessmentName $detail.DisplayName
       Write-Host $detail.DisplayName -ForegroundColor blue
        foreach ($issue in $violator) {
                    Write-Host $Detail.Id
                   Write-Host $issue.ResourceDetails.Id
        }
    }
    #>

    foreach ($assessment in $one) {
    $ResourceDetails = Get-AzSecuritySubAssessment -AssessmentName $assessment.DisplayName

    foreach ($resourceDetail in $ResourceDetails){
        $resourcedtail.ResourceDetails
    }
    }
    
    Get-AzSecurityAssessment | ? {$_.DisplayName -match "trust"}

    Get-AzSecurityAssessment -ResourceId ""
DisplayName     : Container images should be deployed from trusted registries only
Status          : Microsoft.Azure.Commands.Security.Models.Assessments.PSSecurityAssessmentStatus
ResourceDetails : Microsoft.Azure.Commands.Security.Models.Assessments.PSSecurityResourceDetails
AdditionalData  :
    

    Get-AzSecuritySubAssessment
    -AssessedResourceId
    Full resource ID of the resource that the assessment is calculated on.
    -AssessmentName
    Name of the assessment resource.

    # PowerShell
$subscriptionId = (Get-AzContext).subscription.id

#super handy for PowerShell to log an API request:
$context = Get-AzContext
$profile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($profile)
$token = $profileClient.AcquireAccessToken($context.Subscription.TenantId)
$authHeader = @{
    'Content-Type'  = 'application/json'
    'Authorization' = 'Bearer ' + $token.AccessToken
}

$uri = "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.PolicyInsights/policyEvents/default/queryResults?api-version=2019-10-01"
#"https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Security/tasks?api-version=2015-06-01-preview"

$response = Invoke-RestMethod -Uri $uri `
                              -Method Post `
                              -Headers $authHeader

$response.value.properties.securitytaskParameters | ? {$_.policyName -match "trust"} -OutVariable shortlist


$recommendations = Get-AzSecurityTask
$recommendations | $recommendations | ? {$_.RecommendationType -match "trust"}


az account set --subscription 
az security task list

