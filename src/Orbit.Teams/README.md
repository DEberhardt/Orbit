# Orbit.AzureAd

Main Module for all commandlets that require Microsoft.Graph

## Plan

Create anew from AzureAd CmdLets (Users, Groups, PIM, etc.)

## Public Functions

The Session CmdLets come from TeamsFunctions but they aren't yet fit for purpose

- [ ] `AutoAttendant` CmdLets:
  - [ ] Move here
  - [ ] Rework use for both Graph and AzureAd (preferrably though with Graph)
- [ ] `CallQueue` CmdLets:
  - [ ] Move here
  - [ ] Rework use for both Graph and AzureAd (preferrably though with Graph)
- [ ] `ResourceAccount` CmdLets:
  - [ ] Move here
  - [ ] Rework use for both Graph and AzureAd (preferrably though with Graph)
- [ ] `VoiceConfig` CmdLets:
  - [ ] Move here
  - [ ] Rework use for both Graph and AzureAd (preferrably though with Graph)
- [ ] `VoiceRoute` CmdLets:
  - [ ] Move here and break into their own section
  - [ ] Expand on use-cases to test Voice Routing related options
  - [ ] Rework use for both Graph and AzureAd (preferrably though with Graph)
  - [ ] `Find-TeamsUserVoiceRoute`
  - [ ] `Find-TeamsEmergencyCallRoute`
- [ ] `TeamsCallableEntity` CmdLets:
  - [ ] Move here
  - [ ] Rework use for both Graph and AzureAd (preferrably though with Graph)
- [ ] `TeamsCommonAreaPhone` CmdLets:
  - [ ] Move here
  NOTE: This will call Cmdlets in AzureAd - will require connection to Graph
  - [ ] Rework use for both Graph and AzureAd (preferrably though with Graph)
- [ ] Support CmdLets:
  - [ ] Move here
  - [ ] Rework use for both Graph and AzureAd (preferrably though with Graph)
  - [ ] Backup CmdLets

- [ ] TBC - Controller Functions adhereing to PowerShell best practices.

## Private Functions

- [ ] `GetAppIdFromApplicationType`
- [ ] `GetApplicationTypeFromAppId`
- [ ] `Get-TeamAndChannel`
- [ ] `Get-InterpretedVoiceConfigType`
- [ ] `Assert-TeamsAudioFile`
- [ ] `Merge-TeamsAutoAttendantArtefact`
- [ ] `Use-MicrosoftTeamsConnection`
