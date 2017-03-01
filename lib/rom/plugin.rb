require 'rom/plugin_base'
require 'rom/support/configurable'

module ROM
  # Plugin is a simple object used to store plugin configurations
  #
  # @private
  class Plugin < PluginBase
    include Configurable

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
