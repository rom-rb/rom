# frozen_string_literal: true

# Global interface
require_relative "global"

# Global default settings
require_relative "settings"

# Core components
require_relative "components/gateway"
require_relative "components/dataset"
require_relative "components/schema"
require_relative "components/relation"
require_relative "components/association"
require_relative "components/command"
require_relative "components/mapper"

# Core plugins
require_relative "plugins"

# Global ROM interface for core setup
#
# @api public
module ROM
  extend Global
  extend self

  # Global component setup
  #
  # @example
  #   ROM.components do
  #     register :cache, handler: MyApp::MyCacheHandler
  #   end
  #
  # @api public
  def components(&block)
    if defined?(@_components)
      @_components.instance_eval(&block) if block
      @_components
    else
      require_relative "components"
      @_components = Components
      components(&block)
    end
  end

  # Register core component handlers
  components do
    register :gateway, Components::Gateway
    register :dataset, Components::Dataset
    register :schema, Components::Schema
    register :relation, Components::Relation
    register :association, Components::Association
    register :command, Components::Command
    register :mapper, Components::Mapper
  end

  # TODO: this will be automated eventually
  require_relative "relation"
  require_relative "schema"
  require_relative "command"
  require_relative "mapper"

  configs = {
    schema: ROM::Schema,
    relation: ROM::Relation,
    command: ROM::Command,
    mapper: ROM::Mapper
  }

  configs.each do |key, constant|
    constant.config.component.inherit!(config.component)
    config[key].inherit!(constant.config.component)
  end

  configs.each_value(&:configure)

  # Register core plugins
  plugins do
    register :timestamps, ROM::Plugins::Schema::Timestamps, type: :schema
    register :registry_reader, ROM::Plugins::Relation::RegistryReader, type: :relation
    register :instrumentation, ROM::Plugins::Relation::Instrumentation, type: :relation
    register :schema, ROM::Plugins::Command::Schema, type: :command
    register :timestamps, ROM::Plugins::Command::Timestamps, type: :command
  end
end
