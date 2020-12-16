# Custom Logs included in Alerts
Based on the process outlined in the [Custom Logs script](AzureResourceTagstoCustmLogs.md), you can use the following to _Join_ the Tags information into existing Azure Monitor Alerts.

NOTE: replace "DOMAINname" with the name of your domain and update "Tags_CL" if that is not the name of your Custom Log table.

```
| extend Computer = trim(".DOMAINname.com", Computer)
| join kind= leftouter (Tags_CL) on $left.Computer == $right.ResourceName_s
| project Computer, Tags_client_s // and any other columns you need exposed in the Alert
```

The consistency of the above assumes that you've allowed for the [Common Alert Schema](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-common-schema) so that the top results show the desired information.