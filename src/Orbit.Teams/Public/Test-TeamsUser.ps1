# Module:   TeamsFunctions
# Function: Support
# Author:   David Eberhardt
# Updated:  14-NOV-2020
# Status:   Live




function Test-TeamsUser {
  <#
  .SYNOPSIS
    Tests whether an Object exists in Teams (record found)
  .DESCRIPTION
    Simple lookup - does the Object exist - to avoid TRY/CATCH statements for processing
  .PARAMETER UserPrincipalName
    Mandatory. The sign-in address, User Principal Name or Object Id of the Object.
  .EXAMPLE
    Test-TeamsUser -Identity "$UPN"
    Will Return $TRUE only if the object $UPN is found.
    Will Return $FALSE in any other case, including if there is no Connection to MicrosoftTeams!
  .INPUTS
    System.String
  .OUTPUTS
    Boolean
  .NOTES
    None
  .COMPONENT
    SupportingFunction
    UserManagement
  .FUNCTIONALITY
    Tests whether an Teams User exists in AzureAd
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-TeamsUser.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'This is the UserID (UPN)')]
    [Alias('ObjectId', 'Identity')]
    [string]$UserPrincipalName
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($User in $UserPrincipalName) {
      try {
        $CsOnlineUser = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction STOP
        if ( $null -ne $CsOnlineUser ) {
          return $true
        }
        else {
          return $false
        }
      }
      catch [System.Exception] {
        return $false
      }
      catch {
        return $false
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-TeamsUser
