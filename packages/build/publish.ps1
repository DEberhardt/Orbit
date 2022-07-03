begin {
  # release step
  Write-Output 'Creating Release'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
  $ModuleDir = "$RootDir\packages\module"
  Write-Verbose "Module build location: $ModuleDir"

  Set-Location $ModuleDir

}
process {
  # Checking Authenticode Signature for PSM1 File
  $SignatureStatus = (Get-AuthenticodeSignature "$ModuleDir\TeamsFunctions.psm1").Status
  if ( $SignatureStatus -eq 'Valid') {
    Write-Verbose -Message "Status of Code-Signing Signature: $SignatureStatus" -Verbose
  }
  else {
    Write-Warning -Message "Status of Code-Signing Signature: $SignatureStatus" -Verbose
  }''

  #Publish Module
  Write-Verbose -Message 'Publish: Loop through all Modules' -Verbose
  foreach ($Module in $OrbitModule) {
    Write-Verbose -Message "$Module`: Publishing Module - PowerShellGallery" -Verbose
    try {
      # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
      $PM = @{
        Path        = "$ModuleDir\$Module\$Module.psd1"
        NuGetApiKey = $env:NuGetApiKey
        ErrorAction = 'Stop'
        #Tags        = @('', '')
        LicenseUri  = "https://github.com/DEberhardt/Orbit/blob/master/LICENSE.md"
        ProjectUri  = "https://github.com/DEberhardt/Orbit"
      }
      # Fetching current Version from Module
      $ManifestTest = Test-ModuleManifest -Path $PM.path

      Publish-Module @PM
      Write-Output "$Module PowerShell Module version $($ManifestTest.Version) published to the PowerShell Gallery."
    }
    catch {
      # Sad panda; it broke
      Write-Warning "Publishing update $($TestManiManifestTestfest.Version) to the PowerShell Gallery failed."
      throw $_
    }
  }
}
end {
  Set-Location $RootDir.Path
}