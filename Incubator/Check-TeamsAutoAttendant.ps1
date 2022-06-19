# Idea: Check-TeamsAA
<#
Verify whether all resource Accounts connected to the AA (or CQ?) have their requirements met

Similar to Find-TeamsCallableEntity, though the type is External PSTN and if found on any object,
verify that Phone Number and OVP are assigned.

License req. must be fulfilled, as a Number can only be assigned to the RA if Licensed.
Check whether a Nr. and a License are there if ExternalPSTN objects are found.

Feedback warning if no number is assigned ("internal only")
Feedback error if no License is assigned (must be licensed)

#>