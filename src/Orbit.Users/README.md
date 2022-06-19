# Orbit.Users

Main Module for all commandlets that require AzureAd

## Plan

Move all AzureAd CmdLets here

## Public Functions

The Session CmdLets come from TeamsFunctions but they aren't yet fit for purpose

- [ ] `Connect-Me`:
  - [ ] Move here
  - [ ] Expand use for Connection to Graph
  - [ ] Add logic to chose between Connect-AzureAd and Connect-MgGraph?
- [ ] `Disconnect-Me`:
  - [ ] Move here
  - [ ] Expand use to disconnect from all Sessions (dependent on what was connected to?)
- [ ] Licensing-CmdLets:
  - [ ] Move here
- [ ] Add Session Token (Global Variable) to save preference of connection?

## Private Functions

- [ ] `Remove-TeamsFunctionsGlobalVariable`: Transform and hook into Disconnect-Me
- [ ] `Set-PowerShellWindowTitle`: Either hook in here or into Tools
