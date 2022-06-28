begin {
  # Build step
  Write-Output 'Preparing Environment'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
}
process {

  [string[]]$PackageProviders = @('NuGet', 'PowerShellGet')
  [string[]]$PowerShellModules = @('Pester', 'posh-git', 'platyPS', 'InvokeBuild', 'BuildHelpers', 'MicrosoftTeams')

  # Install package providers for PowerShell Modules
  Write-Verbose -Message 'Installing Package Provider' -Verbose
  ForEach ($Provider in $PackageProviders) {
    If (!(Get-PackageProvider $Provider -ErrorAction SilentlyContinue)) {
      Install-PackageProvider $Provider -Force -ForceBootstrap -Scope CurrentUser
    }
  }

  # Install the PowerShell Modules
  Write-Verbose -Message 'Installing PowerShell Modules' -Verbose
  ForEach ($Module in $PowerShellModules) {
    Write-Output "Installing $Module"
    If (!(Get-Module -ListAvailable $Module -ErrorAction SilentlyContinue)) {
      Install-Module $Module -Scope CurrentUser -Force -Repository PSGallery #-AllowClobber
    }
    If (!(Get-Module $Module -ErrorAction SilentlyContinue)) {
      Import-Module $Module -Force
    }
  }
  Get-Module

  #region Custom Functions
  function Get-FunctionStatus {
    param (
      [string[]]$PublicPath = '.\Public',
      [string[]]$PrivatePath = '.\Private'
    )

    # Simple Function to query function status by analysing the Content
    # This searches for calls to "Set-FunctionStatus -Level <Level>"

    $PublicFunctions = if ( [String]::IsNullOrEmpty($PublicPath)) { $null } else { Get-ChildItem -Filter *.ps1 -Path @($PublicPath) -Recurse }
    $PrivateFunctions = if ( [String]::IsNullOrEmpty($PrivatePath) ) { $null } else { Get-ChildItem -Filter *.ps1 -Path @($PrivatePath) -Recurse }

    $FunctionStatus = $null
    $FunctionStatus = [PsCustomObject][ordered] @{
      'Total'        = $PublicFunctions.Count + $PrivateFunctions.Count
      'Public'       = $PublicFunctions.Count
      'Private'      = $PrivateFunctions.Count
      'PublicLive'   = $(($PublicFunctions | Get-Content -ErrorAction Ignore) -match '-Level Live').Count
      'PublicRC'     = $(($PublicFunctions | Get-Content -ErrorAction Ignore) -match '-Level RC').Count
      'PublicBeta'   = $(($PublicFunctions | Get-Content -ErrorAction Ignore) -match '-Level Beta').Count
      'PublicAlpha'  = $(($PublicFunctions | Get-Content -ErrorAction Ignore) -match '-Level Alpha').Count
      'PrivateLive'  = $(($PrivateFunctions | Get-Content -ErrorAction Ignore) -match '-Level Live').Count
      'PrivateRC'    = $(($PrivateFunctions | Get-Content -ErrorAction Ignore) -match '-Level RC').Count
      'PrivateBeta'  = $(($PrivateFunctions | Get-Content -ErrorAction Ignore) -match '-Level Beta').Count
      'PrivateAlpha' = $(($PrivateFunctions | Get-Content -ErrorAction Ignore) -match '-Level Alpha').Count
    }

    return $FunctionStatus
  }
  #endregion

}
end {
  Set-Location $RootDir.Path
}