begin {
  # test step
  Write-Output 'Running Pester Tests'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
  $ModuleDir = "$RootDir\packages\module"
  Write-Verbose "Module build location: $ModuleDir"

  Set-Location $ModuleDir

}
process {
  Write-Verbose -Message 'Loaded Modules' -Verbose
  Get-Module

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

  Set-ShieldsIoBadge -Subject Result -Status $Script:TestResults.Result
  Set-ShieldsIoBadge -Subject Passed -Status $Script:TestResults.PassedCount -Color Blue
  Set-ShieldsIoBadge -Subject Failed -Status $Script:TestResults.FailedCount -Color Red
  Set-ShieldsIoBadge -Subject SkippedCount -Status $Script:TestResults.SkippedCount -Color Yellow
  Set-ShieldsIoBadge -Subject NotRunCount -Status $Script:TestResults.NotRunCount -Color darkgrey

  #Set-ShieldsIoBadge -Subject CodeCoverage -Status $Script:TestResults.Coverage -AsPercentage

}
end {
  Set-Location $RootDir.Path
}