begin {
  # document step
  Write-Output 'Updating Documentation & ReadMe'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
  $ModuleDir = "$RootDir\packages\module"
  Write-Verbose "Module build location: $ModuleDir"

  Set-Location $ModuleDir

}
process {
  # Updating Component Status
  Write-Verbose -Message 'Updating Component Status in ReadMe' -Verbose
  # Updating ShieldsIO badges
  Set-ShieldsIoBadge # Default updates 'Build' to 'pass' or 'fail'

  $AllPublicFunctions = Get-ChildItem -LiteralPath $orbitDirs.FullName | Where-Object Name -EQ 'Public' | Get-ChildItem -Filter *.ps1
  $AllPrivateFunctions = Get-ChildItem -LiteralPath $orbitDirs.FullName | Where-Object Name -EQ 'Private' | Get-ChildItem -Filter *.ps1
  $Script:FunctionStatus = Get-Functionstatus -PublicPath $($AllPublicFunctions.FullName) -PrivatePath $($AllPrivateFunctions.FullName)

  Set-ShieldsIoBadge -Subject Public -Status $Script:FunctionStatus.Public -Color Blue
  Set-ShieldsIoBadge -Subject Private -Status $Script:FunctionStatus.Private -Color LightGrey

  Set-ShieldsIoBadge -Subject Live -Status $Script:FunctionStatus.PublicLive -Color Blue
  Set-ShieldsIoBadge -Subject RC -Status $Script:FunctionStatus.PublicRC -Color Green
  Set-ShieldsIoBadge -Subject Beta -Status $Script:FunctionStatus.PublicBeta -Color Yellow
  Set-ShieldsIoBadge -Subject Alpha -Status $Script:FunctionStatus.PublicAlpha -Color Orange


  # Create new markdown and XML help files
  Write-Verbose -Message 'Creating MarkDownHelp with PlatyPs' -Verbose
  Import-Module PlatyPs
  foreach ($Module in $OrbitModule) {
    $ModuleLoaded = Get-Module TeamsFunctions
    if (-not $ModuleLoaded) { throw "Module '$Module' not found" }
    $DocsFolder = ".\docs\$Module\"

    New-MarkdownHelp -Module $ModuleLoaded.Name -OutputFolder $DocsFolder -Force -AlphabeticParamsOrder:$false
    New-ExternalHelp -Path $DocsFolder -OutputPath $DocsFolder -Force
    $HelpFiles = Get-ChildItem -Path $DocsFolder -Recurse
    Write-Output "Helpfiles total: $($HelpFiles.Count)"
  }
}
end {
  Set-Location $RootDir.Path
}