module ROM
  class Setup
    # plugin registration DSL
    #
    # @private
    class PluginDSL
      attr_reader :defaults

      # @api private
      def initialize(defaults = {}, &block)
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
        ROM.plugin_registry.register(name, mod, defaults.merge(options))
      end

      # Register plugins for a specific adapter
      #
      # @param [Symbol] adapter type
      def adapter(type, &block)
        self.class.new(adapter: type, &block)
      end

    end
  end
end
