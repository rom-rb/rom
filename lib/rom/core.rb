# frozen_string_literal: true

require "dry/core"
require "dry/transformer"

# Global interface
require_relative "global"

# Global default settings
require_relative "settings"

# Core components
require_relative "components/gateway"
require_relative "components/dataset"
require_relative "components/schema"
require_relative "components/relation"
require_relative "components/view"
require_relative "components/association"
require_relative "components/command"
require_relative "components/mapper"

# Core plugins
require_relative "plugins"

# Set up ROM
#
# @api public
def ROM(*args, &block)
  if block
    ROM.setup(*args, &block)
  else
    ROM::Setup.new(*args)
  end
end

# Global ROM interface for core setup
#
# @api public
module ROM
  extend Global

  module_function

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

  # Global plugin setup
  #
  # @example
  #   ROM.plugins do
  #     register :publisher, Plugin::Publisher, type: :command
  #   end
  #
  # @api public
  def plugins(*args, &block)
    if defined?(@_plugins)
      @_plugins.dsl(*args, &block) if block
      @_plugins
    else
      require_relative "plugins"
      @_plugins = Plugins
      plugins(*args, &block)
    end
  end

  # Register core component handlers
  components do
    register :gateway, Components::Gateway
    register :dataset, Components::Dataset
    register :schema, Components::Schema
    register :relation, Components::Relation
    register :view, Components::View
    register :association, Components::Association
    register :command, Components::Command
    register :mapper, Components::Mapper
  end

  # TODO: this will be automated eventually
  require_relative "relation"
  require_relative "schema"
  require_relative "command"
  require_relative "mapper"
  require_relative "transformer"

  configs = {
    schema: [ROM::Schema],
    relation: [ROM::Relation],
    command: [ROM::Command],
    mapper: [ROM::Mapper, ROM::Transformer]
  }

  configs.each do |key, items|
    items.each do |constant|
      constant.config.component.inherit!(config.component)
      config[key].inherit!(constant.config.component)
    end
  end

  configs.values.flatten(1).each(&:configure).each(&:finalize!)

  # Register core plugins
  plugins do
    register :timestamps, ROM::Plugins::Schema::Timestamps, type: :schema
    register :registry_reader, ROM::Plugins::Relation::RegistryReader, type: :relation
    register :instrumentation, ROM::Plugins::Relation::Instrumentation, type: :relation
    register :changeset, ROM::Plugins::Relation::Changeset, type: :relation
    register :schema, ROM::Plugins::Command::Schema, type: :command
    register :timestamps, ROM::Plugins::Command::Timestamps, type: :command
  end

  finalize!
end
