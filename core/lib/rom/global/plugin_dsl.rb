# frozen_string_literal: true

module ROM
  module Global
    # plugin registration DSL
    #
    # @private
    class PluginDSL
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
      def initialize(registry, defaults = EMPTY_HASH, &)
        @registry = registry
        @defaults = defaults
        instance_exec(&)
      end

      # Register a plugin
      #
      # @param [Symbol] name of the plugin
      # @param [Module] mod to include
      # @param [Hash] options
      #
      # @api public
      def register(name, mod, options = EMPTY_HASH)
        registry.register(name, mod, defaults.merge(options))
      end

      # Register plugins for a specific adapter
      #
      # @param [Symbol] type The adapter identifier
      #
      # @api public
      def adapter(type, &)
        self.class.new(registry, adapter: type, &)
      end
    end
  end
end
