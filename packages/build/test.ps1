begin {
  # test step
  Write-Output 'Running Pester Tests'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
  $ModuleDir = "$RootDir\packages\module"
  Write-Verbose "Module build location: $ModuleDir"

  . $PSScriptRoot\Set-ShieldsIoBadge2.ps1

  Set-Location $ModuleDir
  $global:OrbitDirs = Get-ChildItem -Path $ModuleDir -Directory | Sort-Object Name -Descending
  $global:OrbitModule = $OrbitDirs.Basename

}
process {
  Write-Verbose -Message 'Loading Modules' -Verbose
  Get-ChildItem $ModuleDir
  foreach ($Module in $OrbitModule) {
    Write-Output "Importing $Module - $ModuleDir\$Module\$Module.psd1"
    Import-Module "$ModuleDir\$Module\$Module.psd1" -Force
  }
  Get-Module | Select-Object Name, Version, ModuleType, ModuleBase | Format-Table -AutoSize

  Write-Verbose -Message 'Pester Testing' -Verbose
  # Code Coverage currently disabled as output is not secure (no value in $TestResults.Coverage)

  $PesterConfig = New-PesterConfiguration
  #$Pesterconfig.Run.path = $ModuleDir
  $PesterConfig.Run.PassThru = $true
  $PesterConfig.Run.Exit = $true
  $PesterConfig.Run.Throw = $true
  $PesterConfig.TestResult.Enabled = $true
  $PesterConfig.Output.CIFormat = "GithubActions"
  #$PesterConfig.CodeCoverage.Enabled = $true

  $Script:TestResults = Invoke-Pester -Configuration $PesterConfig
  #$CoveragePercent = [math]::floor(100 - (($Script:TestResults.CodeCoverage.NumberOfCommandsMissed / $Script:TestResults.CodeCoverage.NumberOfCommandsAnalyzed) * 100))

  Write-Verbose -Message 'Pester Testing - Updating ReadMe' -Verbose
  Set-BuildEnvironment -Path $ModuleDir

  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md -Subject Result -Status $Script:TestResults.Result
  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md -Subject Passed -Status $Script:TestResults.PassedCount -Color blue
  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md -Subject Failed -Status $Script:TestResults.FailedCount -Color red
  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md -Subject Skipped -Status $Script:TestResults.SkippedCount -Color yellow
  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md -Subject NotRun -Status $Script:TestResults.NotRunCount -Color darkgrey

  #Set-ShieldsIoBadge2 -Subject CodeCoverage -Status $Script:TestResults.Coverage -AsPercentage

  Write-Output 'Displaying ReadMe for validation'
  $ReadMe = Get-Content $RootDir\ReadMe.md
  $ReadMe

}
end {
  Set-Location $RootDir.Path
}