# Teams Callable Entity

## about_TeamsCallableEntity

## SHORT DESCRIPTION

Callable Entities are Objects that CQs or AAs can direct calls to.

## LONG DESCRIPTION

Each type of Object has different requirement to meet before they can be used. Users, for example need to be Licensed with Teams and PhoneSystem, which not only has to be assigned but the respective ServicePlan must be enabled before they can be enabled for Enterprise Voice. Once enabled, they can receive a Phone Number in order to place or receive calls via the PhoneSystem.

These scripts aim to address all these requirements and validate them before allowing them to be used. They feed into Call Queue and Auto Attendant CmdLets that make heavy use of them.

## CmdLets

|                                                      Function | Description                                                                                                                             |
| ------------------------------------------------------------: | --------------------------------------------------------------------------------------------------------------------------------------- |
| [`Assert-TeamsCallableEntity`](Assert-TeamsCallableEntity.md) | Validates an Object for readiness to apply Voice Configuration (License and Ev-Enablement).                                             |
|     [`Find-TeamsCallableEntity`](Find-TeamsCallableEntity.md) | Searches all Call Queues and/or all Auto Attendants for a connected/targeted `Callable Entity` (TelURI, User, Group, Resource Account). |
|       [`Get-TeamsCallableEntity`](Get-TeamsCallableEntity.md) | Creates a new Object emulating the output of a `Callable Entity`, validating the Object type and its usability for CQs or AAs.          |
|       [`New-TeamsCallableEntity`](New-TeamsCallableEntity.md) | Used for Auto Attendants, creates a `Callable Entity` Object given a CallTarget (the type is enumerated through lookup)                 |

## EXAMPLES

Please see the Examples for the individual CmdLets in their respective help files

## NOTE

The Concept of a Callable Entity is introduced with Auto Attendants where Call Targets need to be created as a Callable Entity before they can be used for an Auto Attendant.

The other CmdLets expand on this concept:

- `Assert-TeamsCallableEntity` was broken out of the Get-TeamsCallableEntity and will assert whether the Object is in a state to be used as a Call Target
- `Get-TeamsCallableEntity` will identify and assert whether the Object is in a state to be used as a Call Target and is the backbone of the CallQueue and AutoAttendant improvements in this Module
- `Find-TeamsCallableEntity` finds whether the Object provided is used on any Call Queue or Auto Attendant

## Development Status

Complete.

## TROUBLESHOOTING NOTE

Thoroughly tested, but Unit-tests for these CmdLets are not yet available.

As they are so integral to this Module, they should not throw any Errors, if they do they will be addressed swiftly.

## SEE ALSO

- [about_TeamsCallQueue](about_TeamsCallQueue.md)
- [about_TeamsAutoAttendant](about_TeamsAutoAttendant.md)
- [about_TeamsResourceAccount](about_TeamsResourceAccount.md)

## KEYWORDS

- Creation
- Configuration
- Management
- User, AzureAdUser, CsOnlineUser
- Group, AzureAdGroup
- Resource, Resource Account, CsOnlineApplicationInstance
