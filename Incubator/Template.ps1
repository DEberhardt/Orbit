# Module:   TeamsFunctions
# Function:
# Author:	  David Eberhardt
# Updated:  xx-xxxx-2021
# Status:   Alpha




function Verb-Noun {
  <#
  .SYNOPSIS
    Short description
  .DESCRIPTION
    Long description
  .PARAMETER Identity
    x
  .PARAMETER x
    x
  .EXAMPLE
    Verb-Noun -Identity John@domain.com
    xx
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
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Verb-Noun.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsFunctions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'Username(s)')]
    [Alias('', '')]
    [string[]]$Identity,

    [Parameter(HelpMessage = '')]
    [Alias('')]
    [String]$x

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


  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $Identity) {
      Write-Verbose -Message "[PROCESS] Processing '$Id'"

      #region Applying settings
      Write-Verbose -Message "[PROCESS] User '$($CsUser.DisplayName)' - Action"
      $Parameters = @{
        'Identity'       = $CsUser.ObjectId
        'PromptLanguage' = $Language
        'ErrorAction'    = 'Stop'
      }
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "Function: $($MyInvocation.MyCommand.Name): Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }
      if ($PSCmdlet.ShouldProcess("$($CsUser.DisplayName)", 'Set-Parameters')) {
        try {
          #TEST what output is received before throwing it away
          $null = Set-Command @Parameters
          if ($Called) {
            Write-Information "INFO:    User '$($CsUser.DisplayName)' Action successful"
          }
        }
        catch {
          Write-Error -Message "Error action unsuccessful : $($_.Exception.Message)" -Category InvalidResult
          continue
        }
      }
      else {
        continue
      }
      #endregion

    } #foreach Identity

    if ($stack.length -lt 3) {
      Write-Verbose -Message ''
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Verb-Noun
