# Custom Log Queries
## How to Join two tables together
Full documentation can be found [here](https://docs.microsoft.com/en-us/azure/azure-monitor/log-query/joins). In concept, it is a simple matter of naming the table you want to join in by a common key shared between the two.

NOTE: keys being equal is case sensitive. Thereby, use`tolower()`, etc. as needed.

```
Table1
| join ( Table2 )
on $left.key1 == $right.key2
```
