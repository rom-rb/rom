# frozen_string_literal: true

require "dry/effects"

require "rom/plugin_registry"
require "rom/global/plugin_dsl"
require "rom/configuration"
require "rom/configuration_dsl/relation"

module ROM
  # Globally accessible public interface exposed via ROM module
  #
  # @api public
  module Global
    include Dry::Effects::Handler.Reader(:configuration)

    # Set base global registries in ROM constant
    #
    # @api private
    def self.extended(rom)
      super

      rom.instance_variable_set("@adapters", {})
      rom.instance_variable_set("@plugin_registry", PluginRegistry.new)
    end

    # An internal adapter identifier => adapter module map used by setup
    #
    # @return [Hash<Symbol=>Module>]
    #
    # @api private
    attr_reader :adapters

    # An internal identifier => plugin map used by the setup
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :plugin_registry

    # @api public
    def container(*args, &block)
      configuration =
        case args.first
        when Configuration
          args.first
        else
          Configuration.new(*args, &block)
        end

      with_configuration(configuration) do
        Container.new(configuration.finalize)
      end
    end

    # Global plugin setup DSL
    #
    # @example
    #   ROM.plugins do
    #     register :publisher, Plugin::Publisher, type: :command
    #   end
    #
    # @api public
    def plugins(*args, &block)
      PluginDSL.new(plugin_registry, *args, &block)
    end

    # Register adapter namespace under a specified identifier
    #
    # @param [Symbol] identifier
    # @param [Class,Module] adapter
    #
    # @return [self]
    #
    # @api private
    def register_adapter(identifier, adapter)
      adapters[identifier] = adapter
      self
    end
  end
end
