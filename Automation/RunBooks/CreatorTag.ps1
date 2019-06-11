
# set-azcontext likely preferred...

Get-AzResource -OutVariable AllTheResources | Out-Null

foreach ($thing in $AllTheResources) {
    if ($thing.Tags.Keys -notcontains "Creator")
        {
        $person = (Get-AzLog -ResourceId $thing.ResourceId -StartTime (Get-Date).AddDays(-89) | Where-Object {$_.OperationName.Value -like "*/write"} | Where-Object {$_.Caller -like "*@avenel.com"} | Select caller,EventTimestamp | Sort-Object -Property EventTimestamp | Select-Object caller -First 1).Caller
            if ($person -ne $null)
                {
                    if ($thing.Tags -eq $null)
                        {
                        $name = $thing.Name
                       # $words = "$name is being tagged with the Creator tag, whose value is $person"
                       # Write-Output $words
                        $r = Get-AzResource -ResourceName $name -ResourceGroupName $thing.ResourceGroupName
                        $tagvalue = @{Creator="$person"}
                        Set-AzResource -ResourceId $r.ResourceId -Tag $tagvalue -Force
                        # something about this does not work for Dashboards? all else is fine
                        }
                    else
                        {
                        $name = $thing.Name
                      #  $words = "$name is being tagged with the Creator tag, whose value is $person"
                      #  Write-Output $words
                        $r = Get-AzResource -ResourceName $name -ResourceGroupName $thing.ResourceGroupName
                        $r.Tags.Add("Creator", "$person")
                        Set-AzResource -Tag $r.Tags -ResourceId $r.ResourceId -Force
                        }
                }        
          }
    }