# Teams Auto Attendant

## about_TeamsAutoAttendant

## SHORT DESCRIPTION

My take on AutoAttendants with more integrated options and defaults.

## LONG DESCRIPTION

The complexity of the AutoAttendants and design principles of PowerShell ("one function does one thing and one thing only") means that the `CsAutoAttendant` CmdLets are feeling to be all over the place. Multiple CmdLets have to be used in conjunction in order to create ONE Auto Attendant. No defaults are available. The `TeamsAutoAttendant` CmdLets try to address that. From the basic NEW-Command that - without providing *any* Parameters (except the name of course) can create an Auto Attendant entity. This simplifies things a bit and tries to get you 90% there without lifting much of a finger. Amending it afterwards in the Admin Center is my current mantra. See Support Functions for more versatility!

## CmdLets

|                                                    Function | Underlying Function    | Description                                                                                  |
| ----------------------------------------------------------: | ---------------------- | -------------------------------------------------------------------------------------------- |
|       [`Get-TeamsAutoAttendant`](Get-TeamsAutoAttendant.md) | Get-CsAutoAttendant    | Queries an Auto Attendant                                                                    |
|                                      Set-TeamsAutoAttendant | Set-CsAutoAttendant    | Changes an Auto Attendant with friendly input. Alias to Set-CsAutoAttendant only!            |
|       [`New-TeamsAutoAttendant`](New-TeamsAutoAttendant.md) | New-CsAutoAttendant    | Creates an Auto Attendant with defaults (Disconnect, Standard Business Hours schedule, etc.) |
| [`Remove-TeamsAutoAttendant`](Remove-TeamsAutoAttendant.md) | Remove-CsAutoAttendant | Removes an Auto Attendant from the Tenant                                                    |

> [!NOTE] Currently `Set-TeamsAutoAttendant` and `Set-TeamsAA` are currently only Aliases to `Set-CsOnlineAutoAttendant`. If I find a better use case to write these, I will, but for now they have to stay as they are. I only added the aliases to complete the set and provide a consistent look-and-feel in case people are natively using them.

## Support CmdLets

Creating a Menu or a Call Flow feels clunky to me, the commands require excessive chaining in order to create a full Auto Attendant. The complexity of the AutoAttendants also has spawned a few support functions. Keeping in step with them and simplifying their use a bit is what my take on them represents.

|                                                                  Function | Underlying Function                        | Description                                                                                                       |
| ------------------------------------------------------------------------: | ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
|                 [`Get-PublicHolidayCountry`](Get-PublicHolidayCountry.md) |                                            | Lists all supported Countries for Public Holidays (from Nager.Date)                                               |
|                       [`Get-PublicHolidayList`](Get-PublicHolidayList.md) |                                            | Lists all Public Holidays for a specific Country (from Nager.Date)                                                |
|     [`Get-TeamsAutoAttendantAudioFile`](Get-TeamsAutoAttendantAudioFile.md) |                 | Queries all AudioFiles in an Auto Attendant Object         |
|     [`Get-TeamsAutoAttendantSchedule`](Get-TeamsAutoAttendantSchedule.md) |                 | Queries a `Schedule` Object in an Auto Attendant Object     |
|                       [`Import-TeamsAudioFile`](Import-TeamsAudioFile.md) | Import-CsOnlineAudioFile                   | Imports an Audio File for use within Call Queues or Auto Attendants                                               |
|     [`New-TeamsAutoAttendantCallFlow`](New-TeamsAutoAttendantCallFlow.md) | New-CsAutoAttendantCallFlow                | Creates a `CallFlow` Object with a Prompt and Menu and some default options.                                      |
|                             New-TeamsAutoAttendantCallHandlingAssociation | New-CsAutoAttendantCallHandlingAssociation | This is only an alias, as a CallHandlingAssociation is only combining a `Schedule` object and a `CallFlow` object |
|   [`New-TeamsAutoAttendantDialScope`](New-TeamsAutoAttendantDialScope.md) | New-CsAutoAttendantDialScope               | Creates a `DialScope` Object for provided Office 365 Group Names                                                  |
| [`New-TeamsAutoAttendantMenuOption`](New-TeamsAutoAttendantMenuOption.md) | New-CsAutoAttendantMenuOption              | Creates a `MenuOption` Object for easier use                                                                      |
|             [`New-TeamsAutoAttendantMenu`](New-TeamsAutoAttendantMenu.md) | New-CsAutoAttendantMenu                    | Creates a `Menu` Object for Menu Options in two possible inputs                                                   |
|         [`New-TeamsAutoAttendantPrompt`](New-TeamsAutoAttendantPrompt.md) | New-CsAutoAttendantPrompt                  | Creates a `Prompt` Object and simplifies usage as it determines the type based on the input string.               |
|     [`New-TeamsAutoAttendantSchedule`](New-TeamsAutoAttendantSchedule.md) | New-CsAutoAttendantSchedule                | Creates a `Schedule` Object and simplifies input for use in AA CHA. Multiple default options are available        |
|                   [`New-TeamsCallableEntity`](New-TeamsCallableEntity.md) | New-CsAutoAttendantCallableEntity          | Creates a `CallableEntity` Object given a CallTarget (type is enumerated)                                         |

## EXAMPLES

Please see the Examples for the individual CmdLets in their respective help files

## NOTE

Removing complexity without sacrificing functionality is a hard thing and while writing these CmdLets I learned to appreciate and understand why they are how they are.

That said, I think I have achieved my goal to provide some options to create AutoAttendants easier and faster with PowerShell. For any functionality not available yet, I usually supplement by selecting in the Admin Center (This also serves to double-check everything is set as desired)

## Development Status

The main functionality is built, tested and live.  The only big topic as yet to be integrated is HolidaySets

Planned:

- Creating a HolidaySet (Schedule) for Holidays of a specific country for a specific year
- Adding, removing and replacing(!) HolidaySets from Auto Attendants.
- Adding default options to New-TeamsAutoAttendant with a switch <br />NOTE: This functionality is already available as a CallFlow and CallHandlingAssociations-Object btw.

## TROUBLESHOOTING NOTE

Thoroughly tested, but Unit-tests for these CmdLets are not yet available.

## SEE ALSO

[about_TeamsCallQueue](about_TeamsCallQueue.md)

[about_TeamsResourceAccount](about_TeamsResourceAccount.md)

[about_TeamsCallableEntity](about_TeamsCallableEntity.md)

## KEYWORDS

- Creation
- Configuration
- Management
- AzureAdUser
- AzureAdGroup
- CsOnlineUser
- CsOnlineApplicationInstance
- TeamsResourceAccount
