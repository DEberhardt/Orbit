begin {
  # Checking code back in and creating release
  Write-Output 'Creating Commit &GitHub Release'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
  $ModuleDir = "$RootDir\packages\module"
  Write-Verbose "Module build location: $ModuleDir"

  Set-Location $ModuleDir

}
process {
  # Publish the new version back to Main on GitHub
  Write-Verbose -Message 'Creating git tag for Version, Commit and Push' -Verbose
  $CommitMessage = "Update version to $global:newVersion"
  try {
    # Set up a path to the git.exe cmd, import posh-git to give us control over git, and then push changes to GitHub
    $env:Path += ";$env:ProgramFiles\Git\cmd"
    Import-Module posh-git -ErrorAction Stop
    git checkout main
    git add --all
    git status
    git commit -s -m $CommitMessage
    git push origin main
    Write-Output 'Commit pushed to Origin.'
  }
  catch {
    Write-Warning 'Creating Push to Main failed.'
    throw $_
  }

  # Publish new GitHub Release with Tag "v$global:newVersion"
  try {
    Write-Verbose -Message 'Creating git tag for Version, Commit and Push' -Verbose
    Publish-GithubRelease -AccessToken $env:PUSHTOKEN -RepositoryOwner $env:USER -TagName "v$global:newVersion"
    git tag "v$global:newVersion"
    git push --tags origin
    Write-Output "PowerShell Module version $global:newVersion published to GitHub."
  }
  catch {
    Write-Warning 'Commit push to main failed'
    Write-Warning "failedPublishing update $global:newVersion to GitHub failed."
    throw $_
  }
}
end {
  Set-Location $RootDir.Path
}