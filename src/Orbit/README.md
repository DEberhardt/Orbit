# Orbit

Main Module

## Plan

Session CmdLets `Connect-Me` & `Disconnect-Me` are to move here

## Migration

The Session CmdLets come from TeamsFunctions but they aren't yet fit for purpose

- [ ] `about_Orbit`: New
- [ ] `about_TeamsSession`: Migrate
- [ ] `Connect-Me`:
  - [ ] Move here
  - [ ] Expand use for Connection to Graph
  - [ ] Add logic to chose between Connect-AzureAd and Connect-MgGraph?
- [ ] `Disconnect-Me`:
  - [ ] Move here
  - [ ] Expand use to disconnect from all Sessions (dependent on what was connected to?)
- [ ] Add Session Token (Global Variable) to save preference of connection?

## Tools & Questions

'using Module Orbit.Tools' for using Classes and private(?) Functions of a module?
