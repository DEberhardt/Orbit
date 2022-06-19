# Voice Configuration

## about_VoiceConfiguration

## SHORT DESCRIPTION

All things needed to configure Users for Direct Routing or Calling Plans

## LONG DESCRIPTION

Ascertaining accurate information about the Tenant and an individual user account (or resource account) is the cornerstone of these CmdLets. `Get-TeamsUserVoiceConfig` therefore carefully selects parameters from the `CsOnlineUser`-Object and, with the `DiagnosticLevel`-switch taps further and further into parameters that may be relevant for troubleshooting issues, finally also padding the object with keys from the `AzureAdUser`-Object.

Applying the required elements to enable a User for Direct Routing or Calling Plans should make this easier, more reliable and faster for all admins.

The Tenant Voice Config tries to provide an easy input for those deploying Voice Routing Policies, Voice Routes etc. for Direct Routing more often.

## CmdLets for Tenant Voice Config

|                                                                      Function | Description                                                                                                                                       |
| ----------------------------------------------------------------------------: | ------------------------------------------------------------------------------------------------------------------------------------------------- |
|                     [`Find-TeamsEmergencyCallRoute`](Find-TeamsEmergencyCallRoute.md) | Queries a users Voice Configuration chain to finding a route an Emergency call takes for a User (more granular than `Find-TeamsUserVoiceRoute` as it also evaluates uses of Emergency Call Routing Policies)                       |
|                     [`Find-TeamsUserVoiceRoute`](Find-TeamsUserVoiceRoute.md) | Queries a users Voice Configuration chain to finding a route a call takes for a User (more granular with a `-DialedNumber`)                       |
|                 [`Get-TeamsTenantVoiceConfig`](Get-TeamsTenantVoiceConfig.md) | Queries Voice Configuration present on the Tenant. Switches are available for better at-a-glance visibility                                       |
|                     [`Get-TeamsVoiceRoutingChain`](Get-TeamsVoiceRoutingChain.md) | Queries Voice Routing Chain for Direct Routing and displays visual output. At-a-glance concise output, extensible through `-Detailed`      |
|                     [`New-TeamsVoiceRoutingChain`](New-TeamsVoiceRoutingChain.md) | Creates a full Voice Routing Chain for Direct Routing (OVP, OPU, OVR) for existing Gateways in a standard 1:1:1:1 assignment. Extensions are planned to read Matching Patterns from UCDialPlans via API and to add all Gateways to all OVRs.                  |
|               [`Remove-TeamsVoiceRoutingChain`](Remove-TeamsVoiceRoutingChain.md) | Removes a Voice Routing Chain for Direct Routing from the tenant. Artifacts can be removed forcefully (leaving orphaned objects) if desired. |

## CmdLets for User Voice Config

|                                                                      Function | Description                                                                                                                                       |
| ----------------------------------------------------------------------------: | ------------------------------------------------------------------------------------------------------------------------------------------------- |
|               [`Assert-TeamsUserVoiceConfig`](Assert-TeamsUserVoiceConfig.md) | Validates an Object for proper application of its Voice Configuration and returns Objects that are only partially or not correctly configured.    |
| [`Enable-TeamsUserForEnterpriseVoice`](Enable-TeamsUserForEnterpriseVoice.md) | Validates User License requirements and enables a User for Enterprise Voice (I needed a shortcut)                                                 |
|                   [`Find-TeamsUserVoiceConfig`](Find-TeamsUserVoiceConfig.md) | Queries Voice Configuration parameters against all Users on the tenant. Finding assignments of a number, usage of a specific OVP or TDP, etc.     |
|                 [`Get-TeamsTenantVoiceConfig`](Get-TeamsTenantVoiceConfig.md) | Queries Voice Configuration present on the Tenant. Switches are available for better at-a-glance visibility                                       |
|                     [`Get-TeamsUserVoiceConfig`](Get-TeamsUserVoiceConfig.md) | Queries Voice Configuration assigned to a User and displays visual output. At-a-glance concise output, extensible through `-DiagnosticLevel`      |
|               [`Remove-TeamsUserVoiceConfig`](Remove-TeamsUserVoiceConfig.md) | Removes a Voice Configuration set from the provided Identity. User will become "un-configured" for Voice in order to apply a new Voice Config set |
|                     [`Set-TeamsUserVoiceConfig`](Set-TeamsUserVoiceConfig.md) | Applies a full Set of Voice Configuration (Number, Online Voice Routing Policy, Tenant Dial Plan, etc.) to the provided Identity                  |
|                   [`Test-TeamsUserVoiceConfig`](Test-TeamsUserVoiceConfig.md) | Tests an individual VoiceConfig Package against the provided Identity                                                                             |

