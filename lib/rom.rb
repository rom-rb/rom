require 'equalizer'

require 'rom-support'
require 'rom/version'
require 'rom/constants'

# internal ROM support lib
require 'rom/support/inflector'
require 'rom/support/registry'
require 'rom/support/options'
require 'rom/support/class_macros'
require 'rom/support/class_builder'
require 'rom/support/guarded_inheritance_hook'
require 'rom/support/inheritance_hook'

# core parts
require 'rom/configuration_plugin'
require 'rom/plugin'
require 'rom/relation'
require 'rom-mapper'
require 'rom/commands'

# rom Global
require 'rom/global'

# rom configurations
require 'rom/configuration'

# container with registries
require 'rom/container'

# container factory
require 'rom/create_container'

# register core plugins
require 'rom/plugins/configuration/auto_registration'
require 'rom/plugins/configuration/configuration_dsl'
require 'rom/plugins/relation/registry_reader'

module ROM
  extend Global
  
  plugins do
    register :auto_registration, ROM::ConfigurationPlugins::AutoRegistration, type: :configuration
    register :macros, ROM::ConfigurationPlugins::ConfigurationDSL, type: :configuration
    register :registry_reader, ROM::Plugins::Relation::RegistryReader, type: :relation
  end
end
