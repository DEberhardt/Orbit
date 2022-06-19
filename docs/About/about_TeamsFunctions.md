# TeamsFunctions - An Overview

## about_TeamsFunctions

## SHORT DESCRIPTION

Teams Voice CmdLets adding and improving on AzureAd and MicrosoftTeams CmdLets

## LONG DESCRIPTION

All CmdLets are designed to help with Administration of Users, Common Area Phones, Resource Accounts, Call Queues and Auto Attendants, incl. Licensing, User Voice Configuration with Calling Plans and Direct Routing.

## TOPICS COVERED

This module currently contains over 100 Functions covering a broad area of Teams Functions for Admins: From Session Connection and activating Admin Roles in PIM to User Administration, Licensing and Voice Configuration all the way to Resource Accounts, Call Queues, Auto Attendants

Each topic will get its own ABOUT file soon, diving deeper into the Scripts.

- SkypeOnline Session connection, reconnection and verification
- AzureAd Licensing: Tenant queries, User assignments and verification
- AzureAd Privileged Identity Management: Role Activation
- Object Preparation for EnterpriseVoice Configuration
- Teams Voice Configuration: Direct Routing and Calling Plans
- Teams Common Area Phone: New CmdLets (currently in testing!)
- Teams Analog Contact Object: New CmdLets (coming soon)
- Teams Resource Account: Improvements on existing CmdLets
- Teams Call Queue: Improvements on existing CmdLets
- Teams Auto Attendant: Improvements on existing CmdLets
- Support and Helper functions for Admin tasks

## SCHEDULE

We have reached a level of maturity and stability that now lets me change the schedule from a Monthly/Weekly cadence to a more static one:
I may still issue a mid-month pre-release in order to provide bugfixes and test functionality, but these should be rarer going forward.

- Stable Cycle: `Update-Module TeamsFunctions`
- Testing Cycle: `Update-Module TeamsFunctions -AllowPrerelease`

> [!NOTE] The Stable Cycle is released roughly beginning of the month and will have only one minor version, for Example: "v21.5" for May 2021
> The Testing/Prerelease Cycle will have a third tier indicating the day it was published, for Example "v21.5.18-prerelease" for 18 May 2021

## NOTE

Due to the ever evolving nature of Teams, new features coming in, etc. this seems to be a constant work-in progress.
Please bear with me as I try to keep in lock-step (or very close behind) Microsofts releases.
Any issues found, please raise them against the repository. I am trying to address them pretty rapidly, but I am doing this alone and outside my day-job in my spare time. Cheers.

## REQUIREMENTS

- PowerShell v5.1 is required,
- PowerShell v7.1 throws an error [when connecting to AzureAd](https://github.com/PowerShell/PowerShell/issues/10473)<br />Currently no connection is possible!
- Module `MicrosoftTeams`
- Module `AzureAd` or `AzureAdPreview`
Some functions are only available with the Preview module until they become generally available and move to the AzureAd Module

> [!NOTE] The Module `SkypeOnlineConnector` is deprecated and has been removed as a dependency from this Module with v21.2 - Connection is now solely established with the MicrosoftTeams Module. Please uninstall SkypeOnlineConnector and switch to MicrosoftTeams (v2.0 or higher). Connecting (and reconnecting) sessions has been vastly improved!

## TROUBLESHOOTING NOTE

All Help Files are available in [docs](/docs)
All Topics have been documented as *about_* Files
Each exported function has automatically generated help files with PlatyPS.

If you find bugs, please report them by raising an Issue on this repo or send me a message to [TeamsFunctions@outlook.com](mailto:TeamsFunctions@outlook.com)

Please attach `Verbose` and/or `Debug` output of the Script in question and anonymise the output to remove personally identifiable data.

## SEE ALSO

- [about_TeamsFunctionsAliases](about_TeamsFunctionsAliases.md)
- [about_TeamsSession](about_TeamsSession.md)
- [about_TeamsAutoAttendant](about_TeamsAutoAttendant.md)
- [about_TeamsCallQueue](about_TeamsCallQueue.md)
- [about_TeamsResourceAccount](about_TeamsResourceAccount.md)
- [about_Licensing](about_Licensing.md)
- [about_UserManagement](about_UserManagement.md)
- [about_TeamsCallableEntity](about_TeamsCallableEntity.md)
- [about_TeamsCommonAreaPhone](about_TeamsCommonAreaPhone.md)
- [about_TeamsAnalogDevice](about_TeamsAnalogDevice.md)
- [about_VoiceConfiguration](about_VoiceConfiguration.md)
- [about_Supporting_Functions](about_Supporting_Functions.md)

## KEYWORDS

- Functions
- CmdLets
- ReadMe
- About
