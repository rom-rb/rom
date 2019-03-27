# frozen_string_literal: true

require 'rom/constants'
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
    def apply_to(klass, options = EMPTY_HASH)
      if mod.respond_to?(:new)
        klass.send(:include, mod.new(options))
      else
        klass.send(:include, mod)
      end
    end
  end
end
