# Teams Resource Account

## about_TeamsResourceAccount

## SHORT DESCRIPTION

`CsOnlineApplicationInstance` is a mouthful, `TeamsResourceAccount` is easier

## LONG DESCRIPTION

Though you can now also provide a UserPrincipalName for `CsOnlineApplicationInstance` scripts, they are, I think, not telling you enough. IDs are used for the Application Type. These Scripts are wrapping around them, bind to the *UserPrincipalName* and offer more required information for properly managing Resource Accounts for Call Queues and Auto Attendants.

## CmdLets

| Function                                                              | Underlying Function                 | Description                                                                                                 |
| ---------------------------------------------------------------------: | ----------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| [`Find-TeamsResourceAccount`](Find-TeamsResourceAccount.md)     | Find-CsOnlineApplicationInstance    | Finds Resource Accounts based on provided SearchString                                                      |
| [`Get-TeamsResourceAccount`](Get-TeamsResourceAccount.md)       | Get-CsOnlineApplicationInstance     | Queries Resource Accounts based on input: SearchString, Identity (UserPrincipalName), PhoneNumber, Type     |
| [`New-TeamsResourceAccount`](New-TeamsResourceAccount.md)       | Creates a Resource Account in Teams |                                                                                                             |
| [`Set-TeamsResourceAccount`](Set-TeamsResourceAccount.md)       | Set-CsOnlineApplicationInstance     | Changes settings for a Resource Accounts, applying UsageLocation, Licenses and Phone Numbers, swapping Type |
| [`Remove-TeamsResourceAccount`](Remove-TeamsResourceAccount.md) | Remove-AzureAdUser                  | Removes a Resource Account and optionally (with -Force) also the Associations this account has.             |

## CmdLets for Association

Connecting these Resource Accounts to their Call Queues or Auto Attendants, while ironing out a few quirks, like being able to change the type of ResourceAccount (from CQ to AA or vice versa) before assigning or using friendly words rather than GUIDs for the Type or cleanly disconnecting accounts that have gone stuck is what additional value they bring on top of their main functionality.

| Function                                                                                    | Underlying Function                           | Description                                                                                          |
| -------------------------------------------------------------------------------------------: | --------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| [`Get-TeamsResourceAccountAssociation`](Get-TeamsResourceAccountAssociation.md)       | Get-CsOnlineApplicationInstanceAssociation    | Queries links for one or more Resource Accounts to Call Queues or Auto Attendants. Also shows Status |
| [`New-TeamsResourceAccountAssociation`](New-TeamsResourceAccountAssociation.md)       | New-CsOnlineApplicationInstanceAssociation    | Links one or more Resource Accounts to a Call Queue or an Auto Attendant                             |
| [`Remove-TeamsResourceAccountAssociation`](Remove-TeamsResourceAccountAssociation.md) | Remove-CsOnlineApplicationInstanceAssociation | Removes a link for one or more Resource Accounts                                                     |

> [!NOTE] Aliases for `TeamsResourceAccountAssociation` CmdLets are defined as `TeamsRAA`<br />
> Aliases for `TeamsResourceAccount` CmdLets are only one Character off: `TeamsRA` --
> Handle with care :)

### Support CmdLets

| Function                                                          | Underlying Function | Description                                          |
| -----------------------------------------------------------------: | ------------------- | ---------------------------------------------------- |
| [`Get-TeamsResourceAccountLineIdentity`](Get-TeamsResourceAccountLineIdentity.md) | Get-CsCallingLineIdentity | Queries Line Identity Objects created for a Resource Account |
| [`New-TeamsResourceAccountLineIdentity`](New-TeamsResourceAccountLineIdentity.md) | New-CsCallingLineIdentity | Creates a Line Identity Object for a Resource Account |
| [`Test-TeamsResourceAccount`](Test-TeamsResourceAccount.md) |                     | Testing whether a Resource Account exists in AzureAd |

## EXAMPLES

Please see the Examples for the individual CmdLets in their respective help files

## NOTE

N/A

## Development Status

Development is complete. Fine-tuning might see some changes in the future, but nothing planned right now.

## TROUBLESHOOTING NOTE

Thoroughly tested, but Unit-tests for these CmdLets are not yet available.

## SEE ALSO

- [about_TeamsCallQueue](about_TeamsCallQueue.md)
- [about_TeamsAutoAttendant](about_TeamsAutoAttendant.md)
- [about_TeamsCallableEntity](about_TeamsCallableEntity.md)

## KEYWORDS

- Creation
- Configuration
- Management
- User, AzureAdUser, CsOnlineUser
- Group, AzureAdGroup
- Resource, Resource Account, CsOnlineApplicationInstance
