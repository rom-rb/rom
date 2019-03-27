# frozen_string_literal: true

require 'rom/plugin_base'

module ROM
  # ConfigurationPlugin is a simple object used to store configuration plugin configurations
  #
  # @private
  class ConfigurationPlugin < PluginBase
    # Apply this plugin to the provided configuration
    #
    # @param [ROM::Configuration] configuration
    #
    # @api private
    def apply_to(configuration, options = {})
      mod.apply(configuration, options)
    end
  end
end
