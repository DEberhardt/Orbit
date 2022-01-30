# Orbit.AzureAd

Main Module for all commandlets that require Microsoft.Graph

## Plan

Create anew from AzureAd CmdLets (Users, Groups, PIM, etc.)

## Public Functions

The Session CmdLets come from TeamsFunctions but they aren't yet fit for purpose

- [ ] `AzureAdAdminRole` CmdLets:
  - [ ] Copy here
  - [ ] Rework use for Graph
  - [ ] Add logic to chose between Connect-AzureAd and Connect-MgGraph?
- [ ] `AzureAdObjects` CmdLets:
  - [ ] Copy here
  - [ ] Rework use for Graph
- [ ] Usability-CmdLets
  - [ ] `Set-StrictMode` - Function from TeamsFunctions.psm1
  - [ ] `Show-FunctionStatus`
  - [ ] `Set-PowerShellWindowTitle`
- [ ] Error-Handling-Cmdlets
  - [ ] `Get-ErrorMessageFromErrorString`: Re-evaluate for REST-API Error-output
- [ ] License-Related Tools
  - [ ] `Test-AzureAdLicenseContainsServicePlan`
  - [ ] `New-AzureAdLicenseObject`
- [ ] Progress-CmdLets
  - [ ] `Write-BetterProgress`
  - [ ] `Get-BetterProgressSteps`
- [ ] Helper-CmdLets
  - [ ] `Format-StringForUse`
  - [ ] `Format-StringRemoveSpecialCharacter`
  - [ ] `Get-ISO3166Country`
  - [ ] `Get-RegionFromCountryCode`
- [ ] Module-CmdLets
  - [ ] `Get-NewestModule`
  - [ ] `Assert-Module`
  - [ ]
- [ ] `Fast` Cmdlets provided we can make use of them (permission required from author)
- [ ] TBC - Controller Functions adhereing to PowerShell best practices.

## Private Functions

probably none.
