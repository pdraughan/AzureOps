This [Azure Automation runbook](https://automys.com/library/asset/scheduled-virtual-machine-shutdown-startup-microsoft-azure) automates the scheduled shutdown and startup of virtual machines in an Azure subscription based on the Tag and its value.

To use on a VM, add the **Tag** "AutoShutdownSchedule", with the value of your choice (see below for options).

- The runbook implements a solution for scheduled power management of Azure virtual machines in combination with tags
        on virtual machines or resource groups which define a shutdown schedule. Each time it runs, the runbook looks for all
        virtual machines or resource groups with a tag named "AutoShutdownSchedule" having a value defining the schedule,
        e.g. "10PM -> 6AM". It then checks the current time against each schedule entry, ensuring that VMs with tags or in tagged groups are shut down or started to conform to the defined schedule.
- Acceptable schedule formats can be found [here](https://automys.com/library/asset/scheduled-virtual-machine-shutdown-startup-microsoft-azure) (scroll down to the **Schedule Tag Examples** section).
--For example: `AutoShutdownSchedule : 03:00 - 11:00, Saturday, Sunday, Christmas` has the VM OFF from 10pm CST to 6am CST, all day on Saturday and Sunday, as well as off on Christmas.


Potential Replacement, currently in _Preview_: https://docs.microsoft.com/en-us/azure/automation/automation-solution-vm-management

