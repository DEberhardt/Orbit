# Module:   Orbit
# Function: Test
# Author:		David Eberhardt
# Updated:  28-JUN-2022

$Function = $MyInvocation.MyCommand.Name -Replace '.tests.ps1', ''
$Module = "Orbit"

InModuleScope $Module {
  Describe -Tags ('Unit', 'Acceptance') "Function '$Function'" {

    It 'Should be $true' {
      $true | Should -BeTrue

    }
  }
}
