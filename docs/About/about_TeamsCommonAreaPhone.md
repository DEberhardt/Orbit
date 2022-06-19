# Teams Common Area Phones

## about_TeamsCommonAreaPhone

## SHORT DESCRIPTION

There are currently no native commands for this, so I tried creating them.

## LONG DESCRIPTION

Common Area Phone being User Accounts could be managed with the normal Voice Configuration CmdLets, though not very well. The object returned by GET is tailored more towards the needs of a Common area Phone

## CmdLets

| Function                                                           | Underlying Function | Description                                                                                             |
| ------------------------------------------------------------------: | ------------------- | ------------------------------------------------------------------------------------------------------- |
| [`New-TeamsCommonAreaPhone`](New-TeamsCommonAreaPhone.md)       | New-AzureAdUser     | Creates a Common Area Phone and applies settings to it as provided.                                     |
| [`Get-TeamsCommonAreaPhone`](Get-TeamsCommonAreaPhone.md)       | Get-CsOnlineUser    | Queries a Common Area Phone with friendly inputs (UPN) and output                                       |
| [`Set-TeamsCommonAreaPhone`](Set-TeamsCommonAreaPhone.md)       | Set-CsUser          | Changes a Common Area Phone                                                                             |
| [`Remove-TeamsCommonAreaPhone`](Remove-TeamsCommonAreaPhone.md) | Remove-AzureAdUser  | Removes configuration (with `Remove-TeamsUserVoiceConfig`), then removes the User (requires User Admin) |

## EXAMPLES

Please see the Examples for the individual CmdLets in their respective help files

## NOTE

The most recent addition to the fold, they need some serious testing before they are ready for prime time.

## Development Status

CmdLets are not tested yet.

## TROUBLESHOOTING NOTE

Unit-tests for these CmdLets are not yet available.

CmdLets are fully built (RC), but not much testing time has yet been spent on them. Please be patient with me on these and submit issues as you find them.

## SEE ALSO

- [about_TeamsCallableEntity](about_TeamsCallableEntity.md)
- [about_TeamsAnalogDevice](about_TeamsAnalogDevice.md)
- [about_Licensing](about_Licensing.md)

## KEYWORDS

- IP Phone
