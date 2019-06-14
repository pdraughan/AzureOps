# Run Runbooks more than Once an Hour

Use [this article](https://blogs.technet.microsoft.com/stefan_stranger/2017/06/21/azure-scheduler-schedule-your-runbooks-more-often-than-every-hour/) as a reference.

To complete this feat, it is assumed that you already have created a Runbook you wish to execute. On your Runbook, add a Webhook (be mindful if that webhook triggers the runbook to execute on the Azure or a Hybrid agents; you MUST use a hybrid agent for longer running jobs).
- Save this webhook as this is the only time it is available or shown

Go to Azure > Scheduler Job Collections > Add

- You can add up to 50 jobs [Standard] to a collection. I suggest naming a collection by the job frequency you intend to execute (ie, Minute, Every15, etc.) within that collection.
- Create a Job. Provide the runbook webhook, as the action.
    - https
    - POST
    - Url (address from above)
- Choose the Schedule as "Recurring" and the interval of time preferred.

Now, every time the Job Scheduler runs, the Runbook will be triggered.