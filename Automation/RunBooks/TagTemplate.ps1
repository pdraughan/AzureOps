$resources = Get-AzResource

foreach($resource in $resources)
{
    #Fetching Tags
    $Tags = $resource.Tags
    
    #Checkign if tags is null or have value
    if($Tags -ne $null)
    {
Write-Host $resource.Name $Tags
    }
    else
    {
        Out-Null
    }
}