### Support CmdLets

Diving more into Voice Configuration for the Tenant and defining Direct Routing breakouts, though the provided CmdLets are solid since its Lync days, getting information fast and without the hassle of piping, filtering and selecting was the goal behind creating the below shortcuts.

|                                                                      Function | Description                                                                         |
| ----------------------------------------------------------------------------: | ----------------------------------------------------------------------------------- |
|                                       [`Get-TeamsTenant`](Get-TeamsTenant.md) | Get-CsTenant gives too much output? This can help.                                  |
|                                               [`Get-TeamsCP`](Get-TeamsCP.md) | Get-CsTeamsCallingPolicy is too long to type? Here is a shorter one.                |
|                                             [`Get-TeamsECP`](Get-TeamsECP.md) | Get-CsTeamsEmergencyCallingPolicy is too long to type? Here is a shorter one.       |
|                                           [`Get-TeamsECRP`](Get-TeamsECRP.md) | Get-CsTeamsEmergencyCallRoutingPolicy is too long to type? Here is a shorter one.   |
|                                             [`Get-TeamsIPP`](Get-TeamsIPP.md) | Get-CsTeamsIpPhonePolicy is too long to type? Here is a shorter one.                |
|                                             [`Get-TeamsOVP`](Get-TeamsOVP.md) | Get-CsOnlineVoiceRoutingPolicy is too long to type? Here is a shorter one.          |
|                                             [`Get-TeamsOPU`](Get-TeamsOPU.md) | Get-CsOnlinePstnUsage is too clunky. Here is a shorter one, with a search function! |
|                                             [`Get-TeamsOVR`](Get-TeamsOVR.md) | Get-CsOnlineVoiceRoute, just more concise                                           |
|                                             [`Get-TeamsMGW`](Get-TeamsMGW.md) | Get-CsOnlinePstnGateway, but a bit nicer                                            |
|                                             [`Get-TeamsTDP`](Get-TeamsTDP.md) | Get-TeamsTenantDialPlan is too long to type. Also, we only want the names...        |
|                                             [`Get-TeamsVNR`](Get-TeamsVNR.md) | Displays all Voice Normalization Rules (VNR) for a given Dial Plan                  |
| [`Enable-TeamsUserForEnterpriseVoice`](Enable-TeamsUserForEnterpriseVoice.md) | Nomen est omen                                                                      |
|               [`Grant-TeamsEmergencyAddresss`](Get-TeamsEmergencyAddresss.md) | Applies the `CsOnlineLisAddress` as if it were a Policy                             |

### Legacy support CmdLets

These are the last remnants of the old SkypeFunctions module. Their functionality has been barely touched.
|                                                                              Function | Description                                                                              |
| ------------------------------------------------------------------------------------: | ---------------------------------------------------------------------------------------- |
| [`Get-SkypeOnlineConferenceDialInNumbers`](Get-SkypeOnlineConferenceDialInNumbers.md) | Gathers Dial-In Conferencing Numbers for a specific Domain                               |
| [`Remove-TenantDialPlanNormalizationRule`](Remove-TenantDialPlanNormalizationRule.md) | Displays all Normalisation Rules of a provided Tenant Dial Plan and asks which to remove |

>[!NOTE] These commands are being evaluated for revival and re-integration.

## EXAMPLES

### Example 1 - Teams User Voice Route

````powershell
Find-TeamsUserVoiceRoute -Identity John@domain.com -DialedNumber +15551234567
````

