begin {
  # document step
  Write-Output 'Updating Documentation & ReadMe'

  $RootDir = Get-Location
  Write-Verbose "Current location:      $($RootDir.Path)"
  $ModuleDir = "$RootDir\packages\module"
  Write-Verbose "Module build location: $ModuleDir"

  Set-Location $ModuleDir

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
  #Set-ShieldsIoBadge -Path $RootDir\ReadMe.md # Default updates 'Build' to 'pass' or 'fail'

  $AllPublicFunctions = Get-ChildItem -LiteralPath $global:orbitDirs.FullName | Where-Object Name -EQ 'Public' | Get-ChildItem -Filter *.ps1
  $AllPrivateFunctions = Get-ChildItem -LiteralPath $global:orbitDirs.FullName | Where-Object Name -EQ 'Private' | Get-ChildItem -Filter *.ps1
  $Script:FunctionStatus = Get-Functionstatus -PublicPath $($AllPublicFunctions.FullName) -PrivatePath $($AllPrivateFunctions.FullName)

  Set-ShieldsIoBadge -Path $RootDir\ReadMe.md -Subject Public -Status $Script:FunctionStatus.Public -Color Blue
  Set-ShieldsIoBadge -Path $RootDir\ReadMe.md -Subject Private -Status $Script:FunctionStatus.Private -Color LightGrey

  Set-ShieldsIoBadge -Path $RootDir\ReadMe.md -Subject Live -Status $Script:FunctionStatus.PublicLive -Color Blue
  Set-ShieldsIoBadge -Path $RootDir\ReadMe.md -Subject RC -Status $Script:FunctionStatus.PublicRC -Color Green
  Set-ShieldsIoBadge -Path $RootDir\ReadMe.md -Subject Beta -Status $Script:FunctionStatus.PublicBeta -Color Yellow
  Set-ShieldsIoBadge -Path $RootDir\ReadMe.md -Subject Alpha -Status $Script:FunctionStatus.PublicAlpha -Color Orange

  Write-Output "Displaying ReadMe for validation"
  $ReadMe = Get-Content $RootDir\ReadMe.md
  $ReadMe


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