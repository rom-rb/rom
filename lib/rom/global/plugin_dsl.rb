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
      def initialize(registry, defaults = {}, &block)
        @registry = registry
        @defaults = defaults
        instance_exec(&block)
      end

      # Register a plugin
      #
      # @param [Symbol] name of the plugin
      # @param [Module] mod to include
      # @param [Hash] options
      #
      # @api public
      def register(name, mod, options = {})
        registry.register(name, mod, defaults.merge(options))
      end

      # Register plugins for a specific adapter
      #
      # @param [Symbol] adapter type
      def adapter(type, &block)
        self.class.new(registry, adapter: type, &block)
      end
    end
  end
end
