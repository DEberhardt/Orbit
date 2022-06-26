$Name = 'David Eberhardt'
$User = 'DEberhardt'
$Copyright = "(c) 2020-$( (Get-Date).Year ) $Name. All rights reserved."

# Defining Relative Location to packages\build where this file resides
$LocationSRC = '..\..\src'
$LocationDOC = '..\..\docs'

# Defining Scope (Modules to process)
$OrbitDirs = Get-ChildItem -Path $LocationSRC -Directory | Sort-Object Name -Descending
$OrbitModule = $OrbitDirs.Basename

# Fetching current Version from Root Module
$RootManifestPath = "$LocationSRC\Orbit\Orbit.psd1"
$RootManifestTest = Test-ModuleManifest -Path $RootManifestPath

# Setting Build Helpers Build Environment ENV:BH*
Set-BuildEnvironment -Path $RootManifestPath

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


# Updating all Modules
foreach ($Module in $OrbitModule) {
  #region Updating Version in all
  try {
    Write-Output "Working on Module: $Module"
    # This is where the module manifest lives
    $manifestPath = "$LocationSRC\$Module\$Module.psd1"

    # Setting Build Helpers Build Environment ENV:BH*
    Set-BuildEnvironment -Path $manifestPath

    # Functions to Export
    $Pattern = @('FunctionsToExport', 'AliasesToExport')
    $Pattern | ForEach-Object {
      Write-Output "Old $_`:"
      Select-String -Path $manifestPath -Pattern $_

      switch ($_) {
        'FunctionsToExport' { Set-ModuleFunction }
        'AliasesToExport' { Set-ModuleAlias }
      }

      Write-Output "New $_`:"
      Select-String -Path $manifestPath -Pattern $_
    }

    # Updating Version
    Update-Metadata -Path $env:BHPSModuleManifest -PropertyName Copyright -Value $Copyright
    Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $newVersion
  }
  catch {
    throw $_
  }
  #endregion

  #region Documentation
  # Create new markdown and XML help files
  Write-Output 'Building new function documentation'
  Import-Module -Name "$LocationSRC\$Module" -Force
  New-MarkdownHelp -Module "$Module" -OutputFolder '$LocationDOC\' -Force -AlphabeticParamsOrder:$false
  New-ExternalHelp -Path "$LocationDOC\$Module\" -OutputPath "$LocationDOC\$Module\" -Force
  #endregion

  #region Pester Testing
  $PesterConfig = New-PesterConfiguration
  $PesterConfig.Run.PassThru = $true
  $PesterConfig.Run.Exit = $true
  $PesterConfig.Run.Throw = $true
  $PesterConfig.TestResult.Enabled = $true
  #$PesterConfig.CodeCoverage.Enabled = $true

  $Script:TestResults = Invoke-Pester -Path $LocationSRC -Configuration $PesterConfig
  #$CoveragePercent = [math]::floor(100 - (($Script:TestResults.CodeCoverage.NumberOfCommandsMissed / $Script:TestResults.CodeCoverage.NumberOfCommandsAnalyzed) * 100))

  Set-ShieldsIoBadge -Subject Result -Status $Script:TestResults.Result
  Set-ShieldsIoBadge -Subject Passed -Status $Script:TestResults.PassedCount -Color Blue
  Set-ShieldsIoBadge -Subject Failed -Status $Script:TestResults.FailedCount -Color Red
  Set-ShieldsIoBadge -Subject SkippedCount -Status $Script:TestResults.SkippedCount -Color Yellow
  Set-ShieldsIoBadge -Subject NotRunCount -Status $Script:TestResults.NotRunCount -Color darkgrey

  #Set-ShieldsIoBadge -Subject CodeCoverage -Status $Script:TestResults.Coverage -AsPercentage
  #endregion

  #region Publish the new version to the PowerShell Gallery
  try {
    # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
    $PM = @{
      Path         = "$LocationSRC\$Module"
      NuGetApiKey  = $env:NuGetApiKey
      ErrorAction  = 'Stop'
      Tags         = @('', '')
      LicenseUri   = "https://github.com/$User/Orbit/blob/master/LICENSE.md"
      ProjectUri   = "https://github.com/$User/Orbit"
    }

    Publish-Module @PM
    Write-Output "$Module PowerShell Module version $newVersion published to the PowerShell Gallery."
  }
  catch {
    # Sad panda; it broke
    Write-Warning "Publishing update $newVersion to the PowerShell Gallery failed."
    throw $_
  }
  #endregion
}

#region Documentation - Github
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

#region Publish the new version back to Master on GitHub
try {
  # Set up a path to the git.exe cmd, import posh-git to give us control over git, and then push changes to GitHub
  # Note that "update version" is included in the appveyor.yml file's "skip a build" regex to avoid a loop
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
}
catch {
  # Sad panda; it broke
  Write-Warning "Publishing update $newVersion to GitHub failed."
  throw $_
}
#endregion