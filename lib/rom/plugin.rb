# frozen_string_literal: true

require "rom/initializer"
require "rom/open_struct"

module ROM
  # Plugin is a simple object used to store plugin configurations
  #
  # @private
  class Plugin
    include Dry::Equalizer(:type, :name, :mod, :adapter, :config, :dsl)
    extend Initializer

    # @!attribute [r] type
    #   @return [Symbol] plugin type
    # @api private
    option :type

    # @!attribute [r] name
    #   @return [Symbol] plugin name
    # @api private
    option :name

    # @!attribute [r] mod
    #   @return [Module] a module representing the plugin
    # @api private
    option :mod

    # @!attribute [r] adapter
    #   @return [Symbol] plugin adapter
    # @api private
    option :adapter, optional: true

    # @!attribute [r] config
    #   @return [Symbol] Plugin optional config
    option :config, default: -> { ROM::OpenStruct.new }

    # @!attribute [r] dsl
    #   @return [Module,nil] Optional DSL extensions
    option :dsl, default: -> { mod.const_defined?(:DSL) ? mod.const_get(:DSL) : nil }

    # Plugin registry key
    #
    # @return [String]
    #
    # @api private
    def key
      [adapter, type, name].compact.join(".")
    end

    # Configure plugin
    #
    # @api public
    def configure
      plugin = dup
      yield(plugin.config) if block_given?
      plugin
    end

    # @api private
    def dup
      with(config: ROM::OpenStruct.new(config.to_h.clone))
    end

    # @api private
    def enable(target)
      target.extend(dsl) if dsl
      config.enabled = true
      config.target = target
      self
    end

    # @api private
    def enabled?
      config.key?(:enabled) && config.enabled == true
    end

    # @api private
    def apply
      if enabled?
        apply_to(config.target, **config.to_h)
      else
        raise "Cannot apply a plugin because it was not enabled for any target"
      end
    end

    # Apply this plugin to the target
    #
    # @param [Class,Object] target
    #
    # @api private
    def apply_to(target, **options)
      if mod.respond_to?(:apply)
        mod.apply(target, **config, **options)
      elsif mod.respond_to?(:new)
        target.include(mod.new(**options))
      elsif target.is_a?(::Module)
        target.include(mod)
      end
    end
  end
end
