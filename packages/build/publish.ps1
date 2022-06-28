﻿begin {
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
}
end {
  Set-Location $RootDir.Path
}