# Orbit

This is a work-in-progress built on the shoulders of and replacing [TeamsFunctions](https://github.com/DEberhardt/TeamsFunctions)

## The solution must reduce the administrative overhead

The Microsoft 365 ecosystem is ever expanding. Orbiting it, are tools built on top of these cloud services. Focused on Azure Active Directory and Microsoft Teams, but extensible by design.

Contributors & contributions are welcome

## Status

|           |                                                                                                                                                                                                                                                                                                                                                                    |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| General     |  [![License](https://img.shields.io/github/license/DEberhardt/Orbit)](https://github.com/DEberhardt/Orbit/blob/master/LICENSE) [![Platform](https://img.shields.io/powershellgallery/p/Orbit)](.\readme.md) [![Documentation - GitHub](https://img.shields.io/badge/Documentation-Orbit-blue.svg)](https://github.com/DEberhardt/Orbit/tree/master/docs) [![PowerShell Gallery - Orbit](https://img.shields.io/badge/PowerShell%20Gallery-Orbit-blue.svg)](https://www.powershellgallery.com/packages/Orbit/) |
| Release     | [![Release](https://img.shields.io/github/v/release/DEberhardt/Orbit?include_prereleases&sort=semver)](.\readme.md) [![Downloads](https://img.shields.io/powershellgallery/dt/Orbit)](.\readme.md)  |
| Build     |  [![Build](https://img.shields.io/badge/Build-unknown-orange.svg)](.\readme.md) [![BuildWorkflow](https://img.shields.io/github/workflow/status/DEberhardt/Orbit/Publish)](.\readme.md) [![Issues](https://img.shields.io/github/issues/DEberhardt/Orbit)](https://github.com/DEberhardt/Orbit/issues) |
| Functions | ![Public](https://img.shields.io/badge/Public-xx-blue.svg) ![Private](https://img.shields.io/badge/Private-0-grey.svg) ![Live](https://img.shields.io/badge/Live-xx-blue.svg) ![RC](https://img.shields.io/badge/RC-xx-green.svg) ![BETA](https://img.shields.io/badge/BETA-xx-yellow.svg) ![ALPHA](https://img.shields.io/badge/ALPHA-xx-orange.svg)                                                                                                                                                                           |
| Pester    | ![Result](https://img.shields.io/badge/Result-unknown-lightgrey.svg) ![Passed](https://img.shields.io/badge/Passed-xx-green.svg) ![Failed](https://img.shields.io/badge/Failed-xx-red.svg) ![Skipped](https://img.shields.io/badge/Skipped-xx-yellow.svg) ![NotRun](https://img.shields.io/badge/NotRun-xx-grey.svg) ![CodeCoverage](https://img.shields.io/badge/CodeCoverage-0%25-red.svg)                                                                                                                              |

## Synopsis

Orbit is a PowerShell Module that aims to simplify administrative overhead when working with Microsoft 365 tools.

## Description

When working with AzureAd, Graph or MicrosoftTeams individually, limitations arise that require use of information contained in other spheres of 365. This module aims to connect these spheres and allow a more holistic approach for Teams Administrators that need to license users or gain information from the wider M365 space, be that Azure Active Directory, Exchange, etc.

## Using Orbit

To use this module, install it from PowerShell Gallery

```powershell
# Orbit is built like Microsoft.Graph or Az and will pull all dependent modules
Install-Module Orbit
```

### How to use

This module covers Session connection for multiple services

```powershell
Connect-Me 'your-Admin-Username@yourTenantDomain.com'
# This will connect you to Graph & Teams, but can also connect to AzureAd and/or Exchange with switches.
```

### Coverage

This Module will install child modules analog to Microsoft.Graph. They are published conjointly through this repositories CI/CD pipeline, but can stand by themselves if need be.

```powershell
# Currently available modules (extensible)
Import-Module Orbit
# This will automatically load Orbit.Users, Orbit.Groups, Orbit.Teams & Orbit.Tools
```

## Notes

```yaml
   Name: Orbit
   Created by: David Eberhardt
   Created Date: 30-JAN 2022
   Planned Release: 01-JUL-2022
```
