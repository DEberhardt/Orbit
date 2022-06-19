# Classes defined for all Orbit Modules
# bind them with 'using Module Orbit' in individual scripts

# License Service Plan
class TFTeamsServicePlan {
  [string]$ProductName
  [string]$ServicePlanName
  [ValidatePattern('^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$')]
  [string]$ServicePlanId
  [bool]$RelevantForTeams

  TFTeamsServicePlan(
    [string]$ProductName,
    [string]$ServicePlanName,
    [string]$ServicePlanId,
    [bool]$RelevantForTeams
  ) {
    $this.ProductName = $ProductName
    $this.ServicePlanName = $ServicePlanName
    $this.ServicePlanId = $ServicePlanId
    $this.RelevantForTeams = $RelevantForTeams
  }
}

# License
class TFTeamsLicense {
  [string]$ProductName
  [string]$SkuPartNumber
  [string]$LicenseType
  [string]$ParameterName
  [bool]$IncludesTeams
  [bool]$IncludesPhoneSystem
  [ValidatePattern('^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$')]
  [string]$SkuId
  [object]$ServicePlans

  TFTeamsLicense(
    [string]$ProductName,
    [string]$SkuPartNumber,
    [string]$LicenseType,
    [string]$ParameterName,
    [bool]$IncludesTeams,
    [bool]$IncludesPhoneSystem,
    [string]$SkuId,
    [object]$ServicePlans
  ) {
    $this.ProductName = $ProductName
    $this.SkuPartNumber = $SkuPartNumber
    $this.LicenseType = $LicenseType
    $this.ParameterName = $ParameterName
    $this.IncludesTeams = $IncludesTeams
    $this.IncludesPhoneSystem = $IncludesPhoneSystem
    $this.SkuId = $SkuId
    $this.ServicePlans = $ServicePlans
  }
}

class TFTeamsTenantLicense : TFTeamsLicense {
  [int]$Available
  [int]$Consumed
  [int]$Remaining
  [int]$Expiring

  TFTeamsTenantLicense(
    [string]$ProductName,
    [string]$SkuPartNumber,
    [string]$LicenseType,
    [string]$ParameterName,
    [bool]$IncludesTeams,
    [bool]$IncludesPhoneSystem,
    [string]$SkuId,
    [object]$ServicePlans,
    [int]$Available,
    [int]$Consumed,
    [int]$Remaining,
    [int]$Expiring
  ) : base (
    $ProductName,
    $SkuPartNumber,
    $LicenseType,
    $ParameterName,
    $IncludesTeams,
    $IncludesPhoneSystem,
    $SkuId,
    $ServicePlans
  ) {
    $this.Available = $Available
    $this.Consumed = $Consumed
    $this.Remaining = $Remaining
    $this.Expiring = $Expiring
  }
}

# Callable Entity
class TFCallableEntity {
  [string]$Entity
  [string]$Identity
  [string]$ObjectType
  [string]$Type

  TFCallableEntity(
    [string]$Entity,
    [string]$Identity,
    [string]$ObjectType,
    [string]$Type
  ) {
    $this.Entity = $Entity
    $this.Identity = $Identity
    $this.ObjectType = $ObjectType
    $this.Type = $Type
  }
}

# Callable Entity Connection (to CQ/AA)
class TFCallableEntityConnection {
  [string]$Identity
  [string]$LinkedAs
  [string]$Type
  [string]$Name
  [string]$ObjectId

  TFCallableEntityConnection(
    [string]$Identity,
    [string]$LinkedAs,
    [string]$Type,
    [string]$Name,
    [string]$ObjectId
  ) {
    $this.Identity = $Identity
    $this.LinkedAs = $LinkedAs
    $this.Type = $Type
    $this.Name = $Name
    $this.ObjectId = $ObjectId
  }
}
