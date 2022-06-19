# Module:   TeamsFunctions
# Function: Support
# Author:   David Eberhardt
# Updated:  14-NOV-2020
# Status:   Live




function Test-AzureAdGroup {
  <#
  .SYNOPSIS
    Tests whether an Group exists in Azure AD (record found)
  .DESCRIPTION
    Simple lookup - does the Group Object exist - to avoid TRY/CATCH statements for processing
  .PARAMETER Identity
    Mandatory. The Name or User Principal Name (MailNickName) of the Group to test.
  .EXAMPLE
    Test-AzureAdGroup -Identity "My Group"
    Will Return $TRUE only if the object "My Group" is found.
    Will Return $FALSE in any other case
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
    Tests whether an Azure Ad Group exists in AzureAd
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-AzureAdGroup.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'Required for performance. Removed with Disconnect-Me')]
  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'This is the Name or UserPrincipalName of the Group')]
    [Alias('UserPrincipalName', 'GroupName')]
    [string]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary

    # Loading all Groups
    if ( -not $global:TeamsFunctionsTenantAzureAdGroups) {
      Write-Verbose -Message 'Groups not loaded yet, depending on the size of the Tenant, this will run for a while!' -Verbose
      $global:TeamsFunctionsTenantAzureAdGroups = Get-AzureADGroup -All $true -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    $CallTarget = $null
    $CallTarget = Get-AzureADGroup -SearchString "$Identity" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    $CallTarget = $CallTarget | Where-Object Displayname -EQ "$Id"
    if (-not $CallTarget ) {
      try {
        $CallTarget = Get-AzureADGroup -ObjectId "$Identity" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        if ($Identity -match '@') {
          $CallTarget = $global:TeamsFunctionsTenantAzureAdGroups | Where-Object Mail -EQ "$Identity" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        }
        else {
          $CallTarget = $global:TeamsFunctionsTenantAzureAdGroups | Where-Object DisplayName -EQ "$Identity" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        }
      }
    }

    if ($CallTarget) {
      return $true
    }
    else {
      return $false
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-AzureAdGroup
