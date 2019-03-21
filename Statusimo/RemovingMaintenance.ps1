Import-Module Statusimo

Remove-StatusimoMaintenance -DaysOld 0 -MaintenancePath $PSScriptRoot\Maintenance
New-StatusimoPage -FilePath $PSScriptRoot\StatusPage.html -IncidentsPath $PSScriptRoot\Incidents -MaintenancePath $PSScriptRoot\Maintenance