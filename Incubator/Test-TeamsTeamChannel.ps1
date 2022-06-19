#IDEA:
#Get-Team & Get-TeamChannel with friendly names
# Use for CQs and AAs when Forward to Channel is used
#REGEX -match "^(19:)[0-9a-f]{32}(@thread.)(skype|tacv2|([0-9a-z]{5}))$" Alternative to name to pinpoint channel!

function Test-TeamsTeamChannel {

  param (
    [Parameter(Mandatory, HelpMessage = 'DisplayName of the Team')]
    [string]$Team,

    [Parameter(Mandatory, HelpMessage = 'DisplayName of the Channel')]
    [string]$Channel
  )

  #Breakout as Test-TeamsTeam and Assert-TeamsTeam too! #Spike with object input $Team.GroupId matches
  if ($Team -match "^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$") {
    $TeamObj = Get-Team -GroupId $Team
  }
  else {
    $TeamObj = Get-Team -DisplayName "$Team"
  }

  try {
    if ($Channel -match "^(19:)[0-9a-f]{32}(@thread.)(skype|tacv2|([0-9a-z]{5}))$") {
      $null = $TeamObj | Get-TeamChannel | Where-Object Id -eq "$Channel" -ErrorAction Stop
    }
    else {
      $null = $TeamObj | Get-TeamChannel | Where-Object DisplayName -eq "$Channel" -ErrorAction Stop
    }
    return $true
  }
  catch {
    return $false
  }

}
