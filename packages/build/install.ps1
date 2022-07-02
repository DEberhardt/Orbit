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
      $InstallSplat = @{
        'Name'         = $Module
        'Scope'        = 'CurrentUser'
        'Repository'   = 'PSGallery'
        'Force'        = $true
        'AllowClobber' = $true
      }
      #if ( $Module -eq 'PlatyPS' ) { $InstallSplat += @{ 'RequiredVersion' = '0.14.1' } }
      #if ( $Module -eq 'PlatyPS' ) { $InstallSplat += @{ 'AllowPrerelease' = $true } }
      Install-Module @InstallSplat
    }
    If (!(Get-Module $Module -ErrorAction SilentlyContinue)) {
      $ImportSplat = @{
        'Name'  = $Module
        'Force' = $true
      }
      #if ( $Module -eq 'AzureAdPreview' ) { $ImportSplat += @{ 'Cmdlet' = @('Open-AzureADMSPrivilegedRoleAssignmentRequest', 'Get-AzureADMSPrivilegedRoleAssignment') } }
      Import-Module @ImportSplat
    }
  }
  Get-Module

}
end {
  Set-Location $RootDir.Path
}