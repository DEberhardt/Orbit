begin {
  # Build step
  Write-Output 'Preparing Environment'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
}
process {

  [string[]]$PackageProviders = @('NuGet', 'PowerShellGet')
  [string[]]$PowerShellModules = @('Pester', 'posh-git', 'platyPS', 'InvokeBuild', 'BuildHelpers', 'MicrosoftTeams', 'AzureAd', 'AzureAdPreview')

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
      $Splat = @{
        'Name'         = $Module
        'Scope'        = 'CurrentUser'
        'Repository'   = 'PSGallery'
        'Force'        = $true
        'AllowClobber' = $true
      }
      if ( $Module -eq 'PlatyPS' ) { $Splat += @{ 'RequiredVersion' = '0.14.1' } }
      Install-Module @Splat
    }
    If (!(Get-Module $Module -ErrorAction SilentlyContinue)) {
      Import-Module $Module -Force
    }
  }
  Get-Module

}
end {
  Set-Location $RootDir.Path
}