$Name = 'David Eberhardt'
$User = 'DEberhardt'
$Copyright = "(c) 2020-$( (Get-Date).Year ) $Name. All rights reserved."

# Build step
Write-Verbose -Message "General: Copying Data" -Verbose

$RootDir = Get-Location
Write-Output "Current location:      $($RootDir.Path)"
$ModuleDir = "$RootDir\packages\module"
Write-Output "Module build location: $ModuleDir"

# Create Directory
New-Item -Path $ModuleDir -ItemType Directory

# Copy from Server
$Excludes = @('.vscode', '*.git*', 'TODO.md', 'Archive', 'Incubator', 'packages', 'Workbench', 'PSScriptA*', 'Scrap*.*')
Copy-Item -Path * -Destination $ModuleDir -Exclude $Excludes -Recurse -Force

Set-Location $ModuleDir

# Defining Relative Location to packages\build where this file resides
$LocationSRC = '.\src'
$LocationDOC = '.\docs'

# Defining Scope (Modules to process)
Write-Verbose -Message 'General: Building Module Scope - Parsing Modules' -Verbose
$OrbitDirs = Get-ChildItem -Path $LocationSRC -Directory | Sort-Object Name -Descending
$OrbitModule = $OrbitDirs.Basename

# Fetching current Version from Root Module
$RootManifestPath = "$LocationSRC\Orbit\Orbit.psd1"
$RootManifestTest = Test-ModuleManifest -Path $RootManifestPath

# Setting Build Helpers Build Environment ENV:BH*
Write-Verbose -Message 'General: Module Version' -Verbose
Set-BuildEnvironment -Path $RootManifestTest.ModuleBase
Get-Item ENV:BH*

# Creating new version Number (determined from found Version)
[System.Version]$version = $RootManifestTest.Version
Write-Output "Old Version: $version"
# Determining Next available Version from published Package
$nextAvailableVersion = Get-NextNugetPackageVersion -Name $env:BHProjectName
Write-Output "Next available Version: $nextAvailableVersion"
# We're going to add 1 to the build value since a new commit has been merged to Master
# This means that the major / minor / build values will be consistent across GitHub and the Gallery
# To publish a new minor version, simply remove set the version in Orbit.psd1 from "1.3.14" to "1.4"
[String]$nextProposedVersion = New-Object -TypeName System.Version -ArgumentList ($version.Major, $version.Minor, $($version.Build + 1))
Write-Output "Next proposed Version: $nextProposedVersion"
if ( $nextAvailableVersion -lt $nextProposedVersion ) {
  Write-Warning 'Version mismatch - taking next available version'
  $newVersion = $nextAvailableVersion
}
else {
  $newVersion = $nextProposedVersion
}
Write-Output "New Version: $newVersion"

Write-Verbose -Message "General: Updating Orbit.psm1 to reflect all nested Modules' Version" -Verbose

# Resetting RequiredModules in Orbit Root to allow processing via Build script - This will be added later, before publishing
$RequiredModulesValue   = @(
  @{ModuleName = 'MicrosoftTeams'; ModuleVersion = '4.2.0'; }
  )
  Update-Metadata -Path $env:BHPSModuleManifest -PropertyName RequiredModules -Value $RequiredModulesValue

# Updating all Modules
Write-Verbose -Message 'Build: Loop through all Modules' -Verbose
foreach ($Module in $OrbitModule) {
  #region Updating Version in all
  try {
    Write-Verbose -Message "$Module`: Testing Manifest" -Verbose
    # This is where the module manifest lives
    $ManifestPath = "$LocationSRC\$Module\$Module.psd1"
    $ManifestTest = Test-ModuleManifest -Path $ManifestPath

    # Setting Build Helpers Build Environment ENV:BH*
    Write-Verbose -Message "$Module`: Preparing Build Environment" -Verbose
    Set-BuildEnvironment -Path $ManifestTest.ModuleBase -Force
    Get-Item ENV:BH* | Select-Object Key, Value

    # Functions to Export
    Write-Verbose -Message "$Module`: Updating Manifest (FunctionsToExport, AliasesToExport)" -Verbose
    $Pattern = @('FunctionsToExport', 'AliasesToExport')
    $Pattern | ForEach-Object {
      Write-Output "Old $_`:"
      Select-String -Path $ManifestPath -Pattern $_

      switch ($_) {
        'FunctionsToExport' { Set-ModuleFunction -Name $ManifestTest.ModuleBase }
        'AliasesToExport' { Set-ModuleAlias -Name $ManifestTest.ModuleBase }
      }

      Write-Output "New $_`:"
      Select-String -Path $ManifestPath -Pattern $_
    }

    # Updating Version
    Update-Metadata -Path $env:BHPSModuleManifest -PropertyName Copyright -Value $Copyright
    Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $newVersion

    Write-Output "Manifest re-tested incl. Version, Copyright, etc."
    Test-ModuleManifest -Path $ManifestPath
  }
  catch {
    throw $_
  }
  #endregion

  Write-Verbose -Message "$Module`: Importing Module" -Verbose
  Import-Module -Name $ManifestTest.Path -Force

  #region Documentation
  # Create new markdown and XML help files
  Write-Verbose -Message "$Module`: Creating MarkDownHelp" -Verbose
  New-MarkdownHelp -Module $.ManifestTestName -OutputFolder "$LocationDOC\" -Force -AlphabeticParamsOrder:$false
  New-ExternalHelp -Path "$LocationDOC\$Module\" -OutputPath "$LocationDOC\$Module\" -Force
  $HelpFiles = Get-ChildItem -Path $LocationDOC -Recurse
  Write-Output "Helpfiles created: $($HelpFiles.Count)"

  #endregion
}

