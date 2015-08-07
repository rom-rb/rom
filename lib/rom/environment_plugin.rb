require 'rom/plugin_base'

module ROM
  # EnvironmentPlugin is a simple object used to store environment plugin configurations
  #
  # @private
  class EnvironmentPlugin < PluginBase
    # Apply this plugin to the provided environment
    #
    # @param [ROM::Environment] environment
    #
    # @api private
    def apply_to(environment)
      mod.apply(environment)
    end
  end
end
