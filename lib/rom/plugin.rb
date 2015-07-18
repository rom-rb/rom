require 'rom/plugin_base'

module ROM
  # Plugin is a simple object used to store plugin configurations
  #
  # @private
  class Plugin < PluginBase
    # Apply this plugin to the provided class
    #
    # @param [Class] klass
    #
    # @api private
    def apply_to(klass)
      klass.send(:include, mod)
    end
  end
end
