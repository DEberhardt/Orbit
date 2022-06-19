# Module:     TeamsFunctions
# Function:   UserAdmin
# Author:     David Eberhardt
# Updated:    13-JUN-2021
# Status:     Live




function Disable-AzureAdAdminRole {
  <#
  .SYNOPSIS
    Disables active Admin Roles
  .DESCRIPTION
    Azure Ad Privileged Identity Management can require you to activate Admin Roles.
    Active roles or groups can be deactivated with this Command
  .PARAMETER Identity
    Username of the Admin Account to disable roles for
  .PARAMETER Reason
    Optional. Small statement why these roles are disabled
    By default, "Administration finished" is used as the reason.
  .PARAMETER ProviderId
    Optional. Default is 'aadRoles' for the ProviderId, however, this script could also be used for activating
    Azure Resources ('azureResources'). Use with Confirm and EnableAll.
  .PARAMETER PassThru
    Optional. Displays output object for each activated Role
    Used for further processing to verify command was successful
  .EXAMPLE
    Disable-AzureAdAdminRole John@domain.com
    Disables all active Teams Admin roles for User John@domain.com
  .EXAMPLE
    Disable-AzureAdAdminRole John@domain.com -Reason "Finished"
    Disables all active Admin roles for User John@domain.com with the reason provided.
  .INPUTS
    System.String
  .OUTPUTS
    System.Void - Default Behaviour
    System.Object - With Switch PassThru
    Boolean - If called by other CmdLets
  .NOTES
    Limitations: MFA must be authorised first
    Currently no way to trigger it via PowerShell. If the activation fails, please sign into Office.com
    Once Authorised, this command can be used to activate your eligible Admin Roles.
    AzureResources provider activation is not yet tested.

    Thanks to Nathan O'Bryan, MVP|MCSM - nathan@mcsmlab.com for inspiring this script through Activate-PIMRole.ps1
  .COMPONENT
    UserManagement
  .FUNCTIONALITY
    Disables active Privileged Identity roles
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Disable-AzureAdAdminRole.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([Void])]

  param(
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Enter the identity of the Admin Account')]
    [Alias('UserPrincipalName', 'ObjectId')]
    [string]$Identity,

    [Parameter(HelpMessage = 'Optional Reason for the request')]
    [string]$Reason,

    [Parameter(HelpMessage = 'Azure ProviderId to be used')]
    [ValidateSet('aadRoles', 'azureResources')]
    [string]$ProviderId = 'aadRoles',

    [Parameter(HelpMessage = 'Displays output of activated roles to verify')]
    [switch]$PassThru,

    [Parameter(HelpMessage = 'Overrides confirmation dialog and enables all eligible roles')]
    [switch]$Force

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    #$Stack = Get-PSCallStack
    #$Called = ($stack.length -ge 3)

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
    }
    catch {
      Write-Error -Message 'Module AzureAdPreview not present or failed to import. Please make sure the Module is installed and correctly loaded'
      return
    }

    # preparing Splatting Object
    $Parameters = $null
    $Parameters += @{'ErrorAction' = 'Stop' }

    #region Supporting Parameters
    # Duration
    $Duration = 0
    # Duration is used in $Schedule

    # Reason & Ticket Number
    if ( -not $Reason ) { $Reason = 'Administration' }
    if ( $TicketNr ) {
      #IMPROVE TicketNr is not available yet
      #$Parameters += @{'$TicketNr' = $TicketNr }
      $Reason = "Ticket: $TicketNr - $Reason"
    }
    $Parameters += @{'Reason' = $Reason }

    # ProviderId is hardcoded (or overridden by providing a value)
    Write-Verbose -Message "Using Azure Provider Id: $ProviderId"
    $Parameters += @{'ProviderId' = $ProviderId }

    # ResourceId - is the Tenant Id
    Write-Verbose -Message 'Querying Azure Tenant Id'
    $ResourceId = (Get-AzureADCurrentSessionInfo).TenantId
    $Parameters += @{'ResourceId' = $ResourceId }

    # Assignment state is always Active
    $Parameters += @{'AssignmentState' = 'Active' }

    # Importing all Roles
    Write-Verbose -Message 'Querying Azure Privileged Role Definitions'
    try {
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

    # Defining Schedule
    Write-Verbose -Message "Creating Schedule based on Duration: $Duration hours"
    $Date = Get-Date
    $start = $Date.ToUniversalTime()
    $end = $Date.AddHours($Duration).ToUniversalTime()

    $schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
    $schedule.Type = 'Once'
    $schedule.StartDateTime = $start.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    $schedule.endDateTime = $end.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    Write-Verbose -Message "Admin Roles will be active for $Duration hours, until: $($end.ToString())"
    $Parameters += @{'Schedule' = $schedule }
    #endregion

    # Identity is not mandatory, using connected Session
    if ( -not $PSBoundParameters.ContainsKey('Identity') ) {
      $Identity = (Get-AzureADCurrentSessionInfo).Account.Id
      Write-Information "INFO:    No Identity Provided, using user currently connected to AzureAd: '$Identity'"
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $Identity) {
      # Querying User Account
      Write-Verbose -Message "Processing User '$Id'"
      try {
        $SubjectId = (Get-AzureADUser -ObjectId "$Id" -WarningAction SilentlyContinue -ErrorAction STOP).ObjectId

        # Adding SubjectId to Parameters
        if ($Parameters.SubjectId) {
          $Parameters.SubjectId = $SubjectId
        }
        else {
          $Parameters += @{'SubjectId' = $SubjectId }
        }
      }
      catch {
        Write-Error -Message 'User Account not valid' -Category ObjectNotFound -RecommendedAction 'Verify Identity/UserPrincipalName'
        continue
      }

      # Query current Admin Roles

      <# Commented out for Admin Groups are not yet available via PowerShell
      $TenantRoles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId $ProviderId -ResourceId $ResourceId #-Filter "subjectId eq '$SubjectId'"
      $MyEligibleGroups = $TenantRoles | Where-Object MemberType -EQ "Group"
      $MyRoles = $TenantRoles | Where-Object SubjectId -EQ $SubjectId
      #>
      $MyRoles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId $ProviderId -ResourceId $ResourceId -Filter "subjectId eq '$SubjectId'"


      $MyActiveRoles = $MyRoles | Where-Object AssignmentState -EQ 'Active'
      $MyEligibleRoles = $MyRoles | Where-Object AssignmentState -EQ 'Eligible'
      Write-Verbose -Message "User '$Id' has currently $($MyActiveRoles.Count) of $($MyEligibleRoles.Count) activated"

      [System.Collections.ArrayList]$RolesAndGroups = @()
      <# Commented out for Admin Groups are not yet available via PowerShell
      if ($MyEligibleGroups.Count -eq 0) {
        Write-Verbose -Message "User '$Id' - No Privileged Access Groups are available that can be activated."
      #>
      if ($MyActiveRoles.Count -eq 0) {
        Write-Warning -Message "User '$Id' - No active Privileged Access Roles availabe! - Privileged Access Groups must be enabled via Admin Center/PIM: https://aka.ms/myroles"
        continue
      }
      else {
        # Adding Roles
        foreach ($Role in $MyActiveRoles) {
          [void]$RolesAndGroups.Add($Role)
        }
      }

      # DeActivating Role
      [System.Collections.ArrayList]$DeactivatedRoles = @()

      foreach ($R in $RolesAndGroups) {
        # Querying Role Display Name
        $RoleName = $AllRoles | Where-Object { $_.Id -eq $R.RoleDefinitionId } | Select-Object -ExpandProperty DisplayName

        # Confirm every role if not Force
        if ($PSCmdlet.ShouldProcess("$RoleName")) {
          if (-not ($Force -or $PSCmdlet.ShouldContinue("Eligible Role '$RoleName' found - Activate Role?", 'Enable-AzureAdAdminRole'))) {
            continue # user replied no
          }
          else {

            # Preparing Output object
            $DeactivatedRole = @()
            $DeactivatedRole = [PsCustomObject][ordered]@{
              'User'        = $Id
              'Rolename'    = $RoleName
              'Type'        = $null
              'ActiveUntil' = $null
            }

            # Adding Role Definition Id
            if ($Parameters.RoleDefinitionId) {
              $Parameters.RoleDefinitionId = $R.RoleDefinitionId
            }
            else {
              $Parameters += @{'RoleDefinitionId' = $R.RoleDefinitionId }
            }

            # Determining Activation Type (UserAdd VS UserRenew)
            <#
            The value for the Request type can be AdminAdd, UserAdd, AdminUpdate, AdminRemove, UserRemove, UserExtend, UserRenew, AdminRenew and AdminExtend.
            more options could be provided than UserExtend (Request) and UserAdd. Bears investigation
            #>
            if ( $R.RoleDefinitionId -in $MyActiveRoles.RoleDefinitionId ) {
              Write-Verbose -Message "User '$Id' - '$RoleName' is active and will be deactivated"
              $DeactivatedRole.Type = 'UserRemove'
              if ($Parameters.Type) {
                $Parameters.Type = 'UserRemove'
              }
              else {
                $Parameters += @{'Type' = 'UserRemove' }
              }
            }

            #Deactivating the Role
            try {
              Write-Verbose -Message "User '$Id' - '$RoleName' - Deactivating Role"
              $DeactivatedRole.ActiveUntil = $schedule.endDateTime
              if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
                "Function: $($MyInvocation.MyCommand.Name) - Parameters for Open-AzureADMSPrivilegedRoleAssignmentRequest", ( $Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
              }
              $null = Open-AzureADMSPrivilegedRoleAssignmentRequest @Parameters
              [void]$DeactivatedRoles.Add($DeactivatedRole)
            }
            catch {
              Write-Error -Message $_.Exception.Message
            }
          }
        }
      }

    }

    # Re-Query and output (for all Users!)
    if ( $PassThru ) {
      return $DeactivatedRoles
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Disable-AzureAdAdminRole
