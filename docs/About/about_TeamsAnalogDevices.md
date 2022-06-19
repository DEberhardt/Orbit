# Teams Common Area Phones

## about_TeamsCommonAreaPhone

## SHORT DESCRIPTION

There are currently no native commands for this, so I am trying to create them.

## LONG DESCRIPTION

Analog Devices in Teams behave differently than they do in Skype for Business. There is no Object created in Teams that represents this Analog Device. Instead, this is done via a Contact Object, to put a Name to a Number.

> [!NOTE] These CmdLets are not yet built! I have sketched out what is needed to build these CmdLets, but haven't had the time to build them yet. The links below will not work.

## CmdLets

| Function                                                           | Underlying Function | Description                                                                                             |
| ------------------------------------------------------------------: | ------------------- | ------------------------------------------------------------------------------------------------------- |
| [`New-TeamsAnalogDevice`](New-TeamsAnalogDevice.md)       | New-AzureAdContact     | Creates Contact Objects for an Analog Device.                                     |
| [`Get-TeamsAnalogDevice`](Get-TeamsAnalogDevice.md)       | Get-CsOnlineUser    | Queries Contact Objects for an Analog Device in the Tenant                                       |
| [`Set-TeamsAnalogDevice`](Set-TeamsAnalogDevice.md)       | Set-CsUser          | Changes Contact Objects for an Analog Device in the Tenant                                                                             |
| [`Remove-TeamsAnalogDevice`](Remove-TeamsAnalogDevice.md) | Remove-AzureAdUser  | Removes Contact Objects for an Analog Device in the Tenant |

## EXAMPLES

Please see the Examples for the individual CmdLets in their respective help files

## NOTE

Not built yet.

## Development Status

CmdLets are not built yet.

## TROUBLESHOOTING NOTE

TBC

## SEE ALSO

- [VoiceConfiguration](about_VoiceConfiguration.md)
- [TeamsCommonAreaPhone](about_TeamsCommonAreaPhone.md)

## KEYWORDS

- VoiceConfig
- Common Area Phone
- Contact Object
