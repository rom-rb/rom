
module ROM
  class Setup
    class PluginDSL
      attr_reader :defaults

      # @api private
      def initialize(defaults = {}, &block)
        @defaults = defaults
        instance_exec(&block)
      end

      def register(name, mod, options = {})
        ROM.plugin_registry.register(name, mod, defaults.merge(options))
      end

      def adapter(type, &block)
        self.class.new(adapter: type, &block)
      end

    end
  end
end
