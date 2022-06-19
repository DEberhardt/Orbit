# Licensing in AzureAd

## about_Licensing

## SHORT DESCRIPTION

Simplifying License assignment and validating requirements for Voice Config

## LONG DESCRIPTION

Querying Licensing on the Tenant to inform with names rather than IDs, assigning Licenses by Names and finding requirements for Voice Configuration.
In particular assignment and enablement of the PhoneSystem Service Plan.

## CmdLets

| Function                                                                  | Description                                                                                                    |
| -------------------------------------------------------------------------: | -------------------------------------------------------------------------------------------------------------- |
| [`Get-AzureAdLicense`](Get-AzureAdLicense.md)                       | A Script to query all published Licenses and their Service Plans.<br />Displays all Licenses unless instructed to filter Teams relevant only |
| [`Get-AzureAdLicenseServicePlan`](Get-AzureAdLicenseServicePlan.md) | A Script to query all published Licenses, but displaying Service Plans only.<br />Displays all Licenses unless instructed to filter Teams relevant only             |
| [`Get-AzureAdUserLicense`](Get-AzureAdUserLicense.md)                   | Queries licenses assigned to a User and displays visual output<br />Displays all Licenses unless instructed to filter Teams relevant only                                                 |
| [`Get-AzureAdUserLicenseServicePlan`](Get-AzureAdUserLicenseServicePlan.md) | Queries licenses assigned to a User and displays visual output<br />Displays all Licenses unless instructed to filter Teams relevant only                                                 |
| [`Get-TeamsTenantLicense`](Get-TeamsTenantLicense.md)               | Queries licenses present on the Tenant. Switches are available for better at-a-glance visibility               |
| [`Get-TeamsUserLicenseServicePlan`](Get-TeamsUserLicenseServicePlan.md)                   | Queries licenses assigned to a User and displays visual output<br />Displays only Teams relevant licenses unless instructed to display all                                                 |
| [`Get-TeamsUserLicense`](Get-TeamsUserLicense.md)                   | Queries licenses assigned to a User and displays visual output<br />Displays only Teams relevant licenses unless instructed to display all                                                 |
| [`Set-AzureAdUserLicenseServicePlan`](Set-AzureAdUserLicenseServicePlan.md)                   | Enables or Disables a ServicePlan for assigned Licenses to a user.              |
| [`Set-TeamsUserLicense`](Set-TeamsUserLicense.md)                   | Adds or removes one or more Licenses against the provided Identity. Also can remove all Licenses.              |

> [!NOTE] Get-AzureAdLicense forms the baseline of the Licensing functions, reading directly from Microsoft Docs [Licensing & Service Plan reference](https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference). This bears the risk that an update to the site may break all Licensing functions, but it also gives you the most up to date Licensing information available.

### Support CmdLets

| Function                                                          | Description                                                                         |
| -----------------------------------------------------------------: | ----------------------------------------------------------------------------------- |
| [`Test-TeamsUserLicense`](Test-TeamsUserLicense.md)         | Tests an individual Service Plan or a License Package against the provided Identity |
| [`Test-TeamsUserHasCallPlan`](Test-TeamsUserHasCallPlan.md) | Tests an individual Calling Plains assigned against the provided Identity           |
| [`Test-AzureAdUserLicenseContainsServicePlan`](Test-AzureAdUserLicenseContainsServicePlan.md) | Tests whether a License contains a specific Service Plan           |
| [`New-AzureAdLicenseObject`](New-AzureAdLicenseObject.md)   | Creates a License Object for application. Generic helper function.                  |

## EXAMPLES

### Example 1

````powershell
Get-TeamsUserLicense -Identity John@domain.com
````

Example 1 queries license related elements for a User and returns a custom Object incl.PhoneSystem and PhoneSystemStatus

### Example 2

````powershell
Set-TeamsUserLicense -Identity John@domain.com -Add Office365E3,PhoneSystem
````

Example 2 assigns the Office 365 E3 License and the PhoneSystem License to the User

### Example 3

````powershell
Set-TeamsUserLicense -Identity John@domain.com -Add Office365E5 -Remove Office365E3
````

Example 3 replaces the Office 365 E3 License for an E5 License.

### Example 4

````powershell
Set-TeamsUserLicense -Identity John@domain.com -Add PhoneSystemVirtualUser -RemoveAll
````

Example 4 replaces all assigned licenses with a PhoneSystem Virtual User License.

> [!NOTE] When removing a License from a User, the Users will lose the functionality the license provides. For example, the E3 or E5 License contain a Service Plan for Exchange which will give the User a Mailbox. Completing a License Operation (in PowerShell or in the Admin Center) will trigger the subsystem to process these. When replacing a License, Microsoft recommend to do it in one step as the Example 3 and 4 above illustrate.

## NOTE

Replacing Licenses should be performed in one step to retain the functionality throughout the process.

Resource Accounts can be set up with any License, but ideally utilises the free* PhoneSystem Virtual User License available in the Tenant. Should those license become available later, Resource Accounts may become unusable if the PhoneSystem licenses are not replaced in one step.

## Development Status

Development is complete. As always, some gremlins might still lurk in my code, please let me know.

## TROUBLESHOOTING NOTE

Thoroughly tested, but Unit-tests for these CmdLets are not yet available.

## SEE ALSO

- [about_UserManagement](about_UserManagement.md)
- [about_TeamsResourceAccount](about_TeamsResourceAccount.md)
- [about_TeamsCommonAreaPhone](about_TeamsCommonAreaPhone.md)

## KEYWORDS

- ServicePlan
- PhoneSystem
