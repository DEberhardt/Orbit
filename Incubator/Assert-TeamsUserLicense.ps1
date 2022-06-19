#Idea: Assert-TeamsUserLicense
# Input: UPN, type of Service (DirectRouting/CallingPlans)
# Input: Enable Pipeline for UPN
# Set: Default to DirectRouting?
# Add: Switch "CallingPlans": Checking against any DOM/INT calling plan (Add Switch for CommunicationCredits?)
# Add: Switch "DirectRouting": https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating (Licenses)
# Add: Switch to output Object/Table with all tests preformed everything (seeing what is assigned)
# Add: Verbose output for every step (each tested Plan)
# Output: BOOLEAN: True/False Output: Pass/Fail

$UPNs = @('...')
foreach ($U in $UPNs) {
  $Output = [PSCustomObject][ordered]@{
    "UserPrincipalName" = $U
    "MCOSTANDARD"       = $(Test-TeamsUserLicense -Identity $U -ServicePlan "MCOSTANDARD")
    "MCOPROFESSIONAL"   = $(Test-TeamsUserLicense -Identity $U -ServicePlan "MCOPROFESSIONAL")
    "MCOEV"             = $(Test-TeamsUserLicense -Identity $U -ServicePlan "MCOEV")
    "TEAMS1"            = $(Test-TeamsUserLicense -Identity $U -ServicePlan "TEAMS1")
  }
  $Output | Export-Csv C:\Temp\CHNusers.csv -Append
}
