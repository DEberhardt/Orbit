# Module:   TeamsFunctions
# Function: UserVoiceConfig
# Author:	  David Eberhardt
# Updated:  20-JUN-2021
# Status:   Alpha


# Rework to only include Language related settings? Set-TeamsUserVoiceMailLanguage

function Set-TeamsUserVoiceMail {
  <#
  .SYNOPSIS
    Sets Voicemail Settings for a Teams User
  .DESCRIPTION
    Applies a Teams Voice Users Voicemail settings
  .PARAMETER UserPrincipalName
    Required. UserPrincipalName (UPN) of the User to change the configuration for
  .PARAMETER LanguageId
    Language ID to set the Voicemail greeting to.
  .PARAMETER PassThru
    Optional. Displays Object after action.
  .PARAMETER Force
    By default, this script only applies the Users Voicemail settings. Force overwrites configuration regardless of current status.
    Force also ensures HostedVoicemail is enabled (a Warning is displayed if not enabled otherwise)
    Additionally Suppresses confirmation inputs except when $Confirm is explicitly specified
  .EXAMPLE
    Set-TeamsUserVoiceMail -Identity John@domain.com
    xx
  .EXAMPLE
    Set-TeamsUserVoiceMail -Identity John@domain.com -LanguageId en-IN
    Sets the Language interpreter to English India - The provided language is
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    xx
  .COMPONENT
    xx
  .ROLE
    xx
  .FUNCTIONALITY
    xx
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsUserVoiceMail.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfig.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('Set=TeamsUVM')]
  [OutputType([System.Void])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ValueFromPipeline, HelpMessage = 'UserPrincipalName of the User')]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(HelpMessage = 'Language Identifier from Get-CsAutoAttendantSupportedLanguage.')]
    [ValidateScript( { $_ -in (Get-CsAutoAttendantSupportedLanguage).Id })]
    [string]$LanguageId = 'en-US',

    [Parameter(HelpMessage = 'Enables Voicemail')]
    [bool]$VoicemailEnabled,

    [Parameter(HelpMessage = 'Suppresses confirmation prompt unless -Confirm is used explicitly')]
    [switch]$Force,

    [Parameter(HelpMessage = 'No output is written by default, Switch PassThru will return changed object')]
    [switch]$PassThru
  )

  begin {
    Show-FunctionStatus -Level Alpha
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }


    # Language has to be normalised as the Id is case sensitive. Default value: en-US
    if ( $PSBoundParameters.ContainsKey('LanguageId' )) {
      $Language = $($LanguageId.Split('-')[0]).ToLower() + '-' + $($LanguageId.Split('-')[1]).ToUpper()
      Write-Verbose "LanguageId '$LanguageId' normalised to '$Language'"
      $VoiceResponsesSupported = (Get-CsAutoAttendantSupportedLanguage -Id $Language).VoiceResponseSupported
    }
    else {
      $Language = $null
    }

    if ( -not $VoiceResponsesSupported ) {
      Write-Error -Message 'selected Language does not support Voice Responses'
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($User in $UserPrincipalName) {
      Write-Verbose -Message "[PROCESS] Processing '$User'"
      # Querying Identity
      try {
        Write-Verbose -Message "User '$User' - Querying User Account (CsOnlineUser)"
        $CsUser = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        Write-Error -Message "User '$User' not found. Error encountered: $($_.Exception.Message)" -Category ObjectNotFound
        continue
      }

      # Defining Object
      $CsOnlineVoicemailUserSettings = $null
      $CsOnlineVoicemailUserSettings = @{
        'Identity'         = $CsUser.ObjectId
        'Force'            = if ($Force) { $TRUE } else { $FALSE }
        'ErrorAction'      = 'Stop'
      }

      #region Enable Voicemail and Hostedvoicemail (if not enabled, enabling with -Force)
      if ( -not $CsUser.HostedVoiceMail ) {
        if ($Force -or $PSCmdlet.ShouldProcess('HostedVoicemail', 'Set-CsOnlineUser')) {
          $CsUser | Set-CsUser -HostedVoiceMail $TRUE -ErrorAction Stop
          Write-Information "SUCCESS: User '$User' - HostedVoiceMail enabled"
        }
        else {
          Write-Warning -Message "User '$User' - HostedVoiceMail is not enabled on the CsOnlineUser Object!"
        }
      }
      else {
        Write-Verbose -Message "User '$User' - HostedVoiceMail enabled already"
      }

      # Settings
      if ( $PSBoundParameters.ContainsKey('VoicemailEnabled' )) {
        $CsOnlineVoicemailUserSettings += @{ 'VoicemailEnabled' = $VoicemailEnabled }
      }
      #endregion

      #region Settings
      #region Language
      #BODGE This is not suitable to do if more than one parameters is potentially to be applied!
      <#
      if ( -not $Language ) {
        # set VM greeting language (to Tenant Dial Plan or DP/Usage Location?)
        Write-Verbose -Message "User '$User' - Language - Testing Supported Language exists from Users DialPlan (Usage Location)"
        $LanguageByDialPlan = Get-CsAutoAttendantSupportedLanguage | Where-Object Id -Like "*-$($User.DialPlan)" | Select-Object -First 1
        if ($LanguageByDialPlan) {
          $Language = $LanguageByDialPlan.Id
          Write-Verbose -Message "User '$User' - Language - Selected Language: '$Language'"
        }
        else {
          Write-Error -Message 'No Suitable supported language found to assign. Please use Switch Language to define Voicemail Language'
          continue
        }
      }
      #>
      if ( $Language ) {
        $CsOnlineVoicemailUserSettings += @{ 'PromptLanguage' = "$Language" }
      }
      if ( $Force ) {
        $CsOnlineVoicemailUserSettings += @{ 'Force' = $TRUE }
      }

      #endregion

      # other settings?


      #region Setting Users Voicemail Settings - language
      Write-Verbose -Message "[PROCESS] User '$($CsUser.DisplayName)' - Setting Voicemail language"
      #NOTE this could do more, but do not want to write a full wrapper for the CsOnlineVoicemailUserSettings yet.
      $CsOnlineVoicemailUserSettings = @{
        'Identity'         = $CsUser.ObjectId
        'VoicemailEnabled' = $TRUE
        'PromptLanguage'   = "$Language"
        'Force'            = if ($Force) { $TRUE } else { $FALSE } # Add here or
        'ErrorAction'      = 'Stop'
      }
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "Function: $($MyInvocation.MyCommand.Name): CsOnlineVoicemailUserSettings:", ($CsOnlineVoicemailUserSettings | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }
      if ($Force -or $PSCmdlet.ShouldProcess("$($CsUser.DisplayName)", 'Set-CsOnlineVoicemailUserSettings')) {
        try {
          # Create the Auto Attendant with all enumerated Parameters passed through splatting
          #TEST what output is received - if object is returned, can use that instead of manually using PassThru (and integrate PassThru into $CsOnlineVoicemailUserSettings)
          $null = Set-CsOnlineVoicemailUserSettings @CsOnlineVoicemailUserSettings
          if ($Called) {
            Write-Information "INFO:    User '$($CsUser.DisplayName)' Voicemail language set to '$Language'"
          }
        }
        catch {
          Write-Error -Message "Error setting Voicemail language : $($_.Exception.Message)" -Category InvalidResult
          continue
        }
      }
      else {
        continue
      }
      #endregion


      # Output
      if ( $PassThru -or $stack.length -lt 3) {
        # Re-Query Object
        #Write-Verbose -Message 'Waiting 3-5s for Office 365 to write changes to User Voicemail Object'
        #Start-Sleep -Seconds 3
        $UserVoicemailObjectPost = Get-CsOnlineVoicemailUserSettings -Identity $User -InformationAction SilentlyContinue -WarningAction SilentlyContinue
        return $UserVoicemailObjectPost
      }
      else {
        return
      }

    } #foreach Identity

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Set-TeamsUserVoiceMail
