# Orbit

[![Build status](https://ci.appveyor.com/api/projects/status/7yb9er834qod0xvw?svg=true)](https://ci.appveyor.com/project/Name/templatepowershellmodule)

This is a work-in-progress built on the shoulders of [TeamsFunctions](https://github.com/DEberhardt/TeamsFunctions)

## The solution must reduce the administrative overhead

The Microsoft 365 ecosystem is ever expanding. Orbiting it, are tools built on top of these cloud services. Focused on Azure Active Directory and Microsoft Teams, but extensible by design.

Contributors & contributions are welcome

## Synopsis

Orbit is a PowerShell Module that aims to simplify administrative overhead when working with Microsoft 365 tools, especially licensing and provisioning for Microsoft Teams Voice

## Description

When working with AzureAd, Graph or MicrosoftTeams individually, limitations arise that require use of information contained in other spheres of 365. This module aims to connect these spheres and allow a more holistic approach for Teams Administrators that need to license users or gain information from the Azure Active Directory.

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
Import-Module Orbit.AzureAd
Import-Module Orbit.Graph
Import-Module Orbit.Teams
Import-Module Orbit.Tools
```

## Notes

```yaml
   Name: Orbit
   Created by: David Eberhardt
   Created Date: 30-JAN 2022
```
