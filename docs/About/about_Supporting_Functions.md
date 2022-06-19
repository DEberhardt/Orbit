# Support Functions

## about_Supporting_Functions

## SHORT DESCRIPTION

Support Functions not part of the main focus

## LONG DESCRIPTION

Functions that do not build the core of this module, but nevertheless are usefull additions to it. Covering Backup, Testing, Assertions and other Helper functions for public use. Private Functions are not listed.

## CmdLets

### Backup and Restore

Taking a backup of every outputable CmdLet that Teams has to offer. Curtesy of Ken Lasko

|                                      Function | Description                                                                                                         |
| --------------------------------------------: | ------------------------------------------------------------------------------------------------------------------- |
|         [`Backup-TeamsEV`](Backup-TeamsEV.md) | Takes a backup of all EnterpriseVoice related features in Teams.                                                    |
|       [`Restore-TeamsEV`](Restore-TeamsEV.md) | Makes a full authoritative restore of all EnterpriseVoice related features. Handle with care!                       |
| [`Backup-TeamsTenant`](Backup-TeamsTenant.md) | An adaptation of the above, backing up as much as can be gathered through available `Get`-Commands from the tenant. |

> [!NOTE] The Get-Commands in this function is currently static. While this is fine for Backup-TeamsEV, `Backup-TeamsTenant` may see drift as a result. If additional Get-Commands are added to Teams, this command will need an update. Please let me know. An Automatic mechanism to discover these is desired.

### Helper functions

String reformatting is needed to normalise Numbers as E.164 numbers and allow a more diverse input (like: `'+1(555)-1234 567'`) it also serves to normalise DisplayNames and UPNs should characters be used that are not allowed.

|                                                                        Function | Description                                                                                                                  |
| ------------------------------------------------------------------------------: | ---------------------------------------------------------------------------------------------------------------------------- |
|                                 [`Format-StringForUse`](Format-StringForUse.md) | Prepares a string for use as DisplayName, UserPrincipalName, LineUri or E.164 Number, removing special characters as needed. |
| [`Format-StringRemoveSpecialCharacter`](Format-StringRemoveSpecialCharacter.md) | Formats a String and removes special characters (harmonising Display Names)                                                  |
|                       [`Get-PublicHolidayCountry`](Get-PublicHolidayCountry.md) | Lists all supported Countries for Public Holidays (from Nager.Date)                                                          |
|                             [`Get-PublicHolidayList`](Get-PublicHolidayList.md) | Lists all Public Holidays for a specific Country (from Nager.Date)                                                           |
|                     [`Get-RegionFromCountryCode`](Get-RegionFromCountryCode.md) | Just a little helper figuring out which geographical region (AMER, EMEA, APAC) a specific country is in.                     |
|                                 [`Get-TeamsObjectType`](Get-TeamsObjectType.md) | Little brother to `Get-TeamsCallableEntity` Returns the type of any given Object to identify its use in CQs and AAs.         |
|                             [`Import-TeamsAudioFile`](Import-TeamsAudioFile.md) | Import-CsOnlineAudioFile - Imports an Audio File for use within Call Queues or Auto Attendants                               |

### Voice Configuration Functions

These are helper functions for Voice Configuration.

|                                Function | Description                      |
| --------------------------------------: | -------------------------------- |
|         [`Get-TeamsCP`](Get-TeamsCP.md) | Get-CsCallingPolicy              |
|       [`Get-TeamsECP`](Get-TeamsECP.md) | Get-CsEmergencyCallingPolicy     |
|     [`Get-TeamsECRP`](Get-TeamsECRP.md) | Get-CsEmergencyCallRoutingPolicy |
|       [`Get-TeamsIPP`](Get-TeamsIPP.md) | Get-CsIPPhonePolicy              |
|       [`Get-TeamsMGW`](Get-TeamsMGW.md) | Get-CsOnlineMediaGateway         |
|       [`Get-TeamsOPU`](Get-TeamsOPU.md) | Get-CsOnlinePstnUsage            |
|       [`Get-TeamsOVP`](Get-TeamsOVP.md) | Get-CsOnlineVoiceRoutingPolicy   |
|       [`Get-TeamsOVR`](Get-TeamsOVR.md) | Get-CsOnlineVoiceRoute           |
|       [`Get-TeamsTDP`](Get-TeamsTDP.md) | Get-CsTenantDialPlan             |
| [`Get-TeamsTenant`](Get-TeamsTenant.md) | Get-CsTenant                     |
|       [`Get-TeamsVNR`](Get-TeamsVNR.md) | Get-CsTenantDialPlan             |

