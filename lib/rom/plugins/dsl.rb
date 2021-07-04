# frozen_string_literal: true

require "rom/constants"

module ROM
  module Plugins
    # Plugin registration DSL
    #
    # @private
    class DSL
      # Default options passed to plugin registration
      #
      # @return [Hash]
      #
      # @api private
      attr_reader :defaults

      # Plugin registry
      #
      # @return [PluginRegistry]
      #
      # @api private
      attr_reader :registry

      # @api private
      def initialize(registry, defaults = EMPTY_HASH, &block)
        @registry = registry
        @defaults = defaults
        instance_exec(&block)
      end

      # Register a plugin
      #
      # @param [Symbol] name Name of a plugin
      # @param [Module] mod Plugin module
      # @param [Hash] options
      #
      # @api public
      def register(name, mod, options = EMPTY_HASH)
        registry.register(name, mod: mod, **defaults, **options)
      end

      # Register plugins for a specific adapter
      #
      # @param [Symbol] type The adapter identifier
      #
      # @api public
      def adapter(type, &block)
        self.class.new(registry, adapter: type, &block)
      end
    end
  end
end
