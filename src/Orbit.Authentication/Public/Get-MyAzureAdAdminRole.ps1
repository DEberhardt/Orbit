# Module:     TeamsFunctions
# Function:   UserAdmin
# Author:    David Eberhardt
# Updated:    01-SEP-2020
# Status:     Live




function Get-MyAzureAdAdminRole {
  <#
  .SYNOPSIS
    Queries Admin Roles assigned to the currently connected User
  .DESCRIPTION
    Azure Active Directory Admin Roles assigned to the currently connected User
    Requires a Connection to AzureAd
    Querying '-Type Elibile' requires the Module AzureAdPreview installed
  .PARAMETER Type
    Optional. Switches query to Active (Default) or Eligible Admin Roles
    Eligibility can only be queried with Module AzureAdPreview installed
  .EXAMPLE
    Get-AzureAdAdminRole [-Type Active]
    Returns all active Admin Roles for the currently connected User
  .EXAMPLE
    Get-AzureAdAdminRole -Type Eligible
    Returns all eligible Admin Roles for the currently connected User
  .INPUTS
    System.String
  .OUTPUTS
    PSCustomObject
  .NOTES
    This is a wrapper for Get-AzureAdAdminRole targeting the currently connected User
  .COMPONENT
    UserAdmin
  .FUNCTIONALITY
    Queries active or eligible Privileged Identity roles for Administration of Teams for the currently connected User
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-MyAzureAdAdminRole.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [Alias('gar')]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(HelpMessage = 'Active, Eligible')]
    [ValidateSet('All', 'Active', 'Eligible')]
    #[ValidateSet('All', 'Active', 'Eligible','Group')]
    [string]$Type = 'All'

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    Get-AzureAdAdminRole -Identity $(Get-AzureADCurrentSessionInfo).Account.Id -Type $Type

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-MyAzureAdAdminRole
