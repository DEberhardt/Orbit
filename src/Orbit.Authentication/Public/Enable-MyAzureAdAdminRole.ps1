# Module:   TeamsFunctions
# Function: Testing
# Author:   David Eberhardt
# Updated:  13-MAR-2021
# Status:   Live




function Enable-MyAzureAdAdminRole {
  <#
  .SYNOPSIS
    Activates Azure Ad Admin Roles for currently connected User
  .DESCRIPTION
    Activates Azure Active Directory Privileged Identity Management Admin Roles for the currently connected User.
    Requires a Connection to AzureAd
  .EXAMPLE
    Enable-MyAzureAdAdminRole
  .INPUTS
    None
  .OUTPUTS
    System.Void - If executed from shell
    Boolean - If called by other CmdLets
  .NOTES
    None
  .COMPONENT
    UserManagement
  .FUNCTIONALITY
    Enables eligible Privileged Identity roles for Administration of Teams for the currently connected on User
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Enable-MyAzureAdAdminRole.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [Alias('ear')]
  [OutputType([Boolean])]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    try {
      $PIMavailable = Get-Command -Name 'Get-AzureADMSPrivilegedRoleAssignment' -ErrorAction Stop
      #region Activating Admin Roles
      if ( $PIMavailable ) {
        try {
          $AzureAdFeedback = Get-AzureADCurrentSessionInfo
          $ActivatedRoles = Enable-AzureAdAdminRole -Identity "$($AzureAdFeedback.Account)" -PassThru -Force -ErrorAction Stop # (default should only enable the Teams ones? switch?)
          if ( $ActivatedRoles -or $ActivatedRoles.Count -gt 0 ) {
            return $(if ($Called) { $ActivatedRoles } else {
                Write-Information "INFO:    $($MyInvocation.MyCommand) - $($ActivatedRoles.Count) Roles activated." -InformationAction Continue
                Write-Output $ActivatedRoles
              })
          }
          else {
            return $(if ($Called) { $ActivatedRoles } else {
                Write-Information "INFO:    $($MyInvocation.MyCommand) - No Roles activated, the following roles are active" -InformationAction Continue
                Get-MyAzureAdAdminRole
              })
          }
        }
        catch {
          $Exception = $_.Exception.Message
          return $(if ($Called) { $false } else {
              Write-Error -Message "Activating Admin Roles failed with Exception: $Exception"
            })
        }
      }
      else {
        return $(if ($Called) { $false } else {
            Write-Information "INFO:    $($MyInvocation.MyCommand) - Privileged Identity Management is not enabled for this tenant" -InformationAction Continue
          })
      }
      #endregion
    }
    catch {
      return $(if ($Called) { $false } else {
          Write-Information "INFO:    $($MyInvocation.MyCommand) - Privileged Identity Management functions are not available" -InformationAction Continue
        })
    }
  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Enable-MyAzureAdAdminRole
