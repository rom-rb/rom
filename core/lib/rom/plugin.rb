# frozen_string_literal: true

require 'rom/initializer'
require 'rom/constants'
require 'rom/support/configurable'

module ROM
  # Plugin is a simple object used to store plugin configurations
  #
  # @private
  class Plugin
    extend Initializer
    include Configurable

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

    # Apply this plugin to the target
    #
    # @param [Class,Object] target
    #
    # @api private
    def apply_to(target, options = EMPTY_HASH)
      if mod.respond_to?(:apply)
        mod.apply(target, options)
      elsif mod.respond_to?(:new)
        target.include(mod.new(options))
      elsif target.is_a?(::Module)
        target.include(mod)
      end
    end
  end
end
