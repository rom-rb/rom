
module ROM
  class Setup
    class PluginDSL

      # @api private
      def initialize(&block)
        instance_exec(&block)
      end

      def register(name, mod, options = {})
      end

    end
  end
end
