begin {
  # test step
  Write-Output 'Running Pester Tests'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
  $ModuleDir = "$RootDir\packages\module"
  Write-Verbose "Module build location: $ModuleDir"

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

  Set-ShieldsIoBadge -Path $RootDir\ReadMe.md -Subject Result -Status $Script:TestResults.Result
  Set-ShieldsIoBadge -Path $RootDir\ReadMe.md -Subject Passed -Status $Script:TestResults.PassedCount -Color Blue
  Set-ShieldsIoBadge -Path $RootDir\ReadMe.md -Subject Failed -Status $Script:TestResults.FailedCount -Color Red
  Set-ShieldsIoBadge -Path $RootDir\ReadMe.md -Subject SkippedCount -Status $Script:TestResults.SkippedCount -Color Yellow
  Set-ShieldsIoBadge -Path $RootDir\ReadMe.md -Subject NotRunCount -Status $Script:TestResults.NotRunCount -Color darkgrey

  #Set-ShieldsIoBadge -Subject CodeCoverage -Status $Script:TestResults.Coverage -AsPercentage

  Write-Output 'Displaying ReadMe for validation'
  $ReadMe = Get-Content $RootDir\ReadMe.md
  $ReadMe

}
end {
  Set-Location $RootDir.Path
}