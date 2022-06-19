﻿# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   Martin Heusser
# Updated:  17-APR-2022 v1.0.1
# Status:   Live




function Get-TeamsUserCallFlow {
  <#
    .SYNOPSIS
    Reads the user calling settings of a Teams user and visualizes the call flow using mermaid-js.

    .DESCRIPTION
    Reads the user calling settings of a Teams user and outputs them in an easy to understand SVG diagram. See the script "ExportAllUserCallFlowsToSVG.ps1" in the root of this repo for an example on how to generate a diagram for each user in a tenant.

    Author:             Martin Heusser
    Version:            1.0.1
    Changelog:          Moved to repository at .\Changelog.md

    .PARAMETER Name
    -UserID
        Specifies the identity of the user by an AAD Object Id
        Required:           false
        Type:               string
        Accepted values:    any string
        Default value:      none

    -UserPrincipalName
        Specifies the identity of the user by a upn
        Required:           false
        Type:               string
        Accepted values:    any string
        Default value:      none

    -SetClipBoard
        Specifies if the mermaid code should be copied to the clipboard after the function has been executed.
        Required:           false
        Type:               boolean
        Default value:      false

    -CustomFilePath
        Specifies the file path for the output file.
        Required:           false
        Type:               string
        Accepted values:    file paths e.g. "C:\Temp"
        Default value:      ".\Output\UserCallingSettings"

    -StandAlone
        Specifies if the function is running in standalone mode. This means that the first node (user object ID) will be drawn including the users name. The value $false will only be used when this function is implemented to M365CallFlowVisualizerV2.ps1
        Required:           false
        Type:               bool
        Accepted values:    true, false
        Default value:      true

    -ExportSvg
        Specifies if the function should export the diagram as an SVG image leveraging the mermaid.ink service
        Required:           false
        Type:               bool
        Accepted values:    true, false
        Default value:      true

    -PreviewSvg
        Specifies if the generated diagram should open mermaid.ink in the default browser
        Required:           false
        Type:               bool
        Accepted values:    true, false
        Default value:      true

    -ExportSvg
        Specifies if the function should export the diagram as a markdown file (*.md) NOT YET IMPLEMENTED
        Required:           false
        Type:               bool
        Accepted values:    true, false
        Default value:      false

    .INPUTS
        None.

    .OUTPUTS
        Files:
            - *.svg

    .EXAMPLE
        .\Functions\Get-TeamsUserCallFlow.ps1 -UserPrincipalName user@domain.com

    .LINK
    https://github.com/mozziemozz/M365CallFlowVisualizer

#>

  param (
    [Parameter(Mandatory = $false)][String]$UserId,
    [Parameter(Mandatory = $false)][String]$UserPrincipalName,
    [Parameter(Mandatory = $false)][string]$CustomFilePath,
    [Parameter(Mandatory = $false)][bool]$StandAlone = $true,
    [Parameter(Mandatory = $false)][bool]$ExportMarkdown = $false,
    [Parameter(Mandatory = $false)][bool]$PreviewSvg = $true,
    [Parameter(Mandatory = $false)][bool]$SetClipBoard = $true,
    [Parameter(Mandatory = $false)][bool]$ExportSvg = $true
  )

  #. .\Functions\Connect-M365CFV.ps1

  #. Connect-M365CFV
  Show-FunctionStatus -Level Live
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


  if ($CustomFilePath) {

    $filePath = $CustomFilePath

  }

  else {

    #TEST this may need tweaking as it fails on C:\ - maybe use C:\Temp?
    $filePath = 'C:\Temp\UserCallingSettings'

  }

  if ($UserPrincipalName) {

    $UserId = (Get-CsOnlineUser -Identity $UserPrincipalName).Identity
    $UserId
  }

  $teamsUser = Get-CsOnlineUser -Identity $UserId

  $userCallingSettings = Get-CsUserCallingSettings -Identity $UserId

  $userCallingSettings

  [int]$userUnansweredTimeoutMinutes = ($userCallingSettings.UnansweredDelay).Split(':')[1]
  [int]$userUnansweredTimeoutSeconds = ($userCallingSettings.UnansweredDelay).Split(':')[-1]

  if ($StandAlone) {

    $mdFlowChart = "flowchart TB`n"

    $userNode = "$UserId(User<br> $($teamsUser.DisplayName))"

  }

  else {

    $mdFlowChart = ''

    $userNode = $UserId

  }


  if ($userUnansweredTimeoutMinutes -eq 1) {

    $userUnansweredTimeout = '60 Seconds'

  }

  else {

    $userUnansweredTimeout = "$userUnansweredTimeoutSeconds Seconds"

  }


  # user is neither forwarding or unanswered enabled
  if (!$userCallingSettings.IsForwardingEnabled -and !$userCallingSettings.IsUnansweredEnabled) {

    Write-Host 'User is neither forwaring or unanswered enabled'

    $mdUserCallingSettings = @"
        $userNode
"@

  }

  # user is immediate forwarding enabled
  elseif ($userCallingSettings.ForwardingType -eq 'Immediate') {

    Write-Host 'user is immediate forwarding enabled.'

    switch ($userCallingSettings.ForwardingTargetType) {
      MyDelegates {

        $mdUserCallingSettings = @"
$userNode --> userForwarding$UserId(Immediate Forwarding)
subgraph subgraphSettings$UserId[ ]
userForwarding$UserId --> subgraphDelegates$UserId

"@

        $mdSubgraphDelegates = @"
subgraph subgraphDelegates$UserId[Delegates of $($teamsUser.DisplayName)]
direction LR
ringType$UserId[(Simultaneous Ring)]

"@

        $delegateCounter = 1

        foreach ($delegate in $userCallingSettings.Delegates) {

          $delegateUserObject = (Get-CsOnlineUser -Identity $delegate.Id)

          $delegateRing = "                ringType$UserId -.-> delegate$($delegateUserObject.Identity)$delegateCounter($($delegateUserObject.DisplayName))`n"

          $mdSubgraphDelegates += $delegateRing

          $delegateCounter ++
        }

        $mdUserCallingSettings += $mdSubgraphDelegates

        switch ($userCallingSettings.UnansweredTargetType) {
          Voicemail {
            $mdUnansweredTarget = "--> userVoicemail$UserId(Voicemail<br> $($teamsUser.DisplayName))"
            $subgraphUnansweredSettings = $null
          }
          Group {

            switch ($userCallingSettings.CallGroupOrder) {
              InOrder {
                $ringOrder = 'Serial'
              }
              Simultaneous {
                $ringOrder = 'Simultaneous'
              }
              Default {}
            }

            $subgraphUnansweredSettings = @"
subgraph subgraphCallGroups$UserId[Call Group of $($teamsUser.DisplayName)]
direction LR
callGroupRingType$UserId[($ringOrder Ring)]

"@

            $callGroupMemberCounter = 1

            foreach ($callGroupMember in $userCallingSettings.CallGroupTargets) {

              $callGroupUserObject = (Get-CsOnlineUser -Identity $callGroupMember)

              if ($ringOrder -eq 'Serial') {

                $linkNumber = " |$callGroupMemberCounter|"

              }

              else {

                $linkNumber = $null

              }

              $callGroupRing = "callGroupRingType$UserId -.->$linkNumber callGroupMember$($callGroupUserObject.Identity)$callGroupMemberCounter($($callGroupUserObject.DisplayName))`n"

              $subgraphUnansweredSettings += $callGroupRing

              $callGroupMemberCounter ++
            }

            $subgraphUnansweredSettings += "`nend"

            $mdUnansweredTarget = "--> subgraphCallGroups$UserId"


          }
          SingleTarget {

            if ($userCallingSettings.UnansweredTarget -match 'sip:' -or $userCallingSettings.UnansweredTarget -notmatch '\+') {

              $userForwardingTarget = (Get-CsOnlineUser -Identity $userCallingSettings.UnansweredTarget).DisplayName
              $forwardingTargetType = 'Internal User'

              if ($null -eq $userForwardingTarget) {

                $userForwardingTarget = 'External Tenant'
                $forwardingTargetType = 'Federated User'

              }

            }

            else {

              $userForwardingTarget = $userCallingSettings.UnansweredTarget
              $forwardingTargetType = 'External PSTN'

            }

            $mdUnansweredTarget = "--> userUnansweredTarget$UserId($forwardingTargetType<br> $userForwardingTarget)"
            $subgraphUnansweredSettings = $null

          }
          Default {}
        }

        $mdUserCallingSettingsAddition = @"
end
userForwardingResult$UserId --> |No| userForwardingTimeout$UserId[(Timeout: $userUnansweredTimeout)]
subgraphDelegates$UserId --> userForwardingResult$UserId{Call Answered?}
$subgraphUnansweredSettings
end
userForwardingTimeout$UserId[(Timeout: $userUnansweredTimeout)] $mdUnansweredTarget
userForwardingResult$UserId --> |Yes| userForwardingConnected$UserId((Call Connected))

"@

        $mdUserCallingSettings += $mdUserCallingSettingsAddition

      }
      Voicemail {

        $mdUserCallingSettings = @"
$userNode --> userForwarding$UserId(Immediate Forwarding)
subgraph subgraphSettings$UserId[ ]
userForwarding$UserId --> voicemail$UserId(Voicemail<br> $($teamsUser.DisplayName))
end

"@


      }
      Group {

        switch ($userCallingSettings.CallGroupOrder) {
          InOrder {
            $ringOrder = 'Serial'
          }
          Simultaneous {
            $ringOrder = 'Simultaneous'
          }
          Default {}
        }

        $mdUserCallingSettings = @"
$userNode --> userForwarding$UserId(Immediate Forwarding)
subgraph subgraphSettings$UserId[ ]
userForwarding$UserId --> subgraphCallGroups$UserId

"@

        $mdSubgraphcallGroups = @"
subgraph subgraphCallGroups$UserId[Call Group of $($teamsUser.DisplayName)]
direction LR
ringType$UserId[($ringOrder Ring)]

"@

        $callGroupMemberCounter = 1

        foreach ($callGroupMember in $userCallingSettings.CallGroupTargets) {

          $callGroupUserObject = (Get-CsOnlineUser -Identity $callGroupMember)

          if ($ringOrder -eq 'Serial') {

            $linkNumber = " |$callGroupMemberCounter|"

          }

          else {

            $linkNumber = $null

          }

          $callGroupRing = "ringType$UserId -.->$linkNumber callGroupMember$($callGroupUserObject.Identity)$callGroupMemberCounter($($callGroupUserObject.DisplayName))`n"

          $mdSubgraphcallGroups += $callGroupRing

          $callGroupMemberCounter ++
        }

        $mdUserCallingSettings += $mdSubgraphcallGroups

        $mdUserCallingSettingsAddition = @'
end
end

'@

        $mdUserCallingSettings += $mdUserCallingSettingsAddition




      }
      SingleTarget {

        if ($userCallingSettings.ForwardingTarget -match 'sip:' -or $userCallingSettings.ForwardingTarget -notmatch '\+') {

          $userForwardingTarget = (Get-CsOnlineUser -Identity $userCallingSettings.ForwardingTarget).DisplayName
          $forwardingTargetType = 'Internal User'

          if ($null -eq $userForwardingTarget) {

            $userForwardingTarget = 'External Tenant'
            $forwardingTargetType = 'Federated User'

          }

        }

        else {

          $userForwardingTarget = $userCallingSettings.ForwardingTarget
          $forwardingTargetType = 'External PSTN'

        }


        $mdUserCallingSettings = @"
$userNode --> userForwarding$UserId(Immediate Forwarding)
subgraph subgraphSettings$UserId[ ]
userForwarding$UserId --> userForwardingTarget$UserId($forwardingTargetType<br> $userForwardingTarget)
end

"@

      }
      Default {}
    }

  }

  # user is either forwarding or unansered enabled
  else {

    # user is forwarding and unanswered enabled
    if ($userCallingSettings.IsForwardingEnabled -and $userCallingSettings.IsUnansweredEnabled) {

      Write-Host 'user is forwaring and unanswered enabled'

      switch ($userCallingSettings.UnansweredTargetType) {
        MyDelegates {

          $ringOrder = 'Simultaneous'

          $subgraphUnansweredSettings = @"
subgraph subgraphdelegates$UserId[Delegates of $($teamsUser.DisplayName)]
direction LR
delegateRingType$UserId[($ringOrder Ring)]

"@

          $delegateCounter = 1

          foreach ($delegate in $userCallingSettings.Delegates) {

            $delegateUserObject = (Get-CsOnlineUser -Identity $delegate.Id)

            if ($ringOrder -eq 'Serial') {

              $linkNumber = " |$delegateCounter|"

            }

            else {

              $linkNumber = $null

            }

            $delegateRing = "delegateRingType$UserId -.->$linkNumber delegateMember$($delegateUserObject.Identity)$delegateCounter($($delegateUserObject.DisplayName))`n"

            $subgraphUnansweredSettings += $delegateRing

            $delegateCounter ++
          }

          $subgraphUnansweredSettings += "`nend"

          $mdUnansweredTarget = "--> subgraphdelegates$UserId"


        }

        Voicemail {
          $mdUnansweredTarget = "--> userVoicemail$UserId(Voicemail<br> $($teamsUser.DisplayName))"
          $subgraphUnansweredSettings = $null
        }

        Group {

          if ($userCallingSettings.ForwardingTargetType -eq 'Group') {

            $subgraphUnansweredSettings = $null

            $mdUnansweredTarget = "--> subgraphCallGroups$UserId"

          }

          else {

            switch ($userCallingSettings.CallGroupOrder) {
              InOrder {
                $ringOrder = 'Serial'
              }
              Simultaneous {
                $ringOrder = 'Simultaneous'
              }
              Default {}
            }

            $subgraphUnansweredSettings = @"
subgraph subgraphCallGroups$UserId[Call Group of $($teamsUser.DisplayName)]
direction LR
callGroupRingType$UserId[($ringOrder Ring)]

"@

            $callGroupMemberCounter = 1

            foreach ($callGroupMember in $userCallingSettings.CallGroupTargets) {

              $callGroupUserObject = (Get-CsOnlineUser -Identity $callGroupMember)

              if ($ringOrder -eq 'Serial') {

                $linkNumber = " |$callGroupMemberCounter|"

              }

              else {

                $linkNumber = $null

              }

              $callGroupRing = "callGroupRingType$UserId -.->$linkNumber callGroupMember$($callGroupUserObject.Identity)$callGroupMemberCounter($($callGroupUserObject.DisplayName))`n"

              $subgraphUnansweredSettings += $callGroupRing

              $callGroupCounter ++
            }

            $subgraphUnansweredSettings += "`nend"

            $mdUnansweredTarget = "--> subgraphCallGroups$UserId"


          }


        }
        SingleTarget {

          if ($userCallingSettings.UnansweredTarget -match 'sip:' -or $userCallingSettings.UnansweredTarget -notmatch '\+') {

            $userForwardingTarget = (Get-CsOnlineUser -Identity $userCallingSettings.UnansweredTarget).DisplayName
            $forwardingTargetType = 'Internal User'

            if ($null -eq $userForwardingTarget) {

              $userForwardingTarget = 'External Tenant'
              $forwardingTargetType = 'Federated User'

            }

          }

          else {

            $userForwardingTarget = $userCallingSettings.UnansweredTarget
            $forwardingTargetType = 'External PSTN'

          }

          $mdUnansweredTarget = "--> userUnansweredTarget$UserId($forwardingTargetType<br> $userForwardingTarget)"
          $subgraphUnansweredSettings = $null

        }
        Default {}
      }


      switch ($userCallingSettings.ForwardingTargetType) {
        MyDelegates {

          $mdUserCallingSettings = @"
$userNode --> userForwarding$UserId(Also Ring)
userForwarding$UserId -.-> userParallelRing$userId(Teams Clients<br> $($teamsUser.DisplayName)) ---> userForwardingResult$UserId
userForwarding$UserId -.-> subgraphDelegates$UserId
subgraph subgraphSettings$UserId[ ]

"@

          $mdSubgraphDelegates = @"
subgraph subgraphDelegates$UserId[Delegates of $($teamsUser.DisplayName)]
direction LR
ringType$UserId[(Simultaneous Ring)]

"@

          $delegateCounter = 1

          foreach ($delegate in $userCallingSettings.Delegates) {

            $delegateUserObject = (Get-CsOnlineUser -Identity $delegate.Id)

            $delegateRing = "                ringType$UserId -.-> delegate$($delegateUserObject.Identity)$delegateCounter($($delegateUserObject.DisplayName))`n"

            $mdSubgraphDelegates += $delegateRing

            $delegateCounter ++
          }

          $mdUserCallingSettings += $mdSubgraphDelegates

          $mdUserCallingSettingsAddition = @"
end
userForwardingResult$UserId --> |No| userForwardingTimeout$UserId[(Timeout: $userUnansweredTimeout)]
subgraphDelegates$UserId --> userForwardingResult$UserId{Call Answered?}
$subgraphUnansweredSettings
end
userForwardingTimeout$UserId[(Timeout: $userUnansweredTimeout)] $mdUnansweredTarget
userForwardingResult$UserId --> |Yes| userForwardingConnected$UserId((Call Connected))

"@

          $mdUserCallingSettings += $mdUserCallingSettingsAddition

        }
        Voicemail {

          $mdUserCallingSettings = @"
$userNode --> userForwarding$UserId(Immediate Forwarding)
subgraph subgraphSettings$UserId[ ]
userForwarding$UserId --> voicemail$UserId(Voicemail<br> $($teamsUser.DisplayName))
end

"@


        }
        Group {

          switch ($userCallingSettings.CallGroupOrder) {
            InOrder {
              $ringOrder = 'Serial'
            }
            Simultaneous {
              $ringOrder = 'Simultaneous'
            }
            Default {}
          }

          $mdUserCallingSettings = @"
$userNode --> userForwarding$UserId(Also Ring)
userForwarding$UserId -.-> userParallelRing$userId(Teams Clients<br> $($teamsUser.DisplayName)) ---> userForwardingResult$UserId
userForwarding$UserId -.-> subgraphCallGroups$UserId
subgraph subgraphSettings$UserId[ ]

"@

          $mdSubgraphcallGroups = @"
subgraph subgraphCallGroups$UserId[Call Group of $($teamsUser.DisplayName)]
direction LR
ringType$UserId[($ringOrder Ring)]

"@

          $callGroupMemberCounter = 1

          foreach ($callGroupMember in $userCallingSettings.CallGroupTargets) {

            $callGroupUserObject = (Get-CsOnlineUser -Identity $callGroupMember)

            if ($ringOrder -eq 'Serial') {

              $linkNumber = " |$callGroupMemberCounter|"

            }

            else {

              $linkNumber = $null

            }

            $callGroupRing = "ringType$UserId -.->$linkNumber callGroupMember$($callGroupUserObject.Identity)$callGroupMemberCounter($($callGroupUserObject.DisplayName))`n"

            $mdSubgraphcallGroups += $callGroupRing

            $callGroupMemberCounter ++
          }

          $mdUserCallingSettings += $mdSubgraphcallGroups

          $mdUserCallingSettingsAddition = @"
end
subgraphCallGroups$UserId --> userForwardingResult$UserId{Call Answered?}
$subgraphUnansweredSettings
userForwardingResult$UserId --> |No| userForwardingTimeout$UserId[(Timeout: $userUnansweredTimeout)]
end
userForwardingTimeout$UserId[(Timeout: $userUnansweredTimeout)] $mdUnansweredTarget
userForwardingResult$UserId --> |Yes| userForwardingConnected$UserId((Call Connected))

"@

          $mdUserCallingSettings += $mdUserCallingSettingsAddition




        }
        SingleTarget {

          if ($userCallingSettings.ForwardingTarget -match 'sip:' -or $userCallingSettings.ForwardingTarget -notmatch '\+') {

            $userForwardingTarget = (Get-CsOnlineUser -Identity $userCallingSettings.ForwardingTarget).DisplayName
            $forwardingTargetType = 'Internal User'

            if ($null -eq $userForwardingTarget) {

              $userForwardingTarget = 'External Tenant'
              $forwardingTargetType = 'Federated User'

            }

          }

          else {

            $userForwardingTarget = $userCallingSettings.ForwardingTarget
            $forwardingTargetType = 'External PSTN'

          }


          $mdUserCallingSettings = @"
$userNode --> userForwarding$UserId(Also Ring)
userForwarding$UserId -.-> userParallelRing$userId(Teams Clients<br> $($teamsUser.DisplayName)) ---> userForwardingResult$UserId
userForwarding$UserId -.-> userForwardingTarget$UserId
subgraph subgraphSettings$UserId[ ]
userForwardingTarget$UserId($forwardingTargetType<br> $userForwardingTarget)

"@

          $mdUserCallingSettingsAddition = @"
userForwardingTarget$UserId --> userForwardingResult$UserId{Call Answered?}
$subgraphUnansweredSettings
userForwardingResult$UserId --> |No| userForwardingTimeout$UserId[(Timeout: $userUnansweredTimeout)]
end
userForwardingTimeout$UserId[(Timeout: $userUnansweredTimeout)] $mdUnansweredTarget
userForwardingResult$UserId --> |Yes| userForwardingConnected$UserId((Call Connected))

"@

          $mdUserCallingSettings += $mdUserCallingSettingsAddition


        }

      }

    }

    # user is forwarding enabled but not unanswered enabled
    elseif ($userCallingSettings.IsForwardingEnabled -and !$userCallingSettings.IsUnansweredEnabled) {

      Write-Host 'user is forwarding enabled but not unanswered enabled'

      switch ($userCallingSettings.ForwardingTargetType) {
        Group {

          switch ($userCallingSettings.CallGroupOrder) {
            InOrder {
              $ringOrder = 'Serial'
            }
            Simultaneous {
              $ringOrder = 'Simultaneous'
            }
            Default {}
          }

          $mdUserCallingSettings = @"
$userNode --> userForwarding$UserId(Also Ring)
userForwarding$UserId -.-> userParallelRing$userId(Teams Clients<br> $($teamsUser.DisplayName))
userForwarding$UserId -.-> subgraphCallGroups$UserId
subgraph subgraphSettings$UserId[ ]

"@

          $mdSubgraphcallGroups = @"
subgraph subgraphCallGroups$UserId[Call Group of $($teamsUser.DisplayName)]
direction LR
ringType$UserId[($ringOrder Ring)]

"@

          $callGroupMemberCounter = 1

          foreach ($callGroupMember in $userCallingSettings.CallGroupTargets) {

            $callGroupUserObject = (Get-CsOnlineUser -Identity $callGroupMember)

            if ($ringOrder -eq 'Serial') {

              $linkNumber = " |$callGroupMemberCounter|"

            }

            else {

              $linkNumber = $null

            }

            $callGroupRing = "ringType$UserId -.->$linkNumber callGroupMember$($callGroupUserObject.Identity)$callGroupMemberCounter($($callGroupUserObject.DisplayName))`n"

            $mdSubgraphcallGroups += $callGroupRing

            $callGroupMemberCounter ++
          }

          $mdUserCallingSettings += $mdSubgraphcallGroups

          $mdUserCallingSettingsAddition = @'
    end
    end

'@

          $mdUserCallingSettings += $mdUserCallingSettingsAddition




        }
        SingleTarget {

          if ($userCallingSettings.ForwardingTarget -match 'sip:' -or $userCallingSettings.ForwardingTarget -notmatch '\+') {

            $userForwardingTarget = (Get-CsOnlineUser -Identity $userCallingSettings.ForwardingTarget).DisplayName
            $forwardingTargetType = 'Internal User'

            if ($null -eq $userForwardingTarget) {

              $userForwardingTarget = 'External Tenant'
              $forwardingTargetType = 'Federated User'

            }

          }

          else {

            $userForwardingTarget = $userCallingSettings.ForwardingTarget
            $forwardingTargetType = 'External PSTN'

          }


          $mdUserCallingSettings = @"
$userNode --> userForwarding$UserId(Also Ring)
userForwarding$UserId -.-> userParallelRing$userId(Teams Clients<br> $($teamsUser.DisplayName))
userForwarding$UserId -.-> userForwardingTarget$UserId
subgraph subgraphSettings$UserId[ ]
userForwardingTarget$UserId($forwardingTargetType<br> $userForwardingTarget)
end

"@

        }

      }

    }

    # user is unanswered enabled but not forwarding enabled
    elseif ($userCallingSettings.IsUnansweredEnabled -and !$userCallingSettings.IsForwardingEnabled) {

      Write-Host 'user is unanswered enabled but not forwarding enabled'

      switch ($userCallingSettings.UnansweredTargetType) {
        MyDelegates {

          $ringOrder = 'Simultaneous'

          $subgraphUnansweredSettings = @"
subgraph subgraphdelegates$UserId[Delegates of $($teamsUser.DisplayName)]
direction LR
delegateRingType$UserId[($ringOrder Ring)]

"@

          $delegateCounter = 1

          foreach ($delegate in $userCallingSettings.Delegates) {

            $delegateUserObject = (Get-CsOnlineUser -Identity $delegate.Id)

            if ($ringOrder -eq 'Serial') {

              $linkNumber = " |$delegateCounter|"

            }

            else {

              $linkNumber = $null

            }

            $delegateRing = "delegateRingType$UserId -.->$linkNumber delegateMember$($delegateUserObject.Identity)$delegateCounter($($delegateUserObject.DisplayName))`n"

            $subgraphUnansweredSettings += $delegateRing

            $delegateCounter ++
          }

          $subgraphUnansweredSettings += "`nend"

          $mdUnansweredTarget = "--> subgraphdelegates$UserId"


        }

        Voicemail {
          $mdUnansweredTarget = "--> userVoicemail$UserId(Voicemail<br> $($teamsUser.DisplayName))"
          $subgraphUnansweredSettings = $null
        }

        Group {

          switch ($userCallingSettings.CallGroupOrder) {
            InOrder {
              $ringOrder = 'Serial'
            }
            Simultaneous {
              $ringOrder = 'Simultaneous'
            }
            Default {}
          }

          $subgraphUnansweredSettings = @"
subgraph subgraphCallGroups$UserId[Call Group of $($teamsUser.DisplayName)]
direction LR
callGroupRingType$UserId[($ringOrder Ring)]

"@

          $callGroupMemberCounter = 1

          foreach ($callGroupMember in $userCallingSettings.CallGroupTargets) {

            $callGroupUserObject = (Get-CsOnlineUser -Identity $callGroupMember)

            if ($ringOrder -eq 'Serial') {

              $linkNumber = " |$callGroupMemberCounter|"

            }

            else {

              $linkNumber = $null

            }

            $callGroupRing = "callGroupRingType$UserId -.->$linkNumber callGroupMember$($callGroupUserObject.Identity)$callGroupMemberCounter($($callGroupUserObject.DisplayName))`n"

            $subgraphUnansweredSettings += $callGroupRing

            $callGroupCounter ++
          }

          $subgraphUnansweredSettings += "`nend"

          $mdUnansweredTarget = "--> subgraphCallGroups$UserId"

        }
        SingleTarget {

          if ($userCallingSettings.UnansweredTarget -match 'sip:' -or $userCallingSettings.UnansweredTarget -notmatch '\+') {

            $userForwardingTarget = (Get-CsOnlineUser -Identity $userCallingSettings.UnansweredTarget).DisplayName
            $forwardingTargetType = 'Internal User'

            if ($null -eq $userForwardingTarget) {

              $userForwardingTarget = 'External Tenant'
              $forwardingTargetType = 'Federated User'

            }

          }

          else {

            $userForwardingTarget = $userCallingSettings.UnansweredTarget
            $forwardingTargetType = 'External PSTN'

          }

          $mdUnansweredTarget = "--> userUnansweredTarget$UserId($forwardingTargetType<br> $userForwardingTarget)"
          $subgraphUnansweredSettings = $null

        }
        Default {}
      }

      $mdUserCallingSettings = @"

$userNode --> userParallelRing$userId(Teams Clients<br> $($teamsUser.DisplayName))
subgraph subgraphSettings$UserId[ ]
userParallelRing$userId --> userForwardingResult$UserId{Call Answered?}

"@

      $mdUserCallingSettingsAddition = @"
userForwardingResult$UserId --> |No| userForwardingTimeout$UserId[(Timeout: $userUnansweredTimeout)]
$subgraphUnansweredSettings
end
userForwardingTimeout$UserId[(Timeout: $userUnansweredTimeout)] $mdUnansweredTarget
userForwardingResult$UserId --> |Yes| userForwardingConnected$UserId((Call Connected))

"@

      $mdUserCallingSettings += $mdUserCallingSettingsAddition


    }

  }

  $mdFlowChart += $mdUserCallingSettings

  if ($SetClipBoard) {

    $mdFlowChart | Set-Clipboard

  }

  if ($ExportSvg -or $PreviewSvg) {

    $mdFlowChart = $mdFlowChart.Trim()

    $base64FriendlyFlowChart = @"
$mdFlowChart

"@

    $flowChartBytes = [System.Text.Encoding]::ASCII.GetBytes($base64FriendlyFlowChart)
    $encodedUrl = [Convert]::ToBase64String($flowChartBytes)

    $url = "https://mermaid.ink/svg/$encodedUrl"

  }

  if ($ExportSvg) {

    if (!(Test-Path -Path "$filePath")) {

      New-Item -Path $filePath -ItemType Directory

    }

        (Invoke-WebRequest -Uri $url).Content > "$filePath\UserCallingSettings_$($teamsUser.DisplayName).svg"

  }

  if ($PreviewSvg) {

    Start-Process $url

  }

}