Evaluating the Voice Routing for one user based on the Number being dialed

```powershell
# Example 1 - Output
TBC
```

### Example 2 - Finding Objects with Find-TeamsUserVoiceConfig

````powershell
# The following are some examples for the Voice Config CmdLets
Find-TeamsUserVoiceConfig [-PhoneNumber] "555-1234 567"
# Finds Objects with the normalised number '*5551234567*' (removing special characters)

Find-TeamsUserVoiceConfig -Extension "12-345"
# Finds Objects which have any Extension starting with 12345 assigned (removing special characters)
# NOTE: The CmdLet is searching explicitely for '*;ext=12345*'

Find-TeamsUserVoiceConfig -ConfigurationType CallingPlans
Find-TeamsUserVoiceConfig -VoicePolicy BusinessVoice
# Finds all Objects configured for CallingPlans with two different metrics.

Find-TeamsUserVoiceConfig -Identity John@domain.com
Get-TeamsUserVoiceConfig [-Identity] John@domain.com
# FIND will return either a list of UserPrincipalNames found, or
# if limited results are found, executes GET to display the output.
````

Find can look for User Objects (Users, Common Area Phones or Resource Accounts) returning output based on number of objects returned.
Get-TeamsUserVoiceConfig and Find-TeamsUserVoiceConfig return the same base output, however the Get-Command does have the option to expand on the output object and drill deeper.

- Get-TeamsUserVoiceConfig targets an Identity (UserPrincipalName)
- Find-TeamsUserVoiceConfig can search for PhoneNumbers, Extensions, ID or commonalities like OVP or TDPs
- Pipeline is available for both CmdLets

### Example 3 - Voice Configuration Object with Get-TeamsUserVoiceConfig

````powershell
# Example 2 - Output shows a Direct Routing user correctly provisioned but not yet moved to Teams
UserPrincipalName          : John@domain.com
SipAddress                 : sip:John@domain.com
DisplayName                : John Doe
ObjectId                   : d13e9d53-5dd4-7392-b123-de45b16a7cb4
Identity                   : CN=d13e9d53-5dd4-7392-b123-de45b16a7cb4,OU=d23afe19-5a33-893a
                             -caf1-70b6cd9a8f6e,OU=OCS Tenants,DC=lync0e001,DC=local
HostingProvider            : SRV:
ObjectType                 : User
InterpretedUserType        : HybridOnpremTeamsOnlyUser
VoiceConfigurationType     : DirectRouting
TeamsUpgradeEffectiveMode  : TeamsOnly
UsageLocation              : US
LicensesAssigned           : Office 365 E5
CurrentCallingPlan         :
PhoneSystemStatus          : Success
PhoneSystem                : True
EnterpriseVoiceEnabled     : True
HostedVoiceMail            : True
TeamsUpgradePolicy         :
OnlineVoiceRoutingPolicy   : OVP-EMEA
TenantDialPlan             : DP-US
CallingLineIdentity        :
LineURI                    : tel:+15551234567;ext=4567
````

## NOTE

Voice Config CmdLets started out just limiting the output of Get-CsOnlineUser to retain an overview and avoid unnecessary scrolling and find information faster and in a more consistent way.

Now they are enriching administration in Teams and are a backbone to the Admin Experience.

## Development Status

CmdLets are completely fleshed out and tested. Minor tweaks may still need to be done to round things.

## TROUBLESHOOTING NOTE

Thoroughly tested, but Unit-tests for these CmdLets are not yet available.

None needed. Edge-cases might still lurk that prevent Set-TeamsUserVoiceConfig to succeed. Please raise issues for them, happy to add more checks to validate specific scenarios.

## SEE ALSO

- [about_TeamsLicensing](about_TeamsLicensing.md)
- [about_UserManagement](about_UserManagement.md)
- [about_TeamsCallableEntity](about_TeamsCallableEntity.md)
- [about_Supporting_Functions](about_Supporting_Functions.md)

## KEYWORDS

- Direct Routing
- Calling Plans
- Licensing
- PhoneSystem
- EnterpriseVoice
- Provisioning
