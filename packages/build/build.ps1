begin {
  # Build step
  Write-Output 'Building module'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
  $ModuleDir = "$RootDir\packages\module"
  Write-Verbose "Module build location: $ModuleDir"

}
process {
  Write-Verbose -Message 'Creating Directory' -Verbose
  # Create Directory
  New-Item -Path $ModuleDir -ItemType Directory

  # Copy from Server
  Write-Verbose -Message 'Copying Module' -Verbose
  $Excludes = @('.vscode', '*.git*', 'TODO.md', 'Archive', 'Incubator', 'packages', 'Workbench', 'PSScriptA*', 'Scrap*.*')
  Copy-Item -Path * -Destination $ModuleDir -Exclude $Excludes -Recurse -Force

  #region Orbit specific
  Set-Location $ModuleDir

  # Defining Scope (Modules to process)
  Write-Verbose -Message 'General: Building Module Scope - Parsing Modules' -Verbose
  $global:OrbitDirs = Get-ChildItem -Path $LocationSRC -Directory | Sort-Object Name -Descending
  $global:OrbitModule = $OrbitDirs.Basename
  Write-Output "Defined Scope: $($OrbitModule -join ', ')"
  #endregion

  #region Define Root Module
  # Fetching current Version from Root Module
  $ManifestPath = '.\src\Orbit\Orbit.psd1'
  $ManifestTest = Test-ModuleManifest -Path $ManifestPath

  # Setting Build Helpers Build Environment ENV:BH*
  Write-Verbose -Message 'General: Module Version' -Verbose
  Set-BuildEnvironment -Path $ManifestTest.ModuleBase

  # Creating new version Number (determined from found Version)
  [System.Version]$version = $ManifestTest.Version
  Write-Output "Old Version: $version"
  # Determining Next available Version from published Package
  $nextAvailableVersion = Get-NextNugetPackageVersion -Name $env:BHProjectName
  Write-Output "Next available Version: $nextAvailableVersion"
  # We're going to add 1 to the build value since a new commit has been merged to Master
  # This means that the major / minor / build values will be consistent across GitHub and the Gallery
  # To publish a new minor version, simply remove set the version in Orbit.psd1 from "1.3.14" to "1.4"
  [String]$nextProposedVersion = New-Object -TypeName System.Version -ArgumentList ($version.Major, $version.Minor, $($version.Build + 1))
  Write-Output "Next proposed Version: $nextProposedVersion"
  if ( $nextProposedVersion -lt $nextAvailableVersion ) {
    Write-Warning 'Version mismatch - taking next available version'
    $global:newVersion = $nextAvailableVersion
  }
  else {
    $global:newVersion = $nextProposedVersion
  }
  Write-Output "New Version: $global:newVersion"


  # Resetting RequiredModules in Orbit Root to allow processing via Build script - This will be added later, before publishing
  Write-Verbose -Message "General: Updating Orbit.psm1 to reflect all nested Modules' Version" -Verbose
  $RequiredModulesValue = @(
    @{ModuleName = 'MicrosoftTeams'; ModuleVersion = '4.2.0'; }
  )
  Update-Metadata -Path $env:BHPSModuleManifest -PropertyName RequiredModules -Value $RequiredModulesValue
  #region

  # Updating all Modules
  Write-Verbose -Message 'Build: Loop through all Modules' -Verbose
  foreach ($Module in $OrbitModule) {
    Write-Verbose -Message "$Module`: Testing Manifest" -Verbose
    # This is where the module manifest lives
    $ManifestPath = ".\src\$Module\$Module.psd1"
    $ManifestTest = Test-ModuleManifest -Path $ManifestPath

    # Setting Build Helpers Build Environment ENV:BH*
    Write-Verbose -Message "$Module`: Preparing Build Environment" -Verbose
    Set-BuildEnvironment -Path $ManifestTest.ModuleBase -Force
    Get-Item ENV:BH* | Select-Object Key, Value

    # Functions to Export
    $Pattern = @('FunctionsToExport', 'AliasesToExport')
    $Pattern | ForEach-Object {
      Write-Output "Old $_`:"
      Select-String -Path $manifestPath -Pattern $_

      switch ($_) {
        'FunctionsToExport' { Set-ModuleFunction -Name $manifestPath }
        'AliasesToExport' { Set-ModuleAlias -Name $manifestPath }
      }

      Write-Output "New $_`:"
      Select-String -Path $manifestPath -Pattern $_
    }

    # Updating Version
    $Copyright = "(c) 2020-$( (Get-Date).Year ) $Name. All rights reserved."
    Update-Metadata -Path $ManifestTest.Path -PropertyName Copyright -Value $Copyright
    Update-Metadata -Path $ManifestTest.Path -PropertyName ModuleVersion -Value $newVersion

    Write-Output 'Manifest re-tested incl. Version, Copyright, etc.'
    $ManifestTest = Test-ModuleManifest -Path $ManifestPath
    $ManifestTest

    #Importing Module
    Write-Verbose -Message "$Module`: Importing Module" -Verbose
    Import-Module $manifestTest.Path
  }

}
end {
  Set-Location $RootDir.Path
}