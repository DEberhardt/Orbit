# ToDo List

## Documentation

- [x] TeamsFunctions-help.xml (now in DOCS!)
- [x] Update Markdown files with Platypus does not automatically update .MD files...

- [x] Create Docs (MarkdownHelp)
- [x] Create Help (about_)
- [ ] Improve Comment Based help
  - [x] Apply correct Order: EXAMPLES, INPUTS, OUTPUT, NOTES, COMPONENT, FUNCTIONALITY, LINK
  - [x] .ROLE - Remove
  - [ ] .INPUTS (incl. Pipeline)
  - [x] .OUTPUTS (all variants and how to get to them)
  - [x] .COMPONENT - Adding About_ Topic Name as Component
  - [x] .FUNCTIONALITY - Describe what the function does
  - [x] .LINK - Add ABOUT_ Topic
  - [x] .LINK - Verify linked function is correct across all of the same breed
  - [x] .LINK to specific file, rather than to /docs?
- [ ] Populate about-help
  - [x] Write Licensing
  - [x] Write SupportFunctions
  - [x] Write AutoAttendant
  - [x] Write CallableEntities
  - [x] Write CallQueue
  - [x] Write CommonAreaPhone
  - [ ] Write AnalogDevices
  - [x] Write ResourceAccount
  - [x] Write Session
  - [x] Write UserManagement
  - [x] Write VoiceConfiguration
- [ ] Update About-help
  - [x] Verify all Functions are listed
  - [x] Remove retired functions
- [ ] Add Examples to About
  - [x] Examples for Licensing
  - [x] Examples for SupportFunctions
  - [x] Examples for CallableEntities
  - [x] Examples for CallQueue
  - [x] Examples for Session
  - [x] Examples for UserManagement
  - [x] Examples for VoiceConfiguration
  - [ ] Example for Voice Route(!)

## Module MicrosoftTeams

- [x] New-CsOnlineSession does not have -Username anymore. Test MFA with Credential instead (also interoperability with Connect-Me/AzureAD and MicrosoftTeams)
- [x] Rework Connect-SkypeOnline to use MicrosoftTeams
- [x] Evaluate missing SSO (Authentication once, selection of Account still there)
- [x] Remove SkypeOnlineConnector

## TeamsAutoAttendant

- [ ] Add features
  - [x] Operator
  - [x] Call target
  - [x] Default Schedules
  - [x] Default HolidaySets for a Country (this year/next year)
- [ ] Evaluate integration Scripts
  - [ ] Default forward to CQ (wrapper for New-AA, with Menu to Forward to CallTarget Queue)
  - [ ] Construct of 1 AA and 1 CQ, 2 RA, 2 RAA? (order!)
- [ ] Continue to test Scripts
- [x] Add Argument Completer for all AudioFiles to expect them in C:\Temp: [ArgumentCompleter( { 'C:\Temp\' } )]

## TeamsCallQueue

- [ ] EVALUATE "Karen wants to call the manager" - Manager Attribute on CQs or RAs?
- [ ] EVALUATE Refresh exposed Parameters with `CsOnlineCallQueue` scripts - regularly

## Licenses


## Code Improvements

- [x] Create Function Template
- [x] Add Help
- [ ] Pipeline
  - [x] Add Pipeline options
  - [x] Pipeline active by default (design for Pipes)
  - [ ] Test Pipelines further
- [ ] Disable Positional Binding for CQ and AA scripts https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute?view=powershell-5.1
- [ ] Add Supports Paging (First, Last) for Get Commands Get-TeamsCallQueue and Get-TeamsAutoAttendant at least!
- [ ] Add Timestamp to Verbose steps when Processing multiple elements (just inside the ForEach)
- [ ] Add Argument Completer to some functions, where appropriate: [ArgumentCompleter({(Get-Eventlog -List).log})]
- [ ] Add ScriptMethod ToString Method to other Get-CmdLets
- [ ] TBC

## Pester

- [ ] Change Module checks to this format: https://vexx32.github.io/2020/07/08/Verify-Module-Help-Pester/
- [ ] Figure out Testing with active Sessions - Do I need a demo Tenant?
- [ ] Add more tests
- [ ] MORE

## Other things

### Aliases

- [ ] Add shorthands following three letter model: GCQ, GAA, GRA, etc.
- [ ] Aliases for Parameters (Identity, UserPrincipalName, UPN, Username, etc. - make uniform)

### Evaluate Export to CLIXML

```powershell
$i = Import-Clixml -Path "XML FILE"
$i = Import-Clixml -Path E:\File.xml
$commandresult = $i['Get-CsOnlineUser']
$commandresult | Where-Object SipAddress -eq _____sip:xxx
```
