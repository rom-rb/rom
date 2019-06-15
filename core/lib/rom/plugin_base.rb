# frozen_string_literal: true

require 'rom/initializer'

module ROM
  # Abstract plugin base
  #
  # @private
  class PluginBase
    extend Initializer

    # @!attribute [r] name
    #   @return [Symbol] plugin name
    # @api private
    param :name

    # @!attribute [r] mod
    #   @return [Module] a module representing the plugin
    # @api private
    param :mod

    # @!attribute [r] type
    #   @return [Symbol] plugin type
    # @api private
    option :type

    # @api private
    def relation?
      type == :relation
    end

    # @api private
    def schema?
      type == :schema
    end

    # Apply this plugin to the provided class
    #
    # @param [Mixed] _base
    #
    # @api private
    def apply_to(_base)
      raise NotImplementedError, "#{self.class}#apply_to not implemented"
    end
  end
end
