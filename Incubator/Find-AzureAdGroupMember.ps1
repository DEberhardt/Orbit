
# Find-AzureAdGroup by name, then run
Get-AzureADGroupMember -ObjectId $User.ObjectId | Select-Object ObjectType, DisplayName, UserPrincipalName
