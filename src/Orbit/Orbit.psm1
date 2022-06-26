# using module .\Class\Orbit.Classes.psm1
# Above needs to remain the first line to import Classes
# remove the comment when using classes

#requires -Version 5
#Requires -Modules @{ ModuleName="MicrosoftTeams"; ModuleVersion="4.2.0" }
#Req#uires -Modules @{ ModuleName='Orbit.Authentication'; RequiredVersion = '0.0.0.0' }
#Req#uires -Modules @{ ModuleName='Orbit.Groups'; RequiredVersion = '0.0.0.0' }
#Req#uires -Modules @{ ModuleName='Orbit.Teams'; RequiredVersion = '0.0.0.0' }
#Req#uires -Modules @{ ModuleName='Orbit.Tools'; RequiredVersion = '0.0.0.0' }
#Req#uires -Modules @{ ModuleName='Orbit.Users'; RequiredVersion = '0.0.0.0' }


#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

<#
  Orbit - Module supplementing Microsoft.Graph and MicrosoftTeams
  Supporting Teams Administration, Voice Configuration for Tenant and Users
  User Configuration for Voice, Creation and connection of Resource Accounts,
  Licensing of Objects for Calling Plans & Direct Routing,
  Creation and Management of Call Queues and Auto Attendants

  by David Eberhardt
  david@davideberhardt.at
  @MightyOrmus
  www.davideberhardt.at
  https://github.com/DEberhardt
  https://davideberhardt.wordpress.com/

  Any and all technical advice, scripts, and documentation are provided as is with no guarantee.
  Always review any code and steps before applying to a production system to understand their full impact.

.LINK
  https://github.com/DEberhardt/Orbit/tree/master/docs

#>

#region Functions
#Dot source the files
Foreach ($Function in @($Public + $Private)) {
  Try {
    . $Function.Fullname
  }
  Catch {
    Write-Error -Message "Failed to import function $($Function.Fullname): $_"
  }
}

# Exporting Module Members (Functions)
Export-ModuleMember -Function $Public.Basename
#endregion

#region Aliases
# Query Aliases
$Aliases = $null
#$Aliases = Foreach ($Function in @($Public + $Private)) {
$Aliases = Foreach ($Function in @($Public)) {
  if ( $($Function.Fullname) -match '.tests.ps1' ) { continue }
  $Content = $AliasBlocks = $null

  $Content = $Function | Get-Content

  $AliasBlocks = $Content -split "`n" | Select-String 'Alias\(' -Context 1, 1
  $AliasBlocks | ForEach-Object {
    $Lines = $($_ -split "`n")
    if ( $Lines[0] -match 'CmdletBinding' -or $Lines[0] -match 'OutputType' -or $Lines[2] -match 'CmdletBinding' -or $Lines[2] -match 'OutputType' ) {
      if ( $($_ -split "`n")[1] -match "Alias\('(?<content>.*)'\)" ) {
        $($matches.content -split ',' -replace "'" -replace ' ') | ForEach-Object { if ( $_ -ne '' ) { $_ } }
      }
    }
    else {
      continue
    }
  }
}
Write-Verbose -Message "Aliases to Export - List: $($Aliases -join ',')"
Write-Verbose -Message "Aliases to Export - Count: $($Aliases.Count)"

# Manual definitions
$ManualAliases = @()

# Exporting Module Members (Aliases)
$AliasesToExport = @($Aliases + $ManualAliases)
if ( $AliasesToExport ) {
  Export-ModuleMember -Alias $AliasesToExport
}
#endregion

#region Variables

# Defining Help URL Base string:
$global:OrbitHelpURLBase = 'https://github.com/DEberhardt/Orbit/blob/master/docs/'

#endregion


#region Custom Module Functions
# Addressing Limitations
# Strict Mode
function Get-StrictMode {
  # returns the currently set StrictMode version 1, 2, 3
  # or 0 if StrictMode is off.
  try { $xyz = @(1); $null = ($null -eq $xyz[2]) }
  catch { return 3 }

  try { 'Not-a-Date'.Year }
  catch { return 2 }

  try { $null = ($undefined -gt 1) }
  catch { return 1 }

  return 0
}

if ((Get-StrictMode) -gt 0) {
  Write-Verbose 'TeamsFunctions: Strict Mode interferes with Script execution. Switching Strict Mode off - Please refer to https://github.com/DEberhardt/TeamsFunctions/issues/64 for details'
  Set-StrictMode -Off
}

# Allows use of [ArgumentCompletions] block native to PowerShell 6 and later!
if ($PSVersionTable.PSEdition -ne 'Core') {
  # add the attribute [ArgumentCompletions()]:
  $code = @'
using System;
using System.Collections.Generic;
using System.Management.Automation;

    public class ArgumentCompletionsAttribute : ArgumentCompleterAttribute
    {

        private static ScriptBlock _createScriptBlock(params string[] completions)
        {
            string text = "\"" + string.Join("\",\"", completions) + "\"";
            string code = "param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams);@(" + text + ") -like \"*$WordToComplete*\" | Foreach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }";
            return ScriptBlock.Create(code);
        }

        public ArgumentCompletionsAttribute(params string[] completions) : base(_createScriptBlock(completions))
        {
        }
    }
'@

  $null = Add-Type -TypeDefinition $code *>&1
}

#endregion
