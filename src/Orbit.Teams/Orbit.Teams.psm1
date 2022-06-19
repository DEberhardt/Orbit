# using module .\Class\Orbit.Teams.Classes.psm1
# Above needs to remain the first line to import Classes
# remove the comment when using classes

#requires -Version 5

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

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

#endregion


#region Custom Module Functions

#endregion