#region Pester Testing
Write-Verbose -Message "Pester Testing" -Verbose
$PesterConfig = New-PesterConfiguration
$PesterConfig.Run.PassThru = $true
$PesterConfig.Run.Exit = $true
$PesterConfig.Run.Throw = $true
$PesterConfig.TestResult.Enabled = $true
#$PesterConfig.CodeCoverage.Enabled = $true

$Script:TestResults = Invoke-Pester -Path $ModuleDir -Configuration $PesterConfig
#$CoveragePercent = [math]::floor(100 - (($Script:TestResults.CodeCoverage.NumberOfCommandsMissed / $Script:TestResults.CodeCoverage.NumberOfCommandsAnalyzed) * 100))

Write-Verbose -Message "Pester Testing - Updating ReadMe" -Verbose
Set-ShieldsIoBadge -Subject Result -Status $Script:TestResults.Result
Set-ShieldsIoBadge -Subject Passed -Status $Script:TestResults.PassedCount -Color Blue
Set-ShieldsIoBadge -Subject Failed -Status $Script:TestResults.FailedCount -Color Red
Set-ShieldsIoBadge -Subject SkippedCount -Status $Script:TestResults.SkippedCount -Color Yellow
Set-ShieldsIoBadge -Subject NotRunCount -Status $Script:TestResults.NotRunCount -Color darkgrey

#Set-ShieldsIoBadge -Subject CodeCoverage -Status $Script:TestResults.Coverage -AsPercentage
#endregion

#region Documentation - Github

Write-Verbose -Message 'Documentation - Updating ReadMe' -Verbose
# Updating ShieldsIO badges
Set-ShieldsIoBadge # Default updates 'Build' to 'pass' or 'fail'

# Updating Component Status
$AllPublicFunctions = Get-ChildItem -LiteralPath $orbitDirs.FullName | Where-Object Name -EQ 'Public' | Get-ChildItem -Filter *.ps1
$AllPrivateFunctions = Get-ChildItem -LiteralPath $orbitDirs.FullName | Where-Object Name -EQ 'Private' | Get-ChildItem -Filter *.ps1
$Script:FunctionStatus = Get-Functionstatus -PublicPath $($AllPublicFunctions.FullName) -PrivatePath $($AllPrivateFunctions.FullName)

Set-ShieldsIoBadge -Subject Public -Status $Script:FunctionStatus.Public -Color Blue
Set-ShieldsIoBadge -Subject Private -Status $Script:FunctionStatus.Private -Color LightGrey

Set-ShieldsIoBadge -Subject Live -Status $Script:FunctionStatus.PublicLive -Color Blue
Set-ShieldsIoBadge -Subject RC -Status $Script:FunctionStatus.PublicRC -Color Green
Set-ShieldsIoBadge -Subject Beta -Status $Script:FunctionStatus.PublicBeta -Color Yellow
Set-ShieldsIoBadge -Subject Alpha -Status $Script:FunctionStatus.PublicAlpha -Color Orange
#endregion


#region Publish the new version back to Main on GitHub
try {
  #TODO Check Invoke-Git and replace the below?
  # Set up a path to the git.exe cmd, import posh-git to give us control over git, and then push changes to GitHub
  $env:Path += ";$env:ProgramFiles\Git\cmd"
  Import-Module posh-git -ErrorAction Stop
  git checkout master
  git add --all
  git status
  git commit -s -m "Update version to $newVersion"
  git tag "v$newVersion"
  git push origin master
  git push --tags origin
  Write-Output "$Module PowerShell Module version $newVersion published to GitHub."

  #TODO Call Publish-GitHubRelease from BuildHelpers
}
catch {
  # Sad panda; it broke
  Write-Warning "Publishing update $newVersion to GitHub failed."
  throw $_
}
#endregion



#region Publish the new version to the PowerShell Gallery
# Setting RequiredModules in Orbit Root before publishing
$RequiredModulesValue = @(
  @{ModuleName = 'MicrosoftTeams'; ModuleVersion = '4.2.0'; },
  #@{ModuleName = 'Microsoft.Graph'; ModuleVersion = '1.9.6'; },
  @{ModuleName = 'Orbit.Authentication'; RequiredVersion = "$newVersion"; },
  @{ModuleName = 'Orbit.Groups'; RequiredVersion = "$newVersion"; },
  @{ModuleName = 'Orbit.Teams'; RequiredVersion = "$newVersion"; },
  @{ModuleName = 'Orbit.Tools'; RequiredVersion = "$newVersion"; },
  @{ModuleName = 'Orbit.Users'; RequiredVersion = "$newVersion"; }
)
Update-Metadata -Path $RootManifestTest.Path -PropertyName RequiredModules -Value $RequiredModulesValue

Write-Verbose -Message 'Publish: Loop through all Modules' -Verbose
foreach ($Module in $OrbitModule) {
  Write-Verbose -Message "$Module`: Publishing Module - PowerShellGallery" -Verbose
  try {
    # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
    $PM = @{
      Path        = "$LocationSRC\$Module\$Module.psd1"
      NuGetApiKey = $env:NuGetApiKey
      ErrorAction = 'Stop'
      #Tags        = @('', '')
      LicenseUri  = "https://github.com/$env:USER/Orbit/blob/master/LICENSE.md"
      ProjectUri  = "https://github.com/$env:USER/Orbit"
    }

    #Publish-Module @PM
    Publish-Module @PM -WhatIf
    #Write-Output "$Module PowerShell Module version $newVersion published to the PowerShell Gallery."
  }
  catch {
    # Sad panda; it broke
    Write-Warning "Publishing update $newVersion to the PowerShell Gallery failed."
    throw $_
  }
}
#endregion
