# frozen_string_literal: true

# register core plugins
require "rom/plugins"

# global interface
require "rom/global"

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
