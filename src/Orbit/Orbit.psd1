#
# Module manifest for module 'Orbit'
#
# Generated by: David Eberhardt
#
# Generated on: Sun 19 Jun 2022
#


@{

  # Script module or binary module file associated with this manifest.
  # RootModule = ''

  # Version number of this module.
  ModuleVersion     = '0.0.0.0'

  # Supported PSEditions
  # CompatiblePSEditions = @()

  # ID used to uniquely identify this module
  GUID              = '40904cce-3fe1-4198-a187-06179f4e108b'

  # Author of this module
  Author            = 'David Eberhardt'

  # Company or vendor of this module
  CompanyName       = 'None / Personal'

  # Copyright statement for this module
  Copyright         = '(c) 2022 David Eberhardt. All rights reserved.'

  # Description of the functionality provided by this module
  Description       = 'Scripts & Functions for Administrators working with Microsoft.Graph, MicrosoftTeams covering Resource Accounts, Call Queues, Auto Attendants, Licensing, User Voice Configuration and more.
For more information, please visit https://github.com/DEberhardt/Orbit or https://davideberhardt.wordpress.com/'

  # Minimum version of the Windows PowerShell engine required by this module
  PowerShellVersion = '5.1'

  # Name of the Windows PowerShell host required by this module
  # PowerShellHostName = ''

  # Minimum version of the Windows PowerShell host required by this module
  # PowerShellHostVersion = ''

  # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  # DotNetFrameworkVersion = ''

  # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  # CLRVersion = ''

  # Processor architecture (None, X86, Amd64) required by this module
  # ProcessorArchitecture = ''

  # Modules that must be imported into the global environment prior to importing this module
  RequiredModules   = @(
    @{ModuleName = 'MicrosoftTeams'; ModuleVersion = '4.2.0'; } #,
    #@{ModuleName = 'Microsoft.Graph'; ModuleVersion = '1.9.6'; },
    #@{ModuleName = 'Orbit.Authentication'; RequiredVersion = '1.0.0.0'; },
    #@{ModuleName = 'Orbit.Groups'; RequiredVersion = '1.0.0.0'; },
    #@{ModuleName = 'Orbit.Teams'; RequiredVersion = '1.0.0.0'; },
    #@{ModuleName = 'Orbit.Tools'; RequiredVersion = '1.0.0.0'; },
    #@{ModuleName = 'Orbit.Users'; RequiredVersion = '1.0.0.0'; }
  )
  # Assemblies that must be loaded prior to importing this module
  # RequiredAssemblies = @()

  # Script files (.ps1) that are run in the caller's environment prior to importing this module.
  # ScriptsToProcess = @()

  # Type files (.ps1xml) to be loaded when importing this module
  # TypesToProcess = @()

  # Format files (.ps1xml) to be loaded when importing this module
  # FormatsToProcess = @()

  # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
  # NestedModules = @()

  # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
  FunctionsToExport = '*'

  # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
  CmdletsToExport   = @()

  # Variables to export from this module
  VariablesToExport = '*'

  # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
  AliasesToExport   = @()

  # DSC resources to export from this module
  # DscResourcesToExport = @()

  # List of all modules packaged with this module
  # ModuleList = @()

  # List of all files packaged with this module
  # FileList = @()

  # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
  PrivateData       = @{

    PSData = @{

      # Tags applied to this module. These help with module discovery in online galleries.
      Tags         = @('Office365', 'M365', 'Graph', 'Teams', 'DirectRouting', 'Licensing', 'ResourceAccount', 'CallQueue', 'AutoAttendant', 'VoiceConfig', 'CommonAreaPhone')

      # A URL to the license for this module.
      LicenseUri   = 'https://github.com/DEberhardt/Orbit/blob/master/LICENSE'

      # A URL to the main website for this project.
      ProjectUri   = 'https://github.com/DEberhardt/Orbit'

      # A URL to an icon representing this module.
      # IconUri = ''

      # ReleaseNotes of this module
      ReleaseNotes = 'https://github.com/DEberhardt/Orbit/blob/master/VERSION.md'

    } # End of PSData hashtable

  } # End of PrivateData hashtable

  # HelpInfo URI of this module
  # HelpInfoURI = ''

  # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
  # DefaultCommandPrefix = ''

}
