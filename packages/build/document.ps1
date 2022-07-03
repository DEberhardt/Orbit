begin {
  # document step
  Write-Output 'Updating Documentation & ReadMe'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
  $ModuleDir = "$RootDir\packages\module"
  Write-Verbose "Module build location: $ModuleDir"

  . $PSScriptRoot\Set-ShieldsIoBadge2.ps1
  . $PSScriptRoot\Get-FunctionStatus.ps1

  Set-Location $ModuleDir
  $global:OrbitDirs = Get-ChildItem -Path $ModuleDir -Directory | Sort-Object Name -Descending
  $global:OrbitModule = $OrbitDirs.Basename

}
process {
  Write-Output 'Displaying ReadMe before changes are made to it'
  $ReadMe = Get-Content $RootDir\ReadMe.md
  $ReadMe

  # Updating Component Status
  Write-Verbose -Message 'Updating Component Status in ReadMe' -Verbose

  # Setting Build Helpers Build Environment ENV:BH*
  Set-BuildEnvironment -Path $ModuleDir

  # Updating ShieldsIO badges
  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md # Default updates 'Build' to 'pass' or 'fail'
  $AllPublicFunctions = Get-ChildItem -LiteralPath $global:orbitDirs.FullName | Where-Object Name -EQ 'Public' | Get-ChildItem -Filter *.ps1
  $AllPrivateFunctions = Get-ChildItem -LiteralPath $global:orbitDirs.FullName | Where-Object Name -EQ 'Private' | Get-ChildItem -Filter *.ps1
  Write-Output "Counting AllPrivateFunctions $($AllPrivateFunctions.Count)"
  Write-Output "Counting AllPrivateFunctions $($AllPrivateFunctions.Count)"
  $Script:FunctionStatus = Get-Functionstatus -PublicPath $($AllPublicFunctions.FullName) -PrivatePath $($AllPrivateFunctions.FullName)
  Write-Output $Script:FunctionStatus

  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md -Subject Public -Status $Script:FunctionStatus.Public -Color blue
  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md -Subject Private -Status $Script:FunctionStatus.Private -Color grey

  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md -Subject Live -Status $Script:FunctionStatus.PublicLive -Color blue
  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md -Subject RC -Status $Script:FunctionStatus.PublicRC -Color green
  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md -Subject BETA -Status $Script:FunctionStatus.PublicBeta -Color yellow
  Set-ShieldsIoBadge2 -Path $RootDir\ReadMe.md -Subject ALPHA -Status $Script:FunctionStatus.PublicAlpha -Color orange

  Write-Output 'Displaying ReadMe for validation'
  $ReadMe = Get-Content $RootDir\ReadMe.md
  $ReadMe


  # Create new markdown and XML help files
  Write-Verbose -Message 'Creating MarkDownHelp with PlatyPs' -Verbose
  Import-Module PlatyPs
  foreach ($Module in $OrbitModule) {
    Write-Output "Importing $Module - $ModuleDir\$Module\$Module.psd1"
    Import-Module "$ModuleDir\$Module\$Module.psd1" -Force
    $ModuleLoaded = Get-Module $Module
    if (-not $ModuleLoaded) { throw "Module '$Module' not found" }
    $DocsFolder = ".\docs\$Module\"

    New-MarkdownHelp -Module $ModuleLoaded.Name -OutputFolder $DocsFolder -Force -AlphabeticParamsOrder:$false
    New-ExternalHelp -Path $DocsFolder -OutputPath $DocsFolder -Force
    $HelpFiles = Get-ChildItem -Path $DocsFolder -Recurse
    Write-Output "Helpfiles total: $($HelpFiles.Count)"
  }

  # Updating version for Release Workflow
  Write-Verbose -Message 'Updateing Package.json' -Verbose
  # Fetching current Version from Root Module
  $ManifestPath = "$ModuleDir\Orbit\Orbit.psd1"
  $ManifestTest = Test-ModuleManifest -Path $ManifestPath

  # Workflow Changelog and Release Drafter are using Package.json file to read new version
  $PackageJSON = Get-Content "$RootDir\package.json" -Raw | ConvertFrom-Json
  $PackageJSON.Version = $ManifestTest.Version.ToString()
  Write-Output "Packgage.JSON updated to $($PackageJSON.Version)"
  $PackageJSON | ConvertTo-Json | Set-Content "$RootDir\package.json"
  $PackageJSON

}
end {
  Set-Location $RootDir.Path
}