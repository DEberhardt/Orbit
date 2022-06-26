$Name = 'David Eberhardt'
$User = 'DEberhardt'
$OrbitModule = (Get-ChildItem -Path '..\..\src').BaseName

# Updating all Modules
foreach ($Module in $OrbitModule) {
  #region Updating Version
  # We're going to add 1 to the revision value since a new commit has been merged to Master
  # This means that the major / minor / build values will be consistent across GitHub and the Gallery

  Try {
    # This is where the module manifest lives
    $manifestPath = "..\..\src\$Module\$Module.psd1"

    # Start by importing the manifest to determine the version, then add 1 to the revision
    $manifest = Test-ModuleManifest -Path $manifestPath
    [System.Version]$version = $manifest.Version
    Write-Output "Old Version: $version"
    [String]$newVersion = New-Object -TypeName System.Version -ArgumentList ($version.Major, $version.Minor, $($version.Build + 1))
    Write-Output "New Version: $newVersion"

    # Update the manifest with the new version value and fix the weird string replace bug
    $functionList = ((Get-ChildItem -Path .\$Module\Public).BaseName)
    $splat = @{
      'Path'              = $manifestPath
      'ModuleVersion'     = $newVersion
      'FunctionsToExport' = $functionList
      #Original, fix below may not be needed if created correctly from the start?
      #'FunctionsToExport' = @($functionList -join ', ') # potential fix for below?
      'Copyright'         = "(c) 2022-$( (Get-Date).Year ) $Name. All rights reserved."
    }
    Update-ModuleManifest @splat
    #(Get-Content -Path $manifestPath) -replace "PSGet_$Module", "$Module" | Set-Content -Path $manifestPath
    #(Get-Content -Path $manifestPath) -replace 'NewManifest', $Module | Set-Content -Path $manifestPath
    #Fixing Array fo FunctionsToExport
        (Get-Content -Path $manifestPath) -replace 'FunctionsToExport = ', 'FunctionsToExport = @(' | Set-Content -Path $manifestPath -Force
        (Get-Content -Path $manifestPath) -replace "$($functionList[-1])'", "$($functionList[-1])')" | Set-Content -Path $manifestPath -Force
  }
  catch {
    throw $_
  }
  #endregion

  #region Documentation
  # Create new markdown and XML help files
  Write-Host 'Building new function documentation' -ForegroundColor Yellow
  Import-Module -Name "$PSScriptRoot\$Module" -Force
  New-MarkdownHelp -Module $Module -OutputFolder '.\docs\' -Force
  New-ExternalHelp -Path '.\docs\' -OutputPath ".\$Module\en-US\" -Force
  #. .\docs.ps1
  Write-Host -Object ''
  #endregion

  #region Publish
  # Publish the new version back to Master on GitHub
  Try {
    # Set up a path to the git.exe cmd, import posh-git to give us control over git, and then push changes to GitHub
    # Note that "update version" is included in the appveyor.yml file's "skip a build" regex to avoid a loop
    $env:Path += ";$env:ProgramFiles\Git\cmd"
    Import-Module posh-git -ErrorAction Stop
    git checkout master
    git add --all
    git status
    git commit -s -m "Update version to $newVersion"
    git push origin master
    Write-Host "$Module PowerShell Module version $newVersion published to GitHub." -ForegroundColor Cyan
  }
  Catch {
    # Sad panda; it broke
    Write-Warning "Publishing update $newVersion to GitHub failed."
    throw $_
  }


  # Publish the new version to the PowerShell Gallery
  Try {
    # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
    $PM = @{
      Path         = "..\..\src\$Module"
      NuGetApiKey  = $env:NuGetApiKey
      ErrorAction  = 'Stop'
      Tags         = @('', '')
      LicenseUri   = "https://github.com/$User/$Module/blob/master/LICENSE.md"
      ProjectUri   = "https://github.com/$User/$Module"
      ReleaseNotes = 'Initial release to the PowerShell Gallery'
    }

    Publish-Module @PM
    Write-Host "$Module PowerShell Module version $newVersion published to the PowerShell Gallery." -ForegroundColor Cyan
  }
  Catch {
    # Sad panda; it broke
    Write-Warning "Publishing update $newVersion to the PowerShell Gallery failed."
    throw $_
  }

}