### Test & Assert Functions

These are helper functions for testing Connections and Modules. All Functions return boolean output. Asserting the Status of the SkypeOnline Connection however also tries to reconnect a broken session in the hope of reducing downtime.

|                                                                Function | Description                                                                                                 |
| ----------------------------------------------------------------------: | ----------------------------------------------------------------------------------------------------------- |
|                                     [`Assert-Module`](Assert-Module.md) | Verifies installation and import of a Module and optionally also verifies Version.                          |
|               [`Assert-AzureAdConnection`](Assert-AzureAdConnection.md) | Tests connection and visual feedback in the Verbose stream if called directly.                              |
| [`Assert-MicrosoftTeamsConnection`](Assert-MicrosoftTeamsConnection.md) | Tests connection and visual feedback in the Verbose stream if called directly.                              |
|       [`Assert-SkypeOnlineConnection`](Assert-SkypeOnlineConnection.md) | Tests connection and **Attempts to reconnect** a *broken* session. Alias `PoL` *Ping-of-life*               |
|                   [`Test-AzureAdConnection`](Test-AzureAdConnection.md) | Verifying a Session to AzureAD exists                                                                       |
|     [`Test-MicrosoftTeamsConnection`](Test-MicrosoftTeamsConnection.md) | Verifying a Session to MicrosoftTeams exists                                                                |
|     [`Test-ExchangeOnlineConnection`](Test-ExchangeOnlineConnection.md) | Verifying a Session to ExchangeOnline exists                                                                |
|                             [`Test-AzureAdGroup`](Test-AzureAdGroup.md) | Testing whether the Group exists in AzureAd                                                                 |
|                               [`Test-AzureAdUser`](Test-AzureAdUser.md) | Testing whether the User exists in AzureAd (NOTE: Resource Accounts are AzureAd Users too!)                 |
|             [`Test-TeamsResourceAccount`](Test-TeamsResourceAccount.md) | Testing whether a Resource Account exists in AzureAd                                                        |
|                                   [`Test-TeamsUser`](Test-TeamsUser.md) | Testing whether the User exists in SkypeOnline/Teams                                                        |
|                     [`Test-TeamsUserLicense`](Test-TeamsUserLicense.md) | Testing whether the User has a specific Teams License                                                       |
|             [`Test-TeamsUserHasCallPlan`](Test-TeamsUserHasCallPlan.md) | Testing whether the User has any Call Plan License                                                          |
|                     [`Test-TeamsExternalDNS`](Test-TeamsExternalDNS.md) | Tests DNS Records for Skype for Business Online and Teams<br />NOTE: This command is evaluated for revival. |

## EXAMPLES

### Example 1 - Formatting

```powershell
'+1(555)-1234 567' | Format-StringForUse -As E164
# This will format the String as an E.164 number and return `+15551234567`

'+1(555)-1234 567' | Format-StringForUse -As LineUri
# This will format the String as a LineUri to be used in Teams and return `tel:+15551234567`.
```

Note, LineUris _could_ also have an extension set, but this example focuses on the Number normalisation aspect.  This CmdLet can also normalise DisplayNames and UserPrincipalNames and verifies their limitations.

## NOTE

None.

## Development Status

Mature. All of these CmdLets are pretty static and only receive minor updates.

The String manipulation ones even have Pester tests defined already.

## TROUBLESHOOTING NOTE

Unit-tests are available for Format-CmdLets

All others, though thoroughly tested, have no Unit-tests yet available.

## SEE ALSO

None.

## KEYWORDS

- Test Functions
- Asserting
- Formatting
