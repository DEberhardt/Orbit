# Teams Session CmdLets

## about_TeamsSession

## SHORT DESCRIPTION

Creating a PowerShell Session to Teams/SkypeOnline  with MicrosoftTeams v2.0.0

## LONG DESCRIPTION

SkypeOnline and MSOnline (AzureADv1) are the two oldest Office 365 Services. Creating a Session to them was not implemented very nicely.
The Modules `MicrosoftTeams` (v2 and higher) and `AzureAd` alleviate most of the issues the community had with the connection, but I think they can still use some magic
These CmdLets try to provide said magic and enhance the experience dramatically.

The introduction of Privileged Identity Management and Privileged Access Groups further requires some manual steps that these are trying to make simpler and provide an easier way to connect and activate your roles

## CmdLets

|                                  Function | Description                                                                                                                                                                                                       |
| ----------------------------------------: | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|       [`Connect-Me`](Connect-Me.md) (con) | Creates a Session to AzureAD and MicrosoftTeams (incl. SkypeOnline) in one go. Only displays **ONE** authentication prompt, and, if applicable, **ONE** MFA prompt! Also tries to enable your Admin Roles in PIM. |
| [`Disconnect-Me`](Disconnect-Me.md) (dis) | Disconnects form all Sessions to SkypeOnline, MicrosoftTeams and AzureAD                                                                                                                                          |

Connect-Me aims to solve the issue of having and maintaining a connection to all Office 365 needed for Administration. In most cases, that will be AzureAd and MicrosoftTeams/SkypeOnline, but could also need ExchangeOnline

## Admin Roles

Activating Admin Roles made easier. Please note that Privileged Access Groups are not yet integrated as there are no PowerShell commands available yet in the AzureAdPreview Module. This will be added as soon as possible. Commands are used with `Connect-Me`, but can be used on its own just as well.

> [!NOTE] Please **note**, that Privileged Admin Groups are currently not covered by these CmdLets. This will be added as soon as they have been fully documented and PowerShell CmdLets are available for them.

|                                                      Function | Description                                                                                      |
| ------------------------------------------------------------: | ------------------------------------------------------------------------------------------------ |
|     [`Disable-AzureAdAdminRole`](Disable-AzureAdAdminRole.md) | Disables Admin Roles assigned directly to the AccountId provided.                                |
|       [`Enable-AzureAdAdminRole`](Enable-AzureAdAdminRole.md) | Enables Admin Roles assigned directly to the AccountId provided.                                 |
|             [`Get-AzureAdAdminRole`](Get-AzureAdAdminRole.md) | Displays all (active or eligible) Admin Roles assigned to an AzureAdUser                         |
| [`Disable-MyAzureAdAdminRole`](Disable-MyAzureAdAdminRole.md) | Disables Admin Roles for the currently connected Administrator.                                  |
|   [`Enable-MyAzureAdAdminRole`](Enable-MyAzureAdAdminRole.md) | Enables Admin Roles for the currently connected Administrator.                                   |
|         [`Get-MyAzureAdAdminRole`](Get-MyAzureAdAdminRole.md) | Displays all (active or eligible) Admin Roles assigned to the currently connected  Administrator |

### Support Functions

|                                                                Function | Description                                                                                    |
| ----------------------------------------------------------------------: | ---------------------------------------------------------------------------------------------- |
|               [`Assert-AzureAdConnection`](Assert-AzureAdConnection.md) | Tests connection and visual feedback in the Verbose stream if called directly.                 |
| [`Assert-MicrosoftTeamsConnection`](Assert-MicrosoftTeamsConnection.md) | Tests connection and **Attempts to reconnect** a timed-out session. Alias `PoL` *Ping-of-life* |
|             [`Get-CurrentConnectionInfo`](Get-CurrentConnectionInfo.md) | Returning information about existing Sessions to AzureAd and MicrosoftTeams                    |
|                   [`Test-AzureAdConnection`](Test-AzureAdConnection.md) | Verifying a Session to AzureAD exists                                                          |
|     [`Test-ExchangeOnlineConnection`](Test-ExchangeOnlineConnection.md) | Verifying a Session to ExchangeOnline exists                                                   |
|     [`Test-MicrosoftTeamsConnection`](Test-MicrosoftTeamsConnection.md) | Verifying a Session to MicrosoftTeams exists                                                   |
|           [`Test-SkypeOnlineConnection`](Test-SkypeOnlineConnection.md) | Verifying a Session to SkypeOnline exists                                                      |

