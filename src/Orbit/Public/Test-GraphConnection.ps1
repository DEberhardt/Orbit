# Module:   TeamsFunctions
# Function: Testing
# Author:   David Eberhardt
# Updated:  01-AUG-2020
# Status:   Live




function Test-GraphConnection {
  <#
  .SYNOPSIS
    Tests whether a valid PS Session exists for Azure Active Directory (v2)
  .DESCRIPTION
    A connection established via Connect-AzureAD is parsed.
  .EXAMPLE
    Test-GraphConnection
    Will Return $TRUE only if a session is found.
  .INPUTS
    None
  .OUTPUTS
    Boolean
  .NOTES
    Calls Get-MgContext to determine whether a Connection exists
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Tests the connection to AzureAd
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-GraphConnection.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    try {
      $Context = (Get-MgContext -WarningAction SilentlyContinue -ErrorAction STOP)
      return $( if ( $null -eq $Context ) { $false } else { $true } )
    }
    catch {
      return $false
    }

  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end

} #Test-AzureADConnection
