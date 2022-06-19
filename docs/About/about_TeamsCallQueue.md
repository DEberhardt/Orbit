# Teams Call Queue

## about_TeamsCallQueue

## SHORT DESCRIPTION

Administering Call Queues with friendlier names.

## LONG DESCRIPTION

Call Queues with friendly inputs! Use the DisplayName to find and address changes to Call Queues.
Instead of having to manually input the File and provide an ID to the CallQueue CmdLet, this now also uses Friendly Filenames and performs the import for you.

Call Targets ([`CallableEntities`](about_TeamsCallableEntity.md)) verified, Users are - if licensed - enabled for EnterpriseVoice too. All requirements and dependencies are processed with visual feedback.

Microsoft is continuing to improve these scripts, so I hope these can stand the test of time and make managing Call Queues easier.

> [!NOTE] Microsoft has selected a GUID as the Identity the `CsCallQueue` scripts are a bit cumbersome for the average admin. Though the Searchstring parameter is available, enabling me to utilise it as a basic input method for `TeamsCallQueue` CmdLets. They query by *DisplayName*, which comes with a drawback for the `Set`-command: It requires a unique result.

## CmdLets

| Function                                                    | Underlying Function | Description                                                        |
| -----------------------------------------------------------: | ------------------- | ------------------------------------------------------------------ |
| [`Get-TeamsCallQueue`](Get-TeamsCallQueue.md)       | Get-CsCallQueue     | Queries a Call Queue with friendly inputs (UPN) and output         |
| [`New-TeamsCallQueue`](New-TeamsCallQueue.md)       | New-CsCallQueue     | Creates a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| [`Set-TeamsCallQueue`](Set-TeamsCallQueue.md)       | Set-CsCallQueue     | Changes a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| [`Remove-TeamsCallQueue`](Remove-TeamsCallQueue.md) | Remove-CsCallQueue  | Removes a Call Queue from the Tenant                               |

## Support CmdLet

| Function                                                    | Description                                                                                 |
| -----------------------------------------------------------: | ------------------------------------------------------------------------------------------- |
| [`Import-TeamsAudioFile`](Import-TeamsAudioFile.md)                 | Importing an AudioFile for use as a Greeting in a Call Queue                           |

## EXAMPLES

### Example 1 - Query

```powershell
Get-TeamsCallQueue [-Name] "Test"
# Queries all Call Queues with the Name 'Test' (full name)

Get-TeamsCallQueue -SearchString "Test"
# Queries all Call Queues with the String 'Test' in the name (search)
```

Where `-Name` targets the exact Name and can use the pipeline, `-SearchString` gives you an opportunity to find the Call Queues with similar names.

### Example 2 - Creating a new Call Queue with defaults

```powershell
New-TeamsCallQueue [-Name] "My Queue"
# Creates a Call Queue with improved defaults
# Thresholds: Overflow 10, Timeout 30s
# Improved defaults also cover the default MusicOnHold

New-TeamsCallQueue [-Name] "My Queue" -UseMicrosoftDefaults
# Creates a Call Queue with Microsoft defaults (thresholds)
# Thresholds: Overflow 50, Timeout 1200s
```

For more detailed examples, please see the Docs for the individual CmdLets

### Example 3 - Setting with the Pipeline

```powershell
Get-TeamsCallQueue -Name "My Queue" | Set-TeamsCallQueue -OverflowThreshold 120

# Queries all Call Queues with the Name 'My Queue' (full name) and changes the OverflowThreshold.
# Good for changing one or more Queues to the same setting, though handle with care!
```

Please note that the Name is not a unique criteria, you may have multiple that are called the same. Following Example #1, this can also be used to change multiple Call Queues at the same time with `-SearchString`

### Example 4 - Removing with the Pipeline

```powershell
Get-TeamsCallQueue -SearchString "Test" | Remove-TeamsCallQueue -Confirm

# Queries all Call Queues with the String 'Test' in the name and removes them. Prompts for confirmation for each.
# Handle with care!
```

## NOTE

Pipelines are available, as they are bound to the Name, this name must be unique (unless queried with Get first and the result being piped, where I bind to the individual ID instead). Bulk updating is available - see example above, but handle with care.  Best to capture the Queues to be changed in a variable and double-checking you got the correct ones (and only those) before running. Additionally, `-Confirm` can help.

## Development Status

Developing and testing these is very time consuming. I learned a lot while doing them, but as hard as I try, they probably still contain a few bugs.

## TROUBLESHOOTING NOTE

Thoroughly tested, but Unit-tests for these CmdLets are not yet available.

They are quite mature already, but if you do encounter issues, please capture verbose and debug output as they help me immensely when troubleshooting.

## SEE ALSO

[about_TeamsAutoAttendant](about_TeamsAutoAttendant.md)

[about_TeamsResourceAccount](about_TeamsResourceAccount.md)

[about_TeamsCallableEntity](about_TeamsCallableEntity.md)

## KEYWORDS

- Creation
- Configuration
- Management
- AzureAdUser
- AzureAdGroup
- CsOnlineUser
- CsOnlineApplicationInstance
- TeamsResourceAccount
