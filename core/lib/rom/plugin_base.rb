# frozen_string_literal: true

module ROM
  # Abstract plugin base
  #
  # @private
  class PluginBase
    # @return [Module] a module representing the plugin
    #
    # @api private
    attr_reader :mod

    # @return [Hash] configuration options
    #
    # @api private
    attr_reader :options

    # @api private
    attr_reader :type

    # @api private
    def initialize(mod, options)
      @mod      = mod
      @options  = options
      @type = options.fetch(:type)
    end

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
