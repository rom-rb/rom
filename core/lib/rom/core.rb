require 'dry-equalizer'
require 'dry/core/constants'

require 'rom/version'
require 'rom/constants'

module ROM
  include Dry::Core::Constants
end

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
require 'rom/plugins/configuration/configuration_dsl'
require 'rom/plugins/relation/registry_reader'
require 'rom/plugins/relation/instrumentation'
require 'rom/plugins/command/schema'

module ROM
  extend Global

  plugins do
    register :macros, ROM::ConfigurationPlugins::ConfigurationDSL, type: :configuration
    register :registry_reader, ROM::Plugins::Relation::RegistryReader, type: :relation
    register :instrumentation, ROM::Plugins::Relation::Instrumentation, type: :relation
    register :schema, ROM::Plugins::Command::Schema, type: :command
  end
end
