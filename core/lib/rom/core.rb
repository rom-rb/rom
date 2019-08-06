# frozen_string_literal: true

require 'dry/equalizer'
require 'dry/core/constants'

require 'rom/constants'

# core parts
require 'rom/plugin'
require 'rom/schema_plugin'
require 'rom/relation'
require 'rom/mapper'
require 'rom/processor/transproc'
require 'rom/commands'

# rom Global
require 'rom/global'

# rom configurations
require 'rom/configuration'

# container with registries
require 'rom/container'

# container factory
require 'rom/create_container'

# register known plugin types
require 'rom/schema_plugin'

ROM::Plugins.register(:command)
ROM::Plugins.register(:mapper)
ROM::Plugins.register(:relation)
ROM::Plugins.register(:schema, plugin_type: ROM::SchemaPlugin)
ROM::Plugins.register(:configuration, adapter: false)

# register core plugins
require 'rom/plugins/relation/registry_reader'
require 'rom/plugins/relation/instrumentation'
require 'rom/plugins/command/schema'
require 'rom/plugins/command/timestamps'
require 'rom/plugins/schema/timestamps'

module ROM
  extend Global

  plugins do
    register :timestamps, ROM::Plugins::Schema::Timestamps, type: :schema
    register :registry_reader, ROM::Plugins::Relation::RegistryReader, type: :relation
    register :instrumentation, ROM::Plugins::Relation::Instrumentation, type: :relation
    register :schema, ROM::Plugins::Command::Schema, type: :command
    register :timestamps, ROM::Plugins::Command::Timestamps, type: :command
  end
end
