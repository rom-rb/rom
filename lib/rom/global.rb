# frozen_string_literal: true

require "rom/components"

module ROM
  # Globally accessible public interface exposed via ROM module
  #
  # @api public
  module Global
    # Set base global registries in ROM constant
    #
    # @api private
    def self.extended(rom)
      super

      rom.instance_variable_set("@adapters", {})
    end

    # An internal adapter identifier => adapter module map used by setup
    #
    # @return [Hash<Symbol=>Module>]
    #
    # @api private
    attr_reader :adapters

    # An internal component handler registry
    #
    # @return [Plugins]
    #
    # @api private
    attr_reader :handlers

    # @api private
    # @deprecated
    def plugin_registry
      plugins
    end

    # @api public
    def runtime(*args, &block)
      case args.first
      when Runtime
        args.first
      else
        Runtime.new(*args, &block)
      end.finalize
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
