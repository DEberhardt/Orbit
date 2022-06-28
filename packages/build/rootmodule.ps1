begin {
  # release step
  Write-Output 'Root Module'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
  $ModuleDir = "$RootDir\packages\module"
  Write-Verbose "Module build location: $ModuleDir"

  Set-Location $ModuleDir

}
process {
  $ManifestPath = '.\src\Orbit\Orbit.psd1'
  $ManifestTest = Test-ModuleManifest -Path $ManifestPath
  Set-BuildEnvironment -Path $ManifestTest.ModuleBase

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
  Update-Metadata -Path $ManifestTest.Path -PropertyName RequiredModules -Value $RequiredModulesValue


  # This should be replaced by signing the script with Secret from Github Actions (personal certificate)
  Write-Verbose -Message 'Applying Authenticode Signature' -Verbose
  #Import-Module Microsoft.PowerShell.Security
  Write-Output 'Currently SKIPPED - This should be replaced by signing the script with Secret from Github Actions (personal certificate)' -Verbose




  # Checking Authenticode Signature for PSM1 File
  $SignatureStatus = (Get-AuthenticodeSignature $ManifestTest.Path).Status
  if ( $SignatureStatus -eq 'Valid') {
    Write-Verbose -Message "Status of Code-Signing Signature: $SignatureStatus" -Verbose
  }
  else {
    Write-Warning -Message "Status of Code-Signing Signature: $SignatureStatus" -Verbose
  }

  
}
end {
  Set-Location $RootDir.Path
}