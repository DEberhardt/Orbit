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
    PSTypeName     = 'PowerShell.Orbit.ModuleMeta.FunctionStatus'
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
