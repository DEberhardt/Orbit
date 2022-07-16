# Module:     TeamsFunctions
# Function:   UserAdmin
# Author:    David Eberhardt
# Updated:    01-SEP-2020
# Status:     Live


#IMPROVE Add Eligible Groups once available

function Get-AzureAdAdminRole {
  <#
  .SYNOPSIS
    Queries Admin Roles assigned to an Object
  .DESCRIPTION
    Azure Active Directory Admin Roles assigned to an Object
    Requires a Connection to AzureAd
  .PARAMETER Identity
    Required. One or more UserPrincipalNames of the Office365 Administrator
  .PARAMETER Type
    Optional. Switches query to All (Default), Eligible or Active Admin Roles
    This requires the Module AzureAdPreview installed
  .PARAMETER QueryGroupsOnly
    Optional. Switches query to Active (Default) or Eligible Admin Roles
    Limits the query to Active Directory Groups only. Does not require AzureAdPreview installed
  .EXAMPLE
    Get-AzureAdAdminRole [-Identity] user@domain.com [-Type Active]
    Returns all active Admin Roles for the provided Identity
  .EXAMPLE
    Get-AzureAdAdminRole [-Identity] user@domain.com -Type Eligible
    Returns all eligible Admin Roles for the provided Identity
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Returns an Object containing all Admin Roles assigned to a User.
    This is intended as an informational for the User currently connected to a specific PS session (whoami and whatcanido)
    The Output can be used as baseline for other functions (-contains "Teams Service Admin")
  .COMPONENT
    UserManagement
  .FUNCTIONALITY
    Queries active or eligible Privileged Identity roles for Administration of Teams
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-AzureAdAdminRole.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Enter the identity of the User to Query')]
    [Alias('UserPrincipalName', 'ObjectId')]
    [string]$Identity,

    [Parameter(HelpMessage = 'Filters the output by Type: All, Eligibe or Active only')]
    [ValidateSet('All', 'Active', 'Eligible')]
    #[ValidateSet('All', 'Active', 'Eligible','Group')]
    [string]$Type = 'All',

    [Parameter(HelpMessage = 'Queries Active Group memberships only. Fast, but limited to direct assignments')]
    [switch]$QueryGroupsOnly

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

    # Validating Module
    try {
      if ( -not (Get-Module AzureAdPreview)) {
        Write-Verbose -Message "Removing Module 'AzureAd', Importing Module 'AzureAdPreview'"
        $SaveVerbosePreference = $global:VerbosePreference;
        $global:VerbosePreference = 'SilentlyContinue';
        Remove-Module AzureAd -Force -ErrorAction SilentlyContinue -Verbose:$false
        Import-Module AzureAdPreview -Global -Force -ErrorAction Stop -Verbose:$false
        $global:VerbosePreference = $SaveVerbosePreference
      }
      $AzureAdPreviewModule = $true
    }
    catch {
      $AzureAdPreviewModule = $false
      if ($QueryGroupsOnly) {
        Write-Information 'Module AzureAdPreview not present or failed to import. No assignment data available. Active Roles can only be determined by AzureAd Group Membership'
      }
      else {
        Write-Error -Message 'Module AzureAdPreview not present or failed to import. Please make sure the Module is installed'
        return
      }
    }

    if ($AzureAdPreviewModule -and -not $QueryGroupsOnly) {
      # Importing all Roles
      Write-Verbose -Message 'Querying Azure Privileged Role Definitions'
      try {
        $ProviderId = 'aadRoles'
        $ResourceId = (Get-AzureADCurrentSessionInfo).TenantId
        $AllRoles = Get-AzureADMSPrivilegedRoleDefinition -ProviderId $ProviderId -ResourceId $ResourceId -ErrorAction Stop
      }
      catch {
        if ($_.Exception.Message.Contains('The tenant needs an AAD Premium 2 license')) {
          Write-Error -Message 'Cannot query role definitions. AzureAd Premium License Required' -ErrorAction Stop
        }
        else {
          Write-Error -Message "Cannot query role definitions. Exception: $($_.Exception.Message)" -ErrorAction Stop
        }
      }
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $Identity) {
      try {
        $AzureAdUser = Get-AzureADUser -ObjectId "$Id" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        [string]$Message = $_ | Get-ErrorMessageFromErrorString
        Write-Warning -Message "User '$Id': GetUser$($Message.Split(':')[1])"
      }

      if ( $AzureAdPreviewModule -and -not $QueryGroupsOnly ) {
        #Querying privileged Admin Roles Assignments
        $SubjectId = $AzureAdUser.ObjectId
        $MyAdminRoles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId $ProviderId -ResourceId $ResourceId -Filter "subjectId eq '$SubjectId'"
        $Scope = 'Privileged'
      }
      if ($QueryGroupsOnly) {
        # Querying active roles only with Group Membership
        $MyMemberships = Get-AzureADUserMembership -ObjectId $AzureAdUser.ObjectId #-All $true #IMPROVE Test Performance and reliability without "all!"
        $MyAdminRoles = $MyMemberships | Where-Object ObjectType -EQ Role
        $Scope = 'Group'
      }
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "Function: $($MyInvocation.MyCommand.Name) - MyAdminRoles ($Scope)", ( $MyAdminRoles | Format-List | Out-String).Trim() | Write-Debug
      }

      [System.Collections.Generic.List[object]]$MyRoles = @()
      foreach ($R in $MyAdminRoles) {
        $Role = @()
        switch ($Scope) {
          'Privileged' {
            # Querying Display Name
            $RoleObject = $AllRoles | Where-Object { $_.Id -eq $R.RoleDefinitionId }
            $Role = [PsCustomObject][ordered]@{
              PSTypeName         = 'PowerShell.Orbit.AzureAdAdminRole.RoleActivationAssignment'
              'User'             = $AzureAdUser.UserPrincipalName
              'Rolename'         = $RoleObject.DisplayName
              'Type'             = $R.MemberType
              'ActiveSince'      = $R.StartDateTime
              'ActiveUntil'      = $R.EndDateTime
              'AssignmentState'  = $R.AssignmentState
              'RoleDefinitionId' = $R.RoleDefinitionId
            }
          }
          'Group' {
            $Role = [PsCustomObject][ordered]@{
              PSTypeName         = 'PowerShell.Orbit.AzureAdAdminRole.RoleActivationAssignment'
              'User'             = $AzureAdUser.UserPrincipalName
              'Rolename'         = $R.DisplayName
              'Type'             = 'Direct' # This may be different once we incorporate Groups too!
              'ActiveSince'      = ''
              'ActiveUntil'      = ''
              'AssignmentState'  = 'Active'
              'RoleDefinitionId' = $R.RoleTemplateId
            }

            # Overriding Type as Group only has active entries
            $Type = 'All'
          }
        }
        [void]$MyRoles.Add($Role)
      }

      # Output
      switch ($Type) {
        'Active' {
          Write-Output $MyRoles | Where-Object AssignmentState -EQ 'Active'
        }
        'Eligible' {
          Write-Output $MyRoles | Where-Object AssignmentState -EQ 'Eligible'
        }
        'All' {
          Write-Output $MyRoles
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-AzureAdAdminRole