The Assert cmdlets are nested in all Scripts to ensure sessions are created and available

> [!NOTE] While Assert-MicrosoftTeamsConnection is powerful, I cannot overload it. At a certain point I have to leave the decision to the Administrator on how to proceed
> This includes the infamous `StepablePipelineError` which doesn't hint towards to PIM Admin roles to be activated. Please run `Connect-Me` again to rectify.

### SkypeOnline Functions

Temporarily re-introduced into the modules to allow backwards compatibility with MicrosoftTeams v1

|                                                                            Function | Description                                                                                            |
| ----------------------------------------------------------------------------------: | ------------------------------------------------------------------------------------------------------ |
|                                     [`Connect-SkypeOnline`](Connect-SkypeOnline.md) | Creates a session to SkypeOnline with New-CsOnlineSession (Requires MicrosoftTeams v1.1.10 or higher). |
|                       [`Assert-SkypeOnlineConnection`](Assert-SkypeOnlineConnection.md) | Validating a Session to SkypeOnline exists                                                              |
|                       [`Test-SkypeOnlineConnection`](Test-SkypeOnlineConnection.md) | Verifying a Session to SkypeOnline exists                                                              |

## EXAMPLES

### Example 1 - Connecting to AzureAd, MicrosoftTeams

````powershell
Connect-Me [-AccountId] John@domain.com
````

Establishes a session to AzureAd, enables Admin Roles (with AzureAdPreview), Connects to MicrosoftTeams

### Example 2 - Connecting to AzureAd, MicrosoftTeams and ExchangeOnline

````powershell
Connect-Me [-AccountId] John@domain.com -Exchange
````

Establishes a session to AzureAd, enables Admin Roles (with AzureAdPreview), Connects to MicrosoftTeams and ExchangeOnline

## Background

To properly administer Teams, a connection to `AzureAd` is most likely needed. This Module and all functions therefore tie closely to an existing Azure-Ad Connection. Assertions are performed when the respective sessions are required.
For best performance, connections should start with running `Connect-Me` which will connect to both.

> [!NOTE] Privileged Identity Management and Role Activation are currently only available with the Module `AzureAdPreview` installed in Version `2.0.2.24` or higher, until the functions become generally available through the AzureAd Module.
> If the Module is not installed, a warning is displayed that the functions are not available.

## NOTE

Cleanly disconnecting a session has many benefits. First, it removes the Connections and prepares your PowerShell window to be able to be reused for connections to other Tenants.

Second, it removes all Global Variables set during use (The name is starting with "TF"). This ensures that customer data is cleared up. This includes all Azure Ad Groups, Licenses, etc. queried and stored or better overall performance!

## Development Status

Mature. Fine-tuning is still in progress.
Privileged Identity Management Roles may still an update.

## TROUBLESHOOTING NOTE

Thoroughly tested, but Unit-tests for these CmdLets are not yet available.

To effectively manage multiple tenants, please disconnect your session cleanly (with `dis`), before reconnecting.

Privileged Identity Management Role activation depend heavily on the settings in the Tenant.
If you find a scenario not working for you or producing errors, please open an issue.

## SEE ALSO

- [`Connect-AzureAd`](https://docs.microsoft.com/en-us/powershell/module/azureAd/connect-azuread)
- [`Connect-MicrosoftTeams`](https://docs.microsoft.com/en-us/powershell/module/teams/connect-microsoftteams?view=teams-ps)

## KEYWORDS

- AzureAd
- AzureAdPreview
- Privileged Identity Management
- MicrosoftTeams
- SkypeOnline
- Module
- Requirements
